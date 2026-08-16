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
    testWidgets(
      'renders status and service dropdowns and notifies when selected',
      (WidgetTester tester) async {
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

        // Verify presence of status & service dropdown triggers
        expect(find.byKey(const Key('filter_status_dropdown')), findsOneWidget);
        expect(
          find.byKey(const Key('filter_service_dropdown')),
          findsOneWidget,
        );

        // Open status dropdown and select pending
        await tester.tap(find.byKey(const Key('filter_status_dropdown')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('filter_status_pending')), findsOneWidget);
        await tester.tap(find.byKey(const Key('filter_status_pending')));
        await tester.pumpAndSettle();

        expect(changedStatus, PaymentStatusFilter.pending);

        // Open service dropdown and select electricity
        await tester.tap(find.byKey(const Key('filter_service_dropdown')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(Key('filter_service_${ServiceType.electricity.name}')),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(Key('filter_service_${ServiceType.electricity.name}')),
        );
        await tester.pumpAndSettle();

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
        await tester.tap(find.byKey(const Key('clear_filters_btn')));
        expect(cleared, isTrue);
      },
    );
  });
}
