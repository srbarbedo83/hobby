import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar_community/isar.dart';

import '../../core/calc/liquidity_amounts.dart';
import '../../core/calc/liquidity_profile.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../local/chain.dart';
import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';
import '../local/position_event.dart';
import '../local/price_point.dart';
import '../remote/coingecko_price_client.dart';
import '../remote/erc20_metadata_client.dart';
import '../remote/eth_rpc_client.dart';
import '../remote/uniswap_subgraph_client.dart';
import '../remote/uniswap_v4_pool_state_client.dart';
import '../remote/uniswap_v4_position_manager_client.dart';
import 'pool_fees_repository.dart';
import 'wallet_repository.dart';

const _zeroAddress = '0x0000000000000000000000000000000000000000';

/// Implementação "live": lê posições reais do subgraph Uniswap v3 e
/// calcula fees não reclamadas com a mesma fórmula do contrato
/// (`univ3_fee_math.dart`), sem precisar de uma chamada RPC.
///
/// Agrega várias chains ao mesmo tempo (uma ligação ao subgraph por
/// chain, a mesma API key): as mesmas wallets são consultadas em cada
/// chain selecionada e os resultados somados num só dashboard — um
/// endereço EVM é o mesmo em todas as chains, não há nada específico por
/// chain a configurar além de quais ligar.
///
/// Inclui posições já FECHADAS (liquidez removida): continuam a contar
/// para o total vitalício de fees do dashboard, só deixam de aparecer na
/// lista "Your Pools" — ver `PoolPosition.isClosed` e o ecrã de Pools.
///
/// Aproximações conhecidas, por não serem o foco do pedido original
/// (acompanhar fees) e por implicarem bastante mais superfície:
/// - `liquidityUsd`/`initialLiquidityUsd` usam os montantes depositados
///   menos os retirados, a preço ATUAL (não o valor exato da posição
///   agora, que precisaria da fórmula `getAmountsForLiquidity` com
///   sqrt-price, nem o preço histórico no momento de cada depósito/saque).
///   As fees — o número em destaque na app — não são afetadas por esta
///   aproximação.
/// - `gasCostUsd` fica a 0 no modelo persistido (o subgraph não guarda
///   custo de gás). Quando há um RPC URL configurado nas Definições, e
///   esse RPC responde pela MESMA chain da posição (confirmado via
///   `eth_chainId` — um endpoint só serve uma chain, mas o utilizador pode
///   ter várias selecionadas), [getGasCostUsd] lê os recibos das
///   transações da posição (mint/collects/burn, cujos hashes já vêm de
///   [getEvents]) e soma `gasUsed × effectiveGasPrice` a sério — ver
///   `EthRpcClient`. Sem RPC configurado, ou em Polygon (gás pago em
///   MATIC, sem fonte de preço de MATIC ligada), devolve `null` e o ecrã
///   de detalhe cai para o valor persistido (0).
/// - `closedAt` fica `null`: o subgraph não dá diretamente o timestamp em
///   que uma posição fechou (seria preciso o evento `Burn` mais recente
///   dessa posição). O ecrã de Pools mostra "Closed" sem data nesse caso.
/// - `entryTick` (para o impermanent loss) usa o centro do range como
///   proxy do tick de entrada — o subgraph não liga o tick exato do mint
///   ao tokenId do NFT.
/// - `getEvents` identifica os eventos (mint/collect/burn) desta posição
///   por `pool + owner + tickLower + tickUpper`, pela mesma razão — ver
///   `UniswapSubgraphClient.fetchPositionEvents`.
/// - `getPricePoints` só regista um ponto por refresh a partir do momento
///   em que a app liga — o subgraph não é interrogado pelo histórico de
///   tick antigo, por isso gráficos/streaks que dependem disto ficam
///   curtos logo após ativar modo Live (crescem com o uso).
/// - O histórico por posição (para o gráfico de barras) é alocado a partir
///   do histórico da POOL (`poolHourData`/`poolDayData`), repartido pela
///   quota de liquidez da posição — o subgraph não guarda uma série
///   temporal por posição. Para uma posição fechada isto já não é possível
///   (a quota atual seria 0), por isso o histórico fica congelado no que já
///   estava em cache a partir do momento em que fechou.
///
/// Nunca testado contra um endpoint real nesta sessão (sem API key
/// disponível) — valide com uma Subgraph API key antes de confiar nos
/// números em modo live.
class LivePoolFeesRepository implements PoolFeesRepository {
  final WalletRepository _walletRepository;
  final Isar _isar;
  final Map<Chain, UniswapSubgraphClient> _clients;
  final Map<Chain, String> _v4PositionManagerAddresses;
  final Map<Chain, String> _v4StateViewAddresses;
  final EthRpcClient? _rpcClient;
  final CoinGeckoPriceClient _priceClient;

  List<PoolPosition> _positions = [];
  final Map<String, String> _poolIdByPositionKey = {};
  final Map<String, Chain> _chainByPositionKey = {};
  final Map<Chain, double> _ethPriceUsdByChain = {};
  final StreamController<List<PoolPosition>> _controller =
      StreamController.broadcast();
  DateTime? _lastUpdatedAt;
  String? _lastError;
  Timer? _autoRefreshTimer;
  bool _refreshing = false;
  Future<Chain?>? _rpcChainFuture;

  // Cache de preços v4 (CoinGecko) — o tier gratuito tem rate limit por
  // minuto e recusa mais que 1 endereço por pedido (ver
  // `coingecko_price_client.dart`); sem isto, só o carregamento inicial +
  // um pull-to-refresh já chegam a disparar vários refreshes seguidos
  // (confirmado via logcat) e esgotam o limite em segundos. Preços de
  // tokens não mudam o suficiente num intervalo de minutos para a
  // precisão perder-se por usar um valor com alguns minutos.
  static const _priceCacheTtl = Duration(minutes: 5);
  final Map<String, double> _tokenPriceCache = {};
  final Map<String, DateTime> _tokenPriceCachedAt = {};
  double? _nativeEthPriceCache;
  DateTime? _nativeEthPriceCachedAt;

  LivePoolFeesRepository({
    required List<Chain> chains,
    required String apiKey,
    required WalletRepository walletRepository,
    required Isar isar,
    String rpcUrl = '',
    Map<Chain, String> subgraphIdOverrides = const {},
    Map<Chain, String> v4PositionManagerOverrides = const {},
    Map<Chain, UniswapSubgraphClient>? clients,
    EthRpcClient? rpcClient,
    CoinGeckoPriceClient? priceClient,
  }) : _walletRepository = walletRepository,
       _isar = isar,
       _clients =
           clients ??
           {
             for (final chain in chains)
               chain: UniswapSubgraphClient(
                 chain: chain,
                 apiKey: apiKey,
                 subgraphIdOverride: subgraphIdOverrides[chain],
               ),
           },
       _v4PositionManagerAddresses = {
         for (final chain in chains)
           if ((v4PositionManagerOverrides[chain] ??
                  chain.uniswapV4PositionManagerAddress) !=
              null)
             chain:
                 v4PositionManagerOverrides[chain] ??
                 chain.uniswapV4PositionManagerAddress!,
       },
       _v4StateViewAddresses = {
         for (final chain in chains)
           if (chain.uniswapV4StateViewAddress != null)
             chain: chain.uniswapV4StateViewAddress!,
       },
       _rpcClient =
           rpcClient ?? (rpcUrl.isEmpty ? null : EthRpcClient(rpcUrl: rpcUrl)),
       _priceClient = priceClient ?? CoinGeckoPriceClient() {
    _loadCachedThenRefresh();
  }

  Future<void> _loadCachedThenRefresh() async {
    _positions = await _isar.poolPositions.where().findAll();
    if (_positions.isNotEmpty) _controller.add(List.unmodifiable(_positions));
    await refreshNow();
  }

  @override
  Stream<List<PoolPosition>> watchPositions() async* {
    yield List.unmodifiable(_positions);
    yield* _controller.stream;
  }

  @override
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  @override
  String? get lastError => _lastError;

  @override
  Future<List<FeeSnapshot>> getFeeSnapshots(String positionKey) {
    return _isar.feeSnapshots
        .filter()
        .positionKeyEqualTo(positionKey)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<List<PricePoint>> getPricePoints(String positionKey) {
    return _isar.pricePoints
        .filter()
        .positionKeyEqualTo(positionKey)
        .sortByTimestamp()
        .findAll();
  }

  @override
  Future<List<TickLiquidity>> getLiquidityProfile(String positionKey) async {
    final poolId = _poolIdByPositionKey[positionKey];
    final chain = _chainByPositionKey[positionKey];
    final client = chain == null ? null : _clients[chain];
    if (poolId == null || client == null) return const [];

    PoolPosition? position;
    for (final p in _positions) {
      if (p.positionKey == positionKey) {
        position = p;
        break;
      }
    }
    if (position == null) return const [];

    final width = position.tickUpper - position.tickLower;
    if (width <= 0) return const [];

    final raw = await client.fetchLiquidityProfile(
      poolId: poolId,
      tickLowerBound: position.tickLower - width,
      tickUpperBound: position.tickUpper + width,
    );
    return raw
        .map(
          (t) => TickLiquidity(
            tick: t.tickIdx,
            liquidityGross: t.liquidityGross.toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<List<PositionEvent>> getEvents(String positionKey) async {
    final poolId = _poolIdByPositionKey[positionKey];
    final chain = _chainByPositionKey[positionKey];
    final client = chain == null ? null : _clients[chain];
    if (poolId == null || client == null) return [];

    PoolPosition? position;
    for (final p in _positions) {
      if (p.positionKey == positionKey) {
        position = p;
        break;
      }
    }
    if (position == null) return [];

    final raw = await client.fetchPositionEvents(
      poolId: poolId,
      owner: position.walletAddress,
      tickLower: position.tickLower,
      tickUpper: position.tickUpper,
    );
    return raw
        .map(
          (e) => PositionEvent()
            ..positionKey = positionKey
            ..timestamp = e.timestamp
            ..type = switch (e.kind) {
              RawEventKind.mint => PositionEventType.mint,
              RawEventKind.collect => PositionEventType.collect,
              RawEventKind.burn => PositionEventType.decreaseLiquidity,
            }
            ..amountUsd = e.amountUsd
            ..txHash = e.txHash,
        )
        .toList();
  }

  /// Custo real de gás de uma posição, em USD — `null` quando não há como
  /// calculá-lo (sem RPC configurado, RPC de outra chain, ou Polygon). Ver
  /// a nota sobre `gasCostUsd` no topo do ficheiro.
  @override
  Future<double?> getGasCostUsd(String positionKey) async {
    final rpcClient = _rpcClient;
    final positionChain = _chainByPositionKey[positionKey];
    if (rpcClient == null || positionChain == null) return null;
    // O gás é pago em MATIC em Polygon, não em ETH — não temos uma fonte
    // de preço de MATIC ligada, por isso não arriscamos um número errado.
    if (positionChain == Chain.polygon) return null;

    final rpcChain = await (_rpcChainFuture ??= rpcClient.detectChain());
    if (rpcChain != positionChain) return null;

    final events = await getEvents(positionKey);
    final txHashes = events
        .map((e) => e.txHash)
        .whereType<String>()
        .toSet()
        .toList();
    if (txHashes.isEmpty) return 0;

    final gasWei = await rpcClient.fetchGasCostWei(txHashes);
    final ethPriceUsd = _ethPriceUsdByChain[positionChain] ?? 0;
    return tokenAmountToDouble(gasWei, 18) * ethPriceUsd;
  }

  @override
  Future<void> refreshNow() async {
    if (_refreshing) {
      debugPrint('[v4debug] refreshNow: já estava a correr, saltou este pedido');
      return;
    }
    _refreshing = true;
    debugPrint('[v4debug] refreshNow: a começar');
    try {
      final wallets = await _walletRepository.getAll();
      debugPrint('[v4debug] wallets encontradas: ${wallets.length}');
      if (wallets.isEmpty) {
        _lastUpdatedAt = DateTime.now();
        _controller.add(List.unmodifiable(_positions));
        return;
      }
      final owners = wallets.map((w) => w.address).toList();

      final now = DateTime.now();
      final mapped = <PoolPosition>[];
      final pricePoints = <PricePoint>[];
      String? v3Diagnostic;
      String? v4Diagnostic;

      for (final entry in _clients.entries) {
        final chain = entry.key;
        final client = entry.value;
        // Uma chain v3 com o subgraph a falhar (schema errado, deployment
        // sem indexadores, etc.) não pode travar o refresh inteiro — isso
        // impedia até as OUTRAS chains e o v4 de correrem, já que este
        // loop vem antes do bloco v4 mais abaixo.
        ({List<RawPosition> positions, double ethPriceUsd})? result;
        try {
          result = await client.fetchPositions(owners);
          debugPrint(
            '[v4debug] v3 chain ${chain.name}: ${result.positions.length} posições',
          );
        } catch (e) {
          debugPrint('[v4debug] v3 chain ${chain.name} FALHOU: $e');
          v3Diagnostic = 'Subgraph v3 (${chain.displayName}): $e';
          continue;
        }
        _ethPriceUsdByChain[chain] = result.ethPriceUsd;

        for (final raw in result.positions) {
          final position = _mapPosition(chain, raw, result.ethPriceUsd);
          mapped.add(position);
          _poolIdByPositionKey[position.positionKey] = raw.pool.id;
          _chainByPositionKey[position.positionKey] = chain;
          // Uma posição fechada já não tem quota da pool (liquidity == 0)
          // — não há como alocar-lhe fees novas, por isso o seu histórico
          // fica congelado no que já estava guardado em Isar.
          if (!position.isClosed) {
            await _refreshHistoryForPosition(
              client: client,
              raw: raw,
              position: position,
              now: now,
            );
            // Um ponto de preço por refresh — só prospetivo (ver nota no
            // topo do ficheiro): o subgraph não dá o histórico de tick
            // antigo, por isso o histórico só começa a partir de agora.
            pricePoints.add(
              PricePoint()
                ..positionKey = position.positionKey
                ..timestamp = now
                ..tick = position.currentTick,
            );
          }
        }
      }

      // Posições v4: tudo lido on-chain (ver nota no topo do ficheiro) —
      // o subgraph v4 mostrou-se globalmente não fiável nesta sessão
      // ("bad indexers" ou timeout, em TODAS as posições testadas da
      // wallet real do utilizador, não um caso raro), por isso deixou de
      // ser usado para fosse o que fosse em v4: tokenIds, range/liquidez,
      // tick atual da pool e preço dos tokens vêm todos do RPC +
      // CoinGecko. Cada passo que não encontra nada guarda uma mensagem
      // explicando porquê, em vez de ficar silencioso.
      final rpcClient = _rpcClient;
      debugPrint(
        '[v4debug] _v4PositionManagerAddresses: ${_v4PositionManagerAddresses.keys}, '
        'rpcClient configurado: ${rpcClient != null}',
      );
      if (_v4PositionManagerAddresses.isEmpty) {
        // Nenhuma chain selecionada tem suporte v4 configurado — nem vale
        // a pena mencionar, não é um estado de erro.
      } else if (rpcClient == null) {
        v4Diagnostic =
            'Modo Live v4: sem RPC URL configurado nas Definições — é '
            'sempre necessário para ler posições v4 (ao contrário do v3).';
      } else {
        Chain? rpcChain;
        try {
          rpcChain = await (_rpcChainFuture ??= rpcClient.detectChain());
          debugPrint('[v4debug] detectChain() devolveu: $rpcChain');
        } catch (e, st) {
          debugPrint('[v4debug] detectChain() FALHOU: $e\n$st');
          rethrow;
        }
        if (rpcChain == null) {
          v4Diagnostic =
              'Modo Live v4: o RPC URL configurado não respondeu com uma '
              'chain reconhecida (confirma que é mesmo Ethereum Mainnet).';
        } else {
          final chain = rpcChain;
          final positionManagerAddress = _v4PositionManagerAddresses[chain];
          final stateViewAddress = _v4StateViewAddresses[chain];
          debugPrint(
            '[v4debug] positionManagerAddress: $positionManagerAddress, '
            'stateViewAddress: $stateViewAddress',
          );
          if (positionManagerAddress == null || stateViewAddress == null) {
            v4Diagnostic =
                'Modo Live v4: o RPC configurado responde pela chain '
                '${chain.displayName}, que não tem suporte v4 configurado.';
          } else {
            final posManager = UniswapV4PositionManagerClient(
              rpcClient: rpcClient,
              positionManagerAddress: positionManagerAddress,
            );
            final poolStateClient = UniswapV4PoolStateClient(
              rpcClient: rpcClient,
              stateViewAddress: stateViewAddress,
            );
            // Descoberta via `alchemy_getAssetTransfers`, não via subgraph
            // nem `eth_getLogs` (o plano gratuito da Alchemy limita-o a 10
            // blocos por pedido) — ver nota em
            // `uniswap_v4_position_manager_client.dart`.
            List<({BigInt tokenId, String owner, DateTime createdAt})>
            tokenPositions;
            try {
              final perOwner = await Future.wait(
                owners.map((owner) async {
                  final tokens = await posManager.fetchOwnedTokenIds(owner);
                  return tokens
                      .map(
                        (t) => (
                          tokenId: t.tokenId,
                          owner: owner,
                          createdAt: t.createdAt,
                        ),
                      )
                      .toList();
                }),
              );
              tokenPositions = perOwner.expand((l) => l).toList();
              debugPrint(
                '[v4debug] fetchOwnedTokenIds (RPC) devolveu ${tokenPositions.length} '
                'posições: ${tokenPositions.map((p) => p.tokenId).toList()}',
              );
            } catch (e, st) {
              debugPrint('[v4debug] fetchOwnedTokenIds FALHOU: $e\n$st');
              rethrow;
            }
            if (tokenPositions.isEmpty) {
              v4Diagnostic =
                  'Modo Live v4: não foi encontrada nenhuma posição v4 '
                  '(chain ${chain.displayName}) para esta wallet.';
            } else {
              final result = await _mapV4Positions(
                chain: chain,
                tokenPositions: tokenPositions,
                posManager: posManager,
                poolStateClient: poolStateClient,
              );
              mapped.addAll(result.positions);
              debugPrint(
                '[v4debug] _mapV4Positions: ${result.positions.length}/${tokenPositions.length} '
                'mapeadas, lastError=${result.lastError}',
              );
              if (result.positions.isEmpty) {
                v4Diagnostic =
                    'Modo Live v4: encontradas ${tokenPositions.length} '
                    'posições na wallet, mas nenhuma pôde ser lida '
                    '(${result.lastError ?? "erro desconhecido"}).';
              }
            }
          }
        }
      }

      debugPrint(
        '[v4debug] refreshNow: a terminar com sucesso. mapped=${mapped.length} '
        '(v3+v4), v4Diagnostic=$v4Diagnostic',
      );
      await _isar.writeTxn(() async {
        await _isar.poolPositions.putAll(mapped);
        await _isar.pricePoints.putAll(pricePoints);
      });

      _positions = mapped;
      _lastUpdatedAt = now;
      // v4 é o que importa mostrar primeiro (é o que falta validar); o v3
      // só aparece se o v4 estiver tudo bem, para não tapar o aviso mais
      // relevante com um erro de uma chain que pode nem ter posições.
      _lastError = v4Diagnostic ?? v3Diagnostic;
      _controller.add(List.unmodifiable(_positions));
    } catch (e, st) {
      // Nunca deixa um erro do subgraph/RPC (rede, API key inválida,
      // schema inesperado) rebentar como excepção não apanhada — isso
      // deixava o ecrã silenciosamente sem dados, sem nenhuma pista
      // visível na app (só via logcat). Guarda a mensagem para a UI
      // mostrar um aviso em vez disto.
      debugPrint('[v4debug] refreshNow: EXCEÇÃO APANHADA: $e\n$st');
      _lastError = e.toString();
    } finally {
      debugPrint('[v4debug] refreshNow: a terminar (finally), _lastError=$_lastError');
      _refreshing = false;
    }
  }

  @override
  void startAutoRefresh(Duration interval) {
    _autoRefreshTimer ??= Timer.periodic(interval, (_) => refreshNow());
  }

  @override
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _controller.close();
    for (final client in _clients.values) {
      client.dispose();
    }
    _rpcClient?.dispose();
    _priceClient.dispose();
  }

  PoolPosition _mapPosition(Chain chain, RawPosition raw, double ethPriceUsd) {
    final price0 = raw.pool.token0.priceUsd(ethPriceUsd);
    final price1 = raw.pool.token1.priceUsd(ethPriceUsd);

    final unclaimed = computeUnclaimedTokens(
      feeGrowthGlobal0X128: raw.pool.feeGrowthGlobal0X128,
      feeGrowthGlobal1X128: raw.pool.feeGrowthGlobal1X128,
      feeGrowthOutsideLower0X128: raw.tickLower.feeGrowthOutside0X128,
      feeGrowthOutsideLower1X128: raw.tickLower.feeGrowthOutside1X128,
      feeGrowthOutsideUpper0X128: raw.tickUpper.feeGrowthOutside0X128,
      feeGrowthOutsideUpper1X128: raw.tickUpper.feeGrowthOutside1X128,
      feeGrowthInsideLast0X128: raw.feeGrowthInside0LastX128,
      feeGrowthInsideLast1X128: raw.feeGrowthInside1LastX128,
      liquidity: raw.liquidity,
      currentTick: raw.pool.tick,
      tickLower: raw.tickLower.tickIdx,
      tickUpper: raw.tickUpper.tickIdx,
    );
    final unclaimedUsd =
        tokenAmountToDouble(unclaimed.owed0, raw.pool.token0.decimals) *
            price0 +
        tokenAmountToDouble(unclaimed.owed1, raw.pool.token1.decimals) * price1;

    final initialUsd =
        raw.depositedToken0 * price0 + raw.depositedToken1 * price1;
    // Líquido = depositado - retirado. Nunca negativo: arredondamentos do
    // subgraph podem passar ligeiramente de 0 numa posição já fechada.
    final netToken0 = raw.depositedToken0 - raw.withdrawnToken0;
    final netToken1 = raw.depositedToken1 - raw.withdrawnToken1;
    final currentUsd = (netToken0 * price0 + netToken1 * price1).clamp(
      0.0,
      double.infinity,
    );
    final claimedUsd =
        raw.collectedFeesToken0 * price0 + raw.collectedFeesToken1 * price1;

    return PoolPosition()
      ..positionKey = '${chain.name}:${raw.id}'
      ..chain = chain
      ..walletAddress = raw.owner
      ..tokenIdOnChain = raw.id
      ..token0Symbol = raw.pool.token0.symbol
      ..token1Symbol = raw.pool.token1.symbol
      ..token0Decimals = raw.pool.token0.decimals
      ..token1Decimals = raw.pool.token1.decimals
      ..feeTierBps = raw.pool.feeTierBps
      ..createdAt = raw.createdAt
      ..tickLower = raw.tickLower.tickIdx
      ..tickUpper = raw.tickUpper.tickIdx
      ..currentTick = raw.pool.tick
      // Aproximação: o subgraph não liga o tick exato do mint ao tokenId
      // do NFT — usa-se o centro do range como proxy do preço de entrada,
      // para o impermanent loss. Ver nota no topo do ficheiro.
      ..entryTick = (raw.tickLower.tickIdx + raw.tickUpper.tickIdx) ~/ 2
      ..liquidityUsd = raw.isClosed ? 0 : currentUsd
      ..initialLiquidityUsd = initialUsd
      ..feesClaimedUsd = claimedUsd
      ..feesUnclaimedUsd = unclaimedUsd
      ..gasCostUsd = 0
      ..isClosed = raw.isClosed
      ..closedAt = null;
  }

  /// Equivalente a [_mapPosition], mas para Uniswap v4 — mapeia TODAS as
  /// posições de uma vez, em duas fases, para não bater no rate limit do
  /// tier gratuito da CoinGecko (ver nota no topo do ficheiro: o subgraph
  /// v4 mostrou-se globalmente não fiável, por isso tudo — range,
  /// liquidez, tick atual, símbolo/decimais e preço dos tokens — passou a
  /// vir on-chain + CoinGecko):
  /// 1. Lê cada posição on-chain em paralelo (RPC, sem rate limit prático);
  ///    uma posição que falhe aqui não bloqueia as outras.
  /// 2. Com os endereços de token distintos de TODAS as posições que
  ///    sobreviveram à fase 1, faz UM pedido à CoinGecko para os preços
  ///    (e um só, condicional, para o preço do ETH nativo) — em vez de um
  ///    pedido por posição.
  ///
  /// Limitações desta primeira versão (Fase 1 — ver pedido do utilizador):
  /// - `feesClaimedUsd`/`feesUnclaimedUsd` ficam a 0: calcular isto exige
  ///   ler `feeGrowthInside` on-chain e repetir a mesma fórmula do v3
  ///   (`univ3_fee_math.dart`) para o layout de storage do `PoolManager`
  ///   v4 — ainda não implementado.
  /// - `initialLiquidityUsd` fica igual ao valor atual (P&L "desde a
  ///   abertura" mostra 0 em vez de um número errado): não há como saber
  ///   on-chain o capital originalmente depositado sem reconstruir todo o
  ///   histórico de eventos `ModifyLiquidity` do tokenId.
  /// - `gasCostUsd` fica a 0 pela mesma razão (sem eventos ligados ao
  ///   tokenId para somar os recibos).
  Future<({List<PoolPosition> positions, Object? lastError})> _mapV4Positions({
    required Chain chain,
    required List<({BigInt tokenId, String owner, DateTime createdAt})>
    tokenPositions,
    required UniswapV4PositionManagerClient posManager,
    required UniswapV4PoolStateClient poolStateClient,
  }) async {
    final rawResults = await Future.wait(
      tokenPositions.map((raw) async {
        try {
          final info = await posManager.getPoolAndPositionInfo(raw.tokenId);
          final liquidity = await posManager.getPositionLiquidity(
            raw.tokenId,
          );
          final tick = await poolStateClient.getCurrentTick(info.poolKey);
          return (
            raw: raw,
            info: info,
            liquidity: liquidity,
            tick: tick,
            error: null as Object?,
          );
        } catch (e, st) {
          debugPrint(
            '[v4debug] tokenId ${raw.tokenId} FALHOU (fase on-chain): $e\n$st',
          );
          return (
            raw: raw,
            info: null,
            liquidity: null,
            tick: null,
            error: e,
          );
        }
      }),
    );

    Object? lastError;
    final ok = <({
      ({BigInt tokenId, String owner, DateTime createdAt}) raw,
      V4PositionInfo info,
      BigInt liquidity,
      int tick,
    })>[];
    for (final r in rawResults) {
      if (r.error != null) {
        lastError = r.error;
      } else {
        ok.add((
          raw: r.raw,
          info: r.info!,
          liquidity: r.liquidity!,
          tick: r.tick!,
        ));
      }
    }
    if (ok.isEmpty) return (positions: <PoolPosition>[], lastError: lastError);

    final addresses = <String>{};
    var needsNativeEth = false;
    for (final r in ok) {
      for (final currency in [r.info.poolKey.currency0, r.info.poolKey.currency1]) {
        if (currency.toLowerCase() == _zeroAddress) {
          needsNativeEth = true;
        } else {
          addresses.add(currency.toLowerCase());
        }
      }
    }

    final metadataClient = Erc20MetadataClient(rpcClient: posManager.rpcClient);
    final metadataEntries = await Future.wait(
      addresses.map((address) async {
        try {
          return (address: address, metadata: await metadataClient.fetch(address));
        } catch (e) {
          debugPrint('[v4debug] metadata do token $address FALHOU: $e');
          return (address: address, metadata: null as Erc20Metadata?);
        }
      }),
    );
    final metadataByAddress = {
      for (final entry in metadataEntries)
        if (entry.metadata != null) entry.address: entry.metadata!,
    };

    final now = DateTime.now();
    final platformId = chain.coingeckoPlatformId;
    final staleAddresses = addresses.where((a) {
      final cachedAt = _tokenPriceCachedAt[a];
      return cachedAt == null || now.difference(cachedAt) > _priceCacheTtl;
    }).toList();
    if (platformId != null && staleAddresses.isNotEmpty) {
      try {
        final fetched = await _priceClient.fetchTokenPricesUsd(
          platformId: platformId,
          contractAddresses: staleAddresses,
        );
        for (final entry in fetched.entries) {
          _tokenPriceCache[entry.key] = entry.value;
          _tokenPriceCachedAt[entry.key] = now;
        }
      } catch (e) {
        debugPrint('[v4debug] preços CoinGecko FALHARAM: $e');
        lastError = e;
      }
    }
    final pricesUsd = {
      for (final a in addresses)
        if (_tokenPriceCache.containsKey(a)) a: _tokenPriceCache[a]!,
    };

    double? nativeEthPriceUsd = _nativeEthPriceCache;
    final nativeEthCachedAt = _nativeEthPriceCachedAt;
    final nativeEthIsStale =
        nativeEthCachedAt == null ||
        now.difference(nativeEthCachedAt) > _priceCacheTtl;
    if (needsNativeEth && nativeEthIsStale) {
      try {
        final fetched = await _priceClient.fetchNativeEthPriceUsd();
        if (fetched != null) {
          _nativeEthPriceCache = fetched;
          _nativeEthPriceCachedAt = now;
          nativeEthPriceUsd = fetched;
        }
      } catch (e) {
        debugPrint('[v4debug] preço nativo ETH (CoinGecko) FALHOU: $e');
        lastError = e;
      }
    }

    final mapped = <PoolPosition>[];
    for (final r in ok) {
      final token0 = _resolveV4Token(
        chain,
        r.info.poolKey.currency0,
        metadataByAddress,
        nativeEthPriceUsd,
        pricesUsd,
      );
      final token1 = _resolveV4Token(
        chain,
        r.info.poolKey.currency1,
        metadataByAddress,
        nativeEthPriceUsd,
        pricesUsd,
      );
      if (token0 == null || token1 == null) {
        lastError = 'metadata do token não encontrada';
        continue;
      }

      final amounts = getAmountsForLiquidity(
        liquidity: r.liquidity.toDouble(),
        tick: r.tick,
        tickLower: r.info.tickLower,
        tickUpper: r.info.tickUpper,
      );
      final amount0 = amounts.amount0 / _pow10(token0.decimals);
      final amount1 = amounts.amount1 / _pow10(token1.decimals);
      final currentUsd = amount0 * token0.priceUsd + amount1 * token1.priceUsd;
      final isClosed = r.liquidity == BigInt.zero;

      mapped.add(
        PoolPosition()
          ..positionKey = '${chain.name}:v4:${r.raw.tokenId}'
          ..chain = chain
          ..walletAddress = r.raw.owner
          ..tokenIdOnChain = r.raw.tokenId.toString()
          ..token0Symbol = token0.symbol
          ..token1Symbol = token1.symbol
          ..token0Decimals = token0.decimals
          ..token1Decimals = token1.decimals
          ..feeTierBps = r.info.poolKey.fee
          ..createdAt = r.raw.createdAt
          ..tickLower = r.info.tickLower
          ..tickUpper = r.info.tickUpper
          ..currentTick = r.tick
          ..entryTick = (r.info.tickLower + r.info.tickUpper) ~/ 2
          ..liquidityUsd = isClosed ? 0 : currentUsd
          ..initialLiquidityUsd = currentUsd
          ..feesClaimedUsd = 0
          ..feesUnclaimedUsd = 0
          ..gasCostUsd = 0
          ..isClosed = isClosed
          ..closedAt = null
          ..isV4 = true,
      );
    }

    return (positions: mapped, lastError: lastError);
  }

  /// ETH nativo numa pool v4 é o endereço zero, não um token ERC-20 — não
  /// tem `symbol()`/`decimals()` para chamar. `null` só quando um token
  /// NÃO nativo não tem metadata conhecida (falhou a leitura on-chain);
  /// um preço em falta não impede mostrar a posição, só fica a 0.
  ({String symbol, int decimals, double priceUsd})? _resolveV4Token(
    Chain chain,
    String address,
    Map<String, Erc20Metadata> metadataByAddress,
    double? nativeEthPriceUsd,
    Map<String, double> pricesUsd,
  ) {
    if (address.toLowerCase() == _zeroAddress) {
      return (
        symbol: chain.nativeSymbol,
        decimals: 18,
        priceUsd: nativeEthPriceUsd ?? 0,
      );
    }
    final metadata = metadataByAddress[address.toLowerCase()];
    if (metadata == null) return null;
    return (
      symbol: metadata.symbol,
      decimals: metadata.decimals,
      priceUsd: pricesUsd[address.toLowerCase()] ?? 0,
    );
  }

  static double _pow10(int decimals) {
    var result = 1.0;
    for (var i = 0; i < decimals; i++) {
      result *= 10;
    }
    return result;
  }

  Future<void> _refreshHistoryForPosition({
    required UniswapSubgraphClient client,
    required RawPosition raw,
    required PoolPosition position,
    required DateTime now,
  }) async {
    final shareOfPool = raw.pool.liquidity > BigInt.zero
        ? raw.liquidity.toDouble() / raw.pool.liquidity.toDouble()
        : 0.0;

    final weekAgo = now.subtract(const Duration(days: 7));
    final hourBuckets = await client.fetchPoolHourData(raw.pool.id, weekAgo);
    final dayBuckets = (await client.fetchPoolDayData(
      raw.pool.id,
      now.subtract(const Duration(days: 365)),
    )).where((b) => b.periodStart.isBefore(weekAgo));

    final snapshots = [
      for (final bucket in hourBuckets)
        FeeSnapshot()
          ..positionKey = position.positionKey
          ..timestamp = bucket.periodStart
          ..feesUsdDelta = bucket.feesUsd * shareOfPool,
      for (final bucket in dayBuckets)
        FeeSnapshot()
          ..positionKey = position.positionKey
          ..timestamp = bucket.periodStart
          ..feesUsdDelta = bucket.feesUsd * shareOfPool,
    ];

    await _isar.writeTxn(() async {
      final old = await _isar.feeSnapshots
          .filter()
          .positionKeyEqualTo(position.positionKey)
          .findAll();
      await _isar.feeSnapshots.deleteAll(old.map((s) => s.id).toList());
      await _isar.feeSnapshots.putAll(snapshots);
    });
  }
}
