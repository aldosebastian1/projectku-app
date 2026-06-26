import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../utils/format_rupiah.dart';
import '../../controllers/project_controller.dart';
import '../../models/project_model.dart';
import '../../l10n/app_localizations.dart';

class ProjectDetailView extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectDetailView({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends ConsumerState<ProjectDetailView> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _clientController;
  late TextEditingController _budgetController;
  late TextEditingController _descController;
  late TextEditingController _taskController;
  DateTime? _selectedDueDate;
  String? _selectedStatus;
  String? _selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _clientController = TextEditingController();
    _budgetController = TextEditingController();
    _descController = TextEditingController();
    _taskController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _budgetController.dispose();
    _descController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _initFields(Project project) {
    _nameController.text = project.name;
    _clientController.text = project.clientName;
    _budgetController.text = project.budget.toStringAsFixed(0);
    _descController.text = project.description;
    _selectedDueDate ??= project.dueDate;
    _selectedStatus ??= project.status;
    _selectedPaymentStatus ??= project.paymentStatus;
  }

  Future<void> _selectDueDate(BuildContext context, DateTime currentDate) async {
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
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));
    final listController = ref.watch(projectListControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectDetail),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          projectAsync.when(
            data: (project) => IconButton(
              onPressed: () {
                if (_isEditing) {
                  setState(() {
                    _isEditing = false;
                    _selectedDueDate = null;
                    _selectedStatus = null;
                    _selectedPaymentStatus = null;
                  });
                } else {
                  _initFields(project);
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              icon: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: _isEditing ? AppTheme.errorColor : AppTheme.primaryColor,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: projectAsync.when(
        data: (project) {
          if (_isEditing) {
            _initFields(project);
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: _isEditing
                    ? _buildEditForm(context, project, listController)
                    : _buildDetailContent(context, project, listController),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadDetail,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Project project, ProjectListController listController) {
    final l10n = AppLocalizations.of(context)!;
    final localeStr = Localizations.localeOf(context).toString();
    final isOverdue = project.dueDate.isBefore(DateTime.now()) && project.status != 'Completed';
    final remainingDays = project.dueDate.difference(DateTime.now()).inDays;
    final statusColor = _getStatusColor(project.status);
    final paymentColor = _getPaymentColor(project.paymentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Section Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderHighlightColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_pin_rounded, size: 16, color: AppTheme.textColorSecondary),
                  const SizedBox(width: 8),
                  Text(
                    project.clientName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColorSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.projectBudgetHeader,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColorSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatRupiah(project.budget),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Info Grid Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderHighlightColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statusKeuangan,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                l10n.statusPengerjaan,
                _buildBadge(
                  project.status == 'In Progress'
                      ? l10n.statusInProgress
                      : (project.status == 'Completed' ? l10n.statusCompleted : l10n.statusOnHold),
                  statusColor,
                ),
              ),
              const Divider(color: AppTheme.borderHighlightColor, height: 24),
              _buildDetailRow(
                l10n.statusPembayaran,
                _buildBadge(
                  project.paymentStatus == 'Paid'
                      ? l10n.paymentPaid
                      : (project.paymentStatus == 'Invoice Sent' ? l10n.paymentInvoiceSent : l10n.paymentUnpaid),
                  paymentColor,
                ),
              ),
              const Divider(color: AppTheme.borderHighlightColor, height: 24),
              _buildDetailRow(
                l10n.tenggatWaktu,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isOverdue ? AppTheme.errorColor : AppTheme.textColorSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMMM yyyy', localeStr).format(project.dueDate),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isOverdue ? AppTheme.errorColor : AppTheme.textColorPrimary,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.overdueBadge,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const Divider(color: AppTheme.borderHighlightColor, height: 24),
              _buildDetailRow(
                l10n.sisaWaktu,
                Text(
                  project.status == 'Completed'
                      ? l10n.timeRemainingCompleted
                      : (remainingDays > 0 ? l10n.timeRemainingDays(remainingDays) : (remainingDays == 0 ? l10n.timeRemainingToday : l10n.timeRemainingOverdue)),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: project.status == 'Completed'
                        ? AppTheme.secondaryColor
                        : (isOverdue ? AppTheme.errorColor : AppTheme.textColorPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Description Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderHighlightColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deskripsiProyek,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                project.description.isNotEmpty ? project.description : l10n.noNotes,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: project.description.isNotEmpty
                          ? AppTheme.textColorPrimary
                          : AppTheme.textColorSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildTasksCard(context, project, listController),
        const SizedBox(height: 36),

        // Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showStatusQuickPicker(context, project, listController),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(l10n.quickUpdateStatus),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Text(l10n.deleteTitle, style: Theme.of(context).textTheme.titleLarge),
                content: Text(l10n.deleteConfirm(project.name)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textColorSecondary, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.delete, style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              await listController.deleteProject(project.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.deleteSuccess(project.name))),
                );
                context.pop();
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor.withValues(alpha: 0.12),
            foregroundColor: AppTheme.errorColor,
            elevation: 0,
            side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.3)),
          ),
          child: Text(l10n.deleteProjectBtn),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context, Project project, ProjectListController listController) {
    final l10n = AppLocalizations.of(context)!;
    final localeStr = Localizations.localeOf(context).toString();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.editProjectInfo,
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
                    prefixIcon: const Icon(Icons.work_outline_rounded, size: 20),
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
                    prefixIcon: const Icon(Icons.person_pin_rounded, size: 20),
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                  decoration: InputDecoration(
                    hintText: l10n.projectBudgetHint,
                    prefixIcon: const Icon(Icons.wallet_rounded, size: 20),
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
                  onTap: () => _selectDueDate(context, _selectedDueDate ?? project.dueDate),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderHighlightColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd MMMM yyyy', localeStr).format(_selectedDueDate ?? project.dueDate),
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

          // Status & Keuangan Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
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
                  currentValue: _selectedStatus ?? project.status,
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
                  onChanged: (val) => setState(() => _selectedStatus = val),
                ),
                const SizedBox(height: 20),

                Text(
                  l10n.statusPembayaran,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textColorSecondary),
                ),
                const SizedBox(height: 8),
                _buildChoiceSelector<String>(
                  currentValue: _selectedPaymentStatus ?? project.paymentStatus,
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
                  onChanged: (val) => setState(() => _selectedPaymentStatus = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Description Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
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
                final budget = double.tryParse(_budgetController.text) ?? project.budget;
                final updatedProject = project.copyWith(
                  name: _nameController.text.trim(),
                  clientName: _clientController.text.trim(),
                  budget: budget,
                  dueDate: _selectedDueDate ?? project.dueDate,
                  status: _selectedStatus ?? project.status,
                  paymentStatus: _selectedPaymentStatus ?? project.paymentStatus,
                  description: _descController.text.trim(),
                );

                await listController.updateProject(updatedProject);
                setState(() {
                  _isEditing = false;
                  _selectedDueDate = null;
                  _selectedStatus = null;
                  _selectedPaymentStatus = null;
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.saveChangesSuccess)),
                  );
                }
              }
            },
            child: Text(l10n.saveChanges),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textColorSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        valueWidget,
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.secondaryColor;
      case 'In Progress':
        return AppTheme.primaryColor;
      case 'On Hold':
        return AppTheme.accentColor;
      default:
        return AppTheme.textColorSecondary;
    }
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case 'Paid':
        return AppTheme.secondaryColor;
      case 'Invoice Sent':
        return AppTheme.accentColor;
      case 'Unpaid':
        return AppTheme.errorColor;
      default:
        return AppTheme.textColorSecondary;
    }
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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderHighlightColor),
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
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppTheme.borderHighlightColor : Colors.transparent,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labelBuilder(option),
                  style: TextStyle(
                    color: isSelected ? activeColor : AppTheme.textColorSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showStatusQuickPicker(
    BuildContext context,
    Project project,
    ProjectListController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      l10n.quickUpdateSheetTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.quickUpdateSheetSubtitle,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textColorSecondary),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.statusPengerjaan,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textColorSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusOption(
                      context,
                      l10n.statusInProgress,
                      project.status == 'In Progress',
                      AppTheme.primaryColor,
                      () {
                        controller.updateProjectStatus(project.id, 'In Progress');
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildStatusOption(
                      context,
                      l10n.statusCompleted,
                      project.status == 'Completed',
                      AppTheme.secondaryColor,
                      () {
                        controller.updateProjectStatus(project.id, 'Completed');
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildStatusOption(
                      context,
                      l10n.statusOnHold,
                      project.status == 'On Hold',
                      AppTheme.accentColor,
                      () {
                        controller.updateProjectStatus(project.id, 'On Hold');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.statusPembayaran,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textColorSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusOption(
                      context,
                      l10n.paymentUnpaid,
                      project.paymentStatus == 'Unpaid',
                      AppTheme.errorColor,
                      () {
                        controller.updatePaymentStatus(project.id, 'Unpaid');
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildStatusOption(
                      context,
                      l10n.paymentInvoiceSent,
                      project.paymentStatus == 'Invoice Sent',
                      AppTheme.accentColor,
                      () {
                        controller.updatePaymentStatus(project.id, 'Invoice Sent');
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildStatusOption(
                      context,
                      l10n.paymentPaid,
                      project.paymentStatus == 'Paid',
                      AppTheme.secondaryColor,
                      () {
                        controller.updatePaymentStatus(project.id, 'Paid');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String text,
    bool isSelected,
    Color activeColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.1)
                : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeColor.withValues(alpha: 0.4) : AppTheme.borderHighlightColor,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w600,
              color: isSelected ? activeColor : AppTheme.textColorPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksCard(
    BuildContext context,
    Project project,
    ProjectListController listController,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderHighlightColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.tugasChecklist,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (project.tasks.isNotEmpty)
                Text(
                  '${project.tasks.where((t) => t.isCompleted).length}/${project.tasks.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Add Task Input Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.tugasHint,
                    hintStyle: const TextStyle(color: AppTheme.textColorSecondary, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (val) async {
                    if (val.trim().isNotEmpty) {
                      final newTask = ProjectTask(title: val.trim());
                      final updatedTasks = List<ProjectTask>.from(project.tasks)..add(newTask);
                      await listController.updateProject(project.copyWith(tasks: updatedTasks));
                      _taskController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_taskController.text.trim().isNotEmpty) {
                    final newTask = ProjectTask(title: _taskController.text.trim());
                    final updatedTasks = List<ProjectTask>.from(project.tasks)..add(newTask);
                    await listController.updateProject(project.copyWith(tasks: updatedTasks));
                    _taskController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  minimumSize: Size.zero,
                ),
                child: Text(l10n.tambahTugas),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tasks List
          if (project.tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.tugasKosong,
                  style: const TextStyle(
                    color: AppTheme.textColorSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: project.tasks.length,
              separatorBuilder: (context, index) => const Divider(color: AppTheme.borderHighlightColor, height: 16),
              itemBuilder: (context, index) {
                final task = project.tasks[index];
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final updatedTasks = List<ProjectTask>.from(project.tasks);
                        updatedTasks[index] = task.copyWith(isCompleted: !task.isCompleted);
                        await listController.updateProject(project.copyWith(tasks: updatedTasks));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: task.isCompleted ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: task.isCompleted ? AppTheme.primaryColor : AppTheme.textColorSecondary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(Icons.check, size: 14, color: AppTheme.primaryColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: task.isCompleted ? AppTheme.textColorSecondary : AppTheme.textColorPrimary,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final updatedTasks = List<ProjectTask>.from(project.tasks)..removeAt(index);
                        await listController.updateProject(project.copyWith(tasks: updatedTasks));
                      },
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
