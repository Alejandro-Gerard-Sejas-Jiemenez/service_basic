import 'package:flutter/material.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: fila de vecino (nombre + monto + eliminar)
// skill: autovalidateMode.onUserInteraction = errores en tiempo real
// skill: "Ensure 48×48 dp touch targets"
// ─────────────────────────────────────────────────────────────────────────────
class NeighborRow extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final VoidCallback onRemove;
  final double totalAmount;

  const NeighborRow({
    super.key,
    required this.index,
    required this.nameController,
    required this.amountController,
    required this.onRemove,
    required this.totalAmount,
  });

  static InputDecoration _deco({String? hint, String? suffix}) =>
      InputDecoration(
        hintText: hint,
        suffixText: suffix,
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              key: Key('neighbor_name_$index'),
              controller: nameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: _deco(hint: AppStrings.hintNeighborName),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              key: Key('neighbor_amount_$index'),
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: _deco(hint: '0.0', suffix: 'Bs'),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return null; // vecino es opcional
                }
                final amount = double.tryParse(val);
                if (amount == null) {
                  return AppStrings.valInvalid;
                }
                if (totalAmount > 0 && amount > totalAmount) {
                  return 'Máx ${totalAmount.toStringAsFixed(1)} Bs';
                }
                return null;
              },
            ),
          ),
          IconButton(
            key: Key('neighbor_remove_$index'),
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
            ),
            onPressed: onRemove,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
    );
  }
}
