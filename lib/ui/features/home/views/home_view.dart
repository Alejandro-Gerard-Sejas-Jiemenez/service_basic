import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../core/strings.dart';
import '../view_models/expense_view_model.dart';
import 'add_bill_screen.dart';
import 'widgets/bill_item.dart';
import 'widgets/delete_bill_dialog.dart';
import 'widgets/home_header.dart';
import 'widgets/monthly_group_card.dart';

class HomeView extends StatefulWidget {
  final ExpenseViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadExpenses().then((_) {
      if (mounted && widget.viewModel.groups.isNotEmpty) {
        setState(() {
          _expandedGroups[widget.viewModel.groups.first.id] = true;
        });
      }
    });
  }

  void _showAddBill(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AddBillScreen(
          onSave:
              ({
                required monthId,
                required monthName,
                required type,
                required totalAmount,
                required ownerAmount,
                required splits,
              }) {
                widget.viewModel.addBill(
                  monthId: monthId,
                  monthName: monthName,
                  type: type,
                  totalAmount: totalAmount,
                  ownerAmount: ownerAmount,
                  splits: splits,
                );
                setState(() => _expandedGroups[monthId] = true);
              },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String groupId, String billId) {
    DeleteBillDialog.show(
      context,
      onConfirm: () => widget.viewModel.deleteBill(groupId, billId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Semantics(
        button: true,
        label: AppStrings.addBillButton,
        child: FloatingActionButton.extended(
          key: const Key('fab_add_bill'),
          onPressed: () => _showAddBill(context),
          backgroundColor: AppColors.headerBg,
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.add),
          label: const Text(
            AppStrings.addBillButton,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: widget.viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : widget.viewModel.groups.isEmpty
                    ? const Center(child: Text(AppStrings.noBillsFound))
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          top: AppSpacing.md,
                          bottom: 88,
                        ),
                        itemCount: widget.viewModel.groups.length,
                        itemBuilder: (context, index) {
                          final group = widget.viewModel.groups[index];
                          final isExpanded = _expandedGroups[group.id] ?? false;

                          return MonthlyGroupCard(
                            key: Key('month_card_${group.id}'),
                            group: group,
                            isExpanded: isExpanded,
                            onToggle: () => setState(
                              () => _expandedGroups[group.id] = !isExpanded,
                            ),
                            billItemBuilder: (groupId, bill) => BillItem(
                              key: Key('bill_item_${bill.id}'),
                              bill: bill,
                              onTogglePayment: () => widget.viewModel
                                  .toggleBillPayment(groupId, bill.id),
                              onDelete: () =>
                                  _showDeleteConfirmation(groupId, bill.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
