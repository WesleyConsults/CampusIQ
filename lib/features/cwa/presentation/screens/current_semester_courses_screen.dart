import 'dart:async';

import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/screens/complete_semester_screen.dart';
import 'package:campusiq/features/cwa/presentation/widgets/active_semester_picker.dart';
import 'package:campusiq/features/cwa/presentation/widgets/academic_data_correction_hint.dart';
import 'package:campusiq/features/cwa/presentation/widgets/add_course_sheet.dart';
import 'package:campusiq/features/cwa/presentation/widgets/course_card.dart';
import 'package:campusiq/features/cwa/presentation/widgets/timetable_course_import_sheet.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
import 'package:campusiq/shared/widgets/campus_feedback.dart';
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
    if (repo == null) {
      if (context.mounted) {
        CampusFeedback.showError(
          context,
          message: 'Course could not be saved. Your changes were not lost.',
        );
      }
      return;
    }

    try {
      existing == null
          ? await repo.addCourse(result)
          : await repo.updateCourse(result);
      await AnalyticsService.instance.logCourseSaved(
        action: existing == null ? 'created' : 'updated',
        source: 'current_semester_courses',
        gradingSystem: selectedSystem.id,
      );
      if (context.mounted) {
        CampusFeedback.showSuccess(
          context,
          message: existing == null
              ? '${result.code} added'
              : '${result.code} updated',
        );
      }
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'course_save_failed',
        context: {'source': 'current_semester_courses'},
      );
      debugPrint('CurrentSemesterCoursesScreen _openAddSheet failed: $e');
      if (context.mounted) {
        CampusFeedback.showError(
          context,
          message: 'Course could not be saved. Please try again.',
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
      final repo = ref.read(cwaRepositoryProvider);
      if (repo == null) {
        if (context.mounted) {
          CampusFeedback.showError(
            context,
            message: 'Course could not be deleted. Please try again.',
          );
        }
        return;
      }
      await repo.deleteCourse(course.id);
      if (context.mounted) {
        CampusFeedback.showSuccess(
          context,
          message: '${course.code} deleted',
        );
      }
    } catch (e) {
      debugPrint('CurrentSemesterCoursesScreen deleteCourse failed: $e');
      if (context.mounted) {
        CampusFeedback.showError(
          context,
          message: 'Course could not be deleted. Please try again.',
        );
      }
    }
  }

  void _previewExpectedScore(
    WidgetRef ref,
    int courseId,
    double score,
  ) {
    ref.read(inFlightScoreAdjustmentsProvider.notifier).state = {
      ...ref.read(inFlightScoreAdjustmentsProvider),
      courseId: score,
    };
  }

  Future<void> _saveExpectedScore(
    BuildContext context,
    WidgetRef ref,
    CourseModel course,
    double score,
  ) async {
    final repo = ref.read(cwaRepositoryProvider);
    final prefs = ref.read(cwaPrefsRepositoryProvider);
    final oldScore = course.expectedScore;
    course.expectedScore = score;

    try {
      if (repo == null) throw StateError('Course repository is unavailable');
      await repo.updateCourse(course);
      await prefs?.setAcademicProjectionAdjusted(true);
    } catch (e, stackTrace) {
      course.expectedScore = oldScore;
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'course_projection_update_failed',
        context: {'courseId': course.id, 'source': 'inline_projection'},
      );
      if (context.mounted) {
        CampusFeedback.showError(
          context,
          message: 'Could not update the projection. Please try again.',
        );
      }
    } finally {
      final adjustments = {
        ...ref.read(inFlightScoreAdjustmentsProvider),
      }..remove(course.id);
      ref.read(inFlightScoreAdjustmentsProvider.notifier).state = adjustments;
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
    CampusFeedback.showSuccess(
      context,
      message: 'Semester completed. You are now in $nextSemesterLabel.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final selectedGradingSystem = ref.watch(gradingSystemProvider);
    final projected = ref.watch(projectedCwaProvider);
    final activeSemesterKey = ref.watch(activeSemesterProvider);
    final guideState = ref.watch(academicPlannerGuideProvider).valueOrNull ??
        AcademicPlannerGuideState.initial;

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
          final highImpactCourseId = courses.isEmpty
              ? null
              : courses
                  .reduce((a, b) => a.creditHours >= b.creditHours ? a : b)
                  .id;

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
              if (courses.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                if (!guideState.hasAdjustedProjection) ...[
                  _ProjectionGuideCard(gradingSystem: gradingSystem),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const AcademicDataCorrectionHint(
                  message:
                      'Added something by mistake? Use the menu on a course to edit or delete it. Completed results belong in Academic History.',
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (courses.isEmpty)
                _EmptyCoursesCard(
                  gradingSystem: gradingSystem,
                  onAddCourse: () => _openAddSheet(context, ref),
                  onUseTimetable: () => showTimetableCourseImportSheet(context),
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
                  CourseCard(
                    course: course,
                    gradingSystem:
                        _gradingSystemForCourse(course, gradingSystem),
                    isHighImpact: course.id == highImpactCourseId,
                    onEdit: () => _openAddSheet(
                      context,
                      ref,
                      existing: course,
                    ),
                    onDelete: () => _deleteCourse(context, ref, course),
                    onScoreChanged: (score) =>
                        _previewExpectedScore(ref, course.id, score),
                    onDragEnd: (score) {
                      unawaited(
                        _saveExpectedScore(
                          context,
                          ref,
                          course,
                          score,
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                  if (course != courses.last)
                    const SizedBox(height: AppSpacing.xs2),
                ],
              ],
              const SizedBox(height: AppSpacing.lg),
              _CourseActionsCard(
                hasCourses: courses.isNotEmpty,
                onAddCourse: () => _openAddSheet(context, ref),
                onUseTimetable: () => showTimetableCourseImportSheet(context),
                onImportCourses: () =>
                    context.pushNamed('cwa-import-registration'),
                onSaveFinalResults: courses.isEmpty
                    ? null
                    : () => _openCompleteSemester(context, ref, courses),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProjectionGuideCard extends StatelessWidget {
  final GradingSystem gradingSystem;

  const _ProjectionGuideCard({required this.gradingSystem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: AppRadii.card,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.slidersHorizontal,
            color: colorScheme.primary,
            size: AppIconSizes.xxl,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Try a projected score',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Open the adjustment on any course and change its expected '
                  '${gradingSystem.usesLetterGrades ? 'grade' : 'score'}. '
                  'Your projected ${gradingSystem.label} updates instantly.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  final VoidCallback onUseTimetable;
  final VoidCallback onImportCourses;
  final VoidCallback? onSaveFinalResults;

  const _CourseActionsCard({
    required this.hasCourses,
    required this.onAddCourse,
    required this.onUseTimetable,
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
                : 'Add courses manually, from your timetable, or from a registration slip.',
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
                onPressed: onUseTimetable,
                icon: const Icon(
                  LucideIcons.calendarDays,
                  size: AppIconSizes.md,
                ),
                label: const Text('Use Timetable'),
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
  final VoidCallback onUseTimetable;
  final VoidCallback onImportCourses;

  const _EmptyCoursesCard({
    required this.gradingSystem,
    required this.onAddCourse,
    required this.onUseTimetable,
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
                onPressed: onUseTimetable,
                icon: const Icon(
                  LucideIcons.calendarDays,
                  size: AppIconSizes.md,
                ),
                label: const Text('Use Timetable'),
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
