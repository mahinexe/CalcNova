import 'package:flutter_test/flutter_test.dart';
import 'package:calcnova/features/basic_calculator/basic_calculator_logic.dart';
import 'package:calcnova/features/converters/conversion_units.dart';

void main() {
  group('expression parser', () {
    test('respects precedence and parentheses', () {
      expect(ExpressionParser('12+5*3').parse(), 27);
      expect(ExpressionParser('(12+5)*3').parse(), 51);
    });
    test('supports negative decimals and constants', () {
      expect(ExpressionParser('-2.5 + pi').parse(), closeTo(0.64159265, 1e-7));
    });
    test('supports scientific functions and degrees', () {
      expect(
        ExpressionParser('sin(30)', degrees: true).parse(),
        closeTo(.5, 1e-10),
      );
      expect(ExpressionParser('fact(5)').parse(), 120);
      expect(ExpressionParser('sqrt(144)').parse(), 12);
    });
    test('rejects invalid calculations', () {
      expect(
        () => ExpressionParser('4/0').parse(),
        throwsA(isA<ExpressionException>()),
      );
      expect(
        () => ExpressionParser('sqrt(-1)').parse(),
        throwsA(isA<ExpressionException>()),
      );
    });
  });

  group('conversions', () {
    test('length works in both directions', () {
      final tool = tools.firstWhere((item) => item.id == 'length');
      expect(convertValue(tool, 1, tool.units[3], tool.units[2]), 1000);
      expect(convertValue(tool, 1, tool.units[2], tool.units[3]), .001);
    });
    test('temperature uses equations and absolute zero validation', () {
      final tool = tools.firstWhere((item) => item.id == 'temperature');
      expect(convertValue(tool, 100, tool.units[0], tool.units[1]), 212);
      expect(convertValue(tool, 32, tool.units[1], tool.units[0]), 0);
      expect(
        () => convertValue(tool, -300, tool.units[0], tool.units[2]),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
