import 'package:calcnova/features/base_numbers/base_number_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('base conversion', () {
    test('converts integer values across all bases', () {
      final value = parseBaseNumber('1010', NumberBase.binary);
      expect(formatBaseNumber(value, NumberBase.octal), '12');
      expect(formatBaseNumber(value, NumberBase.decimal), '10');
      expect(formatBaseNumber(value, NumberBase.hexadecimal), 'A');
    });

    test('interprets fractions using the selected radix', () {
      expect(
        formatBaseNumber(
          parseBaseNumber('101.11', NumberBase.binary),
          NumberBase.decimal,
        ),
        '5.75',
      );
      expect(
        formatBaseNumber(
          parseBaseNumber('17.4', NumberBase.octal),
          NumberBase.decimal,
        ),
        '15.5',
      );
      expect(
        formatBaseNumber(
          parseBaseNumber('A.C', NumberBase.hexadecimal),
          NumberBase.decimal,
        ),
        '10.75',
      );
    });

    test('supports signs, leading zeros, and lowercase hexadecimal', () {
      expect(
        formatBaseNumber(
          parseBaseNumber('-00a.c', NumberBase.hexadecimal),
          NumberBase.binary,
        ),
        '-1010.11',
      );
      expect(
        formatBaseNumber(
          parseBaseNumber('000', NumberBase.octal),
          NumberBase.decimal,
        ),
        '0',
      );
    });

    test('rejects malformed and out-of-range digits', () {
      expect(
        () => parseBaseNumber('102', NumberBase.binary),
        throwsA(isA<BaseNumberException>()),
      );
      expect(
        () => parseBaseNumber('1.2.3', NumberBase.decimal),
        throwsA(isA<BaseNumberException>()),
      );
      expect(
        () => parseBaseNumber('-', NumberBase.decimal),
        throwsA(isA<BaseNumberException>()),
      );
    });
  });

  group('base arithmetic', () {
    String calculate(
      String first,
      NumberBase firstBase,
      BaseOperation operation,
      String second,
      NumberBase secondBase,
      NumberBase outputBase,
    ) => calculateBaseNumber(
      first: first,
      firstBase: firstBase,
      second: second,
      secondBase: secondBase,
      outputBase: outputBase,
      operation: operation,
    );

    test('matches the required examples', () {
      expect(
        calculate(
          '101.11',
          NumberBase.binary,
          BaseOperation.add,
          '11.01',
          NumberBase.binary,
          NumberBase.binary,
        ),
        '1001',
      );
      expect(
        calculate(
          '8A.5',
          NumberBase.hexadecimal,
          BaseOperation.add,
          'E',
          NumberBase.hexadecimal,
          NumberBase.hexadecimal,
        ),
        '98.5',
      );
      expect(
        calculate(
          '101.11',
          NumberBase.binary,
          BaseOperation.add,
          '10.5',
          NumberBase.decimal,
          NumberBase.decimal,
        ),
        '16.25',
      );
      expect(
        calculate(
          'FF',
          NumberBase.hexadecimal,
          BaseOperation.add,
          '1',
          NumberBase.binary,
          NumberBase.binary,
        ),
        '100000000',
      );
      expect(
        calculate(
          '10.1',
          NumberBase.binary,
          BaseOperation.multiply,
          '2',
          NumberBase.decimal,
          NumberBase.binary,
        ),
        '101',
      );
      expect(
        calculate(
          '1000',
          NumberBase.binary,
          BaseOperation.divide,
          '10',
          NumberBase.binary,
          NumberBase.binary,
        ),
        '100',
      );
      expect(
        calculate(
          '10.5',
          NumberBase.decimal,
          BaseOperation.subtract,
          '11.01',
          NumberBase.binary,
          NumberBase.decimal,
        ),
        '7.25',
      );
      expect(
        calculate(
          '12',
          NumberBase.octal,
          BaseOperation.multiply,
          '3',
          NumberBase.octal,
          NumberBase.octal,
        ),
        '36',
      );
      expect(
        calculate(
          '10',
          NumberBase.binary,
          BaseOperation.subtract,
          '101',
          NumberBase.binary,
          NumberBase.binary,
        ),
        '-11',
      );
      expect(
        calculate(
          'A',
          NumberBase.hexadecimal,
          BaseOperation.multiply,
          '2',
          NumberBase.hexadecimal,
          NumberBase.hexadecimal,
        ),
        '14',
      );
    });

    test('handles zero division and repeating fractions', () {
      expect(
        () => calculate(
          '1',
          NumberBase.decimal,
          BaseOperation.divide,
          '0',
          NumberBase.decimal,
          NumberBase.decimal,
        ),
        throwsA(isA<BaseNumberException>()),
      );
      expect(
        calculate(
          '1',
          NumberBase.decimal,
          BaseOperation.divide,
          '3',
          NumberBase.decimal,
          NumberBase.decimal,
        ),
        '0.3333333333333333…',
      );
    });
  });
}
