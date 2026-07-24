import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CourseBalanceCard extends StatelessWidget {
  final List<CourseStats> courses;
  final void Function(CourseStats course) onPlanCourse;

  const CourseBalanceCard({
    super.key,
    required this.courses,
    required this.onPlanCourse,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    final maxMinutes = courses.fold<int>(
      0,
      (current, course) =>
          course.actualMinutes > current ? course.actualMinutes : current,
    );
    final visible = courses.take(5).toList();
    final neglected = courses.where((course) => course.actualMinutes == 0);

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your courses this week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final course in visible) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.courseCode,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(course.formattedActual),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            LinearProgressIndicator(
              value: maxMinutes == 0 ? 0 : course.actualMinutes / maxMinutes,
              minHeight: 6,
              borderRadius: AppRadii.pill,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (neglected.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.bookOpen, size: AppIconSizes.md),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'You haven’t studied ${neglected.first.courseName} this week.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onPlanCourse(neglected.first),
                child: const Text('Start this course'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
