import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/service_type.dart';

/// Servicio encargado de generar texto formateado para compartir resúmenes
/// de facturas mensuales a través de WhatsApp o el portapapeles.
class BillShareFormatter {
  const BillShareFormatter._();

  static String _serviceEmoji(ServiceType type) => switch (type) {
    ServiceType.electricity => '💡',
    ServiceType.water => '💧',
    ServiceType.gas => '🔥',
    ServiceType.internet => '📶',
  };

  /// Genera un resumen legible con formato Markdown para WhatsApp.
  static String formatGroupSummary(MonthlyGroup group) {
    final buffer = StringBuffer();
    buffer.writeln('🧾 *Resumen de Servicios Básicos — ${group.monthName}*');
    buffer.writeln();

    if (group.bills.isEmpty) {
      buffer.writeln('No hay facturas registradas en este mes.');
      return buffer.toString();
    }

    for (final bill in group.bills) {
      final emoji = _serviceEmoji(bill.type);
      buffer.writeln(
        '$emoji *${bill.type.displayName}:* ${bill.totalAmount.toStringAsFixed(1)} Bs (Yo: ${bill.ownerAmount.toStringAsFixed(1)} Bs)',
      );

      if (bill.splits.isEmpty) {
        buffer.writeln('  • _Sin asignación a vecinos_');
      } else {
        for (final split in bill.splits) {
          final status = split.isPaid ? '✅ Pagado' : '⏳ Pendiente';
          buffer.writeln(
            '  • ${split.name}: ${split.assignedAmount.toStringAsFixed(1)} Bs [$status]',
          );
        }
      }
      buffer.writeln();
    }

    buffer.writeln('----------------------------------');
    buffer.writeln(
      '💰 *Total Facturas:* ${group.totalAmount.toStringAsFixed(1)} Bs',
    );
    buffer.writeln('👤 *Mi Parte:* ${group.ownerTotal.toStringAsFixed(1)} Bs');
    buffer.writeln(
      '👥 *Total Vecinos:* ${group.tenantTotal.toStringAsFixed(1)} Bs',
    );

    return buffer.toString().trim();
  }
}
