import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';
import '../../view_models/expense_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: barra horizontal de filtros por estado y tipo de servicio
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

  Widget _buildFilterChip({
    required Key key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: 'Filtro $label',
        child: InkWell(
          key: key,
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.headerBg : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.full),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : (iconColor ?? AppColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Estado de pago
            _buildFilterChip(
              key: const Key('filter_status_all'),
              label: AppStrings.filterAll,
              isSelected: selectedStatus == PaymentStatusFilter.all,
              onTap: () => onStatusChanged(PaymentStatusFilter.all),
            ),
            _buildFilterChip(
              key: const Key('filter_status_pending'),
              label: AppStrings.filterPending,
              icon: Icons.hourglass_empty_rounded,
              iconColor: const Color(0xFFF59E0B),
              isSelected: selectedStatus == PaymentStatusFilter.pending,
              onTap: () => onStatusChanged(PaymentStatusFilter.pending),
            ),
            _buildFilterChip(
              key: const Key('filter_status_paid'),
              label: AppStrings.filterPaid,
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF10B981),
              isSelected: selectedStatus == PaymentStatusFilter.paid,
              onTap: () => onStatusChanged(PaymentStatusFilter.paid),
            ),

            // Separador vertical
            Container(
              height: 24,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              color: const Color(0xFFCBD5E1),
            ),

            // Tipos de servicio
            ...ServiceType.values.map((type) {
              final isSelected = selectedService == type;
              final (color, icon) = _serviceMeta(type);
              return _buildFilterChip(
                key: Key('filter_service_${type.name}'),
                label: type.displayName,
                icon: icon,
                iconColor: color,
                isSelected: isSelected,
                onTap: () => onServiceChanged(isSelected ? null : type),
              );
            }),

            // Botón de limpiar filtros
            if (hasActiveFilters) ...[
              const SizedBox(width: AppSpacing.xs),
              Semantics(
                button: true,
                label: 'Limpiar todos los filtros',
                child: TextButton.icon(
                  key: const Key('clear_filters_btn'),
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  label: const Text(
                    AppStrings.clearFilters,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
