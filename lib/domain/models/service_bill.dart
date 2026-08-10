import 'service_type.dart';
import 'neighbor_split.dart';

class ServiceBill {
  final String id;
  final ServiceType type;
  final double totalAmount;
  final double ownerAmount; // How much "Yo" pays
  final List<NeighborSplit> splits;
  final bool isPaid; // Overall status (e.g. if everything is cleared)

  const ServiceBill({
    required this.id,
    required this.type,
    required this.totalAmount,
    required this.ownerAmount,
    required this.splits,
    this.isPaid = false,
  });

  double get totalSplitAssigned => splits.fold(0.0, (sum, item) => sum + item.assignedAmount);

  ServiceBill copyWith({
    String? id,
    ServiceType? type,
    double? totalAmount,
    double? ownerAmount,
    List<NeighborSplit>? splits,
    bool? isPaid,
  }) {
    return ServiceBill(
      id: id ?? this.id,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      ownerAmount: ownerAmount ?? this.ownerAmount,
      splits: splits ?? this.splits,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'totalAmount': totalAmount,
      'ownerAmount': ownerAmount,
      'splits': splits.map((e) => e.toJson()).toList(),
      'isPaid': isPaid,
    };
  }

  factory ServiceBill.fromJson(Map<String, dynamic> json) {
    return ServiceBill(
      id: json['id'] as String,
      type: ServiceType.values.byName(json['type'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      ownerAmount: (json['ownerAmount'] as num).toDouble(),
      splits: (json['splits'] as List<dynamic>)
          .map((e) => NeighborSplit.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }
}
