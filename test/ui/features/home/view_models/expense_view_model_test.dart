import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/data/repositories/expense_repository.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/features/home/view_models/expense_view_model.dart';

class _FakeExpenseRepository extends ExpenseRepository {
  List<MonthlyGroup> inMemoryData = [];
  bool saveCalled = false;

  @override
  Future<List<MonthlyGroup>> loadMonthlyGroups() async {
    return List<MonthlyGroup>.from(inMemoryData);
  }

  @override
  Future<void> saveMonthlyGroups(List<MonthlyGroup> groups) async {
    saveCalled = true;
    inMemoryData = List<MonthlyGroup>.from(groups);
  }
}

void main() {
  late _FakeExpenseRepository repository;
  late ExpenseViewModel viewModel;

  setUp(() {
    repository = _FakeExpenseRepository();
    viewModel = ExpenseViewModel(repository: repository);
  });

  group('ExpenseViewModel - loadExpenses', () {
    test('loads and sorts groups in descending order', () async {
      repository.inMemoryData = [
        const MonthlyGroup(id: '2026-05', monthName: 'Mayo 2026', bills: []),
        const MonthlyGroup(id: '2026-07', monthName: 'Julio 2026', bills: []),
        const MonthlyGroup(id: '2026-06', monthName: 'Junio 2026', bills: []),
      ];

      var notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.loadExpenses();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.groups.length, 3);
      expect(viewModel.groups[0].id, '2026-07');
      expect(viewModel.groups[1].id, '2026-06');
      expect(viewModel.groups[2].id, '2026-05');
      expect(notifyCount, greaterThanOrEqualTo(2));
    });
  });

  group('ExpenseViewModel - addBill', () {
    test('creates a new group when month does not exist', () async {
      await viewModel.addBill(
        monthId: '2026-08',
        monthName: 'Agosto 2026',
        type: ServiceType.electricity,
        totalAmount: 250.0,
        ownerAmount: 150.0,
        splits: [
          const NeighborSplit(
            name: 'Carlos',
            assignedAmount: 100.0,
            isPaid: false,
          ),
        ],
      );

      expect(viewModel.groups.length, 1);
      final group = viewModel.groups.first;
      expect(group.id, '2026-08');
      expect(group.monthName, 'Agosto 2026');
      expect(group.bills.length, 1);
      expect(group.bills.first.type, ServiceType.electricity);
      expect(group.bills.first.totalAmount, 250.0);
      expect(repository.saveCalled, isTrue);
    });

    test('appends bill to existing month group', () async {
      repository.inMemoryData = [
        const MonthlyGroup(
          id: '2026-08',
          monthName: 'Agosto 2026',
          bills: [
            ServiceBill(
              id: '2026-08-water-1',
              type: ServiceType.water,
              totalAmount: 100.0,
              ownerAmount: 50.0,
              splits: [],
              isPaid: false,
            ),
          ],
        ),
      ];
      await viewModel.loadExpenses();

      await viewModel.addBill(
        monthId: '2026-08',
        monthName: 'Agosto 2026',
        type: ServiceType.gas,
        totalAmount: 80.0,
        ownerAmount: 40.0,
        splits: [],
      );

      expect(viewModel.groups.length, 1);
      final group = viewModel.groups.first;
      expect(group.bills.length, 2);
      expect(group.bills[0].type, ServiceType.water);
      expect(group.bills[1].type, ServiceType.gas);
    });
  });

  group('ExpenseViewModel - toggleBillPayment', () {
    test('toggles bill isPaid state and updates splits', () async {
      repository.inMemoryData = [
        const MonthlyGroup(
          id: '2026-08',
          monthName: 'Agosto 2026',
          bills: [
            ServiceBill(
              id: 'bill-1',
              type: ServiceType.water,
              totalAmount: 100.0,
              ownerAmount: 50.0,
              splits: [
                NeighborSplit(name: 'Ana', assignedAmount: 50.0, isPaid: false),
              ],
              isPaid: false,
            ),
          ],
        ),
      ];
      await viewModel.loadExpenses();

      // Toggle to paid
      await viewModel.toggleBillPayment('2026-08', 'bill-1');
      var bill = viewModel.groups.first.bills.first;
      expect(bill.isPaid, isTrue);
      expect(bill.splits.first.isPaid, isTrue);
      expect(bill.splits.first.paidAmount, 50.0);

      // Toggle back to unpaid
      await viewModel.toggleBillPayment('2026-08', 'bill-1');
      bill = viewModel.groups.first.bills.first;
      expect(bill.isPaid, isFalse);
      expect(bill.splits.first.isPaid, isFalse);
      expect(bill.splits.first.paidAmount, 0.0);
    });

    test('ignores non-existent group or bill ID', () async {
      repository.inMemoryData = [
        const MonthlyGroup(id: '2026-08', monthName: 'Agosto 2026', bills: []),
      ];
      await viewModel.loadExpenses();

      await viewModel.toggleBillPayment('non-existent', 'bill-1');
      await viewModel.toggleBillPayment('2026-08', 'non-existent');
      expect(viewModel.groups.length, 1);
    });
  });

  group('ExpenseViewModel - toggleNeighborPayment', () {
    test('toggles individual neighbor split and calculates allPaid', () async {
      repository.inMemoryData = [
        const MonthlyGroup(
          id: '2026-08',
          monthName: 'Agosto 2026',
          bills: [
            ServiceBill(
              id: 'bill-1',
              type: ServiceType.water,
              totalAmount: 150.0,
              ownerAmount: 50.0,
              splits: [
                NeighborSplit(name: 'Ana', assignedAmount: 50.0, isPaid: false),
                NeighborSplit(name: 'Bob', assignedAmount: 50.0, isPaid: false),
              ],
              isPaid: false,
            ),
          ],
        ),
      ];
      await viewModel.loadExpenses();

      // Pay Ana only -> bill still not fully paid
      await viewModel.toggleNeighborPayment('2026-08', 'bill-1', 'Ana');
      var bill = viewModel.groups.first.bills.first;
      expect(bill.splits.firstWhere((s) => s.name == 'Ana').isPaid, isTrue);
      expect(bill.splits.firstWhere((s) => s.name == 'Bob').isPaid, isFalse);
      expect(bill.isPaid, isFalse);

      // Pay Bob too -> bill becomes fully paid
      await viewModel.toggleNeighborPayment('2026-08', 'bill-1', 'Bob');
      bill = viewModel.groups.first.bills.first;
      expect(bill.splits.every((s) => s.isPaid), isTrue);
      expect(bill.isPaid, isTrue);
    });
  });

  group('ExpenseViewModel - deleteBill', () {
    test('removes bill and preserves group if bills remain', () async {
      repository.inMemoryData = [
        const MonthlyGroup(
          id: '2026-08',
          monthName: 'Agosto 2026',
          bills: [
            ServiceBill(
              id: 'bill-1',
              type: ServiceType.water,
              totalAmount: 100.0,
              ownerAmount: 50.0,
              splits: [],
              isPaid: false,
            ),
            ServiceBill(
              id: 'bill-2',
              type: ServiceType.gas,
              totalAmount: 80.0,
              ownerAmount: 40.0,
              splits: [],
              isPaid: false,
            ),
          ],
        ),
      ];
      await viewModel.loadExpenses();

      await viewModel.deleteBill('2026-08', 'bill-1');

      expect(viewModel.groups.length, 1);
      final group = viewModel.groups.first;
      expect(group.bills.length, 1);
      expect(group.bills.first.id, 'bill-2');
    });

    test('removes entire group when last bill is deleted', () async {
      repository.inMemoryData = [
        const MonthlyGroup(
          id: '2026-08',
          monthName: 'Agosto 2026',
          bills: [
            ServiceBill(
              id: 'bill-1',
              type: ServiceType.water,
              totalAmount: 100.0,
              ownerAmount: 50.0,
              splits: [],
              isPaid: false,
            ),
          ],
        ),
      ];
      await viewModel.loadExpenses();

      await viewModel.deleteBill('2026-08', 'bill-1');

      expect(viewModel.groups, isEmpty);
    });
  });

  group('ExpenseViewModel - updateBill', () {
    test('replaces bill in place when month remains the same', () async {
      repository.inMemoryData = [
        const MonthlyGroup(
          id: '2026-08',
          monthName: 'Agosto 2026',
          bills: [
            ServiceBill(
              id: 'bill-1',
              type: ServiceType.water,
              totalAmount: 100.0,
              ownerAmount: 50.0,
              splits: [],
              isPaid: false,
            ),
          ],
        ),
      ];
      await viewModel.loadExpenses();

      const updatedBill = ServiceBill(
        id: 'bill-1',
        type: ServiceType.electricity,
        totalAmount: 250.0,
        ownerAmount: 150.0,
        splits: [
          NeighborSplit(name: 'Vecino', assignedAmount: 100.0, isPaid: false),
        ],
        isPaid: false,
      );

      await viewModel.updateBill(
        oldGroupId: '2026-08',
        newGroupId: '2026-08',
        newGroupName: 'Agosto 2026',
        updatedBill: updatedBill,
      );

      expect(viewModel.groups.length, 1);
      final group = viewModel.groups.first;
      expect(group.bills.length, 1);
      expect(group.bills.first.type, ServiceType.electricity);
      expect(group.bills.first.totalAmount, 250.0);
      expect(group.bills.first.splits.length, 1);
    });

    test(
      'moves bill to another existing month group when month changes',
      () async {
        repository.inMemoryData = [
          const MonthlyGroup(
            id: '2026-08',
            monthName: 'Agosto 2026',
            bills: [
              ServiceBill(
                id: 'bill-1',
                type: ServiceType.water,
                totalAmount: 100.0,
                ownerAmount: 50.0,
                splits: [],
                isPaid: false,
              ),
              ServiceBill(
                id: 'bill-2',
                type: ServiceType.gas,
                totalAmount: 50.0,
                ownerAmount: 25.0,
                splits: [],
                isPaid: false,
              ),
            ],
          ),
          const MonthlyGroup(
            id: '2026-09',
            monthName: 'Septiembre 2026',
            bills: [],
          ),
        ];
        await viewModel.loadExpenses();

        const updatedBill = ServiceBill(
          id: 'bill-1',
          type: ServiceType.water,
          totalAmount: 120.0,
          ownerAmount: 60.0,
          splits: [],
          isPaid: false,
        );

        await viewModel.updateBill(
          oldGroupId: '2026-08',
          newGroupId: '2026-09',
          newGroupName: 'Septiembre 2026',
          updatedBill: updatedBill,
        );

        final aug = viewModel.groups.firstWhere((g) => g.id == '2026-08');
        final sep = viewModel.groups.firstWhere((g) => g.id == '2026-09');

        expect(aug.bills.length, 1);
        expect(aug.bills.first.id, 'bill-2');

        expect(sep.bills.length, 1);
        expect(sep.bills.first.id, 'bill-1');
        expect(sep.bills.first.totalAmount, 120.0);
      },
    );

    test(
      'creates new month group and removes empty old group when month changes',
      () async {
        repository.inMemoryData = [
          const MonthlyGroup(
            id: '2026-08',
            monthName: 'Agosto 2026',
            bills: [
              ServiceBill(
                id: 'bill-1',
                type: ServiceType.water,
                totalAmount: 100.0,
                ownerAmount: 50.0,
                splits: [],
                isPaid: false,
              ),
            ],
          ),
        ];
        await viewModel.loadExpenses();

        const updatedBill = ServiceBill(
          id: 'bill-1',
          type: ServiceType.water,
          totalAmount: 150.0,
          ownerAmount: 75.0,
          splits: [],
          isPaid: false,
        );

        await viewModel.updateBill(
          oldGroupId: '2026-08',
          newGroupId: '2026-10',
          newGroupName: 'Octubre 2026',
          updatedBill: updatedBill,
        );

        expect(viewModel.groups.length, 1);
        expect(viewModel.groups.first.id, '2026-10');
        expect(viewModel.groups.first.monthName, 'Octubre 2026');
        expect(viewModel.groups.first.bills.first.totalAmount, 150.0);
      },
    );
  });
}
