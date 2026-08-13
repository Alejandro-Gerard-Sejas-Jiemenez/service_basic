import 'package:flutter/material.dart';
import '../colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: texto tachado con línea geométrica perfectamente centrada
// skill: "STRICTLY prohibit private _build*() methods. Extract into separate widget classes."
// ─────────────────────────────────────────────────────────────────────────────
class StruckText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final bool isStruck;
  final Color? strikeColor;

  const StruckText({
    super.key,
    required this.text,
    required this.baseStyle,
    required this.isStruck,
    this.strikeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStrikeColor = strikeColor ?? AppColors.textSecondary;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Text(
          text,
          style: isStruck
              ? baseStyle.copyWith(color: AppColors.textSecondary)
              : baseStyle,
        ),
        if (isStruck)
          Positioned(
            left: 0,
            right: 0,
            child: Container(height: 1.5, color: effectiveStrikeColor),
          ),
      ],
    );
  }
}
