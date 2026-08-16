import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/features/home/views/widgets/monthly_group_card.dart';

void main() {
  const sampleGroup = MonthlyGroup(
    id: '2026-08',
    monthName: 'Agosto 2026',
    bills: [
      ServiceBill(
        id: 'bill-1',
        type: ServiceType.electricity,
        totalAmount: 500.0,
        ownerAmount: 200.0,
        splits: [
          NeighborSplit(name: 'Vecina', assignedAmount: 300.0, isPaid: false),
        ],
        isPaid: false,
      ),
    ],
  );

  Widget buildTestWidget({
    required MonthlyGroup group,
    required bool isExpanded,
    required VoidCallback onToggle,
    required VoidCallback onShare,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MonthlyGroupCard(
          group: group,
          isExpanded: isExpanded,
          onToggle: onToggle,
          onShare: onShare,
          billItemBuilder: (groupId, bill) => Text('BillItem: ${bill.id}'),
        ),
      ),
    );
  }

  group('MonthlyGroupCard Widget Tests', () {
    testWidgets('renders month title, totals and handles callbacks', (
      WidgetTester tester,
    ) async {
      var toggled = false;
      var shared = false;

      await tester.pumpWidget(
        buildTestWidget(
          group: sampleGroup,
          isExpanded: false,
          onToggle: () => toggled = true,
          onShare: () => shared = true,
        ),
      );

      // Verify header contents
      expect(find.text('Agosto 2026'), findsOneWidget);
      expect(find.text('1 servicio'), findsOneWidget);
      expect(find.text('500.0 Bs'), findsOneWidget);

      // Bill item should not be rendered when collapsed
      expect(find.text('BillItem: bill-1'), findsNothing);

      // Tap header to toggle
      await tester.tap(find.byKey(const Key('month_toggle_2026-08')));
      expect(toggled, isTrue);

      // Tap share button
      await tester.tap(find.byKey(const Key('share_month_2026-08')));
      expect(shared, isTrue);
    });

    testWidgets('renders children when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          group: sampleGroup,
          isExpanded: true,
          onToggle: () {},
          onShare: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BillItem: bill-1'), findsOneWidget);
    });
  });
}
