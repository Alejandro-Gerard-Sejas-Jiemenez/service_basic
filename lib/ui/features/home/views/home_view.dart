import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:basic_service/domain/models/monthly_group.dart';
import 'package:basic_service/domain/models/service_bill.dart';
import 'package:basic_service/ui/core/colors.dart';
import 'package:basic_service/ui/core/sizes.dart';
import 'package:basic_service/ui/core/strings.dart';
import '../services/bill_share_formatter.dart';
import '../view_models/add_bill_view_model.dart';
import '../view_models/expense_view_model.dart';
import 'add_bill_screen.dart';
import 'widgets/bill_item.dart';
import 'widgets/delete_bill_dialog.dart';
import 'widgets/home_filters_bar.dart';
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

  void _shareMonthlyGroup(BuildContext context, MonthlyGroup group) {
    final text = BillShareFormatter.formatGroupSummary(group);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.summaryCopied),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _showEditBill(BuildContext context, String groupId, ServiceBill bill) {
    final dateParts = groupId.split('-');
    final initialDate = dateParts.length >= 2
        ? DateTime(
            int.tryParse(dateParts[0]) ?? DateTime.now().year,
            int.tryParse(dateParts[1]) ?? DateTime.now().month,
          )
        : DateTime.now();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AddBillScreen(
          viewModel: AddBillViewModel(
            initialBill: bill,
            initialDate: initialDate,
          ),
          onSave:
              ({
                required monthId,
                required monthName,
                required type,
                required totalAmount,
                required ownerAmount,
                required splits,
              }) {
                final updated = bill.copyWith(
                  type: type,
                  totalAmount: totalAmount,
                  ownerAmount: ownerAmount,
                  splits: splits,
                );
                widget.viewModel.updateBill(
                  oldGroupId: groupId,
                  newGroupId: monthId,
                  newGroupName: monthName,
                  updatedBill: updated,
                );
                setState(() => _expandedGroups[monthId] = true);
              },
        ),
      ),
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
          final displayedGroups = widget.viewModel.filteredGroups;

          return Column(
            children: [
              const HomeHeader(),
              HomeFiltersBar(
                selectedService: widget.viewModel.selectedServiceFilter,
                selectedStatus: widget.viewModel.paymentStatusFilter,
                hasActiveFilters: widget.viewModel.hasActiveFilters,
                onServiceChanged: widget.viewModel.setServiceFilter,
                onStatusChanged: widget.viewModel.setPaymentStatusFilter,
                onClear: widget.viewModel.clearFilters,
              ),
              Expanded(
                child: widget.viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayedGroups.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            widget.viewModel.hasActiveFilters
                                ? AppStrings.noFilteredBillsFound
                                : AppStrings.noBillsFound,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          top: AppSpacing.xs,
                          bottom: 88,
                        ),
                        itemCount: displayedGroups.length,
                        itemBuilder: (context, index) {
                          final group = displayedGroups[index];
                          final isExpanded =
                              _expandedGroups[group.id] ??
                              widget.viewModel.hasActiveFilters;

                          return MonthlyGroupCard(
                            key: Key('month_card_${group.id}'),
                            group: group,
                            isExpanded: isExpanded,
                            onToggle: () => setState(
                              () => _expandedGroups[group.id] = !isExpanded,
                            ),
                            onShare: () => _shareMonthlyGroup(context, group),
                            billItemBuilder: (groupId, bill) => BillItem(
                              key: Key('bill_item_${bill.id}'),
                              bill: bill,
                              onTogglePayment: () => widget.viewModel
                                  .toggleBillPayment(groupId, bill.id),
                              onEdit: () =>
                                  _showEditBill(context, groupId, bill),
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
