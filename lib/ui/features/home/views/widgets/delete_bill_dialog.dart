import 'package:flutter/material.dart';
import 'package:basic_service/ui/core/strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget / helper: Diálogo de confirmación para eliminar factura
// skill: "Extract widgets into separate widget classes"
// ─────────────────────────────────────────────────────────────────────────────
class DeleteBillDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteBillDialog({super.key, required this.onConfirm});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => DeleteBillDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.deleteBillTitle),
      content: const Text(AppStrings.deleteBillConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text(
            AppStrings.delete,
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
