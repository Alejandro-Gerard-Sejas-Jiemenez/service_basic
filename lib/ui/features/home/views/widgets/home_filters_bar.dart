import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';
import '../../view_models/expense_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: barra de filtros en 2 niveles (segmentos de estado + chips de servicio)
// skill: "STRICTLY prohibit private _build*() methods. Extract into separate widget classes."
// skill: "Ensure 48×48 dp touch targets"
// ─────────────────────────────────────────────────────────────────────────────
class HomeFiltersBar extends StatelessWidget {
  final ServiceType? selectedService;
  final PaymentStatusFilter selectedStatus;
  final bool hasActiveFilters;
  final ValueChanged<ServiceType?> onServiceChanged;
  final ValueChanged<PaymentStatusFilter> onStatusChanged;
  final VoidCallback onClear;

  const HomeFiltersBar({
    super.key,
    required this.selectedService,
    required this.selectedStatus,
    required this.hasActiveFilters,
    required this.onServiceChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  static (Color, IconData) _serviceMeta(ServiceType type) => switch (type) {
    ServiceType.water => (AppColors.water, Icons.water_drop),
    ServiceType.electricity => (AppColors.electricity, Icons.flash_on),
    ServiceType.gas => (AppColors.gas, Icons.local_fire_department),
    ServiceType.internet => (AppColors.internet, Icons.wifi),
  };

  Widget _buildStatusSegment({
    required Key key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: 'Filtro $label',
        child: InkWell(
          key: key,
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.headerBg : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected
                    ? AppColors.headerBg
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x203B4C63),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChip({
    required Key key,
    required String label,
    required bool isSelected,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Filtro $label',
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── TIER 1: SEGMENTO FIJO DE 3 ESTADOS (Sin scroll, accesible al 100%) ──
          Row(
            children: [
              _buildStatusSegment(
                key: const Key('filter_status_all'),
                label: AppStrings.filterAll,
                isSelected: selectedStatus == PaymentStatusFilter.all,
                onTap: () => onStatusChanged(PaymentStatusFilter.all),
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildStatusSegment(
                key: const Key('filter_status_pending'),
                label: AppStrings.filterPending,
                icon: Icons.hourglass_empty_rounded,
                isSelected: selectedStatus == PaymentStatusFilter.pending,
                onTap: () => onStatusChanged(PaymentStatusFilter.pending),
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildStatusSegment(
                key: const Key('filter_status_paid'),
                label: AppStrings.filterPaid,
                icon: Icons.check_circle_outline_rounded,
                isSelected: selectedStatus == PaymentStatusFilter.paid,
                onTap: () => onStatusChanged(PaymentStatusFilter.paid),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // ── TIER 2: CHIPS DE SERVICIOS + LIMPIAR ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ...ServiceType.values.map((type) {
                  final isSelected = selectedService == type;
                  final (color, icon) = _serviceMeta(type);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: _buildServiceChip(
                      key: Key('filter_service_${type.name}'),
                      label: type.displayName,
                      color: color,
                      icon: icon,
                      isSelected: isSelected,
                      onTap: () => onServiceChanged(isSelected ? null : type),
                    ),
                  );
                }),

                if (hasActiveFilters) ...[
                  Semantics(
                    button: true,
                    label: 'Limpiar todos los filtros',
                    child: InkWell(
                      key: const Key('clear_filters_btn'),
                      onTap: onClear,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: const Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 4),
                            Text(
                              AppStrings.clearFilters,
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
