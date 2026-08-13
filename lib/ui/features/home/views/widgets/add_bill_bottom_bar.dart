import 'package:flutter/material.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: barra inferior de acciones (Guardar / Cancelar)
// skill: "STRICTLY prohibit private _build*() methods. Extract into separate widget classes."
// skill: "Ensure 48×48 dp touch targets"
// ─────────────────────────────────────────────────────────────────────────────
class AddBillBottomBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const AddBillBottomBar({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('add_bill_cancel'),
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.headerBg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text(
                  AppStrings.cancel,
                  style: TextStyle(color: AppColors.headerBg),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                key: const Key('add_bill_save'),
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.headerBg,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text(
                  AppStrings.save,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
