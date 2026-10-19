import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/data/remote/eth_abi.dart';

void main() {
  group('encodeUint256Call', () {
    test('selector + tokenId em 32 bytes left-padded', () {
      final data = encodeUint256Call('0x1efeed33', BigInt.from(42));
      expect(data, '0x1efeed33${'2a'.padLeft(64, '0')}');
      // selector (10 chars incl. 0x) + 64 chars hex = 74 chars.
      expect(data.length, 74);
    });
  });

  group('splitAbiWords', () {
    test('divide dados hex em palavras de 32 bytes', () {
      final words = splitAbiWords('0x${'a' * 64}${'b' * 64}');
      expect(words, [('a' * 64), ('b' * 64)]);
    });

    test('funciona sem o prefixo 0x', () {
      final words = splitAbiWords('c' * 64);
      expect(words, ['c' * 64]);
    });
  });

  group('decodeAddress', () {
    test('extrai os últimos 20 bytes de uma palavra de 32 bytes', () {
      final word = '${'0' * 24}bd216513d74c8cf14cf4747e6aaa6420ff64ee9e';
      expect(decodeAddress(word), '0xbd216513d74c8cf14cf4747e6aaa6420ff64ee9e');
    });
  });

  group('decodeUint', () {
    test('faz parse de um valor hex simples', () {
      expect(decodeUint('${'0' * 62}ff'), BigInt.from(255));
    });
  });

  group('decodeInt24', () {
    test('valor positivo fica igual', () {
      final word = '${'0' * 58}0003e8'; // 1000
      expect(decodeInt24(word), 1000);
    });

    test('valor negativo é sign-extended corretamente', () {
      // -1000 em complemento-de-2 de 24 bits = 0xFFFC18.
      final word = '${'f' * 58}fffc18';
      expect(decodeInt24(word), -1000);
    });

    test('-1 em 24 bits', () {
      final word = ('f' * 64);
      expect(decodeInt24(word), -1);
    });
  });
}
