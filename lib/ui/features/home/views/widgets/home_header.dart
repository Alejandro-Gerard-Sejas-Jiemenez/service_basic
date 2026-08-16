import 'package:flutter/material.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: Header superior de la pantalla principal
// skill: "STRICTLY prohibit private _build*() methods. Extract into separate widget classes."
// ─────────────────────────────────────────────────────────────────────────────
class HomeHeader extends StatelessWidget {
  final VoidCallback? onMetrics;

  const HomeHeader({super.key, this.onMetrics});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.headerBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appHeaderCategory,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.appHeaderTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appHeaderSubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onMetrics != null)
            Semantics(
              button: true,
              label: 'Abrir estadísticas y métricas',
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  key: const Key('btn_open_metrics'),
                  tooltip: AppStrings.metricsTitle,
                  icon: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onMetrics,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
