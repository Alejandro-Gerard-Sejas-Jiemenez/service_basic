import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';
import '../../view_models/expense_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: barra compacta de 2 selectores (Estado y Servicio) + Limpiar
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

  static String _statusLabel(PaymentStatusFilter status) => switch (status) {
    PaymentStatusFilter.all => AppStrings.filterAll,
    PaymentStatusFilter.pending => AppStrings.filterPending,
    PaymentStatusFilter.paid => AppStrings.filterPaid,
  };

  static IconData _statusIcon(PaymentStatusFilter status) => switch (status) {
    PaymentStatusFilter.all => Icons.filter_list_rounded,
    PaymentStatusFilter.pending => Icons.hourglass_empty_rounded,
    PaymentStatusFilter.paid => Icons.check_circle_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final statusActive = selectedStatus != PaymentStatusFilter.all;
    final serviceActive = selectedService != null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // ── SELECTOR 1: ESTADO DE PAGO ──
          Expanded(
            child: Semantics(
              button: true,
              label: 'Filtrar por estado: ${_statusLabel(selectedStatus)}',
              child: PopupMenuButton<PaymentStatusFilter>(
                key: const Key('filter_status_dropdown'),
                initialValue: selectedStatus,
                onSelected: onStatusChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    key: const Key('filter_status_all'),
                    value: PaymentStatusFilter.all,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.filterAll,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  selectedStatus == PaymentStatusFilter.all
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    key: const Key('filter_status_pending'),
                    value: PaymentStatusFilter.pending,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.hourglass_empty_rounded,
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.filterPending,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  selectedStatus == PaymentStatusFilter.pending
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    key: const Key('filter_status_paid'),
                    value: PaymentStatusFilter.paid,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.filterPaid,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  selectedStatus == PaymentStatusFilter.paid
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: statusActive ? AppColors.headerBg : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: statusActive
                          ? AppColors.headerBg
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(selectedStatus),
                        size: 15,
                        color: statusActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _statusLabel(selectedStatus),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: statusActive
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: statusActive
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: statusActive
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── SELECTOR 2: TIPO DE SERVICIO ──
          Expanded(
            child: Semantics(
              button: true,
              label:
                  'Filtrar por servicio: ${selectedService?.displayName ?? "Todos"}',
              child: PopupMenuButton<ServiceType?>(
                key: const Key('filter_service_dropdown'),
                initialValue: selectedService,
                onSelected: onServiceChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    key: const Key('filter_service_all'),
                    value: null,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Todos los servicios',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: selectedService == null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...ServiceType.values.map((type) {
                    final (color, icon) = _serviceMeta(type);
                    return PopupMenuItem(
                      key: Key('filter_service_${type.name}'),
                      value: type,
                      child: Row(
                        children: [
                          Icon(icon, size: 16, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              type.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: selectedService == type
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: serviceActive
                        ? _serviceMeta(selectedService!).$1
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: serviceActive
                          ? _serviceMeta(selectedService!).$1
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedService != null
                            ? _serviceMeta(selectedService!).$2
                            : Icons.grid_view_rounded,
                        size: 15,
                        color: serviceActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selectedService?.displayName ?? 'Servicios',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: serviceActive
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: serviceActive
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: serviceActive
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── BOTÓN LIMPIAR ──
          if (hasActiveFilters) ...[
            const SizedBox(width: AppSpacing.xs),
            Semantics(
              button: true,
              label: 'Limpiar todos los filtros',
              child: IconButton(
                key: const Key('clear_filters_btn'),
                onPressed: onClear,
                tooltip: AppStrings.clearFilters,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
                constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
