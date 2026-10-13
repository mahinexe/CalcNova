enum NumberBase {
  binary(2, 'BIN', 'Binary'),
  octal(8, 'OCT', 'Octal'),
  decimal(10, 'DEC', 'Decimal'),
  hexadecimal(16, 'HEX', 'Hexadecimal');

  const NumberBase(this.radix, this.label, this.name);
  final int radix;
  final String label;
  final String name;
}

enum BaseOperation {
  add('+', 'Addition'),
  subtract('-', 'Subtraction'),
  multiply('×', 'Multiplication'),
  divide('÷', 'Division');

  const BaseOperation(this.symbol, this.name);
  final String symbol;
  final String name;
}

class BaseNumberException implements Exception {
  const BaseNumberException(this.message);
  final String message;

  @override
  String toString() => message;
}

class Rational {
  Rational(BigInt numerator, [BigInt? denominator])
    : numerator = denominator == null
          ? numerator
          : _normaliseNumerator(numerator, denominator),
      denominator = denominator == null
          ? BigInt.one
          : _normaliseDenominator(numerator, denominator);

  final BigInt numerator;
  final BigInt denominator;

  static BigInt _normaliseNumerator(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) {
      throw const BaseNumberException('Cannot divide by zero');
    }
    final divisor = _gcd(numerator.abs(), denominator.abs());
    final sign = denominator.isNegative ? -BigInt.one : BigInt.one;
    return numerator ~/ divisor * sign;
  }

  static BigInt _normaliseDenominator(BigInt numerator, BigInt denominator) {
    final divisor = _gcd(numerator.abs(), denominator.abs());
    return denominator.abs() ~/ divisor;
  }

  bool get isZero => numerator == BigInt.zero;
  Rational operator +(Rational other) => Rational(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );
  Rational operator -(Rational other) => Rational(
    numerator * other.denominator - other.numerator * denominator,
    denominator * other.denominator,
  );
  Rational operator *(Rational other) =>
      Rational(numerator * other.numerator, denominator * other.denominator);
  Rational operator /(Rational other) {
    if (other.isZero) throw const BaseNumberException('Cannot divide by zero');
    return Rational(
      numerator * other.denominator,
      denominator * other.numerator,
    );
  }

  static BigInt _gcd(BigInt a, BigInt b) {
    while (b != BigInt.zero) {
      final remainder = a % b;
      a = b;
      b = remainder;
    }
    return a == BigInt.zero ? BigInt.one : a;
  }
}

Rational parseBaseNumber(String source, NumberBase base) {
  final value = source.trim();
  if (!RegExp(r'^-?(?:[0-9A-Fa-f]+(?:\.[0-9A-Fa-f]*)?|\.[0-9A-Fa-f]+)$')
      .hasMatch(value)) {
    throw const BaseNumberException('Enter a valid number');
  }

  final negative = value.startsWith('-');
  final unsigned = negative ? value.substring(1) : value;
  final parts = unsigned.split('.');
  final integerPart = parts.first.isEmpty ? '0' : parts.first;
  final fractionPart = parts.length == 2 ? parts.last : '';
  final digits = integerPart + fractionPart;
  final radix = BigInt.from(base.radix);
  var numerator = BigInt.zero;
  for (final character in digits.toUpperCase().split('')) {
    final digit = _digitValue(character);
    if (digit < 0 || digit >= base.radix) {
      throw BaseNumberException(
        '$character is not valid in ${base.name.toLowerCase()}',
      );
    }
    numerator = numerator * radix + BigInt.from(digit);
  }
  if (negative) numerator = -numerator;
  final denominator = _pow(radix, fractionPart.length);
  return Rational(numerator, denominator);
}

String formatBaseNumber(Rational value, NumberBase base, {int maxFraction = 16}) {
  if (value.isZero) return '0';
  final negative = value.numerator.isNegative;
  var numerator = value.numerator.abs();
  final denominator = value.denominator;
  final radix = BigInt.from(base.radix);
  final integerPart = numerator ~/ denominator;
  var remainder = numerator % denominator;
  final integerText = _formatInteger(integerPart, base);
  if (remainder == BigInt.zero) {
    return negative ? '-$integerText' : integerText;
  }

  final fraction = StringBuffer();
  var digits = 0;
  while (remainder != BigInt.zero && digits < maxFraction) {
    remainder *= radix;
    final digit = remainder ~/ denominator;
    remainder %= denominator;
    fraction.write(_digitCharacter(digit.toInt()));
    digits++;
  }
  final truncated = remainder != BigInt.zero;
  final suffix = truncated ? '…' : '';
  final result = '$integerText.${fraction.toString()}$suffix';
  return negative ? '-$result' : result;
}

String _formatInteger(BigInt value, NumberBase base) {
  if (value == BigInt.zero) return '0';
  final radix = BigInt.from(base.radix);
  var remaining = value;
  final digits = <String>[];
  while (remaining > BigInt.zero) {
    final digit = remaining % radix;
    digits.add(_digitCharacter(digit.toInt()));
    remaining ~/= radix;
  }
  return digits.reversed.join();
}

int _digitValue(String character) {
  const digits = '0123456789ABCDEF';
  return digits.indexOf(character);
}

String _digitCharacter(int value) => '0123456789ABCDEF'[value];

BigInt _pow(BigInt value, int exponent) {
  var result = BigInt.one;
  for (var i = 0; i < exponent; i++) {
    result *= value;
  }
  return result;
}

String calculateBaseNumber({
  required String first,
  required NumberBase firstBase,
  required String second,
  required NumberBase secondBase,
  required NumberBase outputBase,
  required BaseOperation operation,
}) {
  final left = parseBaseNumber(first, firstBase);
  final right = parseBaseNumber(second, secondBase);
  final result = switch (operation) {
    BaseOperation.add => left + right,
    BaseOperation.subtract => left - right,
    BaseOperation.multiply => left * right,
    BaseOperation.divide => left / right,
  };
  return formatBaseNumber(result, outputBase);
}
