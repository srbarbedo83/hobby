/// Codificação/descodificação ABI mínima para os `eth_call` que o modo
/// Live precisa para ler posições Uniswap v4 diretamente dos contratos
/// (`PositionManager`) — o subgraph v4 não guarda range/liquidez por
/// posição, só o tokenId (ver nota em `uniswap_v4_subgraph_client.dart`).
/// Só o suficiente para os métodos usados: nenhuma dependência de ABI/web3
/// nova, para não repetir o historial de dores do Gradle desta app com
/// plugins nativos — isto é tudo Dart puro sobre `http`.
library;

/// Chamada a um método sem argumentos dinâmicos: 4 bytes do selector +
/// um único `uint256` (ex.: um tokenId) codificado em 32 bytes.
String encodeUint256Call(String selector, BigInt arg) {
  return selector + arg.toUnsigned(256).toRadixString(16).padLeft(64, '0');
}

/// As palavras de 32 bytes (64 carateres hex) da resposta de um `eth_call`,
/// sem o prefixo `0x`.
List<String> splitAbiWords(String hexData) {
  final clean = hexData.startsWith('0x') ? hexData.substring(2) : hexData;
  final words = <String>[];
  for (var i = 0; i + 64 <= clean.length; i += 64) {
    words.add(clean.substring(i, i + 64));
  }
  return words;
}

/// Os últimos 20 bytes (40 carateres) de uma palavra de 32 bytes — como um
/// `address` é codificado em ABI (right-aligned, left-padded com zeros).
String decodeAddress(String word) => '0x${word.substring(24)}';

BigInt decodeUint(String word) => BigInt.parse(word, radix: 16);

/// Um `int24` ABI-codificado numa palavra de 32 bytes: só os 3 bytes menos
/// significativos interessam, com extensão de sinal (bit 23) — a mesma
/// convenção usada por `signextend` em Solidity.
int decodeInt24(String word) {
  final raw = BigInt.parse(word.substring(word.length - 6), radix: 16);
  final signBit = BigInt.from(0x800000);
  final full = BigInt.from(0x1000000);
  return (raw & signBit) != BigInt.zero ? (raw - full).toInt() : raw.toInt();
}
