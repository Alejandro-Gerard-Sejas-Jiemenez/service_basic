import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';
import '../view_models/expense_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MetricsScreen: Pantalla de estadísticas, KPIs y gráficos de gastos acumulados
// skill: "flutter-ui: strict tokens, touch targets 48dp, Semantics accessibility"
// ─────────────────────────────────────────────────────────────────────────────
class MetricsScreen extends StatelessWidget {
  final ExpenseViewModel viewModel;

  const MetricsScreen({super.key, required this.viewModel});

  static Color _serviceColor(ServiceType type) => switch (type) {
    ServiceType.electricity => const Color(0xFFF59E0B),
    ServiceType.water => const Color(0xFF3B82F6),
    ServiceType.gas => const Color(0xFFEF4444),
    ServiceType.internet => const Color(0xFF8B5CF6),
  };

  static String _serviceIcon(ServiceType type) => switch (type) {
    ServiceType.electricity => '💡',
    ServiceType.water => '💧',
    ServiceType.gas => '🔥',
    ServiceType.internet => '📶',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.headerBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          AppStrings.metricsTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Semantics(
          button: true,
          label: 'Volver a la pantalla principal',
          child: IconButton(
            key: const Key('btn_back_metrics'),
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: viewModel.groups.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  AppStrings.noMetricsData,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. TARJETA PRINCIPAL: TOTAL ACUMULADO ──
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D3A4A), Color(0xFF1E2631)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.allTimeTotal,
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${viewModel.allTimeTotal.toStringAsFixed(1)} Bs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Color(0x30FFFFFF), height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildKpiMini(
                              label: AppStrings.myTotal,
                              value:
                                  '${viewModel.allTimeOwnerTotal.toStringAsFixed(1)} Bs',
                              color: const Color(0xFF6EE7B7),
                            ),
                            _buildKpiMini(
                              label: AppStrings.tenantTotal,
                              value:
                                  '${viewModel.allTimeTenantTotal.toStringAsFixed(1)} Bs',
                              color: const Color(0xFF93C5FD),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── 2. PAGADO VS PENDIENTE ──
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estado de Gastos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${viewModel.paidPercentage.toStringAsFixed(0)}% Pagado',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: viewModel.allTimeTotal == 0.0
                                ? 0.0
                                : viewModel.allTimePaidTotal /
                                      viewModel.allTimeTotal,
                            backgroundColor: const Color(0xFFFEE2E2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '✅ Pagado: ${viewModel.allTimePaidTotal.toStringAsFixed(1)} Bs',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '⏳ Pendiente: ${viewModel.allTimePendingTotal.toStringAsFixed(1)} Bs',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── 3. PROMEDIO MENSUAL ──
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.monthlyAverage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${viewModel.monthlyAverage.toStringAsFixed(1)} Bs / mes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${viewModel.groups.length} meses',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── 4. DISTRIBUCIÓN POR SERVICIO ──
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.distributionByService,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...ServiceType.values.map((type) {
                          final amount =
                              viewModel.totalByServiceType[type] ?? 0.0;
                          final pct = viewModel.allTimeTotal == 0.0
                              ? 0.0
                              : (amount / viewModel.allTimeTotal);
                          final color = _serviceColor(type);

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_serviceIcon(type)} ${type.displayName}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${amount.toStringAsFixed(1)} Bs (${(pct * 100).toStringAsFixed(0)}%)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── 5. HISTORIAL MENSUAL COMPARATIVO ──
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.monthlyHistory,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...viewModel.groups.map((group) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group.monthName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${group.totalAmount.toStringAsFixed(1)} Bs',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  static Widget _buildKpiMini({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
