import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/domain/university_defaults.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/layout/shell_overlay_padding.dart';
import 'package:campusiq/core/providers/connectivity_provider.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/domain/home_setup_state.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';
import 'package:campusiq/features/plan/presentation/providers/home_setup_provider.dart';
import 'package:campusiq/features/plan/presentation/widgets/add_manual_task_sheet.dart';
import 'package:campusiq/features/plan/presentation/widgets/initial_home_welcome.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_progress_bar.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_task_tile.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final _drawerUniversityProvider = StreamProvider<University?>((ref) async* {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) {
    yield null;
    return;
  }

  await for (final prefs in repo.watchPrefs()) {
    final universityName = prefs?.universityName;
    yield universityName == null ? null : universityByName(universityName);
  }
});

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  static const double _homeCompactSectionGap = AppSpacing.lg;

  bool _isGenerating = false;
  List<DailyPlanTaskModel> _lastVisibleTasks = const [];
  bool? _showFirstWelcome;
  bool _initialWelcomeRecorded = false;
  bool? _wasInitialHomeSetup;

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      ref.invalidate(generatePlanProvider(today));
      await ref.read(generatePlanProvider(today).future);
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _showAddSheet() async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddManualTaskSheet(),
    );
  }

  void _navigateFromDrawer(String route, {bool push = false}) {
    Navigator.of(context).pop();
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      if (push) {
        context.push(route);
      } else {
        context.go(route);
      }
    });
  }

  Future<void> _openWeeklyReviewFromDrawer() async {
    Navigator.of(context).pop();
    final isOnline = await ref.read(isOnlineProvider.future);
    if (!mounted) return;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You're offline. Connect to use features."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.push('/ai/weekly-review');
  }

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  Future<void> _recordInitialWelcome(HomeSetupState setup) async {
    if (_initialWelcomeRecorded || setup.hasSeenInitialWelcome) return;
    _initialWelcomeRecorded = true;
    await AnalyticsService.instance.logInitialHomeViewed(
      completedStepCount: setup.completedStepCount,
    );
    await ref
        .read(userPrefsRepositoryProvider)
        ?.setHasSeenInitialHomeWelcome(true);
  }

  void _openQuickAction(
    HomeSetupState setup, {
    required String action,
    required String destination,
  }) {
    AnalyticsService.instance.logHomeSetupAction(
      eventName: 'home_quick_action_tapped',
      action: action,
      completedStepCount: setup.completedStepCount,
      destination: destination,
    );
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayPlanProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final studyStreak = ref.watch(studyStreakProvider);
    final gradingSystem = ref.watch(gradingSystemProvider);
    final projectedCwa = ref.watch(projectedCwaProvider);
    final targetCwa = ref.watch(targetCwaProvider);
    final allSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];
    final drawerUniversity = ref.watch(_drawerUniversityProvider).valueOrNull;
    final homeSetup = ref.watch(homeSetupStateProvider);
    final wasInitialHomeSetup = _wasInitialHomeSetup;
    if (homeSetup != null) {
      _wasInitialHomeSetup = homeSetup.isInitialHomeSetup;
      if (wasInitialHomeSetup == true && !homeSetup.isInitialHomeSetup) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AnalyticsService.instance.logHomeSetupAction(
            eventName: 'home_setup_completed',
            action: 'required_setup_complete',
            completedStepCount: homeSetup.completedStepCount,
            destination: 'today_dashboard',
          );
        });
      }
    }

    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);
    final greeting = _greetingFor(now);
    final todayIndex = now.weekday <= 6 ? now.weekday - 1 : 0;
    final todaySlots = allSlots
        .where((slot) => slot.dayIndex == todayIndex)
        .toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final bottomContentPadding = shellOverlayBottomPadding(
      context,
      hasActiveSession: activeSession != null,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primary),
                child: _DrawerHeaderContent(university: drawerUniversity),
              ),
              _DrawerItem(
                icon: Icons.today_outlined,
                label: 'Today',
                onTap: () => _navigateFromDrawer('/plan'),
              ),
              _DrawerItem(
                icon: Icons.local_fire_department_outlined,
                label: 'Streak',
                onTap: () => _navigateFromDrawer('/streak', push: true),
              ),
              _DrawerItem(
                icon: Icons.auto_graph_outlined,
                label: 'Insights',
                onTap: () => _navigateFromDrawer('/insights', push: true),
              ),
              _DrawerItem(
                icon: Icons.rate_review_outlined,
                label: 'Weekly Review',
                onTap: _openWeeklyReviewFromDrawer,
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => _navigateFromDrawer('/settings', push: true),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Today',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: const [
          StreakActionButton(),
        ],
      ),
      body: homeSetup == null
          ? const _PlanLoadingState()
          : homeSetup.isInitialHomeSetup
              ? _buildInitialHome(
                  setup: homeSetup,
                  bottomContentPadding: bottomContentPadding,
                )
              : tasksAsync.when(
                  loading: () => const _PlanLoadingState(),
                  error: (e, _) => ErrorRetryWidget(
                    message: 'We could not load today\'s plan right now.',
                    onRetry: () => ref.invalidate(todayPlanProvider),
                  ),
                  data: (tasks) {
                    if (tasks.isNotEmpty || !_isGenerating) {
                      _lastVisibleTasks = tasks;
                    }
                    final visibleTasks = _isGenerating &&
                            tasks.isEmpty &&
                            _lastVisibleTasks.isNotEmpty
                        ? _lastVisibleTasks
                        : tasks;
                    final visibleCompleted =
                        visibleTasks.where((t) => t.isCompleted).length;
                    final visibleTotal = visibleTasks.length;

                    return _buildBody(
                      tasks: visibleTasks,
                      completed: visibleCompleted,
                      total: visibleTotal,
                      greeting: greeting,
                      dateLabel: dateLabel,
                      activeSession: activeSession,
                      studyStreak: studyStreak,
                      projectedCwa: projectedCwa,
                      targetCwa: targetCwa,
                      gradingSystem: gradingSystem,
                      todaySlots: todaySlots,
                      bottomContentPadding: bottomContentPadding,
                    );
                  },
                ),
    );
  }

  Widget _buildInitialHome({
    required HomeSetupState setup,
    required double bottomContentPadding,
  }) {
    _showFirstWelcome ??= !setup.hasSeenInitialWelcome;
    if (_showFirstWelcome == true && !_initialWelcomeRecorded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _recordInitialWelcome(setup);
      });
    }

    return InitialHomeWelcome(
      bottomPadding: bottomContentPadding,
      animateEntrance: _showFirstWelcome ?? false,
      onGetStarted: () => _openQuickAction(
        setup,
        action: 'get_started',
        destination: setup.nextSetupStep == HomeSetupStep.university
            ? '/settings'
            : '/timetable',
      ),
      onCalculateCwa: () => _openQuickAction(
        setup,
        action: 'calculate_cwa',
        destination: '/cwa',
      ),
      onFocusSession: () => _openQuickAction(
        setup,
        action: 'focus_session',
        destination: '/sessions',
      ),
      onExploreTimetable: () => _openQuickAction(
        setup,
        action: 'explore_timetable',
        destination: '/timetable',
      ),
    );
  }

  Widget _buildBody({
    required List<DailyPlanTaskModel> tasks,
    required int completed,
    required int total,
    required String greeting,
    required String dateLabel,
    required ActiveSessionState? activeSession,
    required StreakResult studyStreak,
    required double projectedCwa,
    required double targetCwa,
    required GradingSystem gradingSystem,
    required List<TimetableSlotModel> todaySlots,
    required double bottomContentPadding,
  }) {
    final attendTasks = tasks.where((t) => t.taskType == 'attend').toList();
    final studyTasks = tasks.where((t) => t.taskType == 'study').toList();
    final personalTasks = tasks.where((t) => t.taskType == 'personal').toList();
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final currentClass = todaySlots
        .where((slot) {
          return slot.startMinutes <= nowMinutes &&
              nowMinutes < slot.endMinutes;
        })
        .cast<TimetableSlotModel?>()
        .firstOrNull;
    final nextClass = todaySlots
        .where((slot) => slot.startMinutes > nowMinutes)
        .cast<TimetableSlotModel?>()
        .firstOrNull;
    final heroContent = _buildHeroContent(
      activeSession: activeSession,
      currentClass: currentClass,
      nextClass: nextClass,
      totalClasses: todaySlots.length,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding.copyWith(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(
                  greeting: greeting,
                  dateLabel: dateLabel,
                ),
                const SizedBox(height: _homeCompactSectionGap),
                _HeroCard(content: heroContent),
                const SizedBox(height: _homeCompactSectionGap),
                CampusSectionHeader(
                  title: 'Today\'s plan',
                  trailing: tasks.isNotEmpty || _isGenerating
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _isGenerating ? null : _generatePlan,
                              icon: _isGenerating
                                  ? const SizedBox(
                                      width: AppIconSizes.md,
                                      height: AppIconSizes.md,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      LucideIcons.refreshCw,
                                      size: AppIconSizes.md,
                                    ),
                              tooltip: 'Regenerate plan',
                            ),
                            OutlinedButton.icon(
                              onPressed: _isGenerating ? null : _showAddSheet,
                              icon: const Icon(
                                LucideIcons.plus,
                                size: AppIconSizes.md,
                              ),
                              label: const Text('Add task'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                if (tasks.isNotEmpty) ...[
                  PlanProgressBar(completed: completed, total: total),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (tasks.isEmpty && !_isGenerating)
                  _EmptyPlanCard(
                    onGenerate: _generatePlan,
                    onAddTask: _showAddSheet,
                    isGenerating: _isGenerating,
                  )
                else if (tasks.isEmpty && _isGenerating)
                  const _PlanGeneratingIndicator(),
              ],
            ),
          ),
        ),
        if (tasks.isNotEmpty) ...[
          if (attendTasks.isNotEmpty) ...[
            const _TaskGroupHeader(
              label: 'Classes',
              icon: LucideIcons.calendarDays,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: CampusCard(
                    padding: EdgeInsets.zero,
                    child: PlanTaskTile(task: attendTasks[i]),
                  ),
                ),
                childCount: attendTasks.length,
              ),
            ),
          ],
          if (studyTasks.isNotEmpty) ...[
            const _TaskGroupHeader(
              label: 'Study',
              icon: LucideIcons.bookOpen,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: CampusCard(
                    padding: EdgeInsets.zero,
                    child: PlanTaskTile(task: studyTasks[i]),
                  ),
                ),
                childCount: studyTasks.length,
              ),
            ),
          ],
          if (personalTasks.isNotEmpty) ...[
            const _TaskGroupHeader(
              label: 'Personal',
              icon: LucideIcons.briefcase,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: CampusCard(
                    padding: EdgeInsets.zero,
                    child: PlanTaskTile(task: personalTasks[i]),
                  ),
                ),
                childCount: personalTasks.length,
              ),
            ),
          ],
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: _AcademicSummary(
              projectedCwa: projectedCwa,
              targetCwa: targetCwa,
              gradingSystem: gradingSystem,
              studyStreak: studyStreak,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: bottomContentPadding)),
      ],
    );
  }

  _HeroContent _buildHeroContent({
    required ActiveSessionState? activeSession,
    required TimetableSlotModel? currentClass,
    required TimetableSlotModel? nextClass,
    required int totalClasses,
  }) {
    if (activeSession != null) {
      return _HeroContent(
        eyebrow: activeSession.isPaused ? 'Session paused' : 'Studying now',
        title: activeSession.courseName,
        meta: activeSession.courseCode,
        actionLabel: 'Continue',
        onAction: () => context.go('/sessions'),
      );
    }

    if (currentClass != null) {
      return _HeroContent(
        eyebrow: 'In class',
        title: currentClass.courseName,
        meta: 'Until ${currentClass.endTimeLabel} · ${currentClass.venue}',
      );
    }

    if (nextClass != null) {
      return _HeroContent(
        eyebrow: 'Next class',
        title: nextClass.courseName,
        meta: '${nextClass.startTimeLabel} · ${nextClass.venue}',
      );
    }

    return _HeroContent(
      eyebrow: 'Today',
      title: totalClasses > 0 ? 'Classes finished' : 'No classes today',
      actionLabel: 'Start studying',
      onAction: () => context.go('/sessions'),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurface),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _DrawerHeaderContent extends StatelessWidget {
  final University? university;

  const _DrawerHeaderContent({required this.university});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.home_rounded, color: Colors.white, size: 32),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'UniMate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Today is your home base',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _DrawerSchoolLogo(university: university),
          ],
        ),
      ],
    );
  }
}

class _DrawerSchoolLogo extends StatelessWidget {
  final University? university;

  const _DrawerSchoolLogo({required this.university});

  @override
  Widget build(BuildContext context) {
    const logoWidth = 96.0;
    const logoHeight = 64.0;
    final logoAssetPath = university?.logoAssetPath;
    final needsDarkBackground = university?.logoNeedsDarkBackground ?? false;
    final backgroundColor = logoAssetPath == null
        ? Colors.white.withValues(alpha: 0.12)
        : needsDarkBackground
            ? AppColors.navySoft
            : Colors.white;

    Widget fallbackIcon() {
      return Icon(
        LucideIcons.school,
        color: Colors.white.withValues(alpha: 0.86),
        size: AppIconSizes.hero,
      );
    }

    return Semantics(
      label: university == null || logoAssetPath == null
          ? 'Selected school'
          : '${university!.name} logo',
      child: Container(
        width: logoWidth,
        height: logoHeight,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Center(
          child: logoAssetPath == null
              ? fallbackIcon()
              : Image.asset(
                  logoAssetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => fallbackIcon(),
                ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String greeting;
  final String dateLabel;

  const _PageHeader({
    required this.greeting,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          dateLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final _HeroContent content;

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.lg,
  );

  const _HeroCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: AppRadii.card,
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navySoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs2,
              ),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.16),
                borderRadius: AppRadii.pill,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                content.eyebrow,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
            ),
            if (content.meta.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                content.meta,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 14,
                    ),
              ),
            ],
            if (content.actionLabel != null && content.onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                onPressed: content.onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                icon: const Icon(LucideIcons.play, size: AppIconSizes.md),
                label: Text(content.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AcademicSummary extends StatelessWidget {
  final double projectedCwa;
  final double targetCwa;
  final GradingSystem gradingSystem;
  final StreakResult studyStreak;

  const _AcademicSummary({
    required this.projectedCwa,
    required this.targetCwa,
    required this.gradingSystem,
    required this.studyStreak,
  });

  @override
  Widget build(BuildContext context) {
    final days = studyStreak.currentStreak;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CampusSectionHeader(title: 'Grades & streaks'),
        const SizedBox(height: AppSpacing.sm),
        CampusCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(LucideIcons.chartNoAxesColumnIncreasing),
                title: Text(
                    '${gradingSystem.projectedLabel}: ${gradingSystem.formatScore(projectedCwa)}'),
                subtitle:
                    Text('Target: ${gradingSystem.formatScore(targetCwa)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/cwa'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.local_fire_department_outlined),
                title: Text('$days-day study streak'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/streak'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyPlanCard extends StatelessWidget {
  static const double _actionButtonHeight = 52;

  final VoidCallback onGenerate;
  final VoidCallback onAddTask;
  final bool isGenerating;

  const _EmptyPlanCard({
    required this.onGenerate,
    required this.onAddTask,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: AppSpacing.compactCardPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Icon(
              LucideIcons.notebookTabs,
              size: 28,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: isGenerating
                    ? const SizedBox(
                        height: _actionButtonHeight,
                        child: ElevatedButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onGenerate,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, _actionButtonHeight),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                size: AppIconSizes.md,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                'Generate plan',
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: onAddTask,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, _actionButtonHeight),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.plus, size: AppIconSizes.md),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Add task',
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskGroupHeader extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TaskGroupHeader({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppIconSizes.md, color: colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanLoadingState extends StatelessWidget {
  const _PlanLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: CampusCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Loading today…',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanGeneratingIndicator extends StatelessWidget {
  const _PlanGeneratingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _HeroContent {
  final String eyebrow;
  final String title;
  final String meta;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _HeroContent({
    required this.eyebrow,
    required this.title,
    this.meta = '',
    this.actionLabel,
    this.onAction,
  });
}
