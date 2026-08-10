import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/data/repositories/expense_repository.dart';
import 'package:basic_service/ui/features/home/view_models/expense_view_model.dart';

// A simple mock repository to avoid writing to SharedPreferences in tests
class MockExpenseRepository extends ExpenseRepository {
  List<MonthlyGroup> _mockGroups = [];

  @override
  Future<List<MonthlyGroup>> loadMonthlyGroups() async {
    return _mockGroups;
  }

  @override
  Future<void> saveMonthlyGroups(List<MonthlyGroup> groups) async {
    _mockGroups = groups;
  }
}

void main() {
  group('Expense Manager Tests', () {
    late MockExpenseRepository repository;
    late ExpenseViewModel viewModel;

    setUp(() {
      repository = MockExpenseRepository();
      viewModel = ExpenseViewModel(repository: repository);
    });

    test('Initial loading is empty', () async {
      await viewModel.loadExpenses();
      expect(viewModel.groups.isEmpty, true);
    });

    test('Add bill and calculate splits correctly', () async {
      await viewModel.loadExpenses();

      // Total 500 Bs, Owner pays 200 Bs, remainder 300 Bs split between 2 neighbors
      final splits = [
        const NeighborSplit(name: 'Vecina 1', assignedAmount: 150.0),
        const NeighborSplit(name: 'Vecina 2', assignedAmount: 150.0),
      ];

      await viewModel.addBill(
        monthId: '2026-08',
        monthName: 'Agosto 2026',
        type: ServiceType.electricity,
        totalAmount: 500.0,
        ownerAmount: 200.0,
        splits: splits,
      );

      expect(viewModel.groups.length, 1);
      final group = viewModel.groups.first;
      expect(group.monthName, 'Agosto 2026');
      expect(group.bills.length, 1);

      final bill = group.bills.first;
      expect(bill.totalAmount, 500.0);
      expect(bill.ownerAmount, 200.0);
      expect(bill.splits.length, 2);
      expect(bill.splits[0].assignedAmount, 150.0);
      expect(bill.splits[1].assignedAmount, 150.0);
      expect(bill.isPaid, false);
    });

    test('Toggle payment status updates splits and bill state', () async {
      await viewModel.loadExpenses();

      final splits = [
        const NeighborSplit(name: 'Vecina 1', assignedAmount: 100.0),
      ];

      await viewModel.addBill(
        monthId: '2026-08',
        monthName: 'Agosto 2026',
        type: ServiceType.water,
        totalAmount: 200.0,
        ownerAmount: 100.0,
        splits: splits,
      );

      final billId = viewModel.groups.first.bills.first.id;

      // Toggle bill payment to true
      await viewModel.toggleBillPayment('2026-08', billId);
      expect(viewModel.groups.first.bills.first.isPaid, true);
      expect(viewModel.groups.first.bills.first.splits.first.isPaid, true);
      expect(viewModel.groups.first.bills.first.splits.first.paidAmount, 100.0);

      // Toggle back to false
      await viewModel.toggleBillPayment('2026-08', billId);
      expect(viewModel.groups.first.bills.first.isPaid, false);
      expect(viewModel.groups.first.bills.first.splits.first.isPaid, false);
      expect(viewModel.groups.first.bills.first.splits.first.paidAmount, 0.0);
    });
  });
}
