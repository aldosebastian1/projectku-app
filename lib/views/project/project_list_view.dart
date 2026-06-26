import '../widgets/custom_progress_bar.dart';
import '../widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../services/firestore_service.dart';
import '../../utils/theme.dart';
import '../../utils/format_rupiah.dart';
import '../../controllers/project_controller.dart';
import '../../models/project_model.dart';
import '../../l10n/app_localizations.dart';

// Riverpod notifier provider for active filter, conforming to MVC / Riverpod Notifier rule
class ProjectFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setFilter(String filter) {
    state = filter;
  }
}

final projectFilterProvider = NotifierProvider<ProjectFilterNotifier, String>(
  () {
    return ProjectFilterNotifier();
  },
);

enum ProjectSortOption { dueDateAsc, budgetDesc, createdAtDesc }

class ProjectSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

final projectSearchProvider = NotifierProvider<ProjectSearchNotifier, String>(
  () {
    return ProjectSearchNotifier();
  },
);

class ProjectSortNotifier extends Notifier<ProjectSortOption> {
  @override
  ProjectSortOption build() => ProjectSortOption.createdAtDesc;

  void setSort(ProjectSortOption option) {
    state = option;
  }
}

final projectSortProvider =
    NotifierProvider<ProjectSortNotifier, ProjectSortOption>(() {
      return ProjectSortNotifier();
    });

class ProjectListView extends ConsumerWidget {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final controller = ref.watch(projectListControllerProvider);
    final currentFilter = ref.watch(projectFilterProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentUser = authAsync.asData?.value;

    final projectsAsync = currentUser == null
        ? const AsyncValue<List<Project>>.loading()
        : ref.watch(projectsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Akun',
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authControllerProvider.notifier).signOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 12),
                    Text('Keluar'),
                  ],
                ),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ), // Responsive Max Width for Calm Workspace
          child: projectsAsync.when(
            data: (projects) {
              if (projects.isEmpty) {
                return _buildUnifiedEmptyState(
                  context: context,
                  icon: Icons.folder_open_rounded,
                  title: l10n.workspaceEmptyTitle,
                  subtitle: l10n.workspaceEmptySubtitle,
                  isFullScreen: true,
                );
              }

              final searchQuery = ref
                  .watch(projectSearchProvider)
                  .trim()
                  .toLowerCase();
              final sortOption = ref.watch(projectSortProvider);

              // 1. Filter by status
              var processedProjects = projects.where((project) {
                if (currentFilter == 'In Progress') {
                  return project.status == 'In Progress';
                }
                if (currentFilter == 'Completed') {
                  return project.status == 'Completed';
                }
                return true; // All
              }).toList();

              // 2. Filter by search query
              if (searchQuery.isNotEmpty) {
                processedProjects = processedProjects.where((project) {
                  return project.name.toLowerCase().contains(searchQuery) ||
                      project.clientName.toLowerCase().contains(searchQuery);
                }).toList();
              }

              // 3. Sort projects
              switch (sortOption) {
                case ProjectSortOption.dueDateAsc:
                  processedProjects.sort(
                    (a, b) => a.dueDate.compareTo(b.dueDate),
                  );
                  break;
                case ProjectSortOption.budgetDesc:
                  processedProjects.sort(
                    (a, b) => b.budget.compareTo(a.budget),
                  );
                  break;
                case ProjectSortOption.createdAtDesc:
                  processedProjects.sort(
                    (a, b) => b.createdAt.compareTo(a.createdAt),
                  );
                  break;
              }

              return _buildDashboardContent(
                context,
                projects,
                processedProjects,
                controller,
                ref,
                currentFilter,
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Koneksi Firebase Terganggu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => context.push('/add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Tambah Project',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isFullScreen = false,
  }) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDF3), // Light borderHighlightColor
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.borderHighlightColor),
          ),
          child: Icon(
            icon,
            size: 48,
            color: AppTheme.textColorSecondary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColorPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textColorSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (isFullScreen) {
      return Center(
        child: Padding(padding: const EdgeInsets.all(32.0), child: content),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderHighlightColor),
        ),
        child: content,
      );
    }
  }

  Widget _buildDashboardContent(
    BuildContext context,
    List<Project> allProjects,
    List<Project> filteredProjects,
    ProjectListController controller,
    WidgetRef ref,
    String currentFilter,
  ) {
    double totalPaid = 0.0;
    double totalPending = 0.0;
    int activeCount = 0;
    int totalTasksCount = 0;
    int completedTasksCount = 0;

    for (var project in allProjects) {
      if (project.paymentStatus == 'Paid') {
        totalPaid += project.budget;
      } else {
        totalPending += project.budget;
      }

      if (project.status == 'In Progress') {
        activeCount++;
      }

      totalTasksCount += project.tasks.length;
      completedTasksCount += project.tasks.where((t) => t.isCompleted).length;
    }

    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard Title
          Text(
            "Dashboard",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 30, // Calm Workspace clean display size
            ),
          ),
          const SizedBox(height: 24),
          // Search & Sort Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) =>
                      ref.read(projectSearchProvider.notifier).setSearch(val),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColorPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppTheme.textColorSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Sort Button
              InkWell(
                onTap: () => _showSortOptions(context, ref),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderHighlightColor),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Metric Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildMetricCard(
                title: l10n.totalPaid,
                value: formatRupiah(totalPaid),
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppTheme.secondaryColor,
              ),
              _buildMetricCard(
                title: l10n.tagihanTertunda,
                value: formatRupiah(totalPending),
                icon: Icons.hourglass_empty_rounded,
                iconColor: AppTheme.errorColor,
              ),
              _buildMetricCard(
                title: l10n.proyekAktif,
                value: l10n.activeProjectsCount(activeCount),
                icon: Icons.work_outline_rounded,
                iconColor: AppTheme.primaryColor,
              ),
              _buildMetricCard(
                title: "Tugas Selesai",
                value: "$completedTasksCount/$totalTasksCount",
                icon: Icons.playlist_add_check_rounded,
                iconColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Financial Analytics Card
          _buildFinancialAnalyticsCard(context, allProjects),
          const SizedBox(height: 24),

          // Custom Premium Segmented Filter Tab Bar
          _buildFilterBar(ref, currentFilter),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.daftarProyek,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium, // Headline Medium for section headings
              ),
              Text(
                l10n.activeProjectsCount(filteredProjects.length),
                style: const TextStyle(
                  color: AppTheme.textColorSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Projects List
          if (filteredProjects.isEmpty)
            _buildUnifiedEmptyState(
              context: context,
              icon: Icons.filter_list_off_rounded,
              title: currentFilter == 'Completed'
                  ? l10n.filterEmptyCompletedTitle
                  : (currentFilter == 'In Progress'
                        ? l10n.filterEmptyInProgressTitle
                        : l10n.filterEmptyGenericTitle),
              subtitle: currentFilter == 'Completed'
                  ? l10n.filterEmptyCompletedSubtitle
                  : (currentFilter == 'In Progress'
                        ? l10n.filterEmptyInProgressSubtitle
                        : l10n.filterEmptyGenericSubtitle),
              isFullScreen: false,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProjects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
                return _buildProjectCard(context, project, controller);
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFilterBar(WidgetRef ref, String currentFilter) {
    final l10n = AppLocalizations.of(ref.context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Segmented Control Background
        borderRadius: BorderRadius.circular(14), // Segmented Control Radius
        border: Border.all(color: AppTheme.borderHighlightColor),
      ),
      child: Row(
        children: [
          _buildFilterTab(ref, 'All', l10n.tabAll, currentFilter == 'All'),
          _buildFilterTab(
            ref,
            'In Progress',
            l10n.tabInProgress,
            currentFilter == 'In Progress',
          ),
          _buildFilterTab(
            ref,
            'Completed',
            l10n.tabCompleted,
            currentFilter == 'Completed',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    WidgetRef ref,
    String filterKey,
    String label,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            ref.read(projectFilterProvider.notifier).setFilter(filterKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.transparent, // Active White
            borderRadius: BorderRadius.circular(10), // Inner Radius
            border: Border.all(
              color: isSelected
                  ? AppTheme.borderHighlightColor
                  : Colors.transparent,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.03,
                      ), // Level 1 Elevation
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textColorSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    Project project,
    ProjectListController controller,
  ) {
    final isOverdue =
        project.dueDate.isBefore(DateTime.now()) &&
        project.status != 'Completed';
    final totalTasks = project.tasks.length;
    final completedTasks = project.tasks.where((t) => t.isCompleted).length;
    final double taskProgress = totalTasks > 0
        ? completedTasks / totalTasks
        : 0.0;

    final initials = project.name.isNotEmpty
        ? project.name[0].toUpperCase()
        : '?';

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.errorAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Hapus Proyek?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus proyek "${project.name}" secara permanen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: AppTheme.textColorSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        controller.deleteProject(project.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.elevatedSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/detail/${project.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.baseBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColorPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.clientName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textColorSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: project.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomProgressBar(
                          percentage: project.status == 'Completed'
                              ? 1.0
                              : taskProgress,
                          isOverdue: isOverdue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(project.status == 'Completed' ? 100 : taskProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColorPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final currentSort = ref.read(projectSortProvider);
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
                    const Icon(
                      Icons.sort_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.sortTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.sortSubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textColorSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSortOptionItem(
                  context: context,
                  ref: ref,
                  label: l10n.sortDueDate,
                  option: ProjectSortOption.dueDateAsc,
                  currentOption: currentSort,
                ),
                const SizedBox(height: 8),
                _buildSortOptionItem(
                  context: context,
                  ref: ref,
                  label: l10n.sortBudget,
                  option: ProjectSortOption.budgetDesc,
                  currentOption: currentSort,
                ),
                const SizedBox(height: 8),
                _buildSortOptionItem(
                  context: context,
                  ref: ref,
                  label: l10n.sortCreatedAt,
                  option: ProjectSortOption.createdAtDesc,
                  currentOption: currentSort,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOptionItem({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required ProjectSortOption option,
    required ProjectSortOption currentOption,
  }) {
    final isSelected = option == currentOption;
    return InkWell(
      onTap: () {
        ref.read(projectSortProvider.notifier).setSort(option);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.4)
                : AppTheme.borderHighlightColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textColorPrimary,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialAnalyticsCard(
    BuildContext context,
    List<Project> projects,
  ) {
    double totalPaid = 0.0;
    double totalPending = 0.0;
    int completedCount = 0;
    int activeCount = 0;

    for (var p in projects) {
      if (p.paymentStatus == 'Paid') {
        totalPaid += p.budget;
      } else {
        totalPending += p.budget;
      }
      if (p.status == 'Completed') {
        completedCount++;
      } else {
        activeCount++;
      }
    }
    final totalProject = projects.length;
    final double completionRate = totalProject > 0
        ? (completedCount / totalProject)
        : 0.0;

    return Column(
      children: [
        // Revenue Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.elevatedSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pendapatan Lunas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                  const Icon(
                    Icons.work_outline_rounded,
                    color: AppTheme.textColorSecondary,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatRupiah(totalPaid),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColorPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.warningAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tagihan Tertunda',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textColorSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatRupiah(totalPending),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColorPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Proyek Aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textColorSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$activeCount',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColorPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.elevatedSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Project',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColorPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Project',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColorSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalProject',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColorPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColorSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColorPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: completionRate,
                          strokeWidth: 6,
                          backgroundColor: AppTheme.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '${(completionRate * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderHighlightColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, size: 20, color: iconColor)],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textColorSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColorPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double paidPercentage;
  final double pendingPercentage;
  final double animationProgress;

  DonutChartPainter({
    required this.paidPercentage,
    required this.pendingPercentage,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 14.0;
    final double innerRadius = radius - strokeWidth;

    final paintPaid = Paint()
      ..color = AppTheme.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintPending = Paint()
      ..color = AppTheme.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintBackground = Paint()
      ..color = AppTheme.borderHighlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: innerRadius);

    canvas.drawArc(rect, 0, 2 * 3.14159265, false, paintBackground);

    if (paidPercentage == 0 && pendingPercentage == 0) {
      return;
    }

    final double totalPercentage = paidPercentage + pendingPercentage;
    final double paidAngle =
        (paidPercentage / totalPercentage) * 2 * 3.14159265 * animationProgress;
    final double pendingAngle =
        (pendingPercentage / totalPercentage) *
        2 *
        3.14159265 *
        animationProgress;

    double startAngle = -3.14159265 / 2;

    if (paidAngle > 0) {
      canvas.drawArc(rect, startAngle, paidAngle, false, paintPaid);
      startAngle += paidAngle;
    }

    if (pendingAngle > 0) {
      canvas.drawArc(rect, startAngle, pendingAngle, false, paintPending);
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.paidPercentage != paidPercentage ||
        oldDelegate.pendingPercentage != pendingPercentage ||
        oldDelegate.animationProgress != animationProgress;
  }
}
