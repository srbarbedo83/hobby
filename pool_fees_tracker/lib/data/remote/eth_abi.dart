/// Codificação/descodificação ABI mínima para os `eth_call` que o modo
/// Live precisa para ler posições Uniswap v4 diretamente dos contratos
/// (`PositionManager`, `StateView`, e ERC-20 `symbol()`/`decimals()`) — o
/// subgraph v4 mostrou-se globalmente não fiável (ver nota em
/// `uniswap_v4_position_manager_client.dart`), por isso tudo o que antes
/// vinha de lá passou a ser lido on-chain. Só o suficiente para os métodos
/// usados: nenhuma dependência de ABI/web3 nova (exceto `pointycastle`,
/// só para `keccak256` — ver `keccak.dart`), para não repetir o historial
/// de dores do Gradle desta app com plugins nativos — isto é tudo Dart
/// puro sobre `http`.
library;

import 'dart:convert';
import 'dart:typed_data';

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

/// Hex (com ou sem prefixo `0x`) para bytes — para montar/descodificar
/// dados que não são só palavras de 32 bytes (ex.: o input do `keccak256`
/// do `poolId`, ou o conteúdo de uma `string` dinâmica).
Uint8List hexToBytes(String hex) {
  final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
  final bytes = Uint8List(clean.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

String bytesToHex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

/// Um `address` (20 bytes) codificado em ABI como uma palavra de 32 bytes
/// (right-aligned, left-padded com zeros) — o inverso de [decodeAddress].
Uint8List encodeAddressWord(String address) => Uint8List.fromList([
  ...List.filled(12, 0),
  ...hexToBytes(address),
]);

/// Um valor não-negativo codificado em ABI como uma palavra de 32 bytes.
Uint8List encodeUintWord(BigInt value) =>
    hexToBytes(value.toUnsigned(256).toRadixString(16).padLeft(64, '0'));

/// Descodifica o retorno ABI de uma função que devolve um único `string`
/// dinâmico (ex.: `symbol()` de um ERC-20) — a 1ª palavra é o offset
/// (sempre `0x20` para um único valor de retorno), a 2ª é o comprimento em
/// bytes, seguido do conteúdo em UTF-8, padded a múltiplos de 32 bytes.
String decodeDynamicString(String hexData) {
  final words = splitAbiWords(hexData);
  if (words.length < 2) return '';
  final length = decodeUint(words[1]).toInt();
  final dataHex = words.sublist(2).join();
  final bytes = hexToBytes(dataHex).take(length).toList();
  return utf8.decode(bytes);
}
