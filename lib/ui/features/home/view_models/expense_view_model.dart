import 'package:flutter/material.dart';
import '../../../../data/repositories/expense_repository.dart';
import '../../../../domain/models/service_type.dart';
import '../../../../domain/models/neighbor_split.dart';
import '../../../../domain/models/service_bill.dart';
import '../../../../domain/models/monthly_group.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseViewModel({required ExpenseRepository repository})
    : _repository = repository;

  List<MonthlyGroup> _groups = [];
  List<MonthlyGroup> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    _groups = await _repository.loadMonthlyGroups();

    // Sort groups by ID descending (latest month first)
    _groups.sort((a, b) => b.id.compareTo(a.id));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBill({
    required String monthId, // e.g. "2026-08"
    required String monthName, // e.g. "Agosto 2026"
    required ServiceType type,
    required double totalAmount,
    required double ownerAmount,
    required List<NeighborSplit> splits,
  }) async {
    final newBill = ServiceBill(
      id: '$monthId-${type.name}-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      totalAmount: totalAmount,
      ownerAmount: ownerAmount,
      splits: splits,
      isPaid: false,
    );

    // Find if the month group already exists
    final groupIndex = _groups.indexWhere((g) => g.id == monthId);

    if (groupIndex != -1) {
      final existingGroup = _groups[groupIndex];
      // Check if service already exists in this month to avoid duplicates (optional, or just add it)
      final updatedBills = List<ServiceBill>.from(existingGroup.bills)
        ..add(newBill);
      _groups[groupIndex] = existingGroup.copyWith(bills: updatedBills);
    } else {
      final newGroup = MonthlyGroup(
        id: monthId,
        monthName: monthName,
        bills: [newBill],
      );
      _groups.add(newGroup);
      _groups.sort((a, b) => b.id.compareTo(a.id));
    }

    await _repository.saveMonthlyGroups(_groups);
    notifyListeners();
  }

  Future<void> toggleBillPayment(String groupId, String billId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final billIndex = group.bills.indexWhere((b) => b.id == billId);
    if (billIndex == -1) return;

    final bill = group.bills[billIndex];
    final newPaidState = !bill.isPaid;

    // Update all splits to match the bill's state (either fully paid or unpaid)
    final updatedSplits = bill.splits.map((s) {
      return s.copyWith(
        isPaid: newPaidState,
        paidAmount: newPaidState ? s.assignedAmount : 0.0,
      );
    }).toList();

    final updatedBill = bill.copyWith(
      isPaid: newPaidState,
      splits: updatedSplits,
    );

    final updatedBills = List<ServiceBill>.from(group.bills);
    updatedBills[billIndex] = updatedBill;

    _groups[groupIndex] = group.copyWith(bills: updatedBills);
    await _repository.saveMonthlyGroups(_groups);
    notifyListeners();
  }

  Future<void> toggleNeighborPayment(
    String groupId,
    String billId,
    String neighborName,
  ) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final billIndex = group.bills.indexWhere((b) => b.id == billId);
    if (billIndex == -1) return;

    final bill = group.bills[billIndex];
    final updatedSplits = bill.splits.map((s) {
      if (s.name == neighborName) {
        final nextPaid = !s.isPaid;
        return s.copyWith(
          isPaid: nextPaid,
          paidAmount: nextPaid ? s.assignedAmount : 0.0,
        );
      }
      return s;
    }).toList();

    // Bill is fully paid if all splits are paid
    final allPaid = updatedSplits.every((s) => s.isPaid);

    final updatedBill = bill.copyWith(splits: updatedSplits, isPaid: allPaid);

    final updatedBills = List<ServiceBill>.from(group.bills);
    updatedBills[billIndex] = updatedBill;

    _groups[groupIndex] = group.copyWith(bills: updatedBills);
    await _repository.saveMonthlyGroups(_groups);
    notifyListeners();
  }

  Future<void> deleteBill(String groupId, String billId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final updatedBills = List<ServiceBill>.from(group.bills)
      ..removeWhere((b) => b.id == billId);

    if (updatedBills.isEmpty) {
      _groups.removeAt(groupIndex);
    } else {
      _groups[groupIndex] = group.copyWith(bills: updatedBills);
    }

    await _repository.saveMonthlyGroups(_groups);
    notifyListeners();
  }

  Future<void> updateBill({
    required String oldGroupId,
    required String newGroupId,
    required String newGroupName,
    required ServiceBill updatedBill,
  }) async {
    final oldGroupIndex = _groups.indexWhere((g) => g.id == oldGroupId);
    if (oldGroupIndex == -1) return;

    if (oldGroupId == newGroupId) {
      final group = _groups[oldGroupIndex];
      final billIndex = group.bills.indexWhere((b) => b.id == updatedBill.id);
      if (billIndex == -1) return;

      final updatedBills = List<ServiceBill>.from(group.bills);
      updatedBills[billIndex] = updatedBill;
      _groups[oldGroupIndex] = group.copyWith(bills: updatedBills);
    } else {
      final oldGroup = _groups[oldGroupIndex];
      final oldBills = List<ServiceBill>.from(oldGroup.bills)
        ..removeWhere((b) => b.id == updatedBill.id);

      if (oldBills.isEmpty) {
        _groups.removeAt(oldGroupIndex);
      } else {
        _groups[oldGroupIndex] = oldGroup.copyWith(bills: oldBills);
      }

      final newGroupIndex = _groups.indexWhere((g) => g.id == newGroupId);
      if (newGroupIndex != -1) {
        final newGroup = _groups[newGroupIndex];
        final newBills = List<ServiceBill>.from(newGroup.bills)
          ..add(updatedBill);
        _groups[newGroupIndex] = newGroup.copyWith(bills: newBills);
      } else {
        final newGroup = MonthlyGroup(
          id: newGroupId,
          monthName: newGroupName,
          bills: [updatedBill],
        );
        _groups.add(newGroup);
        _groups.sort((a, b) => b.id.compareTo(a.id));
      }
    }

    await _repository.saveMonthlyGroups(_groups);
    notifyListeners();
  }
}
