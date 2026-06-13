import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/layout/shell_overlay_padding.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/active_semester_picker.dart';
import 'package:campusiq/features/cwa/presentation/screens/complete_semester_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/current_semester_courses_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';
import 'package:campusiq/shared/widgets/import_option_grid.dart';

class CwaScreen extends ConsumerWidget {
  const CwaScreen({super.key});

  void _openHistory(BuildContext context) {
    context.pushNamed('cwa-history');
  }

  Future<void> _openManualBaselineDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GradingSystem gradingSystem,
    required ManualAcademicBaseline? existingBaseline,
  }) async {
    final repo = ref.read(cwaPrefsRepositoryProvider);
    if (repo == null) return;

    final result = await showModalBottomSheet<({double score, double credits})>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualAcademicBaselineSheet(
        gradingSystem: gradingSystem,
        existingBaseline: existingBaseline,
      ),
    );

    if (result == null) return;

    try {
      await repo.setManualAcademicBaseline(
        score: result.score,
        credits: result.credits,
        gradingSystemId: gradingSystem.id,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your starting point. Try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    final gradingSystem = ref.watch(gradingSystemProvider);
    final hasActiveSession = ref.watch(activeSessionProvider) != null;
    final bottomContentPadding = shellOverlayBottomPadding(
      context,
      hasActiveSession: hasActiveSession,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final currentCourses = ref.watch(coursesProvider).valueOrNull ?? [];
    final manualBaseline =
        ref.watch(manualAcademicBaselineProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          gradingSystem.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<_CwaMenuAction>(
            tooltip: 'More options',
            icon: const Icon(LucideIcons.ellipsisVertical),
            onSelected: (action) {
              switch (action) {
                case _CwaMenuAction.history:
                  _openHistory(context);
                  return;
                case _CwaMenuAction.settings:
                  context.pushNamed('settings');
                  return;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _CwaMenuAction.history,
                child: Text('View result history'),
              ),
              const PopupMenuItem(
                value: _CwaMenuAction.settings,
                child: Text('App settings'),
              ),
            ],
          ),
        ],
      ),
      body: _CwaDashboardView(
        bottomContentPadding: bottomContentPadding,
        onOpenHistory: _openHistory,
        onOpenCompleteSemester: _openCompleteSemester,
        onOpenManualBaseline: _openManualBaselineDialog,
        onShowImportSheet: _showImportSheet,
        onShowTargetDialog: _showTargetDialog,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(
          context,
          ref,
          currentCourses: currentCourses,
          gradingSystem: gradingSystem,
          manualBaseline: manualBaseline,
        ),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  void _showTargetDialog(
    BuildContext context,
    WidgetRef ref,
    double current,
    GradingSystem gradingSystem,
  ) {
    double temp = current
        .clamp(gradingSystem.targetMin, gradingSystem.targetMax)
        .toDouble();
    final step = gradingSystem.maxScore <= 5 ? 0.1 : 1.0;
    final targetDivisions =
        ((gradingSystem.targetMax - gradingSystem.targetMin) / step).round();
    showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text('Set Target ${gradingSystem.label}'),
          content: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: colorScheme.primary,
                      iconSize: 32,
                      onPressed: temp > gradingSystem.targetMin
                          ? () => setState(
                                () => temp = (temp - step)
                                    .clamp(
                                      gradingSystem.targetMin,
                                      gradingSystem.targetMax,
                                    )
                                    .toDouble(),
                              )
                          : null,
                    ),
                    Text(
                      gradingSystem.formatScore(temp),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: colorScheme.primary,
                      iconSize: 32,
                      onPressed: temp < gradingSystem.targetMax
                          ? () => setState(
                                () => temp = (temp + step)
                                    .clamp(
                                      gradingSystem.targetMin,
                                      gradingSystem.targetMax,
                                    )
                                    .toDouble(),
                              )
                          : null,
                    ),
                  ],
                ),
                Slider(
                  value: temp,
                  min: gradingSystem.targetMin,
                  max: gradingSystem.targetMax,
                  divisions: targetDivisions,
                  activeColor: colorScheme.primary,
                  onChanged: (v) => setState(() => temp = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(cwaPrefsRepositoryProvider);
                if (repo == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Your target settings are not ready yet. Please try again.',
                        ),
                      ),
                    );
                  }
                  Navigator.pop(ctx);
                  return;
                }

                try {
                  await repo.setTargetCwa(
                    temp,
                    min: gradingSystem.targetMin,
                    max: gradingSystem.targetMax,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  debugPrint('🔴 CwaScreen _showTargetDialog failed: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not save your target. Please try again.',
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void _showImportSheet(BuildContext context, CwaViewMode viewMode) {
    final title =
        viewMode == CwaViewMode.semester ? 'Import Courses' : 'Import Results';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ImportOptionsSheet(
        title: title,
        options: [
          _ImportOption(
            icon: LucideIcons.camera,
            label: 'Take Photo',
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openImportScreen(context, viewMode, initialSource: 'camera');
            },
          ),
          _ImportOption(
            icon: LucideIcons.imageUp,
            label: 'Upload Image',
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openImportScreen(context, viewMode, initialSource: 'gallery');
            },
          ),
          _ImportOption(
            icon: LucideIcons.fileText,
            label: 'Choose PDF',
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openImportScreen(context, viewMode, initialSource: 'pdf');
            },
          ),
          _ImportOption(
            icon: LucideIcons.squarePen,
            label: 'Enter Manually',
            onTap: () {
              Navigator.of(sheetContext).pop();
              context.push(
                '/cwa/manual-entry?mode=${viewMode == CwaViewMode.semester ? 'semester' : 'cumulative'}',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddGoalSheet(
    BuildContext context,
    WidgetRef ref, {
    required List<CourseModel> currentCourses,
    required GradingSystem gradingSystem,
    required ManualAcademicBaseline? manualBaseline,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AddGoalSheet(
        hasCurrentCourses: currentCourses.isNotEmpty,
        gradingSystem: gradingSystem,
        onCurrentCourses: () {
          Navigator.of(sheetContext).pop();
          _showImportSheet(context, CwaViewMode.semester);
        },
        onPastResults: () {
          Navigator.of(sheetContext).pop();
          _showImportSheet(context, CwaViewMode.cumulative);
        },
        onCurrentCwaOnly: () {
          Navigator.of(sheetContext).pop();
          _openManualBaselineDialog(
            context: context,
            ref: ref,
            gradingSystem: gradingSystem,
            existingBaseline: manualBaseline,
          );
        },
        onFinalResults: () {
          Navigator.of(sheetContext).pop();
          _openCompleteSemester(context, ref, currentCourses);
        },
      ),
    );
  }

  void _openImportScreen(
    BuildContext context,
    CwaViewMode viewMode, {
    required String initialSource,
  }) {
    final path = viewMode == CwaViewMode.semester
        ? 'cwa-import-registration'
        : 'cwa-import-results';
    context.pushNamed(path, queryParameters: {'source': initialSource});
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
      (course) => _gradingSystemForCourse(course, fallback).id == first.id);
  return sameSystem ? first : fallback;
}

enum _CwaMenuAction { history, settings }

class _ImportOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImportOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _ImportOptionsSheet extends StatelessWidget {
  final String title;
  final List<_ImportOption> options;

  const _ImportOptionsSheet({
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return CampusModalSheet(
      title: title,
      leading: const _ImportSheetIcon(),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
        tooltip: 'Close',
      ),
      child: ImportOptionGrid(
        options: options
            .map(
              (option) => ImportOptionGridItem(
                icon: option.icon,
                label: option.label,
                onTap: option.onTap,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ImportSheetIcon extends StatelessWidget {
  const _ImportSheetIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: AppRadii.button,
      ),
      child: Icon(
        LucideIcons.fileUp,
        color: colorScheme.onSecondaryContainer,
        size: AppIconSizes.xl,
      ),
    );
  }
}

class _CwaDashboardView extends ConsumerWidget {
  final void Function(BuildContext context) onOpenHistory;
  final Future<void> Function(BuildContext, WidgetRef, List<CourseModel>)
      onOpenCompleteSemester;
  final Future<void> Function({
    required BuildContext context,
    required WidgetRef ref,
    required GradingSystem gradingSystem,
    required ManualAcademicBaseline? existingBaseline,
  }) onOpenManualBaseline;
  final void Function(BuildContext context, CwaViewMode viewMode)
      onShowImportSheet;
  final void Function(
    BuildContext context,
    WidgetRef ref,
    double current,
    GradingSystem gradingSystem,
  ) onShowTargetDialog;
  final double bottomContentPadding;

  const _CwaDashboardView({
    required this.onOpenHistory,
    required this.onOpenCompleteSemester,
    required this.onOpenManualBaseline,
    required this.onShowImportSheet,
    required this.onShowTargetDialog,
    required this.bottomContentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final semestersAsync = ref.watch(pastSemestersProvider);
    final selectedGradingSystem = ref.watch(gradingSystemProvider);
    final projected = ref.watch(projectedCwaProvider);
    final cumulative = ref.watch(cumulativeCwaProvider);
    final cumulativeGap = ref.watch(cumulativeGapProvider);
    final target = ref.watch(targetCwaProvider);
    final totalCredits = ref.watch(totalCreditsProvider);
    final activeSemesterKey = ref.watch(activeSemesterProvider);
    final manualBaseline =
        ref.watch(manualAcademicBaselineProvider).valueOrNull;

    if (coursesAsync.hasError && coursesAsync.valueOrNull == null) {
      return Padding(
        padding: AppSpacing.screenPadding,
        child: ErrorRetryWidget(
          message: 'We could not load your courses right now.',
          onRetry: () => ref.invalidate(coursesProvider),
        ),
      );
    }

    if (semestersAsync.hasError && semestersAsync.valueOrNull == null) {
      return Padding(
        padding: AppSpacing.screenPadding,
        child: ErrorRetryWidget(
          message: 'We could not load your academic history right now.',
          onRetry: () => ref.invalidate(pastSemestersProvider),
        ),
      );
    }

    if ((coursesAsync.isLoading && coursesAsync.valueOrNull == null) ||
        (semestersAsync.isLoading && semestersAsync.valueOrNull == null)) {
      return const Center(child: CircularProgressIndicator());
    }

    final courses = coursesAsync.valueOrNull ?? const <CourseModel>[];
    final semesters = semestersAsync.valueOrNull ?? const <PastSemesterModel>[];
    final gradingSystem =
        _gradingSystemForCourses(courses, selectedGradingSystem);
    final currentCredits =
        courses.fold<double>(0, (sum, course) => sum + course.creditHours);
    final completedCredits = _completedCreditsForHistory(
      semesters,
      manualBaseline,
    );
    final hasCurrent = courses.isNotEmpty;
    final hasHistory = semesters.isNotEmpty;
    final hasBaseline = manualBaseline != null;
    final hasCumulativeData = hasHistory || hasBaseline;
    final hasAnyData = hasCumulativeData || hasCurrent;
    final activeSemesterAlreadyRecorded =
        semesters.any((semester) => semester.semesterKey == activeSemesterKey);
    final moveNextStepToBottom = hasHistory && hasCurrent;
    final nextStepCard = _NextStepCard(
      gradingSystem: gradingSystem,
      hasAnyData: hasAnyData,
      hasCurrentCourses: hasCurrent,
      hasHistory: hasHistory,
      hasBaseline: hasBaseline,
      onAddCurrentCourses: () =>
          onShowImportSheet(context, CwaViewMode.semester),
      onAddPastResults: () =>
          onShowImportSheet(context, CwaViewMode.cumulative),
      onEnterCurrentCwa: () => onOpenManualBaseline(
        context: context,
        ref: ref,
        gradingSystem: gradingSystem,
        existingBaseline: manualBaseline,
      ),
      onOpenHistory: () => onOpenHistory(context),
      onSaveFinalResults: hasCurrent
          ? () => onOpenCompleteSemester(context, ref, courses)
          : null,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        bottomContentPadding + AppSpacing.xxl,
      ),
      children: [
        _PrimaryScoreCard(
          gradingSystem: gradingSystem,
          projected: projected,
          cumulative: cumulative,
          target: target,
          cumulativeGap: cumulativeGap,
          totalCredits: totalCredits,
          courseCount: courses.length,
          hasCurrentCourses: hasCurrent,
          hasCumulativeData: hasCumulativeData,
        ),
        if (!moveNextStepToBottom) ...[
          const SizedBox(height: AppSpacing.md),
          nextStepCard,
        ],
        const SizedBox(height: AppSpacing.md),
        _CurrentSemesterSummaryCard(
          gradingSystem: gradingSystem,
          activeSemesterLabel: formatActiveSemesterLabel(activeSemesterKey),
          courseCount: courses.length,
          credits: currentCredits,
          projected: projected,
          alreadyRecorded: activeSemesterAlreadyRecorded,
          onAddCourses: () => onShowImportSheet(context, CwaViewMode.semester),
          onViewCourses: () =>
              Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute(
              builder: (_) => const CurrentSemesterCoursesScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AcademicHistorySummaryCard(
          gradingSystem: gradingSystem,
          semesterCount: semesters.length,
          completedCredits: completedCredits,
          cumulative: cumulative,
          hasHistory: hasHistory,
          hasBaseline: hasBaseline,
          onViewHistory: () => onOpenHistory(context),
          onAddPastResults: () =>
              onShowImportSheet(context, CwaViewMode.cumulative),
        ),
        const SizedBox(height: AppSpacing.lg),
        _CwaToolsSection(
          gradingSystem: gradingSystem,
          onTargetPlanner: () => onShowTargetDialog(
            context,
            ref,
            ref.read(targetCwaProvider),
            gradingSystem,
          ),
          onChangeSemester: () => showActiveSemesterDialog(
            context,
            ref,
            ref.read(activeSemesterProvider),
          ),
        ),
        if (moveNextStepToBottom) ...[
          const SizedBox(height: AppSpacing.lg),
          nextStepCard,
        ],
      ],
    );
  }

  double _completedCreditsForHistory(
    List<PastSemesterModel> semesters,
    ManualAcademicBaseline? manualBaseline,
  ) {
    if (semesters.isEmpty) return manualBaseline?.credits ?? 0;
    PastSemesterModel? anchor;
    try {
      anchor = semesters.lastWhere((s) => s.cumulativeCreditsCalc != null);
    } catch (_) {
      anchor = null;
    }
    if (anchor?.cumulativeCreditsCalc != null) {
      return anchor!.cumulativeCreditsCalc!;
    }
    return semesters.fold<double>(
      0,
      (sum, semester) =>
          sum +
          semester.courses.fold<double>(
            0,
            (courseSum, course) => courseSum + course.creditHours,
          ),
    );
  }
}

class _PrimaryScoreCard extends StatelessWidget {
  final GradingSystem gradingSystem;
  final double projected;
  final double cumulative;
  final double target;
  final double cumulativeGap;
  final double totalCredits;
  final int courseCount;
  final bool hasCurrentCourses;
  final bool hasCumulativeData;

  const _PrimaryScoreCard({
    required this.gradingSystem,
    required this.projected,
    required this.cumulative,
    required this.target,
    required this.cumulativeGap,
    required this.totalCredits,
    required this.courseCount,
    required this.hasCurrentCourses,
    required this.hasCumulativeData,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = hasCumulativeData || hasCurrentCourses;
    final showingCumulative = hasCumulativeData;
    final score = showingCumulative ? cumulative : projected;
    final label = showingCumulative
        ? gradingSystem.cumulativeMetricLabel
        : 'Projected ${gradingSystem.label}';
    final eyebrow =
        showingCumulative ? 'Your academic standing' : 'This semester';
    final detail = !hasData
        ? 'Add courses or past results to begin. You can also enter your current ${gradingSystem.cumulativeLabel} only.'
        : showingCumulative
            ? '${totalCredits.toInt()} total credits • Target ${gradingSystem.formatScore(target)}'
            : '$courseCount course${courseCount == 1 ? '' : 's'} in progress';
    final gapLabel = cumulativeGap <= 0
        ? 'On track'
        : 'Gap ${gradingSystem.formatDelta(cumulativeGap)}';

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
            eyebrow,
            style: const TextStyle(
              color: AppColors.goldSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasData ? gradingSystem.formatScore(score) : '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 46,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            detail,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (hasCumulativeData) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                gapLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final GradingSystem gradingSystem;
  final bool hasAnyData;
  final bool hasCurrentCourses;
  final bool hasHistory;
  final bool hasBaseline;
  final VoidCallback onAddCurrentCourses;
  final VoidCallback onAddPastResults;
  final VoidCallback onEnterCurrentCwa;
  final VoidCallback onOpenHistory;
  final VoidCallback? onSaveFinalResults;

  const _NextStepCard({
    required this.gradingSystem,
    required this.hasAnyData,
    required this.hasCurrentCourses,
    required this.hasHistory,
    required this.hasBaseline,
    required this.onAddCurrentCourses,
    required this.onAddPastResults,
    required this.onEnterCurrentCwa,
    required this.onOpenHistory,
    this.onSaveFinalResults,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = _title;
    final actions = _actions;
    final showAcademicHistoryInfo = _showAcademicHistoryInfo;

    return CampusCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: showAcademicHistoryInfo ? AppSpacing.sm : AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(
                  LucideIcons.sparkles,
                  color: colorScheme.primary,
                  size: AppIconSizes.xl,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next step',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (showAcademicHistoryInfo) ...[
                const SizedBox(width: AppSpacing.xxs),
                IconButton(
                  tooltip: 'About academic history',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(LucideIcons.info, size: AppIconSizes.md),
                  color: colorScheme.onSurfaceVariant,
                  onPressed: () => _showAcademicHistoryInfoDialog(context),
                ),
              ],
            ],
          ),
          if (!showAcademicHistoryInfo) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _subtitle,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(
            height: showAcademicHistoryInfo ? AppSpacing.sm : AppSpacing.md,
          ),
          Wrap(
            spacing: AppSpacing.xs2,
            runSpacing: AppSpacing.xs2,
            children: actions,
          ),
        ],
      ),
    );
  }

  bool get _showAcademicHistoryInfo =>
      hasCurrentCourses && !hasHistory && !hasBaseline;

  Future<void> _showAcademicHistoryInfoDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        content: const Text(
          'Your current semester projection is ready. Add past results or '
          'your current CWA so UniMate can show you the bigger picture.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String get _title {
    if (!hasAnyData) return 'Set up your ${gradingSystem.label}';
    if (_showAcademicHistoryInfo) {
      return 'Add your academic history';
    }
    if (hasHistory) return 'Keep your results up to date';
    return 'Build from your starting point';
  }

  String get _subtitle {
    if (!hasAnyData) {
      return 'Add current courses for a semester projection, or add past results to calculate your cumulative ${gradingSystem.cumulativeLabel}.';
    }
    if (hasHistory) {
      return 'Review saved semesters, add missing result slips, or save final results when official marks are released.';
    }
    return 'Your current ${gradingSystem.cumulativeLabel} is saved. Add past result slips later if you want full semester history.';
  }

  List<Widget> get _actions {
    if (!hasAnyData) {
      return [
        _InlineActionButton(
          label: 'Add Courses',
          icon: LucideIcons.plus,
          onPressed: onAddCurrentCourses,
        ),
        _InlineActionButton(
          label: 'Past Results',
          primary: false,
          icon: LucideIcons.fileUp,
          onPressed: onAddPastResults,
        ),
      ];
    }

    final actions = <Widget>[];
    if (hasHistory) {
      actions.add(
        _InlineActionButton(
          label: 'View History',
          icon: LucideIcons.bookOpen,
          onPressed: onOpenHistory,
        ),
      );
      if (onSaveFinalResults != null) {
        actions.add(
          _InlineActionButton(
            label: 'Save Final Results',
            primary: false,
            icon: LucideIcons.badgeCheck,
            onPressed: onSaveFinalResults!,
          ),
        );
      }
    } else {
      actions.add(
        _InlineActionButton(
          label: 'Add Past Results',
          icon: LucideIcons.fileUp,
          onPressed: onAddPastResults,
        ),
      );
      actions.add(
        _InlineActionButton(
          label: 'Current ${gradingSystem.cumulativeLabel}',
          primary: false,
          icon: LucideIcons.calculator,
          onPressed: onEnterCurrentCwa,
        ),
      );
    }
    return actions;
  }
}

class _CurrentSemesterSummaryCard extends StatelessWidget {
  final GradingSystem gradingSystem;
  final String activeSemesterLabel;
  final int courseCount;
  final double credits;
  final double projected;
  final bool alreadyRecorded;
  final VoidCallback onAddCourses;
  final VoidCallback onViewCourses;

  const _CurrentSemesterSummaryCard({
    required this.gradingSystem,
    required this.activeSemesterLabel,
    required this.courseCount,
    required this.credits,
    required this.projected,
    required this.alreadyRecorded,
    required this.onAddCourses,
    required this.onViewCourses,
  });

  @override
  Widget build(BuildContext context) {
    final hasCourses = courseCount > 0;
    return _DashboardSummaryCard(
      icon: LucideIcons.bookOpen,
      title: 'Current semester',
      subtitle: activeSemesterLabel,
      metrics: [
        _DashboardMetric(label: 'Courses', value: '$courseCount'),
        _DashboardMetric(label: 'Credits', value: '${credits.toInt()} cr'),
        _DashboardMetric(
          label: gradingSystem.label,
          value: hasCourses ? gradingSystem.formatScore(projected) : '--',
        ),
      ],
      note: alreadyRecorded
          ? 'This active semester already exists in your saved results.'
          : hasCourses
              ? 'A quick projection based on your current course list.'
              : 'Add your current semester courses to see a projection.',
      actionLabel: hasCourses ? 'View/Edit Courses' : 'Add Courses',
      actionIcon: hasCourses ? LucideIcons.listChecks : LucideIcons.plus,
      onAction: hasCourses ? onViewCourses : onAddCourses,
    );
  }
}

class _AcademicHistorySummaryCard extends StatelessWidget {
  final GradingSystem gradingSystem;
  final int semesterCount;
  final double completedCredits;
  final double cumulative;
  final bool hasHistory;
  final bool hasBaseline;
  final VoidCallback onViewHistory;
  final VoidCallback onAddPastResults;

  const _AcademicHistorySummaryCard({
    required this.gradingSystem,
    required this.semesterCount,
    required this.completedCredits,
    required this.cumulative,
    required this.hasHistory,
    required this.hasBaseline,
    required this.onViewHistory,
    required this.onAddPastResults,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = hasHistory || hasBaseline;
    return _DashboardSummaryCard(
      icon: LucideIcons.graduationCap,
      title: 'Academic history',
      subtitle: hasHistory
          ? '$semesterCount saved semester${semesterCount == 1 ? '' : 's'}'
          : hasBaseline
              ? 'Current ${gradingSystem.cumulativeLabel} saved'
              : 'No saved results yet',
      metrics: [
        _DashboardMetric(label: 'Semesters', value: '$semesterCount'),
        _DashboardMetric(
          label: 'Credits',
          value: hasData ? '${completedCredits.toInt()} cr' : '--',
        ),
        _DashboardMetric(
          label: gradingSystem.cumulativeLabel,
          value: hasData ? gradingSystem.formatScore(cumulative) : '--',
        ),
      ],
      note: hasData
          ? 'Past results help UniMate calculate your cumulative result.'
          : 'Add past results or enter your current ${gradingSystem.cumulativeLabel} to unlock this.',
      actionLabel: hasHistory ? 'View History' : 'Add Past Results',
      actionIcon: hasHistory ? LucideIcons.bookOpen : LucideIcons.fileUp,
      onAction: hasHistory ? onViewHistory : onAddPastResults,
    );
  }
}

class _CwaToolsSection extends StatelessWidget {
  final GradingSystem gradingSystem;
  final VoidCallback onTargetPlanner;
  final VoidCallback onChangeSemester;

  const _CwaToolsSection({
    required this.gradingSystem,
    required this.onTargetPlanner,
    required this.onChangeSemester,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CampusSectionHeader(
          title: 'Tools',
          subtitle: 'Extra options when you need them',
        ),
        const SizedBox(height: AppSpacing.xs2),
        CampusCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              _ToolRow(
                icon: LucideIcons.goal,
                label: 'Target planner',
                subtitle: 'Choose the result you are working toward.',
                onTap: onTargetPlanner,
              ),
              _ToolRow(
                icon: LucideIcons.calendarDays,
                label: 'Change active semester',
                subtitle: 'Choose the semester for current courses',
                onTap: onChangeSemester,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddGoalSheet extends StatelessWidget {
  final bool hasCurrentCourses;
  final GradingSystem gradingSystem;
  final VoidCallback onCurrentCourses;
  final VoidCallback onPastResults;
  final VoidCallback onCurrentCwaOnly;
  final VoidCallback onFinalResults;

  const _AddGoalSheet({
    required this.hasCurrentCourses,
    required this.gradingSystem,
    required this.onCurrentCourses,
    required this.onPastResults,
    required this.onCurrentCwaOnly,
    required this.onFinalResults,
  });

  @override
  Widget build(BuildContext context) {
    return CampusModalSheet(
      title: 'What do you want to add?',
      subtitle: 'Choose the setup path that matches what you have right now.',
      leading: const _AddGoalIcon(),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
        tooltip: 'Close',
      ),
      scrollable: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AddGoalOptionTile(
            icon: LucideIcons.bookOpen,
            title: 'Current semester courses',
            subtitle:
                'Plan your expected ${gradingSystem.label} for this semester.',
            onTap: onCurrentCourses,
          ),
          const SizedBox(height: AppSpacing.xs2),
          _AddGoalOptionTile(
            icon: LucideIcons.fileText,
            title: 'Past result slip / past semester',
            subtitle:
                'Use this to calculate your cumulative ${gradingSystem.cumulativeLabel}.',
            onTap: onPastResults,
          ),
          const SizedBox(height: AppSpacing.xs2),
          _AddGoalOptionTile(
            icon: LucideIcons.calculator,
            title: 'Current ${gradingSystem.cumulativeLabel} only',
            subtitle:
                'Quick setup if you already know your ${gradingSystem.cumulativeLabel} and total credits.',
            onTap: onCurrentCwaOnly,
          ),
          if (hasCurrentCourses) ...[
            const SizedBox(height: AppSpacing.xs2),
            _AddGoalOptionTile(
              icon: LucideIcons.badgeCheck,
              title: 'Final results for this semester',
              subtitle: 'Save your actual marks after results are released.',
              onTap: onFinalResults,
            ),
          ],
        ],
      ),
    );
  }
}

class _AddGoalOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddGoalOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CampusCard(
      padding: EdgeInsets.zero,
      color: AppColors.surfaceMuted,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm2,
          vertical: AppSpacing.sm2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AppRadii.button,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: AppIconSizes.xl,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: colorScheme.onSurfaceVariant,
              size: AppIconSizes.lg,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_DashboardMetric> metrics;
  final String note;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const _DashboardSummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metrics,
    required this.note,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: AppIconSizes.xl,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                Expanded(child: _DashboardMetricView(metric: metrics[i])),
                if (i != metrics.length - 1)
                  const SizedBox(width: AppSpacing.xs2),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon, size: AppIconSizes.md),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric {
  final String label;
  final String value;

  const _DashboardMetric({
    required this.label,
    required this.value,
  });
}

class _DashboardMetricView extends StatelessWidget {
  final _DashboardMetric metric;

  const _DashboardMetricView({required this.metric});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: AppIconSizes.lg),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: colorScheme.onSurfaceVariant,
              size: AppIconSizes.md,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGoalIcon extends StatelessWidget {
  const _AddGoalIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: AppRadii.button,
      ),
      child: Icon(
        LucideIcons.plus,
        color: colorScheme.primary,
        size: AppIconSizes.xl,
      ),
    );
  }
}

class _InlineActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool primary;

  const _InlineActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.xs),
              Text(label),
            ],
          );

    if (primary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      child: child,
    );
  }
}

class _ManualAcademicBaselineSheet extends StatefulWidget {
  final GradingSystem gradingSystem;
  final ManualAcademicBaseline? existingBaseline;

  const _ManualAcademicBaselineSheet({
    required this.gradingSystem,
    required this.existingBaseline,
  });

  @override
  State<_ManualAcademicBaselineSheet> createState() =>
      _ManualAcademicBaselineSheetState();
}

class _ManualAcademicBaselineSheetState
    extends State<_ManualAcademicBaselineSheet> {
  late final TextEditingController _scoreController;
  late final TextEditingController _creditsController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final baseline = widget.existingBaseline;
    _scoreController = TextEditingController(
      text: baseline == null
          ? ''
          : widget.gradingSystem.formatScore(baseline.score),
    );
    _creditsController = TextEditingController(
      text: baseline == null || baseline.credits <= 0
          ? ''
          : baseline.credits.toStringAsFixed(
              baseline.credits == baseline.credits.roundToDouble() ? 0 : 1,
            ),
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _save() {
    final score = double.tryParse(_scoreController.text.trim());
    final credits = double.tryParse(_creditsController.text.trim());
    final gradingSystem = widget.gradingSystem;

    if (score == null ||
        score < gradingSystem.minScore ||
        score > gradingSystem.maxScore) {
      setState(() {
        _errorText =
            'Enter a ${gradingSystem.label} between ${gradingSystem.formatScore(gradingSystem.minScore)} and ${gradingSystem.formatScore(gradingSystem.maxScore)}.';
      });
      return;
    }

    if (credits == null || credits <= 0) {
      setState(() {
        _errorText = 'Enter the credits you have completed so far.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop((score: score, credits: credits));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradingSystem = widget.gradingSystem;

    return CampusModalSheet(
      title: 'Enter current ${gradingSystem.cumulativeLabel}',
      subtitle:
          'Use this if you already know your current cumulative ${gradingSystem.label} but have not imported past results.',
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
        tooltip: 'Close',
      ),
      bottomBar: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Current ${gradingSystem.cumulativeLabel}',
              hintText: gradingSystem.formatScore(
                gradingSystem.defaultTarget,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _creditsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Completed credits so far',
              hintText: '72',
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
