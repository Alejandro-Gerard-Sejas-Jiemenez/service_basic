import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';
import 'package:basic_service/ui/core/widgets/payment_circle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: ítem individual de factura en la lista mensual
// skill: "STRICTLY prohibit private _build*() methods. Extract into separate widget classes."
// skill: "Ensure 48×48 dp touch targets"
// ─────────────────────────────────────────────────────────────────────────────
class BillItem extends StatelessWidget {
  final ServiceBill bill;
  final VoidCallback onTogglePayment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BillItem({
    super.key,
    required this.bill,
    required this.onTogglePayment,
    required this.onEdit,
    required this.onDelete,
  });

  // skill: dart-use-pattern-matching — switch expression exhaustivo
  static (Color, IconData) _serviceMeta(ServiceType type) => switch (type) {
    ServiceType.water => (AppColors.water, Icons.water_drop),
    ServiceType.electricity => (AppColors.electricity, Icons.flash_on),
    ServiceType.gas => (AppColors.gas, Icons.local_fire_department),
    ServiceType.internet => (AppColors.internet, Icons.wifi),
  };

  @override
  Widget build(BuildContext context) {
    final (iconColor, iconData) = _serviceMeta(bill.type);

    final splitsDetail = bill.splits
        .map((s) => '${s.name}: ${s.assignedAmount.toStringAsFixed(1)} Bs')
        .join('\n');
    final detailText =
        'Yo: ${bill.ownerAmount.toStringAsFixed(1)} Bs\n$splitsDetail';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Toggle de pago — skill: "Ensure 48×48 dp touch targets" & "Accessibility: Include Semantics"
          Semantics(
            button: true,
            label:
                '${bill.type.displayName}, ${bill.isPaid ? "marcado como pagado" : "pendiente de pago"}, ${bill.totalAmount.toStringAsFixed(1)} Bolivianos. Toca para cambiar estado.',
            child: GestureDetector(
              key: Key('toggle_payment_${bill.id}'),
              onTap: onTogglePayment,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: PaymentCircle(isPaid: bill.isPaid, size: 26),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Nombre del servicio con ícono al mismo nivel + detalle abajo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: iconColor.withValues(
                        alpha: bill.isPaid ? 0.4 : 1.0,
                      ),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        bill.type.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: bill.isPaid
                              ? AppColors.textSecondary.withValues(alpha: 0.6)
                              : AppColors.textPrimary,
                          decoration: bill.isPaid
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  detailText,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          // Monto total
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${bill.totalAmount.toStringAsFixed(1)} Bs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: bill.isPaid
                      ? AppColors.textSecondary.withValues(alpha: 0.5)
                      : AppColors.textPrimary,
                  decoration: bill.isPaid
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ),

          // Botón editar — skill: "Ensure 48×48 dp touch targets" & "Accessibility: Include Semantics"
          Semantics(
            button: true,
            label: 'Editar factura de ${bill.type.displayName}',
            child: IconButton(
              key: Key('edit_bill_${bill.id}'),
              tooltip: 'Editar',
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.grey.shade600,
              ),
              onPressed: onEdit,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),

          // Botón eliminar — skill: "Ensure 48×48 dp touch targets" & "Accessibility: Include Semantics"
          Semantics(
            button: true,
            label: 'Eliminar factura de ${bill.type.displayName}',
            child: IconButton(
              key: Key('delete_bill_${bill.id}'),
              tooltip: AppStrings.delete,
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.grey.shade400,
              ),
              onPressed: onDelete,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ],
      ),
    );
  }
}
