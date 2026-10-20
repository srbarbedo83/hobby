import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/data/remote/eth_abi.dart';
import 'package:pool_fees_tracker/data/remote/keccak.dart';

void main() {
  group('keccak256', () {
    // Vetores confirmados localmente via Python + pycryptodome
    // (keccak.new(digest_bits=256)), não de memória — ver histórico desta
    // sessão sobre porque isso importa aqui (a EVM usa o Keccak original,
    // não o SHA3 normalizado pelo NIST, que tem padding diferente).
    test('keccak256("") bate com o vetor de referência', () {
      final digest = keccak256(Uint8List(0));
      expect(
        bytesToHex(digest),
        'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
      );
    });

    test('keccak256("abc") bate com o vetor de referência', () {
      final digest = keccak256(Uint8List.fromList('abc'.codeUnits));
      expect(
        bytesToHex(digest),
        '4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45',
      );
    });
  });
}
