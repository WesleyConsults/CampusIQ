import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';

class HubOverviewTab extends ConsumerWidget {
  final CourseModel course;

  const HubOverviewTab({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allSessionsProvider);
    final coursesAsync = ref.watch(coursesProvider);
    final perCourseStreak = ref.watch(perCourseStreakProvider);
    final courseStreak = perCourseStreak[course.code];
    final selectedGradingSystem = ref.watch(gradingSystemProvider);
    final gradingSystem = course.gradingSystemId.trim().isEmpty
        ? selectedGradingSystem
        : GradingSystem.byId(course.gradingSystemId);

    // Loading state
    final isLoading = (sessionsAsync.isLoading && !sessionsAsync.hasValue) ||
        (coursesAsync.isLoading && !coursesAsync.hasValue);
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    final hasError = sessionsAsync.hasError || coursesAsync.hasError;
    if (hasError) {
      return ErrorRetryWidget(
        message: 'We could not load this course overview right now.',
        onRetry: () {
          ref.invalidate(allSessionsProvider);
          ref.invalidate(coursesProvider);
        },
      );
    }

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

    final totalCredits =
        allCourses.fold<double>(0, (sum, c) => sum + c.creditHours);
    final contribution = totalCredits > 0
        ? (course.creditHours * course.expectedScore) / totalCredits
        : 0.0;

    final pairs = allCourses
        .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
        .toList();
    final currentAverage = CwaCalculator.calculate(pairs);

    final gradeLabel = gradingSystem.letterForScore(course.expectedScore) ??
        _gradeLabel(course.expectedScore);
    final gradeColor =
        _gradeColor(course.expectedScore, context, gradingSystem);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // ── Score hero card ────────────────────────────────────────────
        _ScoreHeroCard(
          score: course.expectedScore,
          gradeLabel: gradeLabel,
          gradeColor: gradeColor,
          gradingSystem: gradingSystem,
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Course info ────────────────────────────────────────────────
        _InfoCard(
          icon: LucideIcons.bookOpen,
          title: 'Course',
          children: [
            _InfoRow(label: 'Code', value: course.code, bold: true),
            _InfoRow(label: 'Name', value: course.name),
            _InfoRow(
              label: 'Credits',
              value: '${course.creditHours.toInt()} credit hours',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Grade impact ───────────────────────────────────────────────
        _InfoCard(
          icon: LucideIcons.target,
          title: gradingSystem.impactTitle,
          children: [
            _InfoRow(
              label: 'Your ${gradingSystem.label}',
              value:
                  gradingSystem.formatScore(currentAverage, includeUnit: true),
              bold: true,
            ),
            _InfoRow(
              label: 'This course contributes',
              value: '${contribution.toStringAsFixed(1)} pts',
            ),
            _InfoRow(
              label: 'Weight',
              value: totalCredits > 0
                  ? '${((course.creditHours / totalCredits) * 100).toStringAsFixed(0)}% of ${gradingSystem.label}'
                  : '—',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Study stats ────────────────────────────────────────────────
        _InfoCard(
          icon: LucideIcons.chartColumn,
          title: 'Study Stats',
          children: [
            _InfoRow(label: 'Sessions', value: '${courseSessions.length}'),
            _InfoRow(label: 'Total time', value: timeStr),
            _InfoRow(label: 'Last studied', value: lastStudiedLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Streak mini ────────────────────────────────────────────────
        if (courseStreak != null)
          _StreakCard(
            streak: courseStreak.currentStreak,
            isAlive: courseStreak.isAlive,
            message: courseStreak.statusMessage,
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

  Color _gradeColor(
    double score,
    BuildContext context,
    GradingSystem gradingSystem,
  ) {
    final cs = Theme.of(context).colorScheme;
    final normalized =
        gradingSystem.maxScore == 0 ? 0.0 : score / gradingSystem.maxScore;
    if (normalized >= 0.7) return cs.primary;
    if (normalized >= 0.5) return cs.secondary;
    return cs.error;
  }
}

// ─── Score hero ────────────────────────────────────────────────────────────────

class _ScoreHeroCard extends StatelessWidget {
  final double score;
  final String gradeLabel;
  final Color gradeColor;
  final GradingSystem gradingSystem;

  const _ScoreHeroCard({
    required this.score,
    required this.gradeLabel,
    required this.gradeColor,
    required this.gradingSystem,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.surface, cs.surfaceContainerHighest],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gradingSystem.scoreInputLabel,
                style: textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                )),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  gradingSystem.formatScore(score, includeUnit: true),
                  style: textTheme.headlineLarge?.copyWith(
                    color: cs.primary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: gradeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      gradeLabel,
                      style: textTheme.titleMedium?.copyWith(
                        color: gradeColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xs),
              child: LinearProgressIndicator(
                value: gradingSystem.maxScore == 0
                    ? 0
                    : (score / gradingSystem.maxScore).clamp(0.0, 1.0),
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info card (icon + title + rows) ───────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: AppIconSizes.lg,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Streak card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  final bool isAlive;
  final String message;

  static const double _iconSize = 48;

  const _StreakCard({
    required this.streak,
    required this.isAlive,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: _iconSize,
              height: _iconSize,
              decoration: BoxDecoration(
                color: isAlive
                    ? Colors.orange.withValues(alpha: 0.15)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                LucideIcons.flame,
                size: AppIconSizes.hero,
                color: isAlive
                    ? Colors.orange
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak-day course streak',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    message,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
