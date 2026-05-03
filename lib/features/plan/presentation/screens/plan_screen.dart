import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';
import 'package:campusiq/features/plan/presentation/widgets/add_manual_task_sheet.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_progress_bar.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_task_tile.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/shared/widgets/campus_button.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  bool _isGenerating = false;

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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayPlanProvider);
    final (completed, total) = ref.watch(planProgressProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final studyStreak = ref.watch(studyStreakProvider);
    final attendanceStreak = ref.watch(attendanceStreakProvider);
    final perCourseStreaks = ref.watch(perCourseStreakProvider);
    final projectedCwa = ref.watch(projectedCwaProvider);
    final targetCwa = ref.watch(targetCwaProvider);
    final allSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];

    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);
    final greeting = _greetingFor(now);
    final isDone = total > 0 && completed >= total;
    final todayIndex = now.weekday <= 6 ? now.weekday - 1 : 0;
    final todaySlots = allSlots
        .where((slot) => slot.dayIndex == todayIndex)
        .toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final freeBlocks = FreeTimeDetector.detect(
      dayIndex: todayIndex,
      slots: todaySlots,
    );

    return Scaffold(
      backgroundColor: AppTheme.surface,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: AppTheme.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.home_rounded, color: Colors.white, size: 32),
                    SizedBox(height: 12),
                    Text(
                      'CampusIQ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Today is your home base',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
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
                onTap: () =>
                    _navigateFromDrawer('/ai/weekly-review', push: true),
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => _navigateFromDrawer('/settings', push: true),
              ),
              _DrawerItem(
                icon: Icons.workspace_premium_outlined,
                label: 'Subscribe',
                onTap: () => _navigateFromDrawer('/subscribe', push: true),
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
        actions: [
          const StreakActionButton(),
          IconButton(
            icon: const Icon(
              LucideIcons.bell,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            tooltip: 'Notification settings',
            onPressed: () => context.push('/settings'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: _generatePlan,
                    icon: const Icon(
                      LucideIcons.sparkles,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    label: const Text(
                      'Generate',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      foregroundColor: AppTheme.primary,
                      backgroundColor: AppColors.surface.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.button,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const _PlanLoadingState(),
        error: (e, _) => ErrorRetryWidget(
          message: 'We could not load today\'s plan right now.',
          onRetry: () => ref.invalidate(todayPlanProvider),
        ),
        data: (tasks) => _buildBody(
          tasks: tasks,
          completed: completed,
          total: total,
          isDone: isDone,
          greeting: greeting,
          dateLabel: dateLabel,
          activeSession: activeSession,
          studyStreak: studyStreak,
          attendanceStreak: attendanceStreak,
          totalCourseStreaks: perCourseStreaks.values
              .where((result) => result.currentStreak > 0)
              .length,
          projectedCwa: projectedCwa,
          targetCwa: targetCwa,
          todaySlots: todaySlots,
          freeBlocks: freeBlocks,
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<DailyPlanTaskModel> tasks,
    required int completed,
    required int total,
    required bool isDone,
    required String greeting,
    required String dateLabel,
    required ActiveSessionState? activeSession,
    required StreakResult studyStreak,
    required StreakResult attendanceStreak,
    required int totalCourseStreaks,
    required double projectedCwa,
    required double targetCwa,
    required List<TimetableSlotModel> todaySlots,
    required List<FreeBlock> freeBlocks,
  }) {
    final attendTasks = tasks.where((t) => t.taskType == 'attend').toList();
    final studyTasks = tasks.where((t) => t.taskType == 'study').toList();
    final personalTasks = tasks.where((t) => t.taskType == 'personal').toList();
    final pendingStudyTasks =
        studyTasks.where((task) => !task.isCompleted).toList();
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
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
    final completedClasses =
        todaySlots.where((slot) => slot.endMinutes <= nowMinutes).length;
    final heroContent = _buildHeroContent(
      activeSession: activeSession,
      currentClass: currentClass,
      nextClass: nextClass,
      totalClasses: todaySlots.length,
      completedClasses: completedClasses,
      freeBlocks: freeBlocks,
    );
    final cwaGap = targetCwa - projectedCwa;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      minimum: const EdgeInsets.only(bottom: AppSpacing.md),
      child: CustomScrollView(
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
                    onAddTask: _showAddSheet,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _HeroCard(content: heroContent),
                  const SizedBox(height: AppSpacing.xl),
                  const CampusSectionHeader(
                    title: 'Academic pulse',
                    subtitle: 'A compact look at where your momentum stands.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AcademicPulseCard(
                    projectedCwa: projectedCwa,
                    targetCwa: targetCwa,
                    cwaGap: cwaGap,
                    studyStreak: studyStreak,
                    attendanceStreak: attendanceStreak,
                    totalCourseStreaks: totalCourseStreaks,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const CampusSectionHeader(
                    title: 'Today at a glance',
                    subtitle:
                        'See your classes, focus load, and progress in one pass.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TodayAtGlanceCard(
                    classCount: todaySlots.length,
                    pendingStudyTaskCount: pendingStudyTasks.length,
                    completed: completed,
                    total: total,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ProgressOverviewCard(
                    completed: completed,
                    total: total,
                    isDone: isDone,
                  ),
                  if (activeSession != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _ActiveSessionResumeCard(session: activeSession),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const CampusSectionHeader(
                    title: 'Today in detail',
                    subtitle:
                        'The rest of your schedule stays here when you need specifics.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _TodayClassesCard(slots: todaySlots),
                  const SizedBox(height: AppSpacing.md),
                  _FreeBlocksCard(freeBlocks: freeBlocks),
                  const SizedBox(height: AppSpacing.xl),
                  CampusSectionHeader(
                    title: 'Today\'s plan',
                    subtitle: pendingTasks == 0
                        ? 'Everything here is either complete or ready when you are.'
                        : '$pendingTasks task${pendingTasks == 1 ? '' : 's'} still need attention.',
                    trailing: OutlinedButton.icon(
                      onPressed: _showAddSheet,
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Add task'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (tasks.isEmpty)
                    _EmptyPlanCard(
                      onGenerate: _generatePlan,
                      onAddTask: _showAddSheet,
                      isGenerating: _isGenerating,
                    ),
                ],
              ),
            ),
          ),
          if (tasks.isNotEmpty) ...[
            if (attendTasks.isNotEmpty) ...[
              const _TaskGroupHeader(
                label: 'Planned classes',
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
                label: 'Suggested study tasks',
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
                label: 'Personal tasks',
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
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        ],
      ),
    );
  }

  _HeroContent _buildHeroContent({
    required ActiveSessionState? activeSession,
    required TimetableSlotModel? currentClass,
    required TimetableSlotModel? nextClass,
    required int totalClasses,
    required int completedClasses,
    required List<FreeBlock> freeBlocks,
  }) {
    if (activeSession != null) {
      return _HeroContent(
        eyebrow: 'Focus in motion',
        title: activeSession.courseName,
        body: activeSession.isPomodoroMode
            ? 'Pomodoro is running for ${activeSession.courseCode}. Pick it back up before you lose your rhythm.'
            : 'Your session for ${activeSession.courseCode} is already underway. Drop back in and keep the momentum going.',
        meta:
            'Started at ${DateFormat('h:mm a').format(activeSession.startTime)}',
        actionLabel: 'Resume session',
        onAction: () => context.go('/sessions'),
      );
    }

    if (currentClass != null) {
      return _HeroContent(
        eyebrow: 'Class in progress',
        title: currentClass.courseName,
        body:
            '${currentClass.courseCode} is live right now. When you are free, use the next open block to review or plan ahead.',
        meta: 'Ends at ${currentClass.endTimeLabel} • ${currentClass.venue}',
      );
    }

    if (nextClass != null) {
      return _HeroContent(
        eyebrow: 'Next up',
        title: nextClass.courseName,
        body:
            '${nextClass.courseCode} starts at ${nextClass.startTimeLabel}. You still have time to settle in and prepare calmly.',
        meta: '${nextClass.venue} • ${nextClass.slotType}',
      );
    }

    if (totalClasses > 0) {
      return _HeroContent(
        eyebrow: 'Day wrapped well',
        title: 'Your classes are behind you',
        body: completedClasses == totalClasses
            ? 'All $totalClasses classes are done for today. Use the rest of the day for review, rest, or a short focused session.'
            : 'You are between blocks right now. There are ${freeBlocks.length} free window${freeBlocks.length == 1 ? '' : 's'} you can still use well.',
        meta: '$completedClasses of $totalClasses classes completed',
      );
    }

    return const _HeroContent(
      eyebrow: 'Your day is open',
      title: 'No classes on the calendar',
      body:
          'Use the quieter pace to revise, plan a focused study session, or reset before tomorrow.',
      meta: 'A lighter day is still a good day to make progress.',
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
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String greeting;
  final String dateLabel;
  final VoidCallback onAddTask;

  const _PageHeader({
    required this.greeting,
    required this.dateLabel,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onAddTask,
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Add task'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final _HeroContent content;

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
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
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
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              content.body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              content.meta,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
            ),
            if (content.actionLabel != null && content.onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                onPressed: content.onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                icon: const Icon(LucideIcons.play, size: 16),
                label: Text(content.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AcademicPulseCard extends StatelessWidget {
  final double projectedCwa;
  final double targetCwa;
  final double cwaGap;
  final StreakResult studyStreak;
  final StreakResult attendanceStreak;
  final int totalCourseStreaks;

  const _AcademicPulseCard({
    required this.projectedCwa,
    required this.targetCwa,
    required this.cwaGap,
    required this.studyStreak,
    required this.attendanceStreak,
    required this.totalCourseStreaks,
  });

  @override
  Widget build(BuildContext context) {
    final gapLabel =
        cwaGap <= 0 ? 'On target' : '${cwaGap.toStringAsFixed(1)} short';
    final tiles = [
      _MetricTile(
        label: 'Projected CWA',
        value: projectedCwa.toStringAsFixed(1),
        accentColor: AppTheme.primary,
      ),
      _MetricTile(
        label: 'Target',
        value: targetCwa.toStringAsFixed(1),
        accentColor: AppColors.info,
      ),
      _MetricTile(
        label: 'Gap',
        value: gapLabel,
        accentColor: cwaGap <= 0 ? AppColors.success : AppColors.warning,
      ),
      _MetricTile(
        label: 'Study streak',
        value:
            '${studyStreak.currentStreak} day${studyStreak.currentStreak == 1 ? '' : 's'}',
        accentColor: AppColors.gold,
      ),
      _MetricTile(
        label: 'Attendance',
        value:
            '${attendanceStreak.currentStreak} day${attendanceStreak.currentStreak == 1 ? '' : 's'}',
        accentColor: AppColors.success,
      ),
      _MetricTile(
        label: 'Course streaks',
        value: '$totalCourseStreaks active',
        accentColor: AppColors.info,
      ),
    ];

    return CampusCard(
      padding: AppSpacing.compactCardPadding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, index) => tiles[index],
      ),
    );
  }
}

class _TodayAtGlanceCard extends StatelessWidget {
  final int classCount;
  final int pendingStudyTaskCount;
  final int completed;
  final int total;

  const _TodayAtGlanceCard({
    required this.classCount,
    required this.pendingStudyTaskCount,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progressText =
        total == 0 ? 'No tasks yet' : '$completed of $total done';

    return CampusCard(
      padding: AppSpacing.compactCardPadding,
      child: Column(
        children: [
          _SummaryRow(
            icon: LucideIcons.calendarDays,
            title: classCount == 0
                ? 'No classes today'
                : '$classCount classes today',
            subtitle: classCount == 0
                ? 'A quieter day for review, rest, or planning.'
                : 'Your timetable already defines the main rhythm of today.',
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          _SummaryRow(
            icon: LucideIcons.bookOpen,
            title:
                '$pendingStudyTaskCount suggested study task${pendingStudyTaskCount == 1 ? '' : 's'}',
            subtitle: pendingStudyTaskCount == 0
                ? 'Nothing urgent is queued right now.'
                : 'Start with one clear block and let the rest follow.',
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          _SummaryRow(
            icon: LucideIcons.checkCheck,
            title: progressText,
            subtitle: total == 0
                ? 'Generate a plan or add a manual task when you are ready.'
                : 'Small completions still count toward a calmer day.',
          ),
        ],
      ),
    );
  }
}

class _ActiveSessionResumeCard extends StatelessWidget {
  final ActiveSessionState session;

  const _ActiveSessionResumeCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final subtitle = session.isPomodoroMode
        ? 'Pomodoro in progress for ${session.courseCode}'
        : 'Study session in progress for ${session.courseCode}';

    return _SectionCard(
      icon: LucideIcons.timer,
      title: 'Keep the momentum going',
      subtitle: subtitle,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.courseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Started at ${DateFormat('h:mm a').format(session.startTime)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => context.go('/sessions'),
            icon: const Icon(LucideIcons.play, size: 16),
            label: const Text('Resume'),
          ),
        ],
      ),
    );
  }
}

class _ProgressOverviewCard extends StatelessWidget {
  final int completed;
  final int total;
  final bool isDone;

  const _ProgressOverviewCard({
    required this.completed,
    required this.total,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final supportingText = isDone
        ? 'You gave today real shape. Keep the rest of the evening light.'
        : total > 0
            ? '$completed of $total tasks are complete so far.'
            : 'Generate a plan or add a task to shape the day gently.';

    return CampusCard(
      padding: AppSpacing.compactCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PlanProgressBar(completed: completed, total: total),
          const SizedBox(height: AppSpacing.md),
          Text(
            supportingText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDone ? AppColors.success : AppTheme.textSecondary,
                  fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _TodayClassesCard extends StatelessWidget {
  final List<TimetableSlotModel> slots;

  const _TodayClassesCard({required this.slots});

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const _SectionCard(
        icon: LucideIcons.calendarDays,
        title: 'Classes',
        subtitle: 'No timetable entries were found for today.',
        child: _MutedBodyText(
          'Your schedule is open, so you can decide how much structure you want.',
        ),
      );
    }

    return _SectionCard(
      icon: LucideIcons.calendarDays,
      title: 'Classes',
      subtitle:
          '${slots.length} class${slots.length == 1 ? '' : 'es'} scheduled today',
      child: Column(
        children: [
          for (var i = 0; i < slots.take(3).length; i++) ...[
            _InfoRow(
              icon: LucideIcons.bookOpen,
              title: slots[i].courseCode,
              subtitle:
                  '${slots[i].startTimeLabel} - ${slots[i].endTimeLabel} • ${slots[i].venue}',
            ),
            if (i != slots.take(3).length - 1)
              const Divider(height: 16, color: AppColors.divider),
          ],
          if (slots.length > 3) ...[
            const SizedBox(height: AppSpacing.sm),
            const _MutedBodyText('Open Table for the full timetable.'),
          ],
        ],
      ),
    );
  }
}

class _FreeBlocksCard extends StatelessWidget {
  final List<FreeBlock> freeBlocks;

  const _FreeBlocksCard({required this.freeBlocks});

  @override
  Widget build(BuildContext context) {
    if (freeBlocks.isEmpty) {
      return const _SectionCard(
        icon: LucideIcons.clock3,
        title: 'Free blocks',
        subtitle: 'No major free blocks were detected today.',
        child: _MutedBodyText(
          'Shorter gaps can still work well for review, admin, or rest.',
        ),
      );
    }

    return _SectionCard(
      icon: LucideIcons.clock3,
      title: 'Free blocks',
      subtitle: 'The calmest windows for study or errands',
      child: Column(
        children: [
          for (var i = 0; i < freeBlocks.take(3).length; i++) ...[
            _InfoRow(
              icon: LucideIcons.sparkles,
              title: '${freeBlocks[i].startLabel} - ${freeBlocks[i].endLabel}',
              subtitle: '${freeBlocks[i].durationMinutes} min available',
            ),
            if (i != freeBlocks.take(3).length - 1)
              const Divider(height: 16, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      padding: AppSpacing.compactCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: accentColor == AppColors.gold
                  ? AppTheme.primary
                  : accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 14, color: AppTheme.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MutedBodyText extends StatelessWidget {
  final String text;

  const _MutedBodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
    );
  }
}

class _EmptyPlanCard extends StatelessWidget {
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
    return CampusCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: const Icon(
              LucideIcons.notebookTabs,
              size: 28,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nothing is mapped out yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Generate a calm plan from your timetable or add a task manually if you already know what needs your attention.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: isGenerating
                    ? const SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : CampusButton(
                        onPressed: onGenerate,
                        icon: const Icon(LucideIcons.sparkles, size: 16),
                        child: const Text('Generate plan'),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add task'),
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
            Icon(icon, size: 16, color: AppTheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
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
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Building your day',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'CampusIQ is pulling together your plan, classes, and progress.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroContent {
  final String eyebrow;
  final String title;
  final String body;
  final String meta;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _HeroContent({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.meta,
    this.actionLabel,
    this.onAction,
  });
}
