import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar_community/isar.dart';

import '../../core/calc/liquidity_amounts.dart';
import '../../core/calc/liquidity_profile.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../../core/concurrency.dart';
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
  // Um RPC só responde por UMA chain (confirmada via `eth_chainId`) — uma
  // wallet com posições v4 em mais do que uma chain precisa de um
  // endpoint por cada. `_legacyRpcClient` é o campo "RPC URL" original
  // (de antes de existir mais que uma chain v4 suportada): a chain que ele
  // detetar automaticamente usa-o como padrão, SE não houver aqui um
  // override explícito para essa chain — ver `_resolveRpcClientsByChain`.
  final Map<Chain, EthRpcClient> _v4RpcClients;
  final EthRpcClient? _legacyRpcClient;
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
    Map<Chain, String> v4RpcUrlOverrides = const {},
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
       _v4RpcClients = {
         for (final entry in v4RpcUrlOverrides.entries)
           if (entry.value.isNotEmpty)
             entry.key: EthRpcClient(rpcUrl: entry.value),
       },
       _legacyRpcClient =
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

  /// Combina os RPCs explícitos por chain (`v4RpcUrlOverrides`) com o
  /// campo "RPC URL" legado, que serve de padrão para a chain que
  /// detetar automaticamente — ver nota nos campos da classe. Memoizado
  /// através de `_rpcChainFuture` (a deteção só corre uma vez) — MAS só
  /// enquanto tiver sucesso: uma falha de rede momentânea (confirmado ao
  /// vivo: "Failed host lookup" durante uma quebra breve de rede no
  /// telemóvel) não pode ficar guardada em cache para sempre, senão todos
  /// os refreshes seguintes repetem o mesmo erro indefinidamente mesmo
  /// depois da rede recuperar — e, pior, sem isto isolado aqui, essa
  /// falha abortava o refresh inteiro antes de sequer tentar as chains
  /// com RPC próprio (ex.: Arbitrum), que não deviam ser afetadas por um
  /// problema só no RPC "antigo" do Ethereum.
  Future<Map<Chain, EthRpcClient>> _resolveRpcClientsByChain() async {
    final result = <Chain, EthRpcClient>{..._v4RpcClients};
    final legacy = _legacyRpcClient;
    if (legacy != null) {
      try {
        final legacyChain = await (_rpcChainFuture ??= legacy.detectChain());
        if (legacyChain != null && !result.containsKey(legacyChain)) {
          result[legacyChain] = legacy;
        }
      } catch (e) {
        debugPrint('[v4debug] detectChain() do RPC legado FALHOU: $e');
        _rpcChainFuture = null;
      }
    }
    return result;
  }

  /// Custo real de gás de uma posição, em USD — `null` quando não há como
  /// calculá-lo (sem RPC configurado para a chain da posição, ou Polygon).
  /// Ver a nota sobre `gasCostUsd` no topo do ficheiro.
  @override
  Future<double?> getGasCostUsd(String positionKey) async {
    final positionChain = _chainByPositionKey[positionKey];
    if (positionChain == null) return null;
    // O gás é pago em MATIC em Polygon, não em ETH — não temos uma fonte
    // de preço de MATIC ligada, por isso não arriscamos um número errado.
    if (positionChain == Chain.polygon) return null;

    final rpcClient = (await _resolveRpcClientsByChain())[positionChain];
    if (rpcClient == null) return null;

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
      // Posições v4 não têm subgraph para dar histórico (ver nota mais
      // abaixo) — o "antes" deste refresh é a única base possível para
      // começar a construir um histórico de fees prospetivo, um ponto por
      // refresh, tal como já se faz com `pricePoints` para o tick.
      final previousByKey = {
        for (final p in _positions) p.positionKey: p,
      };
      final oldFeesTotalUsdByKey = {
        for (final entry in previousByKey.entries) entry.key: entry.value.feesTotalUsd,
      };
      final mapped = <PoolPosition>[];
      final pricePoints = <PricePoint>[];
      final v4FeeSnapshots = <FeeSnapshot>[];
      // Pedido do utilizador ("às vezes tem as pools, às vezes não, é
      // aleatório"): uma chain que falhou POR COMPLETO este ciclo (rede,
      // rate limit, RPC em baixo) não deve apagar as posições dessa chain
      // que já se sabiam de ciclos anteriores — ficam "congeladas" na
      // última versão boa em vez de desaparecerem até ao próximo sucesso.
      final failedChains = <Chain>{};
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
          failedChains.add(chain);
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
      final rpcClientsByChain = await _resolveRpcClientsByChain();
      debugPrint(
        '[v4debug] _v4PositionManagerAddresses: ${_v4PositionManagerAddresses.keys}, '
        'rpcClientsByChain: ${rpcClientsByChain.keys}',
      );
      if (_v4PositionManagerAddresses.isEmpty) {
        // Nenhuma chain selecionada tem suporte v4 configurado — nem vale
        // a pena mencionar, não é um estado de erro.
      } else if (rpcClientsByChain.isEmpty) {
        v4Diagnostic =
            'Modo Live v4: sem nenhum RPC URL configurado nas Definições — '
            'é sempre necessário para ler posições v4 (ao contrário do v3).';
      } else {
        // Uma chain com RPC configurado E suporte v4 conhecido — cada uma
        // é tentada independentemente (um RPC a falhar não bloqueia as
        // outras chains, tal como o v3 acima).
        final v4Chains = _v4PositionManagerAddresses.keys
            .where((c) => rpcClientsByChain.containsKey(c))
            .toList();
        if (v4Chains.isEmpty) {
          v4Diagnostic =
              'Modo Live v4: nenhuma chain com RPC configurado tem suporte '
              'v4 (ver Definições → RPC URL por chain).';
        } else {
          // Uma chain de cada vez seria o dobro do tempo sem motivo: cada
          // chain usa o seu próprio RPC/conta (Ethereum e Arbitrum nunca
          // partilham quota), por isso correm em paralelo.
          final perChainResults = await Future.wait(
            v4Chains.map(
              (chain) => _refreshV4Chain(
                chain: chain,
                rpcClient: rpcClientsByChain[chain]!,
                owners: owners,
                previousByKey: previousByKey,
              ),
            ),
          );

          var totalTokenPositions = 0;
          var totalMapped = 0;
          Object? lastV4Error;
          for (var i = 0; i < perChainResults.length; i++) {
            final chain = v4Chains[i];
            final r = perChainResults[i];
            totalTokenPositions += r.tokenPositionCount;
            totalMapped += r.positions.length;
            mapped.addAll(r.positions);
            if (r.error != null) lastV4Error = r.error;
            // Chain que não contribuiu NENHUMA posição fresca este ciclo,
            // apesar de haver trabalho para fazer (erro, ou tokenIds
            // descobertos mas nenhum lido com sucesso) — ver nota em
            // `failedChains` acima.
            if (r.positions.isEmpty && (r.error != null || r.tokenPositionCount > 0)) {
              failedChains.add(chain);
            }
            // Um ponto de fees por refresh, só prospetivo (mesma ideia do
            // `pricePoints` acima): sem subgraph v4, o delta entre este
            // refresh e o anterior é a única fonte de histórico possível.
            // Na primeira vez que se vê o tokenId não há "anterior" — fica
            // delta 0 em vez de atribuir tudo o que já se acumulou (talvez
            // há meses) a este instante.
            for (final position in r.positions) {
              if (position.isClosed) continue;
              final previousTotal = oldFeesTotalUsdByKey[position.positionKey];
              v4FeeSnapshots.add(
                FeeSnapshot()
                  ..positionKey = position.positionKey
                  ..timestamp = now
                  ..feesUsdDelta = previousTotal == null
                      ? 0
                      : position.feesTotalUsd - previousTotal,
              );
            }
          }
          if (totalTokenPositions == 0) {
            v4Diagnostic =
                'Modo Live v4: não foi encontrada nenhuma posição v4 para '
                'esta wallet (chains verificadas: '
                '${v4Chains.map((c) => c.displayName).join(", ")}).';
          } else if (totalMapped == 0) {
            v4Diagnostic =
                'Modo Live v4: encontradas $totalTokenPositions posições na '
                'wallet, mas nenhuma pôde ser lida '
                '(${lastV4Error ?? "erro desconhecido"}).';
          }
        }
      }

      // Última rede de segurança: qualquer posição antiga cuja chain
      // falhou por completo este ciclo e que não tenha sido já recuperada
      // (fallback por posição, dentro de `_mapV4Positions`) continua
      // "congelada" na última versão boa, em vez de desaparecer da lista.
      if (failedChains.isNotEmpty) {
        final mappedKeys = mapped.map((p) => p.positionKey).toSet();
        for (final old in previousByKey.values) {
          if (mappedKeys.contains(old.positionKey)) continue;
          if (failedChains.contains(old.chain)) mapped.add(old);
        }
      }

      debugPrint(
        '[v4debug] refreshNow: a terminar com sucesso. mapped=${mapped.length} '
        '(v3+v4), v4Diagnostic=$v4Diagnostic',
      );
      await _isar.writeTxn(() async {
        await _isar.poolPositions.putAll(mapped);
        await _isar.pricePoints.putAll(pricePoints);
        await _isar.feeSnapshots.putAll(v4FeeSnapshots);
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

  /// Descobre e mapeia as posições v4 de UMA chain — extraído para correr
  /// em paralelo com as outras chains selecionadas (`Future.wait` em
  /// `refreshNow`), já que cada uma usa o seu próprio RPC/conta e nunca
  /// partilha rate limit com as outras.
  Future<({int tokenPositionCount, List<PoolPosition> positions, Object? error})>
  _refreshV4Chain({
    required Chain chain,
    required EthRpcClient rpcClient,
    required List<String> owners,
    required Map<String, PoolPosition> previousByKey,
  }) async {
    final positionManagerAddress = _v4PositionManagerAddresses[chain]!;
    final stateViewAddress = _v4StateViewAddresses[chain];
    if (stateViewAddress == null) {
      return (
        tokenPositionCount: 0,
        positions: const <PoolPosition>[],
        error: 'sem endereço StateView configurado para ${chain.displayName}',
      );
    }
    final posManager = UniswapV4PositionManagerClient(
      rpcClient: rpcClient,
      positionManagerAddress: positionManagerAddress,
    );
    final poolStateClient = UniswapV4PoolStateClient(
      rpcClient: rpcClient,
      stateViewAddress: stateViewAddress,
    );

    // Descoberta via `alchemy_getAssetTransfers`, não via subgraph nem
    // `eth_getLogs` (o plano gratuito da Alchemy limita-o a 10 blocos por
    // pedido) — ver nota em `uniswap_v4_position_manager_client.dart`.
    List<({BigInt tokenId, String owner, DateTime createdAt, String? mintTxHash})>
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
                  mintTxHash: t.mintTxHash,
                ),
              )
              .toList();
        }),
      );
      tokenPositions = perOwner.expand((l) => l).toList();
      debugPrint(
        '[v4debug] ${chain.name}: fetchOwnedTokenIds (RPC) devolveu '
        '${tokenPositions.length} posições: '
        '${tokenPositions.map((p) => p.tokenId).toList()}',
      );
    } catch (e, st) {
      debugPrint('[v4debug] ${chain.name}: fetchOwnedTokenIds FALHOU: $e\n$st');
      return (tokenPositionCount: 0, positions: const <PoolPosition>[], error: e);
    }
    if (tokenPositions.isEmpty) {
      return (tokenPositionCount: 0, positions: const <PoolPosition>[], error: null);
    }

    final result = await _mapV4Positions(
      chain: chain,
      tokenPositions: tokenPositions,
      posManager: posManager,
      poolStateClient: poolStateClient,
      previousByKey: previousByKey,
    );
    debugPrint(
      '[v4debug] ${chain.name}: _mapV4Positions '
      '${result.positions.length}/${tokenPositions.length} mapeadas, '
      'lastError=${result.lastError}',
    );
    return (
      tokenPositionCount: tokenPositions.length,
      positions: result.positions,
      error: result.lastError,
    );
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
    for (final client in _v4RpcClients.values) {
      client.dispose();
    }
    _legacyRpcClient?.dispose();
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
  /// Limitações desta versão (Fase 2 adicionou `feesUnclaimedUsd` — ver
  /// pedido do utilizador; o resto fica para mais tarde):
  /// - `feesClaimedUsd` fica a 0: não há como saber on-chain quanto já foi
  ///   `collect()`ado no passado sem reconstruir todo o histórico de
  ///   eventos do tokenId (ao contrário do unclaimed atual, que o
  ///   `StateView` dá diretamente via `getFeeGrowthInside`/
  ///   `getPositionInfo` — ver `UniswapV4PoolStateClient`).
  /// - `initialLiquidityUsd` fica igual ao valor atual (P&L "desde a
  ///   abertura" mostra 0 em vez de um número errado): não há como saber
  ///   on-chain o capital originalmente depositado sem reconstruir todo o
  ///   histórico de eventos `ModifyLiquidity` do tokenId.
  /// - `gasCostUsd` já é real quando a Alchemy devolveu o hash da tx de
  ///   mint (`V4OwnedToken.mintTxHash`): lê-se o recibo dessa UMA
  ///   transação (`eth_getTransactionReceipt`, sem o limite de blocos do
  ///   `eth_getLogs`) e soma-se `gasUsed × effectiveGasPrice`. Só cobre o
  ///   mint — increases/decreases/collects posteriores ao mesmo tokenId
  ///   não são somados (precisariam do histórico completo de eventos, que
  ///   continua indisponível) — fica a 0 quando o hash não veio na resposta.
  Future<({List<PoolPosition> positions, Object? lastError})> _mapV4Positions({
    required Chain chain,
    required List<({BigInt tokenId, String owner, DateTime createdAt, String? mintTxHash})>
    tokenPositions,
    required UniswapV4PositionManagerClient posManager,
    required UniswapV4PoolStateClient poolStateClient,
    required Map<String, PoolPosition> previousByKey,
  }) async {
    // Concorrência limitada (ver `mapWithConcurrency`) e espaçada no tempo
    // (ver `EthRpcClient._waitForTurn`) — cada posição faz 4-5 pedidos RPC,
    // e uma wallet com muitas posições (confirmado ao vivo com 81 no
    // Arbitrum) excedia o rate limit da Alchemy (plano gratuito) sem isto.
    final rawResults = await mapWithConcurrency(tokenPositions, (raw) async {
      try {
        final info = await posManager.getPoolAndPositionInfo(raw.tokenId);
        final tick = await poolStateClient.getCurrentTick(info.poolKey);
        // `getPositionInfo` já devolve a liquidez (o mesmo valor de
        // `posManager.getPositionLiquidity`, lido do mesmo sítio) — poupa
        // um pedido RPC por posição não o chamar à parte.
        final positionInfo = await poolStateClient.getPositionInfo(
          poolKey: info.poolKey,
          owner: posManager.positionManagerAddress,
          tickLower: info.tickLower,
          tickUpper: info.tickUpper,
          salt: raw.tokenId,
        );
        final feeGrowthInside = await poolStateClient.getFeeGrowthInside(
          info.poolKey,
          tickLower: info.tickLower,
          tickUpper: info.tickUpper,
        );
        // O custo de gás do mint nunca muda — uma vez lido com sucesso
        // numa posição já conhecida, não há motivo para voltar a pedir o
        // recibo em TODOS os refreshes seguintes (gasto extra de RPC que
        // ajudou a esgotar o rate limit da Alchemy num arranque a frio
        // com muitas posições). Só se busca quando é a primeira vez que
        // se vê este tokenId.
        var gasWei = BigInt.zero;
        double? gasCostUsdOverride;
        final previousPosition = previousByKey['${chain.name}:v4:${raw.tokenId}'];
        if (previousPosition != null) {
          gasCostUsdOverride = previousPosition.gasCostUsd;
        } else {
          // Falhar a ler o recibo de gás não deve invalidar a posição
          // inteira (fees/range continuam válidos sem isto) — fica a 0.
          final mintTxHash = raw.mintTxHash;
          if (mintTxHash != null) {
            try {
              gasWei = await posManager.rpcClient.fetchGasCostWei([
                mintTxHash,
              ]);
            } catch (e) {
              debugPrint(
                '[v4debug] tokenId ${raw.tokenId}: recibo de gás FALHOU: $e',
              );
            }
          }
        }
        return (
          raw: raw,
          info: info,
          liquidity: positionInfo.liquidity,
          tick: tick,
          feeGrowthInside0: feeGrowthInside.inside0,
          feeGrowthInside1: feeGrowthInside.inside1,
          feeGrowthInside0Last: positionInfo.feeGrowthInside0Last,
          feeGrowthInside1Last: positionInfo.feeGrowthInside1Last,
          gasWei: gasWei,
          gasCostUsdOverride: gasCostUsdOverride,
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
          feeGrowthInside0: null,
          feeGrowthInside1: null,
          feeGrowthInside0Last: null,
          feeGrowthInside1Last: null,
          gasWei: BigInt.zero,
          gasCostUsdOverride: null as double?,
          error: e,
        );
      }
    });

    Object? lastError;
    final ok = <({
      ({BigInt tokenId, String owner, DateTime createdAt, String? mintTxHash}) raw,
      V4PositionInfo info,
      BigInt liquidity,
      int tick,
      BigInt feeGrowthInside0,
      BigInt feeGrowthInside1,
      BigInt feeGrowthInside0Last,
      BigInt feeGrowthInside1Last,
      BigInt gasWei,
      double? gasCostUsdOverride,
    })>[];
    // Pedido do utilizador ("às vezes tem as pools, às vezes não, é
    // aleatório"): uma posição que continua confirmadamente dele
    // (apareceu em `tokenPositions`, ou seja a Alchemy confirmou a posse)
    // mas falhou só a leitura on-chain NESTE refresh (rate limit, timeout
    // pontual) não deve desaparecer da lista — mostra-se a última versão
    // conhecida, em vez de nada, até o próximo refresh ter sucesso.
    final staleFallbacks = <PoolPosition>[];
    for (final r in rawResults) {
      if (r.error != null) {
        lastError = r.error;
        final stale = previousByKey['${chain.name}:v4:${r.raw.tokenId}'];
        if (stale != null && !stale.isClosed) staleFallbacks.add(stale);
      } else {
        ok.add((
          raw: r.raw,
          info: r.info!,
          liquidity: r.liquidity!,
          tick: r.tick!,
          feeGrowthInside0: r.feeGrowthInside0!,
          feeGrowthInside1: r.feeGrowthInside1!,
          feeGrowthInside0Last: r.feeGrowthInside0Last!,
          feeGrowthInside1Last: r.feeGrowthInside1Last!,
          gasWei: r.gasWei,
          gasCostUsdOverride: r.gasCostUsdOverride,
        ));
      }
    }
    if (ok.isEmpty) {
      return (positions: staleFallbacks, lastError: lastError);
    }

    final addresses = <String>{};
    // Gás é sempre pago em ETH nativo nestas chains (Ethereum/Arbitrum),
    // independentemente dos tokens da pool — por isso também força a
    // buscar o preço nativo quando há algum recibo de gás NOVO para
    // converter (posições já conhecidas reutilizam `gasCostUsdOverride`,
    // já em USD, e não precisam do preço nativo outra vez).
    var needsNativeEth = ok.any(
      (r) => r.gasCostUsdOverride == null && r.gasWei > BigInt.zero,
    );
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
    final metadataEntries = await mapWithConcurrency(addresses.toList(), (
      address,
    ) async {
      try {
        return (address: address, metadata: await metadataClient.fetch(address));
      } catch (e) {
        debugPrint('[v4debug] metadata do token $address FALHOU: $e');
        return (address: address, metadata: null as Erc20Metadata?);
      }
    });
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

      // Mesma fórmula do v3 (`tokensOwed`), só que o `feeGrowthInside`
      // ATUAL vem já calculado do `StateView` (ver
      // `UniswapV4PoolStateClient.getFeeGrowthInside`) em vez de ter de
      // ser derivado de `feeGrowthGlobal`/`feeGrowthOutside` — o v4 faz
      // essa derivação por nós.
      final owed0 = tokensOwed(
        feeGrowthInsideX128: r.feeGrowthInside0,
        feeGrowthInsideLastX128: r.feeGrowthInside0Last,
        liquidity: r.liquidity,
      );
      final owed1 = tokensOwed(
        feeGrowthInsideX128: r.feeGrowthInside1,
        feeGrowthInsideLastX128: r.feeGrowthInside1Last,
        liquidity: r.liquidity,
      );
      final unclaimedUsd =
          tokenAmountToDouble(owed0, token0.decimals) * token0.priceUsd +
          tokenAmountToDouble(owed1, token1.decimals) * token1.priceUsd;
      final gasCostUsd =
          r.gasCostUsdOverride ??
          (nativeEthPriceUsd == null
              ? 0.0
              : tokenAmountToDouble(r.gasWei, 18) * nativeEthPriceUsd);

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
          ..feesUnclaimedUsd = unclaimedUsd
          ..gasCostUsd = gasCostUsd
          ..isClosed = isClosed
          ..closedAt = null
          ..isV4 = true,
      );
    }

    return (positions: [...mapped, ...staleFallbacks], lastError: lastError);
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
