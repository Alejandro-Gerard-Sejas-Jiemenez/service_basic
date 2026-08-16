import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/features/home/view_models/expense_view_model.dart';
import 'package:basic_service/ui/features/home/views/widgets/home_filters_bar.dart';

void main() {
  Widget buildTestWidget({
    required ServiceType? selectedService,
    required PaymentStatusFilter selectedStatus,
    required bool hasActiveFilters,
    required ValueChanged<ServiceType?> onServiceChanged,
    required ValueChanged<PaymentStatusFilter> onStatusChanged,
    required VoidCallback onClear,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HomeFiltersBar(
          selectedService: selectedService,
          selectedStatus: selectedStatus,
          hasActiveFilters: hasActiveFilters,
          onServiceChanged: onServiceChanged,
          onStatusChanged: onStatusChanged,
          onClear: onClear,
        ),
      ),
    );
  }

  group('HomeFiltersBar Widget Tests', () {
    testWidgets('renders chips and notifies when tapped', (
      WidgetTester tester,
    ) async {
      ServiceType? changedService;
      PaymentStatusFilter? changedStatus;
      var cleared = false;

      await tester.pumpWidget(
        buildTestWidget(
          selectedService: null,
          selectedStatus: PaymentStatusFilter.all,
          hasActiveFilters: false,
          onServiceChanged: (type) => changedService = type,
          onStatusChanged: (status) => changedStatus = status,
          onClear: () => cleared = true,
        ),
      );

      // Verify presence of all status chips
      expect(find.byKey(const Key('filter_status_all')), findsOneWidget);
      expect(find.byKey(const Key('filter_status_pending')), findsOneWidget);
      expect(find.byKey(const Key('filter_status_paid')), findsOneWidget);

      // Tap pending filter
      await tester.tap(find.byKey(const Key('filter_status_pending')));
      expect(changedStatus, PaymentStatusFilter.pending);

      // Tap electricity filter
      await tester.tap(
        find.byKey(Key('filter_service_${ServiceType.electricity.name}')),
      );
      expect(changedService, ServiceType.electricity);

      // Clear button should not be present when hasActiveFilters is false
      expect(find.byKey(const Key('clear_filters_btn')), findsNothing);

      // Rebuild with active filters to verify clear button
      await tester.pumpWidget(
        buildTestWidget(
          selectedService: ServiceType.electricity,
          selectedStatus: PaymentStatusFilter.pending,
          hasActiveFilters: true,
          onServiceChanged: (type) => changedService = type,
          onStatusChanged: (status) => changedStatus = status,
          onClear: () => cleared = true,
        ),
      );

      expect(find.byKey(const Key('clear_filters_btn')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('clear_filters_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('clear_filters_btn')));
      expect(cleared, isTrue);
    });
  });
}
