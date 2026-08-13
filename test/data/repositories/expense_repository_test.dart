import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basic_service/data/repositories/expense_repository.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExpenseRepository repository;

  setUp(() {
    repository = ExpenseRepository();
  });

  group('ExpenseRepository - loadMonthlyGroups', () {
    test('returns mock data and saves it when storage is empty', () async {
      SharedPreferences.setMockInitialValues({});

      final groups = await repository.loadMonthlyGroups();

      expect(groups, isNotEmpty);
      expect(groups.length, 3);
      expect(groups[0].id, '2026-07');
      expect(groups[1].id, '2026-06');
      expect(groups[2].id, '2026-05');

      // Verify that initial mock data was written to storage
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString('monthly_groups');
      expect(storedJson, isNotNull);
      expect(storedJson, contains('2026-07'));
    });

    test('correctly decodes stored JSON into MonthlyGroup models', () async {
      const sampleJson = '''
      [
        {
          "id": "2026-08",
          "monthName": "Agosto 2026",
          "bills": [
            {
              "id": "2026-08-water",
              "type": "water",
              "totalAmount": 100.0,
              "ownerAmount": 50.0,
              "splits": [
                {
                  "name": "Vecina",
                  "assignedAmount": 50.0,
                  "isPaid": true,
                  "paidAmount": 50.0
                }
              ],
              "isPaid": true
            }
          ]
        }
      ]
      ''';

      SharedPreferences.setMockInitialValues({'monthly_groups': sampleJson});

      final groups = await repository.loadMonthlyGroups();

      expect(groups.length, 1);
      final group = groups.first;
      expect(group.id, '2026-08');
      expect(group.monthName, 'Agosto 2026');
      expect(group.bills.length, 1);
      final bill = group.bills.first;
      expect(bill.type, ServiceType.water);
      expect(bill.totalAmount, 100.0);
      expect(bill.ownerAmount, 50.0);
      expect(bill.isPaid, isTrue);
      expect(bill.splits.length, 1);
      expect(bill.splits.first.name, 'Vecina');
      expect(bill.splits.first.isPaid, isTrue);
    });

    test('returns fallback mock data when stored JSON is malformed', () async {
      SharedPreferences.setMockInitialValues({
        'monthly_groups': 'invalid-json-data-string',
      });

      final groups = await repository.loadMonthlyGroups();

      expect(groups, isNotEmpty);
      expect(groups.length, 3);
    });
  });

  group('ExpenseRepository - saveMonthlyGroups', () {
    test(
      'serializes and persists MonthlyGroup models to SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});

        final sampleGroups = [
          const MonthlyGroup(
            id: '2026-09',
            monthName: 'Septiembre 2026',
            bills: [
              ServiceBill(
                id: '2026-09-electricity',
                type: ServiceType.electricity,
                totalAmount: 300.0,
                ownerAmount: 100.0,
                splits: [
                  NeighborSplit(
                    name: 'Juan',
                    assignedAmount: 200.0,
                    isPaid: false,
                  ),
                ],
                isPaid: false,
              ),
            ],
          ),
        ];

        await repository.saveMonthlyGroups(sampleGroups);

        // Verify read-back via repository
        final loaded = await repository.loadMonthlyGroups();
        expect(loaded.length, 1);
        expect(loaded.first.id, '2026-09');
        expect(loaded.first.monthName, 'Septiembre 2026');
        expect(loaded.first.bills.first.type, ServiceType.electricity);
        expect(loaded.first.bills.first.totalAmount, 300.0);
        expect(loaded.first.bills.first.splits.first.name, 'Juan');
      },
    );
  });
}
