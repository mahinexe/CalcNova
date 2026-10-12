import 'dart:math' as math;

class ExpressionException implements Exception {
  const ExpressionException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ExpressionParser {
  ExpressionParser(this.input, {this.degrees = false})
    : _tokens = _tokenize(input);
  final String input;
  final bool degrees;
  final List<String> _tokens;
  int _position = 0;

  double parse() {
    if (_tokens.isEmpty) {
      throw const ExpressionException('Enter an expression');
    }
    final result = _expression();
    if (_position != _tokens.length) {
      throw const ExpressionException('Unexpected input');
    }
    if (!result.isFinite) {
      throw const ExpressionException('Result is undefined');
    }
    return result.toDouble();
  }

  double _expression() {
    var value = _term();
    while (_match('+') || _match('-')) {
      final operator = _tokens[_position - 1];
      final right = _term();
      value = operator == '+' ? value + right : value - right;
    }
    return value;
  }

  double _term() {
    var value = _power();
    while (_match('*') || _match('/') || _match('%')) {
      final operator = _tokens[_position - 1];
      final right = _power();
      if ((operator == '/' || operator == '%') && right == 0) {
        throw const ExpressionException('Cannot divide by zero');
      }
      value = operator == '*'
          ? value * right
          : operator == '/'
          ? value / right
          : value % right;
    }
    return value;
  }

  double _power() {
    var value = _unary();
    if (_match('^')) value = math.pow(value, _power()).toDouble();
    return value;
  }

  double _unary() {
    if (_match('+')) {
      return _unary();
    }
    if (_match('-')) {
      return -_unary();
    }
    return _primary();
  }

  double _primary() {
    if (_match('(')) {
      final value = _expression();
      _expect(')');
      return value;
    }
    final token = _position < _tokens.length ? _tokens[_position++] : '';
    if (double.tryParse(token) case final number?) {
      return number;
    }
    if (token == 'pi' || token == 'π') {
      return math.pi;
    }
    if (token == 'e') {
      return math.e;
    }
    if (_position < _tokens.length && _tokens[_position] == '(') {
      _position++;
      final argument = _expression();
      _expect(')');
      return _function(token, argument);
    }
    throw const ExpressionException('Malformed expression');
  }

  double _function(String name, double x) {
    final radians = degrees ? x * math.pi / 180 : x;
    final result = switch (name) {
      'sin' => math.sin(radians),
      'cos' => math.cos(radians),
      'tan' => math.tan(radians),
      'asin' => degrees ? math.asin(x) * 180 / math.pi : math.asin(x),
      'acos' => degrees ? math.acos(x) * 180 / math.pi : math.acos(x),
      'atan' => degrees ? math.atan(x) * 180 / math.pi : math.atan(x),
      'ln' => math.log(x),
      'log' => math.log(x) / math.ln10,
      'sqrt' => math.sqrt(x),
      'cbrt' => x < 0 ? -math.pow(-x, 1 / 3) : math.pow(x, 1 / 3),
      'abs' => x.abs(),
      'exp' => math.exp(x),
      'fact' => _factorial(x),
      'inv' => 1 / x,
      _ => throw const ExpressionException('Unknown function'),
    };
    if (!result.isFinite) {
      throw const ExpressionException('Invalid mathematical domain');
    }
    return result.toDouble();
  }

  double _factorial(double x) {
    if (x < 0 || x != x.truncate()) {
      throw const ExpressionException('Factorial needs a whole number');
    }
    var result = 1.0;
    for (var i = 2; i <= x; i++) {
      result *= i;
    }
    return result;
  }

  bool _match(String value) =>
      _position < _tokens.length && _tokens[_position] == value
      ? (++_position > 0)
      : false;
  void _expect(String value) {
    if (!_match(value)) {
      throw const ExpressionException('Missing parenthesis');
    }
  }

  static List<String> _tokenize(String source) {
    final tokens = <String>[];
    final pattern = RegExp(
      r'(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|[A-Za-z]+|[()+\-*/%^]',
    );
    var end = 0;
    for (final match in pattern.allMatches(
      source.replaceAll('×', '*').replaceAll('÷', '/'),
    )) {
      if (source.substring(end, match.start).trim().isNotEmpty) {
        throw const ExpressionException('Invalid character');
      }
      tokens.add(match.group(0)!.toLowerCase());
      end = match.end;
    }
    if (source.substring(end).trim().isNotEmpty) {
      throw const ExpressionException('Invalid character');
    }
    return tokens;
  }
}
