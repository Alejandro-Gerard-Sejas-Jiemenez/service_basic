import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/data/repositories/expense_repository.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/features/home/view_models/expense_view_model.dart';
import 'package:basic_service/ui/features/home/views/metrics_screen.dart';

class MockExpenseRepository implements ExpenseRepository {
  List<MonthlyGroup> inMemoryData = [];

  @override
  Future<List<MonthlyGroup>> loadMonthlyGroups() async => inMemoryData;

  @override
  Future<void> saveMonthlyGroups(List<MonthlyGroup> groups) async {
    inMemoryData = groups;
  }
}

void main() {
  late MockExpenseRepository repository;
  late ExpenseViewModel viewModel;

  setUp(() {
    repository = MockExpenseRepository();
    viewModel = ExpenseViewModel(repository: repository);
  });

  Widget buildTestWidget() {
    return MaterialApp(home: MetricsScreen(viewModel: viewModel));
  }

  group('MetricsScreen Widget Tests', () {
    testWidgets('renders empty state when no expenses exist', (
      WidgetTester tester,
    ) async {
      await viewModel.loadExpenses();
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Métricas de Gastos'), findsOneWidget);
      expect(
        find.text('No hay datos suficientes para calcular métricas.'),
        findsOneWidget,
      );
    });

    testWidgets('renders KPI cards, progress bars and history accurately', (
      WidgetTester tester,
    ) async {
      repository.inMemoryData = [
        const MonthlyGroup(
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
          ],
        ),
      ];
      await viewModel.loadExpenses();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Acumulado'), findsOneWidget);
      expect(find.text('500.0 Bs'), findsAtLeastNWidgets(1));
      expect(find.text('Mi Parte'), findsOneWidget);
      expect(find.text('200.0 Bs'), findsOneWidget);
      expect(find.text('Vecinos'), findsOneWidget);
      expect(find.text('300.0 Bs'), findsOneWidget);
      expect(find.text('Promedio Mensual'), findsOneWidget);
      expect(find.text('500.0 Bs / mes'), findsOneWidget);
      expect(find.text('Distribución por Servicio'), findsOneWidget);
      expect(find.text('Historial por Mes'), findsOneWidget);

      // Verify back button
      expect(find.byKey(const Key('btn_back_metrics')), findsOneWidget);
    });
  });
}
