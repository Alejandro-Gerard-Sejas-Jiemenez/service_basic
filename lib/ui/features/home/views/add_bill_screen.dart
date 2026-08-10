import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/service_type.dart';
import '../../../../domain/models/neighbor_split.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../core/strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: selector de tipo de servicio
// (skill: "Extract widgets into separate widget classes")
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceTypeSelector extends StatelessWidget {
  final ServiceType selected;
  final ValueChanged<ServiceType> onChanged;

  const _ServiceTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  static const Map<ServiceType, _ServiceMeta> _meta = {
    ServiceType.water:       _ServiceMeta(color: AppColors.water,       icon: Icons.water_drop),
    ServiceType.electricity: _ServiceMeta(color: AppColors.electricity,  icon: Icons.flash_on),
    ServiceType.gas:         _ServiceMeta(color: AppColors.gas,          icon: Icons.local_fire_department),
    ServiceType.internet:    _ServiceMeta(color: AppColors.internet,     icon: Icons.wifi),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ServiceType.values.map((type) {
        final meta       = _meta[type]!;
        final isSelected = type == selected;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              key: Key('service_type_${type.name}'),
              onTap: () => onChanged(type),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? meta.color.withOpacity(0.13)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? meta.color : const Color(0xFFEEEEEE),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Icon(meta.icon,
                        color: isSelected ? meta.color : AppColors.textSecondary),
                    const SizedBox(height: 4),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected ? meta.color : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Helper class para metadata de servicio (evita hardcodear valores en el build)
class _ServiceMeta {
  final Color color;
  final IconData icon;
  const _ServiceMeta({required this.color, required this.icon});
}

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: selector de mes/año
// ─────────────────────────────────────────────────────────────────────────────
class _MonthYearPicker extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _MonthYearPicker({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy', 'es').format(date).toUpperCase();
    return InkWell(
      key: const Key('month_year_picker'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Icon(Icons.calendar_month, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extracted widget: fila de vecino (nombre + monto + eliminar)
// ─────────────────────────────────────────────────────────────────────────────
class _NeighborRow extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final bool canRemove;
  final VoidCallback onRemove;

  const _NeighborRow({
    required this.index,
    required this.nameController,
    required this.amountController,
    required this.canRemove,
    required this.onRemove,
  });

  static InputDecoration _deco({String? hint, String? suffix}) => InputDecoration(
        hintText: hint,
        suffixText: suffix,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              key: Key('neighbor_name_$index'),
              controller: nameController,
              decoration: _deco(hint: AppStrings.hintNeighborName),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              key: Key('neighbor_amount_$index'),
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _deco(hint: AppStrings.suffixBs, suffix: 'Bs'),
              validator: (val) {
                if (val == null || val.isEmpty) return AppStrings.valRequired;
                if (double.tryParse(val) == null) return AppStrings.valInvalid;
                return null;
              },
            ),
          ),
          if (canRemove)
            IconButton(
              key: Key('neighbor_remove_$index'),
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.redAccent),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla principal — Scaffold completo
// (skill: "Prefer full Scaffold screens over ModalBottomSheet for complex forms")
// ─────────────────────────────────────────────────────────────────────────────
class AddBillScreen extends StatefulWidget {
  final Function({
    required String monthId,
    required String monthName,
    required ServiceType type,
    required double totalAmount,
    required double ownerAmount,
    required List<NeighborSplit> splits,
  }) onSave;

  const AddBillScreen({super.key, required this.onSave});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey         = GlobalKey<FormState>();
  ServiceType _type      = ServiceType.electricity;
  DateTime    _date      = DateTime.now();

  final _totalController = TextEditingController();
  final _ownerController = TextEditingController();
  final List<Map<String, TextEditingController>> _neighbors = [];

  @override
  void initState() {
    super.initState();
    _addNeighbor(name: 'Vecina');
    _totalController.addListener(_autoDistribute);
    _ownerController.addListener(_autoDistribute);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _ownerController.dispose();
    for (final n in _neighbors) {
      n['name']!.dispose();
      n['amount']!.dispose();
    }
    super.dispose();
  }

  void _addNeighbor({String name = ''}) {
    setState(() {
      _neighbors.add({
        'name':   TextEditingController(text: name),
        'amount': TextEditingController(),
      });
    });
    _autoDistribute();
  }

  void _removeNeighbor(int i) {
    if (_neighbors.length <= 1) return;
    setState(() {
      _neighbors[i]['name']!.dispose();
      _neighbors[i]['amount']!.dispose();
      _neighbors.removeAt(i);
    });
    _autoDistribute();
  }

  void _autoDistribute() {
    final total     = double.tryParse(_totalController.text) ?? 0.0;
    final owner     = double.tryParse(_ownerController.text) ?? 0.0;
    final remainder = total - owner;
    final share     = (_neighbors.isNotEmpty && remainder > 0)
        ? remainder / _neighbors.length
        : 0.0;
    for (final n in _neighbors) {
      n['amount']!.text = share.toStringAsFixed(1);
    }
  }

  Future<void> _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: AppStrings.labelMonth,
    );
    // skill: "Check `mounted` before using `context` across async gaps"
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final total     = double.tryParse(_totalController.text) ?? 0.0;
    final owner     = double.tryParse(_ownerController.text) ?? 0.0;
    final monthId   = DateFormat('yyyy-MM').format(_date);
    final rawName   = DateFormat('MMMM yyyy', 'es').format(_date);
    final monthName = rawName.isEmpty
        ? rawName
        : '${rawName[0].toUpperCase()}${rawName.substring(1)}';

    final splits = _neighbors.map((n) {
      final name   = n['name']!.text.trim();
      final amount = double.tryParse(n['amount']!.text) ?? 0.0;
      return NeighborSplit(
        name: name.isEmpty ? 'Vecino' : name,
        assignedAmount: amount,
      );
    }).toList();

    widget.onSave(
      monthId:     monthId,
      monthName:   monthName,
      type:        _type,
      totalAmount: total,
      ownerAmount: owner,
      splits:      splits,
    );

    Navigator.pop(context);
  }

  static InputDecoration _fieldDeco({String? hint}) => InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      );

  // Etiqueta de sección — no es un _build*(), es un helper de estilo
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
      // Botones fijos fuera del scroll (skill: separar acciones del contenido)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('add_bill_cancel'),
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.headerBg),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: const Text(AppStrings.cancel,
                      style: TextStyle(color: AppColors.headerBg)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  key: const Key('add_bill_save'),
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.headerBg,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: const Text(AppStrings.save,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        // ListView para que el teclado no tape campos (skill: handle keyboard)
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // ── Tipo de servicio ──────────────────────────────────────────
            _label(context, AppStrings.labelService),
            const SizedBox(height: AppSpacing.sm),
            _ServiceTypeSelector(
              selected:  _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Mes / Año ─────────────────────────────────────────────────
            _label(context, AppStrings.labelMonth),
            const SizedBox(height: AppSpacing.sm),
            _MonthYearPicker(date: _date, onTap: _pickMonthYear),
            const SizedBox(height: AppSpacing.lg),

            // ── Monto total ───────────────────────────────────────────────
            _label(context, AppStrings.labelTotalAmount),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: const Key('total_amount_field'),
              controller: _totalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _fieldDeco(hint: AppStrings.hintTotalAmount),
              validator: (val) {
                if (val == null || val.isEmpty) return AppStrings.valRequired;
                if (double.tryParse(val) == null)
                  return AppStrings.valInvalidAmount;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Monto propietario ─────────────────────────────────────────
            _label(context, AppStrings.labelOwnerAmount),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: const Key('owner_amount_field'),
              controller: _ownerController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _fieldDeco(hint: AppStrings.hintOwnerAmount),
              validator: (val) {
                if (val == null || val.isEmpty) return AppStrings.valRequired;
                final ownerVal = double.tryParse(val);
                final totalVal =
                    double.tryParse(_totalController.text) ?? 0.0;
                if (ownerVal == null) return AppStrings.valInvalidAmount;
                if (ownerVal > totalVal) return AppStrings.valAmountTooHigh;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Vecinos ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label(context, AppStrings.labelNeighbors),
                TextButton.icon(
                  key: const Key('add_neighbor_btn'),
                  onPressed: _addNeighbor,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(AppStrings.addNeighborButton),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(
              _neighbors.length,
              (i) => _NeighborRow(
                index:            i,
                nameController:   _neighbors[i]['name']!,
                amountController: _neighbors[i]['amount']!,
                canRemove:        _neighbors.length > 1,
                onRemove:         () => _removeNeighbor(i),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
