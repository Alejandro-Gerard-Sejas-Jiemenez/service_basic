import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/features/home/services/bill_share_formatter.dart';

void main() {
  group('BillShareFormatter - formatGroupSummary', () {
    test('formats empty monthly group properly', () {
      const group = MonthlyGroup(
        id: '2026-08',
        monthName: 'Agosto 2026',
        bills: [],
      );

      final summary = BillShareFormatter.formatGroupSummary(group);
      expect(summary, contains('Agosto 2026'));
      expect(summary, contains('No hay facturas registradas'));
    });

    test('formats bills with neighbor splits and statuses accurately', () {
      const group = MonthlyGroup(
        id: '2026-08',
        monthName: 'Agosto 2026',
        bills: [
          ServiceBill(
            id: 'bill-1',
            type: ServiceType.electricity,
            totalAmount: 500.0,
            ownerAmount: 200.0,
            splits: [
              NeighborSplit(
                name: 'Vecina',
                assignedAmount: 300.0,
                isPaid: false,
              ),
            ],
            isPaid: false,
          ),
          ServiceBill(
            id: 'bill-2',
            type: ServiceType.water,
            totalAmount: 100.0,
            ownerAmount: 50.0,
            splits: [
              NeighborSplit(
                name: 'Vecina',
                assignedAmount: 50.0,
                isPaid: true,
                paidAmount: 50.0,
              ),
            ],
            isPaid: true,
          ),
        ],
      );

      final summary = BillShareFormatter.formatGroupSummary(group);

      expect(summary, contains('Agosto 2026'));
      expect(summary, contains('💡 *Luz:* 500.0 Bs (Yo: 200.0 Bs)'));
      expect(summary, contains('• Vecina: 300.0 Bs [⏳ Pendiente]'));
      expect(summary, contains('💧 *Agua:* 100.0 Bs (Yo: 50.0 Bs)'));
      expect(summary, contains('• Vecina: 50.0 Bs [✅ Pagado]'));
      expect(summary, contains('💰 *Total Facturas:* 600.0 Bs'));
      expect(summary, contains('👤 *Mi Parte:* 250.0 Bs'));
      expect(summary, contains('👥 *Total Vecinos:* 350.0 Bs'));
    });
  });
}
