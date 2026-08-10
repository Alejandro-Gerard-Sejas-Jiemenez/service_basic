class NeighborSplit {
  final String name;
  final double assignedAmount;
  final double paidAmount;
  final bool isPaid;

  const NeighborSplit({
    required this.name,
    required this.assignedAmount,
    this.paidAmount = 0.0,
    this.isPaid = false,
  });

  NeighborSplit copyWith({
    String? name,
    double? assignedAmount,
    double? paidAmount,
    bool? isPaid,
  }) {
    return NeighborSplit(
      name: name ?? this.name,
      assignedAmount: assignedAmount ?? this.assignedAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'assignedAmount': assignedAmount,
      'paidAmount': paidAmount,
      'isPaid': isPaid,
    };
  }

  factory NeighborSplit.fromJson(Map<String, dynamic> json) {
    return NeighborSplit(
      name: json['name'] as String,
      assignedAmount: (json['assignedAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }
}
