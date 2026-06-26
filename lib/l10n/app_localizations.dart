import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'ProjectKu'**
  String get appTitle;

  /// The subtitle of the application
  ///
  /// In en, this message translates to:
  /// **'Freelancer Workspace'**
  String get appSubtitle;

  /// Status message showing Firebase sync is active
  ///
  /// In en, this message translates to:
  /// **'Firebase Sync Active in Real-Time'**
  String get syncStatus;

  /// Welcome heading on dashboard
  ///
  /// In en, this message translates to:
  /// **'Hello, Freelancer!'**
  String get welcomeTitle;

  /// Welcome subtitle on dashboard
  ///
  /// In en, this message translates to:
  /// **'Track project status and manage your finances.'**
  String get welcomeSubtitle;

  /// Search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search projects or clients...'**
  String get searchHint;

  /// Label for paid totals card
  ///
  /// In en, this message translates to:
  /// **'TOTAL PAID INCOME'**
  String get totalPaid;

  /// Verified badge label
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Label for unpaid total amount
  ///
  /// In en, this message translates to:
  /// **'Pending Invoices'**
  String get tagihanTertunda;

  /// Label for active projects count
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get proyekAktif;

  /// Number of projects label
  ///
  /// In en, this message translates to:
  /// **'{count} Projects'**
  String activeProjectsCount(int count);

  /// Heading of project list section
  ///
  /// In en, this message translates to:
  /// **'Projects List'**
  String get daftarProyek;

  /// Filter tab all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// Filter tab in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get tabInProgress;

  /// Filter tab completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tabCompleted;

  /// Title when no projects at all
  ///
  /// In en, this message translates to:
  /// **'Workspace is Empty'**
  String get workspaceEmptyTitle;

  /// Subtitle when no projects at all
  ///
  /// In en, this message translates to:
  /// **'Start managing your freelance business by adding your first project.'**
  String get workspaceEmptySubtitle;

  /// Title when completed filter yields nothing
  ///
  /// In en, this message translates to:
  /// **'No Completed Projects Yet'**
  String get filterEmptyCompletedTitle;

  /// Subtitle when completed filter yields nothing
  ///
  /// In en, this message translates to:
  /// **'Complete your projects to see them listed here.'**
  String get filterEmptyCompletedSubtitle;

  /// Title when in progress filter yields nothing
  ///
  /// In en, this message translates to:
  /// **'No Projects in Progress'**
  String get filterEmptyInProgressTitle;

  /// Subtitle when in progress filter yields nothing
  ///
  /// In en, this message translates to:
  /// **'All of your projects are completed or haven\'\'t started yet.'**
  String get filterEmptyInProgressSubtitle;

  /// Title when generic filter yields nothing
  ///
  /// In en, this message translates to:
  /// **'No Projects Found'**
  String get filterEmptyGenericTitle;

  /// Subtitle when generic filter yields nothing
  ///
  /// In en, this message translates to:
  /// **'No projects match your current filter or search criteria.'**
  String get filterEmptyGenericSubtitle;

  /// Remaining time when completed
  ///
  /// In en, this message translates to:
  /// **'Project is completed'**
  String get timeRemainingCompleted;

  /// Remaining days to due date
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String timeRemainingDays(int days);

  /// Remaining time when due date is today
  ///
  /// In en, this message translates to:
  /// **'Deadline is today'**
  String get timeRemainingToday;

  /// Time progress when completed
  ///
  /// In en, this message translates to:
  /// **'100% Completed'**
  String get timeProgressCompleted;

  /// Percentage of elapsed project time
  ///
  /// In en, this message translates to:
  /// **'{percentage}% Time'**
  String timeProgressPercent(int percentage);

  /// In Progress status badge label
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// Completed status badge label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// On Hold status badge label
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get statusOnHold;

  /// Paid payment badge label
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentPaid;

  /// Invoice sent payment badge label
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get paymentInvoiceSent;

  /// Unpaid payment badge label
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get paymentUnpaid;

  /// Overdue deadline badge label
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get overdueBadge;

  /// Title of delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Project?'**
  String get deleteTitle;

  /// Confirm message of delete dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete the project \"{name}\"?'**
  String deleteConfirm(String name);

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Message after successful deletion
  ///
  /// In en, this message translates to:
  /// **'Project \"{name}\" was successfully deleted.'**
  String deleteSuccess(String name);

  /// Title of sorting sheet
  ///
  /// In en, this message translates to:
  /// **'Sort Projects'**
  String get sortTitle;

  /// Subtitle of sorting sheet
  ///
  /// In en, this message translates to:
  /// **'Select criteria to arrange your project list.'**
  String get sortSubtitle;

  /// Sort option closest due date
  ///
  /// In en, this message translates to:
  /// **'Closest Due Date'**
  String get sortDueDate;

  /// Sort option highest budget
  ///
  /// In en, this message translates to:
  /// **'Highest Budget'**
  String get sortBudget;

  /// Sort option newest created
  ///
  /// In en, this message translates to:
  /// **'Newest Created'**
  String get sortCreatedAt;

  /// Form title to add project
  ///
  /// In en, this message translates to:
  /// **'Add New Project'**
  String get addProject;

  /// Main information section card header
  ///
  /// In en, this message translates to:
  /// **'Main Information'**
  String get informasiUtama;

  /// Status and finance section card header
  ///
  /// In en, this message translates to:
  /// **'Status & Finance'**
  String get statusKeuangan;

  /// Additional info section card header
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get informasiTambahan;

  /// Project name input field label
  ///
  /// In en, this message translates to:
  /// **'Project Name *'**
  String get projectNameLabel;

  /// Project name input field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Landing Page Design'**
  String get projectNameHint;

  /// Client name input field label
  ///
  /// In en, this message translates to:
  /// **'Client Name *'**
  String get clientNameLabel;

  /// Client name input field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Indotama Corp'**
  String get clientNameHint;

  /// Project budget input field label
  ///
  /// In en, this message translates to:
  /// **'Project Budget *'**
  String get projectBudgetLabel;

  /// Project budget input field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., 5000000'**
  String get projectBudgetHint;

  /// Due date picker field label
  ///
  /// In en, this message translates to:
  /// **'Due Date *'**
  String get dueDateLabel;

  /// Validation error when name is empty
  ///
  /// In en, this message translates to:
  /// **'Project name is required'**
  String get validationNameRequired;

  /// Validation error when client name is empty
  ///
  /// In en, this message translates to:
  /// **'Client name is required'**
  String get validationClientRequired;

  /// Validation error when budget is empty
  ///
  /// In en, this message translates to:
  /// **'Budget is required'**
  String get validationBudgetRequired;

  /// Validation error when budget is not valid number
  ///
  /// In en, this message translates to:
  /// **'Enter a valid budget amount'**
  String get validationBudgetInvalid;

  /// Status pengerjaan label
  ///
  /// In en, this message translates to:
  /// **'Project Status'**
  String get statusPengerjaan;

  /// Status pembayaran label
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get statusPembayaran;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Notes / Scope of Work'**
  String get descriptionLabel;

  /// Description field hint
  ///
  /// In en, this message translates to:
  /// **'Write project scope, figma links, or client instructions...'**
  String get descriptionHint;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save to Database'**
  String get saveToDatabase;

  /// Success message after saving new project
  ///
  /// In en, this message translates to:
  /// **'Project successfully saved to Cloud Firestore'**
  String get saveSuccess;

  /// Error message when saving project fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save to Firestore: {error}'**
  String saveError(String error);

  /// Title of detail screen
  ///
  /// In en, this message translates to:
  /// **'Project Detail'**
  String get projectDetail;

  /// Label of budget header in detail card
  ///
  /// In en, this message translates to:
  /// **'PROJECT BUDGET'**
  String get projectBudgetHeader;

  /// Quick status update button label
  ///
  /// In en, this message translates to:
  /// **'Quick Update Status'**
  String get quickUpdateStatus;

  /// Delete project button label
  ///
  /// In en, this message translates to:
  /// **'Delete Project'**
  String get deleteProjectBtn;

  /// Edit project info header
  ///
  /// In en, this message translates to:
  /// **'Edit Project Info'**
  String get editProjectInfo;

  /// Save changes button label
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Success message after saving changes
  ///
  /// In en, this message translates to:
  /// **'Project changes successfully saved'**
  String get saveChangesSuccess;

  /// Error message when failing to load project detail
  ///
  /// In en, this message translates to:
  /// **'Failed to load project details'**
  String get errorLoadDetail;

  /// Due date row label
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get tenggatWaktu;

  /// Time remaining row label
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get sisaWaktu;

  /// Project description card header
  ///
  /// In en, this message translates to:
  /// **'Project Description / Notes'**
  String get deskripsiProyek;

  /// Text when there are no project notes
  ///
  /// In en, this message translates to:
  /// **'No additional notes.'**
  String get noNotes;

  /// Quick status sheet title
  ///
  /// In en, this message translates to:
  /// **'Update Project Status'**
  String get quickUpdateSheetTitle;

  /// Quick status sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Quickly update work or payment status.'**
  String get quickUpdateSheetSubtitle;

  /// Remaining time when deadline has passed
  ///
  /// In en, this message translates to:
  /// **'Deadline has passed'**
  String get timeRemainingOverdue;

  /// Task checklist card header
  ///
  /// In en, this message translates to:
  /// **'Task Checklist / Milestones'**
  String get tugasChecklist;

  /// Add task button label
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get tambahTugas;

  /// Add task textfield hint
  ///
  /// In en, this message translates to:
  /// **'Write task title...'**
  String get tugasHint;

  /// Empty tasks list message
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Add your first task above!'**
  String get tugasKosong;

  /// Financial analytics section header
  ///
  /// In en, this message translates to:
  /// **'Financial Analytics'**
  String get analitikKeuangan;

  /// Income comparison title
  ///
  /// In en, this message translates to:
  /// **'Income Status'**
  String get perbandinganPendapatan;

  /// Bar chart title for monthly incomes
  ///
  /// In en, this message translates to:
  /// **'Paid Income: Last 6 Months'**
  String get pendapatan6Bulan;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
