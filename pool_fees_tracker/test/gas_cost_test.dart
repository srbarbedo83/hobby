import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/gas_cost.dart';

void main() {
  group('parseHexBigInt', () {
    test('interpreta um hex com prefixo 0x', () {
      expect(parseHexBigInt('0x5208'), BigInt.from(21000));
    });

    test('interpreta um hex sem prefixo', () {
      expect(parseHexBigInt('5208'), BigInt.from(21000));
    });

    test('null ou vazio devolve zero em vez de rebentar', () {
      expect(parseHexBigInt(null), BigInt.zero);
      expect(parseHexBigInt(''), BigInt.zero);
      expect(parseHexBigInt('0x'), BigInt.zero);
    });

    test('maiúsculas também funcionam (0X)', () {
      expect(parseHexBigInt('0X1A'), BigInt.from(26));
    });
  });

  group('receiptGasCostWei', () {
    test('multiplica gasUsed por effectiveGasPrice', () {
      final cost = receiptGasCostWei(
        gasUsed: BigInt.from(21000),
        gasPrice: BigInt.from(30000000000), // 30 gwei
      );
      expect(cost, BigInt.from(21000) * BigInt.from(30000000000));
    });
  });

  group('sumGasCostWei', () {
    test('soma o custo de vários recibos', () {
      final total = sumGasCostWei([
        (gasUsed: BigInt.from(100000), gasPrice: BigInt.from(20000000000)),
        (gasUsed: BigInt.from(80000), gasPrice: BigInt.from(25000000000)),
      ]);
      final expected =
          BigInt.from(100000) * BigInt.from(20000000000) +
          BigInt.from(80000) * BigInt.from(25000000000);
      expect(total, expected);
    });

    test('lista vazia soma zero', () {
      expect(sumGasCostWei(const []), BigInt.zero);
    });
  });
}
