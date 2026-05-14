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
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
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
  static const double _compactSectionGap = AppSpacing.xs2;

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
    int totalRounds = 4,
  }) async {
    if (isPomodoroMode) {
      await NotificationService.instance.requestPermission();
      if (!context.mounted) return;
    }

    final prefsRepo = ref.read(userPrefsRepositoryProvider);
    final vibrate = await prefsRepo?.getVibrateOnTimerEnd() ?? true;
    final playSound = await prefsRepo?.getPlaySoundOnTimerEnd() ?? true;
    if (!context.mounted) return;

    final picked = await showModalBottomSheet<PickedCourse>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
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
          totalRounds: totalRounds,
          vibrateOnTimerEnd: vibrate,
          playSoundOnTimerEnd: playSound,
        );
  }

  Future<void> _stopSession(String semesterKey) async {
    final notifier = ref.read(activeSessionProvider.notifier);
    final completed = notifier.stopSession();
    if (completed == null) return;

    final durationMins = completed.elapsedMinutes;
    if (durationMins < 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session too short to save (under 1 minute).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

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
    if (repo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save session. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      await repo.saveSession(session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save session. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sessions'),
        actions: [
          TextButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              useSafeArea: true,
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
              AppSpacing.xs,
              AppSpacing.xl,
              0,
            ),
            child: _TabSwitcher(controller: _tabController),
          ),
          const SizedBox(height: AppSpacing.xs2),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HistoryTab(
                  activeSession: activeSession,
                  bottomContentPadding: bottomContentPadding,
                  onStart: (isPomodoroMode, focus, shortBreak, longBreak,
                          totalRounds) =>
                      _startSession(
                    context,
                    isPomodoroMode: isPomodoroMode,
                    focusDuration: focus,
                    shortBreakDuration: shortBreak,
                    longBreakDuration: longBreak,
                    totalRounds: totalRounds,
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
    int totalRounds,
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
              _SessionScreenState._compactSectionGap,
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
              _SessionScreenState._compactSectionGap,
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
                _SessionScreenState._compactSectionGap,
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
                _SessionScreenState._compactSectionGap,
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
              _SessionScreenState._compactSectionGap,
              AppSpacing.xl,
              AppSpacing.xs2,
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
                    onDelete: () async {
                      final confirm = await showCampusConfirmDialog(
                        context: context,
                        title: 'Delete session?',
                        message:
                            'Remove this ${session.courseCode} study session? This cannot be undone.',
                        confirmLabel: 'Delete',
                        destructive: true,
                      );
                      if (confirm != true) return;
                      final repo = ref.read(sessionRepositoryProvider);
                      if (repo == null) return;
                      try {
                        await repo.deleteSession(session.id);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Could not delete session. Please try again.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xs2),
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
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.pill,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: AppRadii.pill,
        ),
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: 'History'),
          Tab(text: 'Plan'),
        ],
      ),
    );
  }
}

class _StartCard extends ConsumerStatefulWidget {
  final void Function(
    bool isPomodoroMode,
    Duration focus,
    Duration shortBreak,
    Duration longBreak,
    int totalRounds,
  ) onStart;

  const _StartCard({required this.onStart});

  @override
  ConsumerState<_StartCard> createState() => _StartCardState();
}

class _StartCardState extends ConsumerState<_StartCard> {
  static const int _defaultTotalRounds = 4;
  static const int _defaultFocusMinutes = 25;
  static const int _defaultShortBreakMinutes = 5;
  static const int _defaultLongBreakMinutes = 15;

  bool _isPomodoroMode = false;
  bool _showPomodoroCustomizer = false;
  int _totalRounds = _defaultTotalRounds;
  int _focusMinutes = _defaultFocusMinutes;
  int _shortBreakMinutes = _defaultShortBreakMinutes;
  int _longBreakMinutes = _defaultLongBreakMinutes;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final repo = ref.read(userPrefsRepositoryProvider);
    if (repo == null) return;
    final focus = _validRangeOrDefault(
      await repo.getDefaultFocusMinutes(),
      min: 10,
      max: 60,
      fallback: _defaultFocusMinutes,
    );
    final short = _validRangeOrDefault(
      await repo.getDefaultShortBreakMinutes(),
      min: 5,
      max: 30,
      fallback: _defaultShortBreakMinutes,
    );
    final long = _validRangeOrDefault(
      await repo.getDefaultLongBreakMinutes(),
      min: 10,
      max: 60,
      fallback: _defaultLongBreakMinutes,
    );
    final rounds = _validRangeOrDefault(
      await repo.getDefaultTotalRounds(),
      min: 2,
      max: 10,
      fallback: _defaultTotalRounds,
    );
    if (mounted) {
      setState(() {
        _focusMinutes = focus;
        _shortBreakMinutes = short;
        _longBreakMinutes = long;
        _totalRounds = rounds;
      });
    }
  }

  Future<void> _saveDefaults() async {
    final repo = ref.read(userPrefsRepositoryProvider);
    if (repo == null) return;
    await Future.wait([
      repo.setDefaultFocusMinutes(_focusMinutes),
      repo.setDefaultShortBreakMinutes(_shortBreakMinutes),
      repo.setDefaultLongBreakMinutes(_longBreakMinutes),
      repo.setDefaultTotalRounds(_totalRounds),
    ]);
  }

  int _validRangeOrDefault(
    int value, {
    required int min,
    required int max,
    required int fallback,
  }) {
    if (value < min || value > max) return fallback;
    return value;
  }

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
    final colorScheme = Theme.of(context).colorScheme;
    final title = _isPomodoroMode ? 'Pomodoro focus' : 'Normal study session';
    final description = _isPomodoroMode
        ? 'Use focused rounds with gentle breaks when you want a clearer rhythm.'
        : 'Pick a course and track your focus time without extra setup.';

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CampusSectionHeader(
            title: 'Ready to focus?',
            subtitle: 'Choose a mode and start a calm study session.',
          ),
          const SizedBox(height: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs2,
            runSpacing: AppSpacing.xs2,
            children: _isPomodoroMode
                ? [
                    CampusChip(
                      label: '$_totalRounds rounds',
                      icon: LucideIcons.repeat,
                      backgroundColor: AppColors.goldSoft,
                    ),
                    CampusChip(
                      label: '$_focusMinutes min focus',
                      icon: LucideIcons.timer,
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                    CampusChip(
                      label: '$_shortBreakMinutes min break',
                      icon: LucideIcons.coffee,
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                    CampusChip(
                      label: '$_longBreakMinutes min long break',
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
            const SizedBox(height: AppSpacing.sm),
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
                padding: const EdgeInsets.only(top: AppSpacing.xxs2),
                child: Column(
                  children: [
                    _RoundsStepper(
                      rounds: _totalRounds,
                      onDecrement: () => _adjust(
                        _totalRounds,
                        -1,
                        2,
                        10,
                        (value) => _totalRounds = value,
                      ),
                      onIncrement: () => _adjust(
                        _totalRounds,
                        1,
                        2,
                        10,
                        (value) => _totalRounds = value,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs2),
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
                    const SizedBox(height: AppSpacing.xs2),
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
                    const SizedBox(height: AppSpacing.xs2),
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
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: CampusButton(
              onPressed: () {
                _saveDefaults();
                widget.onStart(
                  _isPomodoroMode,
                  Duration(minutes: _focusMinutes),
                  Duration(minutes: _shortBreakMinutes),
                  Duration(minutes: _longBreakMinutes),
                  _totalRounds,
                );
              },
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.pill,
        border: Border.all(color: colorScheme.outlineVariant),
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
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm2,
          vertical: AppSpacing.xs2,
        ),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: AppRadii.pill,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSizes.md,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
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
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs2,
      ),
      color: AppColors.surfaceMuted,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13,
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
                    fontSize: 14,
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

class _RoundsStepper extends StatelessWidget {
  final int rounds;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _RoundsStepper({
    required this.rounds,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs2,
      ),
      color: AppColors.surfaceMuted,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Rounds',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _StepperButton(
            icon: LucideIcons.minus,
            onPressed: onDecrement,
          ),
          SizedBox(
            width: 82,
            child: Text(
              '$rounds rounds',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
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
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadii.pill,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadii.pill,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Icon(icon, size: AppIconSizes.md, color: colorScheme.primary),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
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
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs2),
          Text(
            'Start your first study session and build your focus rhythm one calm block at a time.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}
