import 'package:flutter/material.dart';

const calculatorKeyGap = 8.0;
const calculatorKeyRadius = 14.0;

class CalculatorKeyButton extends StatelessWidget {
  const CalculatorKeyButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(calculatorKeyRadius),
        ),
      ),
      child: icon == null
          ? Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            )
          : Icon(icon, size: 21),
    ),
  );
}
