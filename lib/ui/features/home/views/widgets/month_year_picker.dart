import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: selector interactivo de mes/año
// skill: "Extract widgets into separate widget classes"
// ─────────────────────────────────────────────────────────────────────────────
class MonthYearPicker extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const MonthYearPicker({super.key, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy', 'es').format(date).toUpperCase();

    return InkWell(
      key: const Key('month_year_picker'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Icon(Icons.calendar_month, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
