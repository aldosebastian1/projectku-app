import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../controllers/project_controller.dart';
import '../../l10n/app_localizations.dart';

class ProjectAddView extends ConsumerStatefulWidget {
  const ProjectAddView({super.key});

  @override
  ConsumerState<ProjectAddView> createState() => _ProjectAddViewState();
}

class _ProjectAddViewState extends ConsumerState<ProjectAddView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _budgetController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context, WidgetRef ref, DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: AppTheme.backgroundColor,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textColorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != currentDate) {
      ref.read(projectAddControllerProvider.notifier).selectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectAddControllerProvider);
    final controller = ref.read(projectAddControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final localeStr = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addProject),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: AppTheme.errorColor, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x0CFFFFFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.informasiUtama,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.projectNameLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: l10n.projectNameHint,
                              prefixIcon: const Icon(Icons.work_outline_rounded, color: AppTheme.textColorSecondary, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? l10n.validationNameRequired : null,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.clientNameLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _clientController,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: l10n.clientNameHint,
                              prefixIcon: const Icon(Icons.person_pin_rounded, color: AppTheme.textColorSecondary, size: 20),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? l10n.validationClientRequired : null,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.projectBudgetLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                            decoration: InputDecoration(
                              hintText: l10n.projectBudgetHint,
                              prefixIcon: const Icon(Icons.wallet_rounded, color: AppTheme.textColorSecondary, size: 20),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return l10n.validationBudgetRequired;
                              final numVal = double.tryParse(val);
                              if (numVal == null || numVal <= 0) return l10n.validationBudgetInvalid;
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.dueDateLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDueDate(context, ref, state.dueDate),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1524),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0x0CFFFFFF)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor, size: 18),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('dd MMMM yyyy', localeStr).format(state.dueDate),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textColorPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textColorSecondary, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status & Parameters Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x0CFFFFFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.statusKeuangan,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.statusPengerjaan,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                          ),
                          const SizedBox(height: 8),
                          _buildChoiceSelector<String>(
                            currentValue: state.status,
                            options: const ['In Progress', 'Completed', 'On Hold'],
                            labelBuilder: (val) {
                              if (val == 'In Progress') return l10n.statusInProgress;
                              if (val == 'Completed') return l10n.statusCompleted;
                              return l10n.statusOnHold;
                            },
                            activeColorBuilder: (val) {
                              if (val == 'Completed') return AppTheme.secondaryColor;
                              if (val == 'In Progress') return AppTheme.primaryColor;
                              return AppTheme.accentColor;
                            },
                            onChanged: (val) => controller.selectStatus(val),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.statusPembayaran,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                          ),
                          const SizedBox(height: 8),
                          _buildChoiceSelector<String>(
                            currentValue: state.paymentStatus,
                            options: const ['Unpaid', 'Invoice Sent', 'Paid'],
                            labelBuilder: (val) {
                              if (val == 'Paid') return l10n.paymentPaid;
                              if (val == 'Invoice Sent') return l10n.paymentInvoiceSent;
                              return l10n.paymentUnpaid;
                            },
                            activeColorBuilder: (val) {
                              if (val == 'Paid') return AppTheme.secondaryColor;
                              if (val == 'Invoice Sent') return AppTheme.accentColor;
                              return AppTheme.errorColor;
                            },
                            onChanged: (val) => controller.selectPaymentStatus(val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Additional Description Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x0CFFFFFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.informasiTambahan,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),

                          Text(
                            l10n.descriptionLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descController,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, height: 1.4),
                            decoration: InputDecoration(
                              hintText: l10n.descriptionHint,
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final budget = double.tryParse(_budgetController.text) ?? 0.0;
                          final success = await controller.saveProject(
                            name: _nameController.text,
                            clientName: _clientController.text,
                            budget: budget,
                            description: _descController.text,
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.saveSuccess)),
                            );
                            context.pop();
                          }
                        }
                      },
                      child: Text(l10n.saveToDatabase),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChoiceSelector<T>({
    required T currentValue,
    required List<T> options,
    required String Function(T) labelBuilder,
    required Color Function(T) activeColorBuilder,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0CFFFFFF)),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == currentValue;
          final activeColor = activeColorBuilder(option);
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? activeColor.withValues(alpha: 0.3) : Colors.transparent,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  labelBuilder(option),
                  style: TextStyle(
                    color: isSelected ? activeColor : AppTheme.textColorSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
