import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/domain/models/service_type.dart';

/// Entrada que encapsula los controladores de un vecino individual.
class NeighborControllerEntry {
  final TextEditingController name;
  final TextEditingController amount;

  NeighborControllerEntry({String name = '', String amount = ''})
    : name = TextEditingController(text: name),
      amount = TextEditingController(text: amount);

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

/// ViewModel para la pantalla de adición/edición de facturas.
/// Gestiona controladores, reactividad, auto-distribución matemática y validación.
class AddBillViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ServiceBill? initialBill;

  late ServiceType _type;
  ServiceType get type => _type;

  late DateTime _date;
  DateTime get date => _date;

  final TextEditingController totalController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final List<NeighborControllerEntry> _neighbors = [];
  List<NeighborControllerEntry> get neighbors => List.unmodifiable(_neighbors);

  bool get isEditing => initialBill != null;

  AddBillViewModel({this.initialBill, DateTime? initialDate}) {
    if (initialBill != null) {
      _type = initialBill!.type;
      _date = initialDate ?? DateTime.now();
      totalController.text = initialBill!.totalAmount.toStringAsFixed(1);
      ownerController.text = initialBill!.ownerAmount.toStringAsFixed(1);
      for (final split in initialBill!.splits) {
        _neighbors.add(
          NeighborControllerEntry(
            name: split.name,
            amount: split.assignedAmount.toStringAsFixed(1),
          ),
        );
      }
    } else {
      _type = ServiceType.electricity;
      _date = initialDate ?? DateTime.now();
    }

    totalController.addListener(autoDistribute);
    ownerController.addListener(autoDistribute);
  }

  void setType(ServiceType newType) {
    if (_type != newType) {
      _type = newType;
      notifyListeners();
    }
  }

  void setDate(DateTime newDate) {
    _date = newDate;
    notifyListeners();
  }

  void addNeighbor({String name = ''}) {
    _neighbors.add(NeighborControllerEntry(name: name));
    autoDistribute();
    notifyListeners();
  }

  void removeNeighbor(int index) {
    if (index >= 0 && index < _neighbors.length) {
      _neighbors[index].dispose();
      _neighbors.removeAt(index);
      autoDistribute();
      notifyListeners();
    }
  }

  void autoDistribute() {
    final total = double.tryParse(totalController.text) ?? 0.0;
    final owner = double.tryParse(ownerController.text) ?? 0.0;
    final remainder = total - owner;
    final share = (_neighbors.isNotEmpty && remainder > 0)
        ? remainder / _neighbors.length
        : 0.0;

    for (final n in _neighbors) {
      n.amount.text = share.toStringAsFixed(1);
    }
  }

  bool submit({
    required void Function({
      required String monthId,
      required String monthName,
      required ServiceType type,
      required double totalAmount,
      required double ownerAmount,
      required List<NeighborSplit> splits,
    })
    onSave,
  }) {
    if (!formKey.currentState!.validate()) return false;

    final total = double.tryParse(totalController.text) ?? 0.0;
    final owner = double.tryParse(ownerController.text) ?? 0.0;
    final monthId = DateFormat('yyyy-MM').format(_date);
    final rawName = DateFormat('MMMM yyyy', 'es').format(_date);
    final monthName = rawName.isEmpty
        ? rawName
        : '${rawName[0].toUpperCase()}${rawName.substring(1)}';

    final splits = _neighbors.map((n) {
      final nameText = n.name.text.trim();
      final amount = double.tryParse(n.amount.text) ?? 0.0;
      return NeighborSplit(
        name: nameText.isEmpty ? 'Vecino' : nameText,
        assignedAmount: amount,
      );
    }).toList();

    onSave(
      monthId: monthId,
      monthName: monthName,
      type: _type,
      totalAmount: total,
      ownerAmount: owner,
      splits: splits,
    );

    return true;
  }

  @override
  void dispose() {
    totalController.dispose();
    ownerController.dispose();
    for (final n in _neighbors) {
      n.dispose();
    }
    super.dispose();
  }
}
