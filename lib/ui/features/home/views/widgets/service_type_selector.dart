import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';

// Helper class para metadata de servicio (evita hardcodear valores en el build)
class _ServiceMeta {
  final Color color;
  final IconData icon;
  const _ServiceMeta({required this.color, required this.icon});
}

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: selector de tipo de servicio
// skill: "Extract widgets into separate widget classes"
// skill: "dart-use-pattern-matching — switch expression exhaustivo"
// ─────────────────────────────────────────────────────────────────────────────
class ServiceTypeSelector extends StatelessWidget {
  final ServiceType selected;
  final ValueChanged<ServiceType> onChanged;

  const ServiceTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  // skill: dart-use-pattern-matching — switch expression exhaustivo
  static _ServiceMeta _meta(ServiceType type) => switch (type) {
    ServiceType.water => const _ServiceMeta(
      color: AppColors.water,
      icon: Icons.water_drop,
    ),
    ServiceType.electricity => const _ServiceMeta(
      color: AppColors.electricity,
      icon: Icons.flash_on,
    ),
    ServiceType.gas => const _ServiceMeta(
      color: AppColors.gas,
      icon: Icons.local_fire_department,
    ),
    ServiceType.internet => const _ServiceMeta(
      color: AppColors.internet,
      icon: Icons.wifi,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ServiceType.values.map((type) {
        final meta = _meta(type);
        final isSelected = type == selected;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              key: Key('service_type_${type.name}'),
              onTap: () => onChanged(type),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? meta.color.withValues(alpha: 0.13)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? meta.color : const Color(0xFFEEEEEE),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Icon(
                      meta.icon,
                      color: isSelected ? meta.color : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? meta.color
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
