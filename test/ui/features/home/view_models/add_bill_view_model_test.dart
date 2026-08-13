import 'package:flutter_test/flutter_test.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/features/home/view_models/add_bill_view_model.dart';

void main() {
  late AddBillViewModel viewModel;

  setUp(() {
    viewModel = AddBillViewModel();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('AddBillViewModel - State & Properties', () {
    test('initializes with default values', () {
      expect(viewModel.type, ServiceType.electricity);
      expect(viewModel.totalController.text, isEmpty);
      expect(viewModel.ownerController.text, isEmpty);
      expect(viewModel.neighbors, isEmpty);
    });

    test('setType updates type and notifies listeners', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.setType(ServiceType.water);
      expect(viewModel.type, ServiceType.water);
      expect(notified, isTrue);
    });

    test('setDate updates date and notifies listeners', () {
      var notified = false;
      viewModel.addListener(() => notified = true);

      final newDate = DateTime(2026, 12, 1);
      viewModel.setDate(newDate);
      expect(viewModel.date, newDate);
      expect(notified, isTrue);
    });
  });

  group('AddBillViewModel - Neighbor Management & Auto-Distribution', () {
    test('adds and removes neighbors properly', () {
      viewModel.addNeighbor(name: 'Vecino 1');
      expect(viewModel.neighbors.length, 1);
      expect(viewModel.neighbors.first.name.text, 'Vecino 1');

      viewModel.addNeighbor(name: 'Vecino 2');
      expect(viewModel.neighbors.length, 2);

      viewModel.removeNeighbor(0);
      expect(viewModel.neighbors.length, 1);
      expect(viewModel.neighbors.first.name.text, 'Vecino 2');
    });

    test('auto-distributes remainder among neighbors accurately', () {
      viewModel.totalController.text = '300.0';
      viewModel.ownerController.text = '100.0';

      viewModel.addNeighbor(name: 'Vecino 1');
      viewModel.addNeighbor(name: 'Vecino 2');

      // Remainder = 300 - 100 = 200 / 2 = 100.0 each
      expect(viewModel.neighbors[0].amount.text, '100.0');
      expect(viewModel.neighbors[1].amount.text, '100.0');

      // Add third neighbor -> 200 / 3 = 66.7 each
      viewModel.addNeighbor(name: 'Vecino 3');
      expect(viewModel.neighbors[0].amount.text, '66.7');
      expect(viewModel.neighbors[1].amount.text, '66.7');
      expect(viewModel.neighbors[2].amount.text, '66.7');
    });
  });
}
