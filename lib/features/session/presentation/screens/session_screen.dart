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

  Future<void> _startSession(BuildContext context) async {
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
    );
  }

  Future<void> _stopSession(String semesterKey) async {
    final notifier = ref.read(activeSessionProvider.notifier);
    final completed = notifier.stopSession();
    if (completed == null) return;

    final durationMins = completed.elapsedMinutes;
    if (durationMins < 1) return;

    final todaySlots = ref.read(activeDaySlotsProvider);
    final wasPlanned = todaySlots.any((s) => s.courseCode == completed.courseCode);

    final session = StudySessionModel()
      ..courseCode = completed.courseCode
      ..courseName = completed.courseName
      ..startTime = completed.startTime
      ..endTime = DateTime.now()
      ..durationMinutes = durationMins
      ..wasPlanned = wasPlanned
      ..courseSource = completed.courseSource
      ..semesterKey = semesterKey;

    final repo = ref.read(sessionRepositoryProvider);
    await repo?.saveSession(session);

    await NotificationService.instance.cancelStudiedTodayAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(activeSessionProvider);
    final semester = ref.watch(activeSemesterProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Study Sessions',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const WeeklyReviewSheet(),
            ),
            child: const Text('This Week', style: TextStyle(color: Colors.white)),
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
          // Tab 0: History — all existing content
          _HistoryTab(
            activeSession: activeSession,
            semester: semester,
            onStart: () => _startSession(context),
            onStop: () => _stopSession(semester),
            onCancel: () => ref.read(activeSessionProvider.notifier).cancelSession(),
          ),
          // Tab 1: Plan
          const StudyPlanTab(),
        ],
      ),
    );
  }
}

// ── History tab — extracted so it can be kept as-is ─────────────────────────

class _HistoryTab extends ConsumerWidget {
  final dynamic activeSession;
  final String semester;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  const _HistoryTab({
    required this.activeSession,
    required this.semester,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                    onDelete: () =>
                        ref.read(sessionRepositoryProvider)?.deleteSession(session.id),
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

class _StartCard extends StatelessWidget {
  final VoidCallback onStart;
  const _StartCard({required this.onStart});

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
          const Icon(Icons.timer_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          const Text('Ready to study?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Pick a course and start your session',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session',
                  style: TextStyle(fontWeight: FontWeight.w700)),
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
