import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

class HubOverviewTab extends ConsumerWidget {
  final CourseModel course;

  const HubOverviewTab({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final perCourseStreak = ref.watch(perCourseStreakProvider);
    final courseStreak = perCourseStreak[course.code];

    final sessions = sessionsAsync.valueOrNull ?? [];
    final courseSessions =
        sessions.where((s) => s.courseCode == course.code).toList();
    final allCourses = coursesAsync.valueOrNull ?? [];

    final totalMinutes =
        courseSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    final lastSession = courseSessions.isNotEmpty
        ? courseSessions
            .reduce((a, b) => a.startTime.isAfter(b.startTime) ? a : b)
        : null;
    final daysSince = lastSession != null
        ? DateTime.now().difference(lastSession.startTime).inDays
        : -1;
    final lastStudiedLabel = daysSince < 0
        ? 'Not studied yet'
        : daysSince == 0
            ? 'Today'
            : daysSince == 1
                ? 'Yesterday'
                : '$daysSince days ago';

    // CWA contribution: (creditHours * score) / totalCreditHours
    final totalCredits =
        allCourses.fold<double>(0, (sum, c) => sum + c.creditHours);
    final contribution = totalCredits > 0
        ? (course.creditHours * course.expectedScore) / totalCredits
        : 0.0;

    // CWA impact: what happens to CWA if this course changes by 10%
    final pairs = allCourses
        .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
        .toList();
    final currentCwa = CwaCalculator.calculate(pairs);

    final gradeLabel = _gradeLabel(course.expectedScore);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // ── Course info card ─────────────────────────────────────────
        _InfoCard(
          title: 'Course',
          children: [
            _InfoRow(label: 'Code', value: course.code, bold: true),
            _InfoRow(label: 'Name', value: course.name),
            _InfoRow(
                label: 'Credits',
                value: '${course.creditHours.toInt()} credit hours'),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Score card ───────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Expected Score',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${course.expectedScore.toInt()}%',
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _gradeColor(course.expectedScore)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.md2),
                      ),
                      child: Text(
                        gradeLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _gradeColor(course.expectedScore),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                LinearProgressIndicator(
                  value: course.expectedScore / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _gradeColor(course.expectedScore)),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── CWA contribution ─────────────────────────────────────────
        _InfoCard(
          title: 'CWA Impact',
          children: [
            _InfoRow(
              label: 'Your CWA',
              value: '${currentCwa.toStringAsFixed(1)}%',
              bold: true,
            ),
            _InfoRow(
              label: 'This course contributes',
              value: '${contribution.toStringAsFixed(1)} pts',
            ),
            _InfoRow(
              label: 'Weight',
              value: totalCredits > 0
                  ? '${((course.creditHours / totalCredits) * 100).toStringAsFixed(0)}% of CWA'
                  : '—',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Study stats ──────────────────────────────────────────────
        _InfoCard(
          title: 'Study Stats',
          children: [
            _InfoRow(label: 'Sessions', value: '${courseSessions.length}'),
            _InfoRow(label: 'Total time', value: timeStr),
            _InfoRow(label: 'Last studied', value: lastStudiedLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Streak mini ──────────────────────────────────────────────
        if (courseStreak != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: courseStreak.isAlive
                          ? Colors.orange.shade50
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_fire_department,
                        size: 28,
                        color:
                            courseStreak.isAlive ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${courseStreak.currentStreak}-day course streak',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text(
                          courseStreak.statusMessage,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _gradeLabel(double score) {
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  Color _gradeColor(double score) {
    if (score >= 70) return AppTheme.success;
    if (score >= 50) return AppTheme.accent;
    return AppTheme.warning;
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
