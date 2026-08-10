import 'service_bill.dart';

class MonthlyGroup {
  final String id; // e.g. "2026-08"
  final String monthName; // e.g. "Agosto 2026"
  final List<ServiceBill> bills;

  const MonthlyGroup({
    required this.id,
    required this.monthName,
    required this.bills,
  });

  double get totalAmount => bills.fold(0.0, (sum, bill) => sum + bill.totalAmount);
  double get ownerTotal => bills.fold(0.0, (sum, bill) => sum + bill.ownerAmount);
  
  // Total of all splits
  double get tenantTotal => bills.fold(0.0, (sum, bill) => sum + bill.totalSplitAssigned);

  bool get isPaid => bills.isNotEmpty && bills.every((bill) => bill.isPaid);

  MonthlyGroup copyWith({
    String? id,
    String? monthName,
    List<ServiceBill>? bills,
  }) {
    return MonthlyGroup(
      id: id ?? this.id,
      monthName: monthName ?? this.monthName,
      bills: bills ?? this.bills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthName': monthName,
      'bills': bills.map((e) => e.toJson()).toList(),
    };
  }

  factory MonthlyGroup.fromJson(Map<String, dynamic> json) {
    return MonthlyGroup(
      id: json['id'] as String,
      monthName: json['monthName'] as String,
      bills: (json['bills'] as List<dynamic>)
          .map((e) => ServiceBill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
