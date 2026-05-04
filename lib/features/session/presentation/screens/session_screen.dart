import 'package:campusiq/core/layout/shell_overlay_padding.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/presentation/widgets/study_plan_tab.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/review/presentation/widgets/weekly_review_sheet.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/active_timer_card.dart';
import 'package:campusiq/features/session/presentation/widgets/analytics_summary_card.dart';
import 'package:campusiq/features/session/presentation/widgets/course_breakdown_card.dart';
import 'package:campusiq/features/session/presentation/widgets/course_picker_sheet.dart';
import 'package:campusiq/features/session/presentation/widgets/session_tile.dart';
import 'package:campusiq/features/session/presentation/widgets/weekly_bar_chart.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/shared/widgets/campus_button.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_chip.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _startSession(
    BuildContext context, {
    bool isPomodoroMode = false,
    Duration focusDuration = const Duration(minutes: 25),
    Duration shortBreakDuration = const Duration(minutes: 5),
    Duration longBreakDuration = const Duration(minutes: 15),
  }) async {
    if (isPomodoroMode) {
      await NotificationService.instance.requestPermission();
      if (!context.mounted) return;
    }

    final picked = await showModalBottomSheet<PickedCourse>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      builder: (_) => const CoursePickerSheet(),
    );

    if (picked == null || !context.mounted) return;

    ref.read(activeSessionProvider.notifier).startSession(
          courseCode: picked.courseCode,
          courseName: picked.courseName,
          courseSource: picked.source,
          isPomodoroMode: isPomodoroMode,
          focusDuration: focusDuration,
          shortBreakDuration: shortBreakDuration,
          longBreakDuration: longBreakDuration,
        );
  }

  Future<void> _stopSession(String semesterKey) async {
    final notifier = ref.read(activeSessionProvider.notifier);
    final completed = notifier.stopSession();
    if (completed == null) return;

    final durationMins = completed.elapsedMinutes;
    if (durationMins < 1) return;

    final existingSessions = ref.read(allSessionsProvider).valueOrNull ?? [];
    final today = DateTime.now();
    final hadSessionToday = existingSessions.any((s) {
      final d = s.startTime;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    });

    final todaySlots = ref.read(activeDaySlotsProvider);
    final wasPlanned =
        todaySlots.any((s) => s.courseCode == completed.courseCode);

    final session = StudySessionModel()
      ..courseCode = completed.courseCode
      ..courseName = completed.courseName
      ..startTime = completed.startTime
      ..endTime = DateTime.now()
      ..durationMinutes = durationMins
      ..wasPlanned = wasPlanned
      ..courseSource = completed.courseSource
      ..semesterKey = semesterKey
      ..sessionType = completed.isPomodoroMode ? 'pomodoro' : 'normal'
      ..pomodoroRoundsCompleted =
          completed.isPomodoroMode ? completed.pomodoroRoundsCompleted : null;

    final repo = ref.read(sessionRepositoryProvider);
    await repo?.saveSession(session);

    await NotificationService.instance.cancelStudiedTodayAlerts();

    if (!hadSessionToday) {
      final streak = ref.read(studyStreakProvider);
      await NotificationService.instance
          .showStreakSecured(streak.currentStreak);
    }
  }

  void _onPhaseExpired() {
    ref.read(activeSessionProvider.notifier).advancePhase();
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    final semester = ref.watch(activeSemesterProvider);
    final bottomContentPadding = shellOverlayBottomPadding(
      context,
      hasActiveSession: activeSession != null,
    );

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Sessions'),
        actions: [
          TextButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const WeeklyReviewSheet(),
            ),
            icon: const Icon(LucideIcons.calendarRange, size: AppIconSizes.md),
            label: const Text('This Week'),
          ),
          const StreakActionButton(),
          IconButton(
            onPressed: () => context.push('/insights'),
            tooltip: 'Insights',
            icon: const Icon(LucideIcons.sparkles, size: AppIconSizes.lg),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              0,
            ),
            child: _TabSwitcher(controller: _tabController),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HistoryTab(
                  activeSession: activeSession,
                  bottomContentPadding: bottomContentPadding,
                  onStart: (isPomodoroMode, focus, shortBreak, longBreak) =>
                      _startSession(
                    context,
                    isPomodoroMode: isPomodoroMode,
                    focusDuration: focus,
                    shortBreakDuration: shortBreak,
                    longBreakDuration: longBreak,
                  ),
                  onPause: () =>
                      ref.read(activeSessionProvider.notifier).pauseSession(),
                  onResume: () =>
                      ref.read(activeSessionProvider.notifier).resumeSession(),
                  onStop: () => _stopSession(semester),
                  onCancel: () =>
                      ref.read(activeSessionProvider.notifier).cancelSession(),
                  onPhaseExpired: _onPhaseExpired,
                  onSkipBreak: () =>
                      ref.read(activeSessionProvider.notifier).skipBreak(),
                ),
                StudyPlanTab(bottomContentPadding: bottomContentPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final ActiveSessionState? activeSession;
  final void Function(
    bool isPomodoroMode,
    Duration focus,
    Duration shortBreak,
    Duration longBreak,
  ) onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback onPhaseExpired;
  final VoidCallback onSkipBreak;
  final double bottomContentPadding;

  const _HistoryTab({
    required this.activeSession,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onCancel,
    required this.onPhaseExpired,
    required this.onSkipBreak,
    required this.bottomContentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final todaySummary = ref.watch(todayAnalyticsProvider) ??
        DayAnalytics(
          date: DateTime.now(),
          sessions: const [],
          totalActualMinutes: 0,
          totalPlannedMinutes: 0,
          perCourse: const [],
        );
    final weeklyAnalytics = ref.watch(weeklyAnalyticsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              0,
            ),
            child: activeSession != null
                ? ActiveTimerCard(
                    session: activeSession!,
                    onPause: onPause,
                    onResume: onResume,
                    onStop: onStop,
                    onCancel: onCancel,
                    onPhaseExpired: onPhaseExpired,
                    onSkipBreak: onSkipBreak,
                  )
                : _StartCard(onStart: onStart),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              0,
            ),
            child: AnalyticsSummaryCard(analytics: todaySummary),
          ),
        ),
        if (todaySummary.perCourse.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                0,
              ),
              child: CourseBreakdownCard(courses: todaySummary.perCourse),
            ),
          ),
        if (weeklyAnalytics != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                0,
              ),
              child: WeeklyBarChart(weekly: weeklyAnalytics),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: CampusSectionHeader(
              title: 'Recent sessions',
              subtitle: 'A calmer look at your latest focus history.',
              trailing: sessionsAsync.whenOrNull(
                    data: (sessions) => CampusChip(
                      label:
                          '${sessions.length} session${sessions.length == 1 ? '' : 's'}',
                      icon: LucideIcons.history,
                      backgroundColor: AppColors.surfaceMuted,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                  ) ??
                  const SizedBox.shrink(),
            ),
          ),
        ),
        sessionsAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: ErrorRetryWidget(
                message: 'We could not load your sessions right now.',
                onRetry: () => ref.invalidate(allSessionsProvider),
              ),
            ),
          ),
          data: (sessions) {
            if (sessions.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: _HistoryEmptyState(),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              sliver: SliverList.separated(
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return SessionTile(
                    session: session,
                    onDelete: () => ref
                        .read(sessionRepositoryProvider)
                        ?.deleteSession(session.id),
                  );
                },
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemCount: sessions.length,
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: bottomContentPadding),
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final TabController controller;

  const _TabSwitcher({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: AppRadii.pill,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: 'History'),
          Tab(text: 'Plan'),
        ],
      ),
    );
  }
}

class _StartCard extends StatefulWidget {
  final void Function(
    bool isPomodoroMode,
    Duration focus,
    Duration shortBreak,
    Duration longBreak,
  ) onStart;

  const _StartCard({required this.onStart});

  @override
  State<_StartCard> createState() => _StartCardState();
}

class _StartCardState extends State<_StartCard> {
  bool _isPomodoroMode = false;
  bool _showPomodoroCustomizer = false;
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;

  void _adjust(
    int current,
    int delta,
    int min,
    int max,
    void Function(int) update,
  ) {
    final next = current + delta;
    if (next >= min && next <= max) {
      setState(() => update(next));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isPomodoroMode ? 'Pomodoro focus' : 'Normal study session';
    final description = _isPomodoroMode
        ? 'Use focused rounds with gentle breaks when you want a clearer rhythm.'
        : 'Pick a course and track your focus time without extra setup.';

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CampusSectionHeader(
            title: 'Ready to focus?',
            subtitle: 'Choose a mode and start a calm study session.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ModeToggle(
            isPomodoroMode: _isPomodoroMode,
            onChanged: (value) {
              setState(() {
                _isPomodoroMode = value;
                if (!value) {
                  _showPomodoroCustomizer = false;
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _isPomodoroMode
                ? [
                    CampusChip(
                      label: '${_focusMinutes} min focus',
                      icon: LucideIcons.timer,
                      backgroundColor: AppColors.goldSoft,
                    ),
                    CampusChip(
                      label: '${_shortBreakMinutes} min break',
                      icon: LucideIcons.coffee,
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                    CampusChip(
                      label: '${_longBreakMinutes} min long break',
                      icon: LucideIcons.moonStar,
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                  ]
                : const [
                    CampusChip(
                      label: 'Course picker',
                      icon: LucideIcons.bookOpen,
                      backgroundColor: AppColors.goldSoft,
                    ),
                    CampusChip(
                      label: 'Tracks real focus time',
                      icon: LucideIcons.chartColumn,
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                  ],
          ),
          if (_isPomodoroMode) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showPomodoroCustomizer = !_showPomodoroCustomizer;
                  });
                },
                icon: Icon(
                  _showPomodoroCustomizer
                      ? LucideIcons.chevronUp
                      : LucideIcons.slidersHorizontal,
                  size: AppIconSizes.md,
                ),
                label: Text(
                  _showPomodoroCustomizer
                      ? 'Hide customization'
                      : 'Customize timer',
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Column(
                  children: [
                    _DurationStepper(
                      label: 'Focus',
                      minutes: _focusMinutes,
                      onDecrement: () => _adjust(
                        _focusMinutes,
                        -5,
                        10,
                        60,
                        (value) => _focusMinutes = value,
                      ),
                      onIncrement: () => _adjust(
                        _focusMinutes,
                        5,
                        10,
                        60,
                        (value) => _focusMinutes = value,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DurationStepper(
                      label: 'Short break',
                      minutes: _shortBreakMinutes,
                      onDecrement: () => _adjust(
                        _shortBreakMinutes,
                        -5,
                        5,
                        30,
                        (value) => _shortBreakMinutes = value,
                      ),
                      onIncrement: () => _adjust(
                        _shortBreakMinutes,
                        5,
                        5,
                        30,
                        (value) => _shortBreakMinutes = value,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DurationStepper(
                      label: 'Long break',
                      minutes: _longBreakMinutes,
                      onDecrement: () => _adjust(
                        _longBreakMinutes,
                        -5,
                        10,
                        60,
                        (value) => _longBreakMinutes = value,
                      ),
                      onIncrement: () => _adjust(
                        _longBreakMinutes,
                        5,
                        10,
                        60,
                        (value) => _longBreakMinutes = value,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _showPomodoroCustomizer
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: CampusButton(
              onPressed: () => widget.onStart(
                _isPomodoroMode,
                Duration(minutes: _focusMinutes),
                Duration(minutes: _shortBreakMinutes),
                Duration(minutes: _longBreakMinutes),
              ),
              icon: Icon(
                _isPomodoroMode ? LucideIcons.timerReset : LucideIcons.play,
                size: AppIconSizes.lg,
              ),
              child: Text(_isPomodoroMode ? 'Start Pomodoro' : 'Start Session'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isPomodoroMode;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({
    required this.isPomodoroMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeSegment(
              label: 'Normal',
              icon: LucideIcons.bookOpen,
              selected: !isPomodoroMode,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _ModeSegment(
              label: 'Pomodoro',
              icon: LucideIcons.timerReset,
              selected: isPomodoroMode,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: AppRadii.pill,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSizes.md,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationStepper extends StatelessWidget {
  final String label;
  final int minutes;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  static const double _durationDisplayWidth = 82;

  const _DurationStepper({
    required this.label,
    required this.minutes,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surfaceMuted,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _StepperButton(
            icon: LucideIcons.minus,
            onPressed: onDecrement,
          ),
          SizedBox(
            width: _durationDisplayWidth,
            child: Text(
              '$minutes min',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          _StepperButton(
            icon: LucideIcons.plus,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  static const double _size = 34;

  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadii.pill,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.pill,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: AppIconSizes.md, color: AppTheme.primary),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Icon(
              LucideIcons.clock3,
              color: AppTheme.primary,
              size: AppIconSizes.xxxl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No sessions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Start your first study session and build your focus rhythm one calm block at a time.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
