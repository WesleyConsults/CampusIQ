import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_chip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CourseBreakdownCard extends StatelessWidget {
  final List<CourseStats> courses;

  const CourseBreakdownCard({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return CampusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CampusChip(
                label: 'By course',
                icon: LucideIcons.bookCopy,
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: AppTheme.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...courses.map((course) => _CourseRow(stats: course)),
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final CourseStats stats;

  const _CourseRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final fill = stats.completionRate.clamp(0.0, 1.0);
    final accent = stats.isOverStudied
        ? AppTheme.success
        : fill >= 0.7
            ? AppTheme.primary
            : AppTheme.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: () => context.push('/course/${stats.courseCode}'),
        borderRadius: AppRadii.button,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.courseCode,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          stats.courseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    stats.plannedMinutes > 0
                        ? '${stats.formattedActual} / ${stats.formattedPlanned}'
                        : stats.formattedActual,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fill,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                stats.plannedMinutes == 0
                    ? 'A self-directed study block with no timetable plan attached yet.'
                    : stats.isOverStudied
                        ? 'You went beyond plan here. Nicely done.'
                        : 'Need ${_fmt(stats.gapMinutes)} more to match your timetable plan.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
