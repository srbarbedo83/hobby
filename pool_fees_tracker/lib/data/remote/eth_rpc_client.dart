import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/calc/gas_cost.dart';
import '../local/chain.dart';

class EthRpcException implements Exception {
  final String message;

  EthRpcException(this.message);

  @override
  String toString() => 'EthRpcException: $message';
}

/// Cliente JSON-RPC mínimo, só com o que é preciso para o custo real de
/// gás: confirmar a que chain o endpoint responde, e ler recibos de
/// transação. Não serve para ler posições — isso continua a vir do
/// subgraph (`UniswapSubgraphClient`); este cliente existe só para dar
/// alguma utilidade real ao campo "RPC URL" das Definições.
class EthRpcClient {
  final String rpcUrl;
  final http.Client _httpClient;

  EthRpcClient({required this.rpcUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  // Atraso antes de cada nova tentativa num HTTP 429 — a própria mensagem
  // de erro da Alchemy recomenda isto ("If you have retries enabled, you
  // can safely ignore this message"). Sozinho não chegou (confirmado ao
  // vivo): o problema real não é "muitos pedidos ao mesmo tempo", é
  // "muitos pedidos por segundo" — limitar a concorrência (ver
  // `mapWithConcurrency`) continuava a mandar rajadas que excediam o
  // limite da Alchemy. Daí `_waitForTurn`, abaixo, espaçar os pedidos no
  // tempo, não só limitar quantos correm ao mesmo tempo.
  static const _retryDelays = [
    Duration(milliseconds: 500),
    Duration(milliseconds: 1500),
    Duration(seconds: 3),
  ];

  // Espaçamento mínimo entre o INÍCIO de pedidos consecutivos deste
  // cliente (uma instância por chain — ver `LivePoolFeesRepository`, por
  // isso não interfere com o RPC de outra chain). `_rateGate` serializa só
  // o cálculo do "turno" de cada chamada (não a chamada em si): cada
  // chamada marca o seu lugar na fila antes de a anterior sequer começar
  // a esperar, para não haver condições de corrida a decidir o mesmo slot
  // duas vezes.
  static const _minRequestSpacing = Duration(milliseconds: 300);
  DateTime? _nextAllowedAt;
  Future<void> _rateGate = Future.value();

  Future<void> _waitForTurn() {
    final myTurn = _rateGate;
    final completer = Completer<void>();
    _rateGate = completer.future;
    return myTurn.then((_) async {
      final now = DateTime.now();
      final next = _nextAllowedAt;
      final waitUntil = (next != null && next.isAfter(now)) ? next : now;
      _nextAllowedAt = waitUntil.add(_minRequestSpacing);
      final delay = waitUntil.difference(now);
      if (delay > Duration.zero) await Future.delayed(delay);
      completer.complete();
    });
  }

  Future<Map<String, dynamic>> _call(
    String method,
    List<dynamic> params,
  ) async {
    for (var attempt = 0; ; attempt++) {
      await _waitForTurn();
      http.Response response;
      try {
        response = await _httpClient
            .post(
              Uri.parse(rpcUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'jsonrpc': '2.0',
                'method': method,
                'params': params,
                'id': 1,
              }),
            )
            // Ver nota equivalente em `uniswap_subgraph_client.dart` — um
            // RPC lento ou pendurado não pode deixar o refresh Live preso
            // para sempre sem nunca mostrar erro.
            .timeout(const Duration(seconds: 20));
      } on http.ClientException catch (e) {
        // Confirmado ao vivo (logcat): "Software caused connection abort"
        // no `alchemy_getAssetTransfers` do Arbitrum (muito mais histórico
        // de transferências para paginar do que o Ethereum, por ter mais
        // posições) — uma quebra de ligação a meio do pedido, não um HTTP
        // 429, por isso não entrava no retry já existente (só olhava para
        // o status code). Sem isto, UM pedido falhado abortava a
        // descoberta de tokenIds inteira dessa chain.
        if (attempt < _retryDelays.length) {
          await Future.delayed(_retryDelays[attempt]);
          continue;
        }
        throw EthRpcException('ligação falhou: $e');
      } on TimeoutException {
        if (attempt < _retryDelays.length) {
          await Future.delayed(_retryDelays[attempt]);
          continue;
        }
        throw EthRpcException('pedido excedeu o tempo limite (20s)');
      }
      if (response.statusCode == 429 && attempt < _retryDelays.length) {
        await Future.delayed(_retryDelays[attempt]);
        continue;
      }
      if (response.statusCode != 200) {
        throw EthRpcException('HTTP ${response.statusCode}: ${response.body}');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['error'] != null) {
        throw EthRpcException(decoded['error'].toString());
      }
      return decoded;
    }
  }

  /// `eth_call` genérico (leitura on-chain, sem gastar gás) — usado para ler
  /// posições Uniswap v4 diretamente do `PositionManager` (ver
  /// `uniswap_v4_position_manager_client.dart`), já que o subgraph v4 não
  /// guarda range/liquidez por posição. Devolve o resultado em hex, com o
  /// prefixo `0x`.
  Future<String> ethCall({required String to, required String data}) async {
    final result = await _call('eth_call', [
      {'to': to, 'data': data},
      'latest',
    ]);
    return result['result'] as String;
  }

  /// A que [Chain] este endpoint responde, via `eth_chainId` — `null` se
  /// não for uma das chains que a app conhece.
  Future<Chain?> detectChain() async {
    final result = await _call('eth_chainId', const []);
    final id = parseHexBigInt(result['result'] as String?).toInt();
    return chainFromEvmChainId(id);
  }

  /// `alchemy_getAssetTransfers` — extensão específica da Alchemy (não é
  /// `eth_getLogs` standard) para descobrir que NFTs uma wallet recebeu de
  /// um contrato, sem o limite de "10 blocos por pedido" que o plano
  /// gratuito impõe ao `eth_getLogs` normal (confirmado via logcat —
  /// `eth_getLogs` falhava sempre com esse erro). Só funciona com um RPC
  /// da Alchemy; outros fornecedores não têm este método (o pedido falha
  /// com "method not found", visível no banner de erro como qualquer
  /// outro). Pagina automaticamente até não haver mais `pageKey`.
  Future<List<Map<String, dynamic>>> getAssetTransfers({
    required String toAddress,
    required List<String> contractAddresses,
  }) async {
    final transfers = <Map<String, dynamic>>[];
    String? pageKey;
    do {
      final params = <String, dynamic>{
        'fromBlock': '0x0',
        'toBlock': 'latest',
        'toAddress': toAddress,
        'contractAddresses': contractAddresses,
        'category': ['erc721'],
        'withMetadata': false,
        if (pageKey != null) 'pageKey': pageKey,
      };
      final result = await _call('alchemy_getAssetTransfers', [params]);
      final data = result['result'] as Map<String, dynamic>;
      transfers.addAll(
        (data['transfers'] as List).cast<Map<String, dynamic>>(),
      );
      pageKey = data['pageKey'] as String?;
    } while (pageKey != null);
    return transfers;
  }

  /// Timestamp (UTC) de um bloco, via `eth_getBlockByNumber` — usado para
  /// saber quando uma posição v4 foi criada (o `Transfer` de mint é o
  /// primeiro evento do tokenId).
  Future<DateTime> getBlockTimestamp(BigInt blockNumber) async {
    final result = await _call('eth_getBlockByNumber', [
      '0x${blockNumber.toRadixString(16)}',
      false,
    ]);
    final block = result['result'] as Map<String, dynamic>;
    final seconds = parseHexBigInt(block['timestamp'] as String?).toInt();
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }

  /// Preço de gás atual da chain (wei por unidade de gás), via
  /// `eth_gasPrice` — pedido do utilizador para ter uma referência rápida
  /// do custo de transacionar agora, sem ter de ir a um explorer externo.
  Future<BigInt> getGasPriceWei() async {
    final result = await _call('eth_gasPrice', const []);
    return parseHexBigInt(result['result'] as String?);
  }

  /// Soma `gasUsed × effectiveGasPrice` de várias transações, em wei do
  /// token nativo da chain. Hashes que o RPC não encontrar são ignorados
  /// (ex.: endpoint com histórico truncado) em vez de rebentar a conta toda.
  Future<BigInt> fetchGasCostWei(List<String> txHashes) async {
    final receipts = <({BigInt gasUsed, BigInt gasPrice})>[];
    for (final hash in txHashes) {
      final result = await _call('eth_getTransactionReceipt', [hash]);
      final receipt = result['result'] as Map<String, dynamic>?;
      if (receipt == null) continue;
      receipts.add((
        gasUsed: parseHexBigInt(receipt['gasUsed'] as String?),
        gasPrice: parseHexBigInt(
          (receipt['effectiveGasPrice'] ?? receipt['gasPrice']) as String?,
        ),
      ));
    }
    return sumGasCostWei(receipts);
  }

  void dispose() => _httpClient.close();
}
