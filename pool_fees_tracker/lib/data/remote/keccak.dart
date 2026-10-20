import 'dart:typed_data';

import 'package:pointycastle/digests/keccak.dart';

/// `keccak256` (o Keccak original, pré-normalização NIST — a função usada
/// pela EVM, incluindo para o `poolId` da Uniswap v4, NÃO o SHA3-256
/// padronizado, que usa um padding diferente). `KeccakDigest` do
/// `pointycastle` implementa esta variante original; `SHA3Digest` seria a
/// errada aqui — ver `test/keccak_test.dart` para o vetor de teste que
/// confirma isto.
Uint8List keccak256(Uint8List input) => KeccakDigest(256).process(input);
