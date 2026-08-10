import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/service_type.dart';
import '../../domain/models/neighbor_split.dart';
import '../../domain/models/service_bill.dart';
import '../../domain/models/monthly_group.dart';

class ExpenseRepository {
  static const String _storageKey = 'monthly_groups';

  Future<List<MonthlyGroup>> loadMonthlyGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);

    if (jsonStr == null) {
      // First launch: generate prototype mock data
      final initialData = _generateMockData();
      await saveMonthlyGroups(initialData);
      return initialData;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => MonthlyGroup.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback in case of parse error
      return _generateMockData();
    }
  }

  Future<void> saveMonthlyGroups(List<MonthlyGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(groups.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  List<MonthlyGroup> _generateMockData() {
    return [
      MonthlyGroup(
        id: '2026-07',
        monthName: 'Julio 2026',
        bills: [
          const ServiceBill(
            id: '2026-07-agua',
            type: ServiceType.water,
            totalAmount: 115.0,
            ownerAmount: 57.5,
            splits: [
              NeighborSplit(name: 'Vecina', assignedAmount: 57.5, isPaid: false),
            ],
            isPaid: false,
          ),
          const ServiceBill(
            id: '2026-07-luz',
            type: ServiceType.electricity,
            totalAmount: 528.0,
            ownerAmount: 200.0,
            splits: [
              NeighborSplit(name: 'Vecina', assignedAmount: 328.0, isPaid: false),
            ],
            isPaid: false,
          ),
        ],
      ),
      MonthlyGroup(
        id: '2026-06',
        monthName: 'Junio 2026',
        bills: [
          const ServiceBill(
            id: '2026-06-agua',
            type: ServiceType.water,
            totalAmount: 153.0,
            ownerAmount: 76.5,
            splits: [
              NeighborSplit(name: 'Vecina', assignedAmount: 76.5, isPaid: false),
            ],
            isPaid: false,
          ),
          const ServiceBill(
            id: '2026-06-luz',
            type: ServiceType.electricity,
            totalAmount: 478.0,
            ownerAmount: 200.0,
            splits: [
              NeighborSplit(name: 'Vecina', assignedAmount: 278.0, isPaid: false),
            ],
            isPaid: false,
          ),
        ],
      ),
      MonthlyGroup(
        id: '2026-05',
        monthName: 'Mayo 2026',
        bills: [
          const ServiceBill(
            id: '2026-05-agua',
            type: ServiceType.water,
            totalAmount: 125.0,
            ownerAmount: 62.5,
            splits: [
              NeighborSplit(name: 'Vecina', assignedAmount: 62.5, isPaid: true, paidAmount: 62.5),
            ],
            isPaid: true,
          ),
          const ServiceBill(
            id: '2026-05-luz',
            type: ServiceType.electricity,
            totalAmount: 533.0,
            ownerAmount: 200.0,
            splits: [
              NeighborSplit(name: 'Vecina', assignedAmount: 333.0, isPaid: true, paidAmount: 333.0),
            ],
            isPaid: true,
          ),
        ],
      ),
    ];
  }
}
