import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

final projectFilterProvider = NotifierProvider<ProjectFilterNotifier, String>(() {
  return ProjectFilterNotifier();
});

enum ProjectSortOption {
  dueDateAsc,
  budgetDesc,
  createdAtDesc,
}

class ProjectSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

final projectSearchProvider = NotifierProvider<ProjectSearchNotifier, String>(() {
  return ProjectSearchNotifier();
});

class ProjectSortNotifier extends Notifier<ProjectSortOption> {
  @override
  ProjectSortOption build() => ProjectSortOption.createdAtDesc;

  void setSort(ProjectSortOption option) {
    state = option;
  }
}

final projectSortProvider = NotifierProvider<ProjectSortNotifier, ProjectSortOption>(() {
  return ProjectSortNotifier();
});

class ProjectListView extends ConsumerWidget {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final controller = ref.watch(projectListControllerProvider);
    final currentFilter = ref.watch(projectFilterProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  l10n.appSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textColorSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.syncStatus),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.bolt, color: AppTheme.secondaryColor, size: 24),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850), // Responsive Max Width for Large Screens
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

              final searchQuery = ref.watch(projectSearchProvider).trim().toLowerCase();
              final sortOption = ref.watch(projectSortProvider);

              // 1. Filter by status
              var processedProjects = projects.where((project) {
                if (currentFilter == 'In Progress') return project.status == 'In Progress';
                if (currentFilter == 'Completed') return project.status == 'Completed';
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
                  processedProjects.sort((a, b) => a.dueDate.compareTo(b.dueDate));
                  break;
                case ProjectSortOption.budgetDesc:
                  processedProjects.sort((a, b) => b.budget.compareTo(a.budget));
                  break;
                case ProjectSortOption.createdAtDesc:
                  processedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  break;
              }

              return _buildDashboardContent(context, projects, processedProjects, controller, ref, currentFilter);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.errorColor),
                    const SizedBox(height: 16),
                    Text(
                      'Koneksi Firebase Terganggu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add_rounded, size: 28),
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
            color: const Color(0xFF0F1524),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x0CFFFFFF)),
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: content,
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x0CFFFFFF)),
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

    for (var project in allProjects) {
      if (project.paymentStatus == 'Paid') {
        totalPaid += project.budget;
      } else {
        totalPending += project.budget;
      }

      if (project.status == 'In Progress') {
        activeCount++;
      }
    }

    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard Welcome Title using Headline Large
          Text(
            l10n.welcomeTitle,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.welcomeSubtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textColorSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // Search & Sort Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => ref.read(projectSearchProvider.notifier).setSearch(val),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.textColorSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F1524),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0x0CFFFFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0x0CFFFFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1524),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x0CFFFFFF)),
                  ),
                  child: const Icon(Icons.swap_vert_rounded, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Sleek Wallet-styled Metric Dashboard Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E2640), // Navy
                  Color(0xFF0F1524), // Charcoal black
                ],
              ),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalPaid,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textColorSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppTheme.secondaryColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            l10n.verified,
                            style: const TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  formatRupiah(totalPaid),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textColorPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0x0CFFFFFF), height: 1),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.tagihanTertunda,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(totalPending),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textColorPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: const Color(0x0CFFFFFF),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.proyekAktif,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.activeProjectsCount(activeCount),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
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
          const SizedBox(height: 24),

          // Custom Premium Segmented Filter Tab Bar
          _buildFilterBar(ref, currentFilter),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.daftarProyek,
                style: Theme.of(context).textTheme.headlineMedium, // Headline Medium for section headings
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
                  : (currentFilter == 'In Progress' ? l10n.filterEmptyInProgressTitle : l10n.filterEmptyGenericTitle),
              subtitle: currentFilter == 'Completed'
                  ? l10n.filterEmptyCompletedSubtitle
                  : (currentFilter == 'In Progress' ? l10n.filterEmptyInProgressSubtitle : l10n.filterEmptyGenericSubtitle),
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
        color: const Color(0xFF0F1524), // Darker background for contrast matching ui_documentation.md
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0CFFFFFF)),
      ),
      child: Row(
        children: [
          _buildFilterTab(ref, 'All', l10n.tabAll, currentFilter == 'All'),
          _buildFilterTab(ref, 'In Progress', l10n.tabInProgress, currentFilter == 'In Progress'),
          _buildFilterTab(ref, 'Completed', l10n.tabCompleted, currentFilter == 'Completed'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(WidgetRef ref, String filterKey, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(projectFilterProvider.notifier).setFilter(filterKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cardColor : Colors.transparent, // High contrast selected color
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0x0CFFFFFF) : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textColorSecondary,
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
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor(project.status);
    final paymentColor = _getPaymentColor(project.paymentStatus);
    final isOverdue = project.dueDate.isBefore(DateTime.now()) && project.status != 'Completed';

    // Calculate urgency percentage for progress indicator
    final totalDays = project.dueDate.difference(project.createdAt).inDays;
    final remainingDays = project.dueDate.difference(DateTime.now()).inDays;
    double timeProgress = 0.0;
    if (totalDays > 0) {
      timeProgress = ((totalDays - remainingDays) / totalDays).clamp(0.0, 1.0);
    } else {
      timeProgress = 1.0;
    }

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Hapus Proyek?', style: Theme.of(context).textTheme.titleLarge),
            content: Text('Apakah Anda yakin ingin menghapus proyek "${project.name}" secara permanen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal', style: TextStyle(color: AppTheme.textColorSecondary, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        controller.deleteProject(project.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Proyek "${project.name}" berhasil dihapus dari database')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x0CFFFFFF)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/detail/${project.id}'),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person_pin_rounded, size: 14, color: AppTheme.textColorSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  project.clientName,
                                  style: const TextStyle(
                                    color: AppTheme.textColorSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatRupiah(project.budget),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),

                // Custom Time Remaining Indicator / Progress Line (Always visible for consistency in size)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      project.status == 'Completed'
                          ? l10n.timeRemainingCompleted
                          : (remainingDays > 0 ? l10n.timeRemainingDays(remainingDays) : l10n.timeRemainingToday),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: project.status == 'Completed'
                            ? AppTheme.secondaryColor
                            : (isOverdue ? AppTheme.errorColor : AppTheme.textColorSecondary),
                      ),
                    ),
                    Text(
                      project.status == 'Completed' ? l10n.timeProgressCompleted : l10n.timeProgressPercent((timeProgress * 100).toInt()),
                      style: TextStyle(
                        fontSize: 10,
                        color: project.status == 'Completed' ? AppTheme.secondaryColor : AppTheme.textColorSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: project.status == 'Completed' ? 1.0 : timeProgress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFF0F1524),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      project.status == 'Completed'
                          ? AppTheme.secondaryColor
                          : (isOverdue
                              ? AppTheme.errorColor
                              : (remainingDays <= 3 ? AppTheme.accentColor : AppTheme.primaryColor)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                const Divider(height: 1, color: Color(0x0CFFFFFF)),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isOverdue ? AppTheme.errorColor : AppTheme.textColorSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(project.dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue ? FontWeight.w800 : FontWeight.w600,
                            color: isOverdue ? AppTheme.errorColor : AppTheme.textColorSecondary,
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
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    Row(
                      children: [
                        _buildBadge(
                          project.status == 'In Progress'
                              ? l10n.statusInProgress
                              : (project.status == 'Completed' ? l10n.statusCompleted : l10n.statusOnHold),
                          statusColor,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          project.paymentStatus == 'Paid'
                              ? l10n.paymentPaid
                              : (project.paymentStatus == 'Invoice Sent' ? l10n.paymentInvoiceSent : l10n.paymentUnpaid),
                          paymentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
          fontWeight: FontWeight.w800,
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
                    const Icon(Icons.sort_rounded, color: AppTheme.primaryColor, size: 24),
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
                  style: const TextStyle(fontSize: 13, color: AppTheme.textColorSecondary),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : const Color(0xFF0F1524),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.4) : const Color(0x0CFFFFFF),
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
                color: isSelected ? AppTheme.primaryColor : AppTheme.textColorPrimary,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
