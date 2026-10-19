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

  Future<Map<String, dynamic>> _call(
    String method,
    List<dynamic> params,
  ) async {
    final response = await _httpClient
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
        // Ver nota equivalente em `uniswap_subgraph_client.dart` — um RPC
        // lento ou pendurado não pode deixar o refresh Live preso para
        // sempre sem nunca mostrar erro.
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw EthRpcException('HTTP ${response.statusCode}: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      throw EthRpcException(decoded['error'].toString());
    }
    return decoded;
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
