import 'package:flutter/material.dart';
import '../colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: círculo interactivo de estado de pago (reutilizable)
// skill: "STRICTLY prohibit private _build*() methods. Extract into separate widget classes."
// skill: "Ensure 48×48 dp touch targets"
// ─────────────────────────────────────────────────────────────────────────────
class PaymentCircle extends StatelessWidget {
  final bool isPaid;
  final double size;
  final Color? paidColor;
  final Color? unpaidColor;

  const PaymentCircle({
    super.key,
    required this.isPaid,
    this.size = 28,
    this.paidColor,
    this.unpaidColor,
  });

  static const Color defaultEmerald = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final effectivePaidColor = paidColor ?? defaultEmerald;
    final effectiveUnpaidColor =
        unpaidColor ?? AppColors.textSecondary.withValues(alpha: 0.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPaid
            ? effectivePaidColor.withValues(alpha: 0.15)
            : Colors.transparent,
        border: Border.all(
          color: isPaid ? effectivePaidColor : effectiveUnpaidColor,
          width: 1.8,
        ),
      ),
      child: isPaid
          ? Icon(Icons.check, size: size * 0.55, color: effectivePaidColor)
          : null,
    );
  }
}
