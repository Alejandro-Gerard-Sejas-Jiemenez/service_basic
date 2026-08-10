import 'package:flutter/material.dart';
import '../../../../domain/models/service_type.dart';
import '../../../../domain/models/service_bill.dart';
import '../../../../domain/models/monthly_group.dart';
import '../../../core/colors.dart';
import '../../../core/sizes.dart';
import '../../../core/strings.dart';
import '../view_models/expense_view_model.dart';
import 'add_bill_screen.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  void _showAddBill(BuildContext context) {
    // skill: Navigator.push con MaterialPageRoute para pantallas completas
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddBillScreen(
          onSave: ({
            required monthId,
            required monthName,
            required type,
            required totalAmount,
            required ownerAmount,
            required splits,
          }) {
            widget.viewModel.addBill(
              monthId:     monthId,
              monthName:   monthName,
              type:        type,
              totalAmount: totalAmount,
              ownerAmount: ownerAmount,
              splits:      splits,
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
      // FAB: acción principal de crear (según flutter-ui skill)
      floatingActionButton: FloatingActionButton.extended(
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
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return Column(
            children: [
              // Premium Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60.0,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.headerBg,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.lg),
                    bottomRight: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appHeaderCategory,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.appHeaderTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.appHeaderSubtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Expense List
              Expanded(
                child: widget.viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : widget.viewModel.groups.isEmpty
                        ? const Center(child: Text(AppStrings.noBillsFound))
                        : ListView.builder(
                            // Padding inferior para que el FAB no tape el último ítem
                            padding: const EdgeInsets.only(
                              left:   AppSpacing.md,
                              right:  AppSpacing.md,
                              top:    AppSpacing.md,
                              bottom: 88, // altura FAB (56) + margen (32)
                            ),
                            itemCount: widget.viewModel.groups.length,
                            itemBuilder: (context, index) {
                              final group = widget.viewModel.groups[index];
                              final isExpanded = _expandedGroups[group.id] ?? false;
                              return _buildMonthlyGroupCard(group, isExpanded);
                            },
                          ),
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthlyGroupCard(MonthlyGroup group, bool isExpanded) {
    const Color monthBgExpanded  = Color(0xFF2D3A4A);
    const Color monthBgCollapsed = Color(0xFFECEFF4);
    const Color monthTextExp     = Colors.white;
    const Color monthSubTextExp  = Color(0xFFB0BEC5);
    const Color distPrimaryExp   = Colors.white;
    const Color distSecondaryExp = Color(0xFFCFD8DC);
    const Color distPrimaryColl  = Color(0xFF37474F);
    const Color distSecondaryColl= Color(0xFF607D8B);
    const double radius = 12.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER DEL MES: forma FIJA, siempre bordes redondeados completos ──
          // Este contenedor NUNCA cambia de forma, solo cambia el color de fondo
          GestureDetector(
            onTap: () => setState(() => _expandedGroups[group.id] = !isExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isExpanded ? monthBgExpanded : monthBgCollapsed,
                // Bordes siempre redondeados en los 4 vértices — NUNCA cambian
                borderRadius: BorderRadius.circular(radius),
                boxShadow: const [
                  BoxShadow(color: Color(0x18000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _buildPaymentCircleStyled(
                    group.isPaid,
                    size: 20,
                    paidColor: isExpanded ? const Color(0xFF90A4AE) : const Color(0xFF10B981),
                    unpaidColor: isExpanded ? monthSubTextExp : const Color(0xFF90A4AE),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.monthName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isExpanded ? monthTextExp : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${group.bills.length} servicios\nTotal: ${group.totalAmount.toStringAsFixed(1)} Bs',
                          style: TextStyle(
                            fontSize: 11,
                            color: isExpanded ? monthSubTextExp : AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Yo: ${group.ownerTotal.toStringAsFixed(1)} Bs',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isExpanded ? distPrimaryExp : distPrimaryColl,
                        ),
                      ),
                      Text(
                        group.bills.isEmpty
                            ? 'Vecina: 0.0 Bs'
                            : group.bills.first.splits.length == 1
                                ? 'Vecina: ${group.tenantTotal.toStringAsFixed(1)} Bs'
                                : 'Vecinos: ${group.tenantTotal.toStringAsFixed(1)} Bs',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isExpanded ? distSecondaryExp : distSecondaryColl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: isExpanded ? monthSubTextExp : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // ── LISTA: contenedor separado que se despliega DEBAJO del header ──
          // El header nunca cambia — la lista aparece/desaparece independientemente
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // Solo esquinas inferiores redondeadas (forma rectangular arriba)
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(radius),
                        bottomRight: Radius.circular(radius),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x12000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    // padding horizontal = lista más angosta que el header
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      // padding: zero elimina el espacio interno por defecto del ListView
                      padding: EdgeInsets.zero,
                      itemCount: group.bills.length,
                      itemBuilder: (context, index) {
                        final bill = group.bills[index];
                        return _buildBillItem(group.id, bill);
                      },
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }


  // Círculo de pago genérico (para items de factura)
  Widget _buildPaymentCircle(bool isPaid, {required double size}) {
    const Color emerald = Color(0xFF10B981);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPaid ? emerald.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: isPaid ? emerald : AppColors.textSecondary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: isPaid
          ? Icon(Icons.check, size: size * 0.55, color: emerald)
          : null,
    );
  }

  // Círculo de pago con colores personalizables (para el header del mes)
  Widget _buildPaymentCircleStyled(
    bool isPaid, {
    required double size,
    required Color paidColor,
    required Color unpaidColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPaid ? paidColor.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: isPaid ? paidColor : unpaidColor,
          width: 1.8,
        ),
      ),
      child: isPaid
          ? Icon(Icons.check, size: size * 0.55, color: paidColor)
          : null,
    );
  }

  Widget _buildBillItem(String groupId, ServiceBill bill) {
    Color iconColor;
    IconData iconData;

    switch (bill.type) {
      case ServiceType.water:
        iconColor = AppColors.water;
        iconData = Icons.water_drop;
        break;
      case ServiceType.electricity:
        iconColor = AppColors.electricity;
        iconData = Icons.flash_on;
        break;
      case ServiceType.gas:
        iconColor = AppColors.gas;
        iconData = Icons.local_fire_department;
        break;
      case ServiceType.internet:
        iconColor = AppColors.internet;
        iconData = Icons.wifi;
        break;
    }

    // Detalle de vecinos con salto de línea por cada uno
    final splitsDetail = bill.splits
        .map((s) => '${s.name}: ${s.assignedAmount.toStringAsFixed(1)} Bs')
        .join('\n');
    final detailText = 'Yo: ${bill.ownerAmount.toStringAsFixed(1)} Bs\n$splitsDetail';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
      decoration: const BoxDecoration(
        // Divisor coincide con el borde de la card (sin indent)
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Toggle de pago — skill: "Ensure 48×48 dp touch targets"
          GestureDetector(
            onTap: () => widget.viewModel.toggleBillPayment(groupId, bill.id),
            child: SizedBox(
              width:  48,
              height: 48,
              child: Center(
                child: _buildPaymentCircle(bill.isPaid, size: 26),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Nombre del servicio con ícono al mismo nivel + detalle abajo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono + nombre del servicio en la misma fila (mismo nivel que subtítulo)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      color: iconColor.withOpacity(bill.isPaid ? 0.4 : 1.0),
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    bill.isPaid
                        ? _struckText(
                            bill.type.displayName,
                            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            AppColors.textSecondary.withOpacity(0.6),
                          )
                        : Text(
                            bill.type.displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 3),
                // Detalle con salto de línea por vecino
                Text(
                  detailText,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Monto total (tachado exactamente centrado)
          bill.isPaid
              ? _struckText(
                  '${bill.totalAmount.toStringAsFixed(1)} Bs',
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  AppColors.textSecondary.withOpacity(0.5),
                )
              : Text(
                  '${bill.totalAmount.toStringAsFixed(1)} Bs',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

          // Botón eliminar — skill: "Ensure 48×48 dp touch targets"
          IconButton(
            key: const Key('delete_bill_btn'),
            icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade400),
            onPressed: () => _showDeleteConfirmation(groupId, bill.id),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
    );
  }

  /// Dibuja texto con una línea de tachado exactamente en el centro vertical,
  /// independiente de las métricas del font.
  Widget _struckText(String text, TextStyle style, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(text, style: style.copyWith(color: color)),
        Positioned.fill(
          child: Center(
            child: Container(
              height: 1.5,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(String groupId, String billId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteBillTitle),
        content: const Text(AppStrings.deleteBillConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.viewModel.deleteBill(groupId, billId);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.delete, style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

