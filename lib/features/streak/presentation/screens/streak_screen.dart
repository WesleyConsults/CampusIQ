import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/streak/presentation/widgets/activity_heatmap.dart';
import 'package:campusiq/features/streak/presentation/widgets/attendance_tracker.dart';
import 'package:campusiq/features/streak/presentation/widgets/course_streak_list.dart';
import 'package:campusiq/features/streak/presentation/widgets/milestone_grid.dart';
import 'package:campusiq/features/streak/presentation/widgets/next_milestone_card.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_hero_card.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_summary_mini.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  /// Builds a day → session count map for the heatmap
  Map<DateTime, int> _buildActivityMap(List<StudySessionModel> sessions) {
    final map = <DateTime, int>{};
    for (final s in sessions) {
      final norm = DateTime(
          s.startTime.year, s.startTime.month, s.startTime.day);
      map[norm] = (map[norm] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyStreak      = ref.watch(studyStreakProvider);
    final attendanceStreak = ref.watch(attendanceStreakProvider);
    final perCourseStreaks  = ref.watch(perCourseStreakProvider);
    final attendedDates    = ref.watch(attendedDatesProvider).valueOrNull ?? [];
    final sessions         = ref.watch(allSessionsProvider).valueOrNull ?? [];
    final prefsRepo        = ref.watch(userPrefsRepositoryProvider);

    final activityMap = _buildActivityMap(sessions);
    final activeCourseStreaks = perCourseStreaks.values
        .where((r) => r.currentStreak > 0)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Streaks',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Summary mini row ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: StreakSummaryRow(
                study: studyStreak,
                attendance: attendanceStreak,
                totalCourseStreaks: activeCourseStreaks,
              ),
            ),
          ),

          // ── Study streak hero ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: StreakHeroCard(
                streak: studyStreak,
                title: 'Study streak',
              ),
            ),
          ),

          // ── Next milestone ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: NextMilestoneCard(streak: studyStreak),
            ),
          ),

          // ── Milestone badge grid ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: MilestoneGrid(
                unlocked: studyStreak.unlockedMilestones,
                currentStreak: studyStreak.currentStreak,
              ),
            ),
          ),

          // ── Attendance tracker ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AttendanceTracker(
                attendanceStreak: attendanceStreak,
                attendedDates: attendedDates,
                onToggle: (date) => prefsRepo?.toggleAttendance(date),
              ),
            ),
          ),

          // ── Per-course streaks ────────────────────────────────────────
          if (perCourseStreaks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: CourseStreakList(streaks: perCourseStreaks),
              ),
            ),

          // ── Activity heatmap ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ActivityHeatmap(activityByDay: activityMap),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
