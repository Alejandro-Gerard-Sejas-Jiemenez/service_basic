import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/widgets/payment_circle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: tarjeta de grupo mensual (acordeón y header con estadísticas)
// skill: "STRICTLY prohibit private _build*() methods. Extract into separate widget classes."
// ─────────────────────────────────────────────────────────────────────────────
class MonthlyGroupCard extends StatelessWidget {
  final MonthlyGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onShare;
  final Widget Function(String groupId, ServiceBill bill) billItemBuilder;

  const MonthlyGroupCard({
    super.key,
    required this.group,
    required this.isExpanded,
    required this.onToggle,
    required this.onShare,
    required this.billItemBuilder,
  });

  static const Color _monthBgExpanded = Color(0xFF2D3A4A);
  static const Color _monthBgCollapsed = Color(0xFFECEFF4);
  static const Color _monthTextExp = Colors.white;
  static const Color _monthSubTextExp = Color(0xFFB0BEC5);
  static const Color _distPrimaryExp = Colors.white;
  static const Color _distSecondaryExp = Color(0xFFCFD8DC);
  static const Color _distPrimaryColl = Color(0xFF37474F);
  static const Color _distSecondaryColl = Color(0xFF607D8B);
  static const double _radius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER: forma FIJA, siempre bordes redondeados completos ──
          Semantics(
            button: true,
            label:
                '${group.monthName}, ${group.isPaid ? "todos los servicios pagados" : "servicios pendientes"}, ${group.bills.length} servicios, total ${group.totalAmount.toStringAsFixed(1)} Bolivianos. ${isExpanded ? "Toca para contraer" : "Toca para expandir"}.',
            child: GestureDetector(
              key: Key('month_toggle_${group.id}'),
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isExpanded ? _monthBgExpanded : _monthBgCollapsed,
                  borderRadius: BorderRadius.circular(_radius),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    PaymentCircle(
                      isPaid: group.isPaid,
                      size: 20,
                      paidColor: isExpanded
                          ? const Color(0xFF90A4AE)
                          : const Color(0xFF10B981),
                      unpaidColor: isExpanded
                          ? _monthSubTextExp
                          : const Color(0xFF90A4AE),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.monthName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isExpanded
                                  ? _monthTextExp
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${group.bills.length} servicios\nTotal: ${group.totalAmount.toStringAsFixed(1)} Bs',
                            style: TextStyle(
                              fontSize: 11,
                              color: isExpanded
                                  ? _monthSubTextExp
                                  : AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Yo: ${group.ownerTotal.toStringAsFixed(1)} Bs',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isExpanded
                                    ? _distPrimaryExp
                                    : _distPrimaryColl,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              group.bills.isEmpty
                                  ? 'Vecina: 0.0 Bs'
                                  : group.bills.first.splits.length == 1
                                  ? 'Vecina: ${group.tenantTotal.toStringAsFixed(1)} Bs'
                                  : 'Vecinos: ${group.tenantTotal.toStringAsFixed(1)} Bs',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isExpanded
                                    ? _distSecondaryExp
                                    : _distSecondaryColl,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Semantics(
                      button: true,
                      label: 'Compartir resumen de ${group.monthName}',
                      child: IconButton(
                        key: Key('share_month_${group.id}'),
                        tooltip: 'Compartir resumen',
                        icon: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: isExpanded
                              ? _monthSubTextExp
                              : AppColors.textSecondary,
                        ),
                        onPressed: onShare,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: isExpanded
                          ? _monthSubTextExp
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── LISTA: debajo del header, sin cambiar su forma ──
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(_radius),
                        bottomRight: Radius.circular(_radius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: group.bills.length,
                      itemBuilder: (_, index) =>
                          billItemBuilder(group.id, group.bills[index]),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}
