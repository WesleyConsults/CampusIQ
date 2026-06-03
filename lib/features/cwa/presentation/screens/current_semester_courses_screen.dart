import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/screens/complete_semester_screen.dart';
import 'package:campusiq/features/cwa/presentation/widgets/active_semester_picker.dart';
import 'package:campusiq/features/cwa/presentation/widgets/add_course_sheet.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CurrentSemesterCoursesScreen extends ConsumerWidget {
  const CurrentSemesterCoursesScreen({super.key});

  Future<void> _openAddSheet(
    BuildContext context,
    WidgetRef ref, {
    CourseModel? existing,
  }) async {
    final selectedSystem = ref.read(gradingSystemProvider);
    final sheetSystem = existing == null
        ? selectedSystem
        : GradingSystem.byId(existing.gradingSystemId);
    final result = await showModalBottomSheet<CourseModel>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCourseSheet(
        semesterKey: ref.read(activeSemesterProvider),
        existing: existing,
        gradingSystem: sheetSystem,
      ),
    );

    if (result == null) return;
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) return;

    try {
      existing == null
          ? await repo.addCourse(result)
          : await repo.updateCourse(result);
      await AnalyticsService.instance.logCourseSaved(
        action: existing == null ? 'created' : 'updated',
        source: 'current_semester_courses',
        gradingSystem: selectedSystem.id,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'course_save_failed',
        context: {'source': 'current_semester_courses'},
      );
      debugPrint('CurrentSemesterCoursesScreen _openAddSheet failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save course. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _deleteCourse(
    BuildContext context,
    WidgetRef ref,
    CourseModel course,
  ) async {
    final confirm = await showCampusConfirmDialog(
      context: context,
      title: 'Delete course?',
      message:
          'Remove ${course.code} from this semester projection? This only deletes the course entry from your current setup.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirm != true) return;

    try {
      await ref.read(cwaRepositoryProvider)?.deleteCourse(course.id);
    } catch (e) {
      debugPrint('CurrentSemesterCoursesScreen deleteCourse failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete course. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _openCompleteSemester(
    BuildContext context,
    WidgetRef ref,
    List<CourseModel> courses,
  ) async {
    if (courses.isEmpty) return;

    final nextSemesterLabel =
        await Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(
        builder: (_) => CompleteSemesterScreen(
          currentSemesterKey: ref.read(activeSemesterProvider),
          courses: courses,
        ),
      ),
    );

    if (nextSemesterLabel == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Semester completed. You are now in $nextSemesterLabel.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final selectedGradingSystem = ref.watch(gradingSystemProvider);
    final projected = ref.watch(projectedCwaProvider);
    final activeSemesterKey = ref.watch(activeSemesterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Current Semester',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: AppSpacing.screenPadding,
          child: ErrorRetryWidget(
            message: 'We could not load your courses right now.',
            onRetry: () => ref.invalidate(coursesProvider),
          ),
        ),
        data: (courses) {
          final gradingSystem =
              _gradingSystemForCourses(courses, selectedGradingSystem);
          final credits = courses.fold<double>(
            0,
            (sum, course) => sum + course.creditHours,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            children: [
              _CurrentSemesterHeader(
                semesterLabel: formatActiveSemesterLabel(activeSemesterKey),
                gradingSystem: gradingSystem,
                projected: projected,
                courseCount: courses.length,
                credits: credits,
              ),
              const SizedBox(height: AppSpacing.md),
              _CourseActionsCard(
                hasCourses: courses.isNotEmpty,
                onAddCourse: () => _openAddSheet(context, ref),
                onImportCourses: () =>
                    context.pushNamed('cwa-import-registration'),
                onSaveFinalResults: courses.isEmpty
                    ? null
                    : () => _openCompleteSemester(context, ref, courses),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (courses.isEmpty)
                _EmptyCoursesCard(
                  gradingSystem: gradingSystem,
                  onAddCourse: () => _openAddSheet(context, ref),
                  onImportCourses: () =>
                      context.pushNamed('cwa-import-registration'),
                )
              else ...[
                Text(
                  'Courses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs2),
                for (final course in courses) ...[
                  _CompactCurrentCourseCard(
                    course: course,
                    gradingSystem:
                        _gradingSystemForCourse(course, gradingSystem),
                    onEditScore: () => _openAddSheet(
                      context,
                      ref,
                      existing: course,
                    ),
                    onEdit: () => _openAddSheet(
                      context,
                      ref,
                      existing: course,
                    ),
                    onDelete: () => _deleteCourse(context, ref, course),
                  ),
                  if (course != courses.last)
                    const SizedBox(height: AppSpacing.xs2),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CurrentSemesterHeader extends StatelessWidget {
  final String semesterLabel;
  final GradingSystem gradingSystem;
  final double projected;
  final int courseCount;
  final double credits;

  const _CurrentSemesterHeader({
    required this.semesterLabel,
    required this.gradingSystem,
    required this.projected,
    required this.courseCount,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navySoft],
        ),
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            semesterLabel,
            style: const TextStyle(
              color: AppColors.goldSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            courseCount == 0 ? '--' : gradingSystem.formatScore(projected),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Projected ${gradingSystem.label}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _HeaderStat(label: 'Courses', value: '$courseCount'),
              const SizedBox(width: AppSpacing.xs2),
              _HeaderStat(label: 'Credits', value: '${credits.toInt()} cr'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxs),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseActionsCard extends StatelessWidget {
  final bool hasCourses;
  final VoidCallback onAddCourse;
  final VoidCallback onImportCourses;
  final VoidCallback? onSaveFinalResults;

  const _CourseActionsCard({
    required this.hasCourses,
    required this.onAddCourse,
    required this.onImportCourses,
    required this.onSaveFinalResults,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasCourses ? 'Manage courses' : 'Add your first courses',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            hasCourses
                ? 'Keep your course list and expected scores up to date.'
                : 'Add courses manually or import your registration slip.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs2,
            runSpacing: AppSpacing.xs2,
            children: [
              ElevatedButton.icon(
                onPressed: onAddCourse,
                icon: const Icon(LucideIcons.plus, size: AppIconSizes.md),
                label: const Text('Add Course'),
              ),
              OutlinedButton.icon(
                onPressed: onImportCourses,
                icon: const Icon(LucideIcons.fileUp, size: AppIconSizes.md),
                label: const Text('Import Courses'),
              ),
              if (onSaveFinalResults != null)
                OutlinedButton.icon(
                  onPressed: onSaveFinalResults,
                  icon: const Icon(
                    LucideIcons.badgeCheck,
                    size: AppIconSizes.md,
                  ),
                  label: const Text('Save Final Results'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCoursesCard extends StatelessWidget {
  final GradingSystem gradingSystem;
  final VoidCallback onAddCourse;
  final VoidCallback onImportCourses;

  const _EmptyCoursesCard({
    required this.gradingSystem,
    required this.onAddCourse,
    required this.onImportCourses,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(
              LucideIcons.bookOpen,
              color: colorScheme.primary,
              size: AppIconSizes.xxxl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No courses yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add your current semester courses to see your projected ${gradingSystem.label}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs2,
            runSpacing: AppSpacing.xs2,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onAddCourse,
                icon: const Icon(LucideIcons.plus, size: AppIconSizes.md),
                label: const Text('Add Course'),
              ),
              OutlinedButton.icon(
                onPressed: onImportCourses,
                icon: const Icon(LucideIcons.fileUp, size: AppIconSizes.md),
                label: const Text('Import'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactCurrentCourseCard extends StatelessWidget {
  final CourseModel course;
  final GradingSystem gradingSystem;
  final VoidCallback onEditScore;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CompactCurrentCourseCard({
    required this.course,
    required this.gradingSystem,
    required this.onEditScore,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${course.creditHours.toInt()} cr',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.xxs),
                ),
                child: Text(
                  gradingSystem.formatScore(course.expectedScore),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: onEditScore,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
          PopupMenuButton<_CourseMenuAction>(
            tooltip: 'Course options',
            icon:
                const Icon(LucideIcons.ellipsisVertical, size: AppIconSizes.lg),
            onSelected: (action) {
              switch (action) {
                case _CourseMenuAction.edit:
                  onEdit();
                  return;
                case _CourseMenuAction.delete:
                  onDelete();
                  return;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _CourseMenuAction.edit,
                child: Text('Edit course'),
              ),
              PopupMenuItem(
                value: _CourseMenuAction.delete,
                child: Text('Delete course'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CourseMenuAction { edit, delete }

GradingSystem _gradingSystemForCourse(
  CourseModel course,
  GradingSystem fallback,
) {
  final system = GradingSystem.byId(course.gradingSystemId);
  return course.gradingSystemId.trim().isEmpty ? fallback : system;
}

GradingSystem _gradingSystemForCourses(
  List<CourseModel> courses,
  GradingSystem fallback,
) {
  if (courses.isEmpty) return fallback;
  final first = _gradingSystemForCourse(courses.first, fallback);
  final sameSystem = courses.every(
    (course) => _gradingSystemForCourse(course, fallback).id == first.id,
  );
  return sameSystem ? first : fallback;
}
