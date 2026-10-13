import 'package:flutter/material.dart';

class UnitDefinition {
  const UnitDefinition(this.name, this.symbol, this.toBase);
  final String name, symbol;
  final double Function(double) toBase;
  double fromBase(double value) => toBase(1) == 0 ? value : value / toBase(1);
}

class ToolDefinition {
  const ToolDefinition(
    this.id,
    this.title,
    this.icon,
    this.units, {
    this.temperature = false,
  });
  final String id, title;
  final IconData icon;
  final List<UnitDefinition> units;
  final bool temperature;
}

double Function(double) _factor(double factor) =>
    (_) => factor;
final tools = <ToolDefinition>[
  const ToolDefinition(
    'basic',
    'Basic calculator',
    Icons.calculate_rounded,
    [],
  ),
  const ToolDefinition(
    'scientific',
    'Scientific calculator',
    Icons.functions_rounded,
    [],
  ),
  const ToolDefinition(
    'base-calculator',
    'Base calculator',
    Icons.calculate_outlined,
    [],
  ),
  const ToolDefinition(
    'base-converter',
    'Base converter',
    Icons.swap_horiz_rounded,
    [],
  ),
  ToolDefinition('length', 'Length', Icons.straighten_rounded, [
    UnitDefinition('Millimeter', 'mm', _factor(0.001)),
    UnitDefinition('Centimeter', 'cm', _factor(0.01)),
    UnitDefinition('Meter', 'm', _factor(1)),
    UnitDefinition('Kilometer', 'km', _factor(1000)),
    UnitDefinition('Inch', 'in', _factor(0.0254)),
    UnitDefinition('Foot', 'ft', _factor(0.3048)),
    UnitDefinition('Yard', 'yd', _factor(0.9144)),
    UnitDefinition('Mile', 'mi', _factor(1609.344)),
    UnitDefinition('Nautical mile', 'nmi', _factor(1852)),
  ]),
  ToolDefinition('area', 'Area', Icons.square_foot_rounded, [
    UnitDefinition('Square millimeter', 'mm²', _factor(1e-6)),
    UnitDefinition('Square centimeter', 'cm²', _factor(1e-4)),
    UnitDefinition('Square meter', 'm²', _factor(1)),
    UnitDefinition('Hectare', 'ha', _factor(10000)),
    UnitDefinition('Square kilometer', 'km²', _factor(1e6)),
    UnitDefinition('Square inch', 'in²', _factor(0.00064516)),
    UnitDefinition('Square foot', 'ft²', _factor(0.09290304)),
    UnitDefinition('Square yard', 'yd²', _factor(0.83612736)),
    UnitDefinition('Acre', 'ac', _factor(4046.8564224)),
    UnitDefinition('Square mile', 'mi²', _factor(2589988.110336)),
  ]),
  ToolDefinition('volume', 'Volume', Icons.water_drop_outlined, [
    UnitDefinition('Milliliter', 'mL', _factor(0.001)),
    UnitDefinition('Liter', 'L', _factor(1)),
    UnitDefinition('Cubic centimeter', 'cm³', _factor(0.001)),
    UnitDefinition('Cubic meter', 'm³', _factor(1000)),
    UnitDefinition('Cubic inch', 'in³', _factor(0.016387064)),
    UnitDefinition('Cubic foot', 'ft³', _factor(28.316846592)),
    UnitDefinition('US gallon', 'gal', _factor(3.785411784)),
    UnitDefinition('US quart', 'qt', _factor(0.946352946)),
    UnitDefinition('US pint', 'pt', _factor(0.473176473)),
    UnitDefinition('US fluid ounce', 'fl oz', _factor(0.0295735295625)),
  ]),
  ToolDefinition('mass', 'Weight & mass', Icons.fitness_center_rounded, [
    UnitDefinition('Milligram', 'mg', _factor(1e-6)),
    UnitDefinition('Gram', 'g', _factor(0.001)),
    UnitDefinition('Kilogram', 'kg', _factor(1)),
    UnitDefinition('Metric tonne', 't', _factor(1000)),
    UnitDefinition('Ounce', 'oz', _factor(0.028349523125)),
    UnitDefinition('Pound', 'lb', _factor(0.45359237)),
    UnitDefinition('Stone', 'st', _factor(6.35029318)),
  ]),
  ToolDefinition('temperature', 'Temperature', Icons.thermostat_rounded, [
    UnitDefinition('Celsius', '°C', _factor(1)),
    UnitDefinition('Fahrenheit', '°F', _factor(1)),
    UnitDefinition('Kelvin', 'K', _factor(1)),
  ], temperature: true),
  ToolDefinition('speed', 'Speed', Icons.speed_rounded, [
    UnitDefinition('Meters per second', 'm/s', _factor(1)),
    UnitDefinition('Kilometers per hour', 'km/h', _factor(0.2777777778)),
    UnitDefinition('Miles per hour', 'mph', _factor(0.44704)),
    UnitDefinition('Feet per second', 'ft/s', _factor(0.3048)),
    UnitDefinition('Knots', 'kn', _factor(0.5144444444)),
  ]),
  ToolDefinition('pressure', 'Pressure', Icons.compress_rounded, [
    UnitDefinition('Pascal', 'Pa', _factor(1)),
    UnitDefinition('Kilopascal', 'kPa', _factor(1000)),
    UnitDefinition('Megapascal', 'MPa', _factor(1e6)),
    UnitDefinition('Bar', 'bar', _factor(100000)),
    UnitDefinition('Millibar', 'mbar', _factor(100)),
    UnitDefinition('Standard atmosphere', 'atm', _factor(101325)),
    UnitDefinition('Torr', 'Torr', _factor(133.322368)),
    UnitDefinition('PSI', 'psi', _factor(6894.757293)),
  ]),
  ToolDefinition('power', 'Power', Icons.bolt_rounded, [
    UnitDefinition('Watt', 'W', _factor(1)),
    UnitDefinition('Kilowatt', 'kW', _factor(1000)),
    UnitDefinition('Megawatt', 'MW', _factor(1e6)),
    UnitDefinition('Milliwatt', 'mW', _factor(0.001)),
    UnitDefinition('Metric horsepower', 'PS', _factor(735.49875)),
    UnitDefinition('Mechanical horsepower', 'hp', _factor(745.699872)),
  ]),
];

double convertValue(
  ToolDefinition tool,
  double value,
  UnitDefinition from,
  UnitDefinition to,
) {
  if (tool.temperature) {
    final celsius = switch (from.symbol) {
      '°C' => value,
      '°F' => (value - 32) * 5 / 9,
      'K' => value - 273.15,
      _ => value,
    };
    if (celsius < -273.15) {
      throw const FormatException('Temperature is below absolute zero');
    }
    return switch (to.symbol) {
      '°C' => celsius,
      '°F' => celsius * 9 / 5 + 32,
      'K' => celsius + 273.15,
      _ => celsius,
    };
  }
  return value * from.toBase(1) / to.toBase(1);
}
