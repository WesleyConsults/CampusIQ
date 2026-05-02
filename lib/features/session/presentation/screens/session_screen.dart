import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/active_timer_card.dart';
import 'package:campusiq/features/session/presentation/widgets/analytics_summary_card.dart';
import 'package:campusiq/features/session/presentation/widgets/course_breakdown_card.dart';
import 'package:campusiq/features/session/presentation/widgets/course_picker_sheet.dart';
import 'package:campusiq/features/session/presentation/widgets/session_tile.dart';
import 'package:campusiq/features/session/presentation/widgets/weekly_bar_chart.dart';
import 'package:campusiq/features/review/presentation/widgets/weekly_review_sheet.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/study_plan_tab.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Go to Today',
          icon: const Icon(Icons.home_outlined, semanticLabel: 'Go to Today'),
          onPressed: () => context.go('/plan'),
        ),
        title: const Text('Sessions',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          const StreakActionButton(),
          TextButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const WeeklyReviewSheet(),
            ),
            child:
                const Text('This Week', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'Insights',
            onPressed: () => context.push('/insights'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Plan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HistoryTab(
            activeSession: activeSession,
            semester: semester,
            onStart: (isPomodoroMode, focus, shortBreak, longBreak) =>
                _startSession(
              context,
              isPomodoroMode: isPomodoroMode,
              focusDuration: focus,
              shortBreakDuration: shortBreak,
              longBreakDuration: longBreak,
            ),
            onStop: () => _stopSession(semester),
            onCancel: () =>
                ref.read(activeSessionProvider.notifier).cancelSession(),
            onPhaseExpired: _onPhaseExpired,
            onSkipBreak: () =>
                ref.read(activeSessionProvider.notifier).skipBreak(),
          ),
          const StudyPlanTab(),
        ],
      ),
    );
  }
}

// ── History tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  final dynamic activeSession;
  final String semester;
  final void Function(bool isPomodoroMode, Duration focus, Duration shortBreak,
      Duration longBreak) onStart;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback onPhaseExpired;
  final VoidCallback onSkipBreak;

  const _HistoryTab({
    required this.activeSession,
    required this.semester,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
    required this.onPhaseExpired,
    required this.onSkipBreak,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final todayAnalytics = ref.watch(todayAnalyticsProvider);
    final weeklyAnalytics = ref.watch(weeklyAnalyticsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: activeSession != null
                ? ActiveTimerCard(
                    session: activeSession,
                    onStop: onStop,
                    onCancel: onCancel,
                    onPhaseExpired: onPhaseExpired,
                    onSkipBreak: onSkipBreak,
                  )
                : _StartCard(onStart: onStart),
          ),
        ),
        if (todayAnalytics != null && todayAnalytics.sessionCount > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnalyticsSummaryCard(analytics: todayAnalytics),
            ),
          ),
        if (todayAnalytics != null && todayAnalytics.perCourse.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: CourseBreakdownCard(courses: todayAnalytics.perCourse),
            ),
          ),
        if (weeklyAnalytics != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: WeeklyBarChart(weekly: weeklyAnalytics),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('History',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                sessionsAsync.whenOrNull(
                      data: (s) => Text('${s.length} sessions',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary)),
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        sessionsAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('Error: $e')),
          ),
          data: (sessions) {
            if (sessions.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No sessions yet — start studying!',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final session = sessions[i];
                  return SessionTile(
                    session: session,
                    onDelete: () => ref
                        .read(sessionRepositoryProvider)
                        ?.deleteSession(session.id),
                  );
                },
                childCount: sessions.length,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ── Start card with mode toggle ───────────────────────────────────────────────

class _StartCard extends StatefulWidget {
  final void Function(bool isPomodoroMode, Duration focus, Duration shortBreak,
      Duration longBreak) onStart;
  const _StartCard({required this.onStart});

  @override
  State<_StartCard> createState() => _StartCardState();
}

class _StartCardState extends State<_StartCard> {
  bool _isPomodoroMode = false;
  int _focusMinutes = 1;
  int _shortBreakMinutes = 1;
  int _longBreakMinutes = 15;

  void _adjust(
      int current, int delta, int min, int max, void Function(int) update) {
    final next = current + delta;
    if (next >= min && next <= max) setState(() => update(next));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        children: [
          // Mode toggle
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _ModeChip(
                  label: 'Normal',
                  icon: Icons.timer_outlined,
                  selected: !_isPomodoroMode,
                  onTap: () => setState(() => _isPomodoroMode = false),
                ),
                _ModeChip(
                  label: 'Pomodoro',
                  icon: Icons.hourglass_bottom_rounded,
                  selected: _isPomodoroMode,
                  onTap: () => setState(() => _isPomodoroMode = true),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_isPomodoroMode) ...[
            _DurationStepper(
              label: 'Focus',
              minutes: _focusMinutes,
              onDecrement: () =>
                  _adjust(_focusMinutes, -5, 10, 60, (v) => _focusMinutes = v),
              onIncrement: () =>
                  _adjust(_focusMinutes, 5, 10, 60, (v) => _focusMinutes = v),
            ),
            const SizedBox(height: 8),
            _DurationStepper(
              label: 'Short Break',
              minutes: _shortBreakMinutes,
              onDecrement: () => _adjust(
                  _shortBreakMinutes, -5, 5, 30, (v) => _shortBreakMinutes = v),
              onIncrement: () => _adjust(
                  _shortBreakMinutes, 5, 5, 30, (v) => _shortBreakMinutes = v),
            ),
            const SizedBox(height: 8),
            _DurationStepper(
              label: 'Long Break',
              minutes: _longBreakMinutes,
              onDecrement: () => _adjust(
                  _longBreakMinutes, -5, 10, 60, (v) => _longBreakMinutes = v),
              onIncrement: () => _adjust(
                  _longBreakMinutes, 5, 10, 60, (v) => _longBreakMinutes = v),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const Text(
              'Pick a course and start your session',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onStart(
                _isPomodoroMode,
                Duration(minutes: _focusMinutes),
                Duration(minutes: _shortBreakMinutes),
                Duration(minutes: _longBreakMinutes),
              ),
              icon: Icon(_isPomodoroMode
                  ? Icons.hourglass_bottom_rounded
                  : Icons.play_arrow),
              label: Text(
                _isPomodoroMode ? 'Start Pomodoro' : 'Start Session',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
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

  const _DurationStepper({
    required this.label,
    required this.minutes,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ),
        const Spacer(),
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          color: AppTheme.primary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '$minutes min',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          color: AppTheme.primary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
