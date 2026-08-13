import 'package:flutter/material.dart';
import 'package:basic_service/domain/models/neighbor_split.dart';
import 'package:basic_service/domain/models/service_type.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';
import '../view_models/add_bill_view_model.dart';
import 'widgets/add_bill_bottom_bar.dart';
import 'widgets/month_year_picker.dart';
import 'widgets/neighbor_row.dart';
import 'widgets/service_type_selector.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla de creación de factura — Scaffold limpio que delega en AddBillViewModel
// (skill: "Prefer full Scaffold screens over ModalBottomSheet for complex forms")
// ─────────────────────────────────────────────────────────────────────────────
class AddBillScreen extends StatefulWidget {
  final void Function({
    required String monthId,
    required String monthName,
    required ServiceType type,
    required double totalAmount,
    required double ownerAmount,
    required List<NeighborSplit> splits,
  })
  onSave;
  final AddBillViewModel? viewModel;

  const AddBillScreen({super.key, required this.onSave, this.viewModel});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  late final AddBillViewModel _viewModel;
  late final bool _isInternalViewModel;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else {
      _viewModel = AddBillViewModel();
      _isInternalViewModel = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: AppStrings.labelMonth,
    );
    if (picked != null && mounted) {
      _viewModel.setDate(picked);
    }
  }

  void _onSavePressed() {
    final success = _viewModel.submit(onSave: widget.onSave);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  static InputDecoration _fieldDeco({String? hint}) => InputDecoration(
    hintText: hint,
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
    ),
  );

  static Widget _label(BuildContext context, String text) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      letterSpacing: 0.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.headerBg,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              AppStrings.addBillTitle,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            leading: IconButton(
              key: const Key('add_bill_close'),
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          bottomNavigationBar: AddBillBottomBar(
            onCancel: () => Navigator.pop(context),
            onSave: _onSavePressed,
          ),
          body: Form(
            key: _viewModel.formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _label(context, AppStrings.labelService),
                const SizedBox(height: AppSpacing.sm),
                ServiceTypeSelector(
                  selected: _viewModel.type,
                  onChanged: _viewModel.setType,
                ),
                const SizedBox(height: AppSpacing.lg),
                _label(context, AppStrings.labelMonth),
                const SizedBox(height: AppSpacing.sm),
                MonthYearPicker(date: _viewModel.date, onTap: _pickMonthYear),
                const SizedBox(height: AppSpacing.lg),
                _label(context, AppStrings.labelTotalAmount),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  key: const Key('total_amount_field'),
                  controller: _viewModel.totalController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _fieldDeco(hint: AppStrings.hintTotalAmount),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppStrings.valRequired;
                    }
                    if (double.tryParse(val) == null) {
                      return AppStrings.valInvalidAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _label(context, AppStrings.labelOwnerAmount),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  key: const Key('owner_amount_field'),
                  controller: _viewModel.ownerController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _fieldDeco(hint: AppStrings.hintOwnerAmount),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppStrings.valRequired;
                    }
                    final ownerVal = double.tryParse(val);
                    final totalVal =
                        double.tryParse(_viewModel.totalController.text) ?? 0.0;
                    if (ownerVal == null) return AppStrings.valInvalidAmount;
                    if (ownerVal > totalVal) {
                      return 'No puede superar el total (${totalVal.toStringAsFixed(1)} Bs)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _label(context, AppStrings.labelNeighbors),
                    TextButton.icon(
                      key: const Key('add_neighbor_btn'),
                      onPressed: _viewModel.addNeighbor,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(AppStrings.addNeighborButton),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_viewModel.neighbors.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      'Sin vecinos — el total es completamente tuyo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ...List.generate(
                  _viewModel.neighbors.length,
                  (i) => NeighborRow(
                    index: i,
                    nameController: _viewModel.neighbors[i].name,
                    amountController: _viewModel.neighbors[i].amount,
                    totalAmount:
                        double.tryParse(_viewModel.totalController.text) ?? 0.0,
                    onRemove: () => _viewModel.removeNeighbor(i),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}
