import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../domain/models/service_type.dart';
import '../../../../../domain/models/neighbor_split.dart';
import '../../../../core/colors.dart';
import '../../../../core/sizes.dart';
import '../../../../core/strings.dart';

class AddBillSheet extends StatefulWidget {
  final Function({
    required String monthId,
    required String monthName,
    required ServiceType type,
    required double totalAmount,
    required double ownerAmount,
    required List<NeighborSplit> splits,
  }) onSave;

  const AddBillSheet({super.key, required this.onSave});

  @override
  State<AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends State<AddBillSheet> {
  final _formKey = GlobalKey<FormState>();
  
  ServiceType _selectedType = ServiceType.electricity;
  DateTime _selectedDate = DateTime.now();
  
  final _totalController = TextEditingController();
  final _ownerController = TextEditingController();
  
  // List of controllers and names for dynamic neighbors
  final List<Map<String, dynamic>> _neighbors = [];

  @override
  void initState() {
    super.initState();
    // Default to 1 neighbor "Vecina" as in prototype
    _addNeighbor(name: 'Vecina');
    
    _totalController.addListener(_autoDistribute);
    _ownerController.addListener(_autoDistribute);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _ownerController.dispose();
    for (var n in _neighbors) {
      n['controller'].dispose();
      n['nameController'].dispose();
    }
    super.dispose();
  }

  void _addNeighbor({String name = ''}) {
    final nameController = TextEditingController(text: name);
    final amountController = TextEditingController();
    
    setState(() {
      _neighbors.add({
        'nameController': nameController,
        'controller': amountController,
      });
    });
    _autoDistribute();
  }

  void _removeNeighbor(int index) {
    if (_neighbors.length <= 1) return; // Keep at least one
    
    setState(() {
      final removed = _neighbors.removeAt(index);
      removed['controller'].dispose();
      removed['nameController'].dispose();
    });
    _autoDistribute();
  }

  void _autoDistribute() {
    final total = double.tryParse(_totalController.text) ?? 0.0;
    final owner = double.tryParse(_ownerController.text) ?? 0.0;
    final remainder = total - owner;

    if (remainder > 0 && _neighbors.isNotEmpty) {
      final splitShare = remainder / _neighbors.length;
      for (var n in _neighbors) {
        n['controller'].text = splitShare.toStringAsFixed(1);
      }
    } else {
      for (var n in _neighbors) {
        n['controller'].text = '0.0';
      }
    }
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    // Show a date picker that allows picking month/year
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Selecciona el mes y año de la factura',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final total = double.tryParse(_totalController.text) ?? 0.0;
    final owner = double.tryParse(_ownerController.text) ?? 0.0;
    
    // Format monthId (e.g. 2026-08) and monthName (e.g. Agosto 2026)
    final monthId = DateFormat('yyyy-MM').format(_selectedDate);
    // Capitalize month name
    final rawMonthName = DateFormat('MMMM yyyy', 'es').format(_selectedDate);
    final monthName = rawMonthName.isNotEmpty 
        ? '${rawMonthName[0].toUpperCase()}${rawMonthName.substring(1)}'
        : rawMonthName;

    final List<NeighborSplit> splits = [];
    for (var n in _neighbors) {
      final name = n['nameController'].text.trim();
      final amount = double.tryParse(n['controller'].text) ?? 0.0;
      splits.add(NeighborSplit(
        name: name.isEmpty ? 'Vecino' : name,
        assignedAmount: amount,
      ));
    }

    widget.onSave(
      monthId: monthId,
      monthName: monthName,
      type: _selectedType,
      totalAmount: total,
      ownerAmount: owner,
      splits: splits,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.addBillTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Service Type Selector
              Text(AppStrings.labelService, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ServiceType.values.map((type) {
                  final isSelected = _selectedType == type;
                  Color activeColor;
                  IconData icon;

                  switch (type) {
                    case ServiceType.water:
                      activeColor = AppColors.water;
                      icon = Icons.water_drop;
                      break;
                    case ServiceType.electricity:
                      activeColor = AppColors.electricity;
                      icon = Icons.flash_on;
                      break;
                    case ServiceType.gas:
                      activeColor = AppColors.gas;
                      icon = Icons.local_fire_department;
                      break;
                    case ServiceType.internet:
                      activeColor = AppColors.internet;
                      icon = Icons.wifi;
                      break;
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedType = type),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? activeColor.withOpacity(0.15) : Colors.white,
                            border: Border.all(
                              color: isSelected ? activeColor : const Color(0xFFEEEEEE),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            children: [
                              Icon(icon, color: isSelected ? activeColor : AppColors.textSecondary),
                              const SizedBox(height: 4),
                              Text(
                                type.displayName,
                                style: TextStyle(
                                  color: isSelected ? activeColor : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date Picker Month
              Text(AppStrings.labelMonth, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () => _selectMonthYear(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy', 'es').format(_selectedDate).toUpperCase(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Icon(Icons.calendar_month, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Total Amount
              Text(AppStrings.labelTotalAmount, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _totalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: AppStrings.hintTotalAmount,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return AppStrings.valRequired;
                  if (double.tryParse(val) == null) return AppStrings.valInvalidAmount;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Owner Amount
              Text(AppStrings.labelOwnerAmount, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _ownerController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: AppStrings.hintOwnerAmount,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return AppStrings.valRequired;
                  final ownerVal = double.tryParse(val);
                  final totalVal = double.tryParse(_totalController.text) ?? 0.0;
                  if (ownerVal == null) return AppStrings.valInvalidAmount;
                  if (ownerVal > totalVal) return AppStrings.valAmountTooHigh;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Dynamic Neighbors List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.labelNeighbors, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
                  TextButton.icon(
                    onPressed: () => _addNeighbor(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(AppStrings.addNeighborButton),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...List.generate(_neighbors.length, (index) {
                final n = _neighbors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      // Name input
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: n['nameController'],
                          decoration: InputDecoration(
                            hintText: AppStrings.hintNeighborName,
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Amount input (usually read-only or customizable, let's keep editable but auto-split by default)
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: n['controller'],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: AppStrings.suffixBs,
                            suffixText: AppStrings.suffixBs,
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return AppStrings.valRequired;
                            if (double.tryParse(val) == null) return AppStrings.valInvalid;
                            return null;
                          },
                        ),
                      ),
                      // Remove button if more than 1
                      if (_neighbors.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () => _removeNeighbor(index),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.headerBg,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      child: const Text(AppStrings.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
