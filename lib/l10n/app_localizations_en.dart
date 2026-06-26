// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ProjectKu';

  @override
  String get appSubtitle => 'Freelancer Workspace';

  @override
  String get syncStatus => 'Firebase Sync Active in Real-Time';

  @override
  String get welcomeTitle => 'Hello, Freelancer!';

  @override
  String get welcomeSubtitle =>
      'Track project status and manage your finances.';

  @override
  String get searchHint => 'Search projects or clients...';

  @override
  String get totalPaid => 'TOTAL PAID INCOME';

  @override
  String get verified => 'Verified';

  @override
  String get tagihanTertunda => 'Pending Invoices';

  @override
  String get proyekAktif => 'Active Projects';

  @override
  String activeProjectsCount(int count) {
    return '$count Projects';
  }

  @override
  String get daftarProyek => 'Projects List';

  @override
  String get tabAll => 'All';

  @override
  String get tabInProgress => 'In Progress';

  @override
  String get tabCompleted => 'Completed';

  @override
  String get workspaceEmptyTitle => 'Workspace is Empty';

  @override
  String get workspaceEmptySubtitle =>
      'Start managing your freelance business by adding your first project.';

  @override
  String get filterEmptyCompletedTitle => 'No Completed Projects Yet';

  @override
  String get filterEmptyCompletedSubtitle =>
      'Complete your projects to see them listed here.';

  @override
  String get filterEmptyInProgressTitle => 'No Projects in Progress';

  @override
  String get filterEmptyInProgressSubtitle =>
      'All of your projects are completed or haven\'t started yet.';

  @override
  String get filterEmptyGenericTitle => 'No Projects Found';

  @override
  String get filterEmptyGenericSubtitle =>
      'No projects match your current filter or search criteria.';

  @override
  String get timeRemainingCompleted => 'Project is completed';

  @override
  String timeRemainingDays(int days) {
    return '$days days remaining';
  }

  @override
  String get timeRemainingToday => 'Deadline is today';

  @override
  String get timeProgressCompleted => '100% Completed';

  @override
  String timeProgressPercent(int percentage) {
    return '$percentage% Time';
  }

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusOnHold => 'On Hold';

  @override
  String get paymentPaid => 'Paid';

  @override
  String get paymentInvoiceSent => 'Invoice';

  @override
  String get paymentUnpaid => 'Unpaid';

  @override
  String get overdueBadge => 'OVERDUE';

  @override
  String get deleteTitle => 'Delete Project?';

  @override
  String deleteConfirm(String name) {
    return 'Are you sure you want to permanently delete the project \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String deleteSuccess(String name) {
    return 'Project \"$name\" was successfully deleted.';
  }

  @override
  String get sortTitle => 'Sort Projects';

  @override
  String get sortSubtitle => 'Select criteria to arrange your project list.';

  @override
  String get sortDueDate => 'Closest Due Date';

  @override
  String get sortBudget => 'Highest Budget';

  @override
  String get sortCreatedAt => 'Newest Created';

  @override
  String get addProject => 'Add New Project';

  @override
  String get informasiUtama => 'Main Information';

  @override
  String get statusKeuangan => 'Status & Finance';

  @override
  String get informasiTambahan => 'Additional Information';

  @override
  String get projectNameLabel => 'Project Name *';

  @override
  String get projectNameHint => 'e.g., Landing Page Design';

  @override
  String get clientNameLabel => 'Client Name *';

  @override
  String get clientNameHint => 'e.g., Indotama Corp';

  @override
  String get projectBudgetLabel => 'Project Budget *';

  @override
  String get projectBudgetHint => 'e.g., 5000000';

  @override
  String get dueDateLabel => 'Due Date *';

  @override
  String get validationNameRequired => 'Project name is required';

  @override
  String get validationClientRequired => 'Client name is required';

  @override
  String get validationBudgetRequired => 'Budget is required';

  @override
  String get validationBudgetInvalid => 'Enter a valid budget amount';

  @override
  String get statusPengerjaan => 'Project Status';

  @override
  String get statusPembayaran => 'Payment Status';

  @override
  String get descriptionLabel => 'Notes / Scope of Work';

  @override
  String get descriptionHint =>
      'Write project scope, figma links, or client instructions...';

  @override
  String get saveToDatabase => 'Save to Database';

  @override
  String get saveSuccess => 'Project successfully saved to Cloud Firestore';

  @override
  String saveError(String error) {
    return 'Failed to save to Firestore: $error';
  }

  @override
  String get projectDetail => 'Project Detail';

  @override
  String get projectBudgetHeader => 'PROJECT BUDGET';

  @override
  String get quickUpdateStatus => 'Quick Update Status';

  @override
  String get deleteProjectBtn => 'Delete Project';

  @override
  String get editProjectInfo => 'Edit Project Info';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveChangesSuccess => 'Project changes successfully saved';

  @override
  String get errorLoadDetail => 'Failed to load project details';

  @override
  String get tenggatWaktu => 'Due Date';

  @override
  String get sisaWaktu => 'Time Remaining';

  @override
  String get deskripsiProyek => 'Project Description / Notes';

  @override
  String get noNotes => 'No additional notes.';

  @override
  String get quickUpdateSheetTitle => 'Update Project Status';

  @override
  String get quickUpdateSheetSubtitle =>
      'Quickly update work or payment status.';

  @override
  String get timeRemainingOverdue => 'Deadline has passed';

  @override
  String get tugasChecklist => 'Task Checklist / Milestones';

  @override
  String get tambahTugas => 'Add Task';

  @override
  String get tugasHint => 'Write task title...';

  @override
  String get tugasKosong => 'No tasks yet. Add your first task above!';
}
