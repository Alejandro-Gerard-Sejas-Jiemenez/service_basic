import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/features/home/views/widgets/bill_item.dart';

void main() {
  const sampleBill = ServiceBill(
    id: 'bill-1',
    type: ServiceType.electricity,
    totalAmount: 500.0,
    ownerAmount: 200.0,
    splits: [
      NeighborSplit(name: 'Vecina', assignedAmount: 300.0, isPaid: false),
    ],
    isPaid: false,
  );

  Widget buildTestWidget({
    required ServiceBill bill,
    required VoidCallback onTogglePayment,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BillItem(
          bill: bill,
          onTogglePayment: onTogglePayment,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  group('BillItem Widget Tests', () {
    testWidgets('renders service information and triggers action callbacks', (
      WidgetTester tester,
    ) async {
      var toggled = false;
      var edited = false;
      var deleted = false;

      await tester.pumpWidget(
        buildTestWidget(
          bill: sampleBill,
          onTogglePayment: () => toggled = true,
          onEdit: () => edited = true,
          onDelete: () => deleted = true,
        ),
      );

      // Verify content
      expect(find.text('Luz'), findsOneWidget);
      expect(find.text('500.0 Bs'), findsOneWidget);
      expect(find.textContaining('Yo: 200.0 Bs'), findsOneWidget);
      expect(find.textContaining('Vecina: 300.0 Bs'), findsOneWidget);

      // Tap toggle payment circle
      await tester.tap(find.byKey(const Key('toggle_payment_bill-1')));
      expect(toggled, isTrue);

      // Tap edit button
      await tester.tap(find.byKey(const Key('edit_bill_bill-1')));
      expect(edited, isTrue);

      // Tap delete button
      await tester.tap(find.byKey(const Key('delete_bill_bill-1')));
      expect(deleted, isTrue);
    });
  });
}
