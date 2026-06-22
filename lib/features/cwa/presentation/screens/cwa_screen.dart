import 'dart:async';

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
import 'package:campusiq/features/cwa/presentation/widgets/timetable_course_import_sheet.dart';
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
    final pastSemesters = ref.watch(pastSemestersProvider).valueOrNull ?? [];
    final manualBaseline =
        ref.watch(manualAcademicBaselineProvider).valueOrNull;
    final targetConfirmed =
        ref.watch(cwaSetupTargetConfirmedProvider).valueOrNull ?? false;
    final isSetupComplete = currentCourses.isNotEmpty &&
        (pastSemesters.isNotEmpty || manualBaseline != null) &&
        targetConfirmed;

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
      floatingActionButton: isSetupComplete
          ? FloatingActionButton.extended(
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
            )
          : null,
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
                  await repo.confirmCwaSetupTarget();
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
          if (viewMode == CwaViewMode.semester)
            _ImportOption(
              icon: LucideIcons.calendarDays,
              label: 'Use Timetable',
              onTap: () {
                Navigator.of(sheetContext).pop();
                showTimetableCourseImportSheet(context);
              },
            ),
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
    final targetConfirmed =
        ref.watch(cwaSetupTargetConfirmedProvider).valueOrNull ?? false;
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
    final setupComplete = hasCurrent && hasCumulativeData && targetConfirmed;
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

    final setupView = _CwaSetupView(
      bottomContentPadding: bottomContentPadding,
      gradingSystem: gradingSystem,
      hasCurrentCourses: hasCurrent,
      hasAcademicHistory: hasCumulativeData,
      targetConfirmed: targetConfirmed,
      target: target,
      onAddCurrentCourses: () =>
          onShowImportSheet(context, CwaViewMode.semester),
      onAddPastResults: () =>
          onShowImportSheet(context, CwaViewMode.cumulative),
      onEnterCurrentScore: () => onOpenManualBaseline(
        context: context,
        ref: ref,
        gradingSystem: gradingSystem,
        existingBaseline: manualBaseline,
      ),
      onSetTarget: () => onShowTargetDialog(
        context,
        ref,
        target,
        gradingSystem,
      ),
    );

    final dashboardView = ListView(
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
        if (!moveNextStepToBottom) ...[
          const SizedBox(height: AppSpacing.md),
          nextStepCard,
        ],
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

    return _FinalSetupTransition(
      setupComplete: setupComplete,
      setupView: setupView,
      dashboardView: dashboardView,
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

class _FinalSetupTransition extends StatefulWidget {
  final bool setupComplete;
  final Widget setupView;
  final Widget dashboardView;

  const _FinalSetupTransition({
    required this.setupComplete,
    required this.setupView,
    required this.dashboardView,
  });

  @override
  State<_FinalSetupTransition> createState() => _FinalSetupTransitionState();
}

class _FinalSetupTransitionState extends State<_FinalSetupTransition> {
  static const _completionWindow = Duration(milliseconds: 3000);

  Timer? _completionTimer;
  late bool _showSetup;
  bool _transitionPending = false;

  @override
  void initState() {
    super.initState();
    _showSetup = !widget.setupComplete;
  }

  @override
  void didUpdateWidget(covariant _FinalSetupTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.setupComplete && widget.setupComplete) {
      _completionTimer?.cancel();
      _showSetup = true;
      if (_routeIsVisible) {
        _scheduleDashboardTransition();
      } else {
        _transitionPending = true;
      }
    } else if (oldWidget.setupComplete && !widget.setupComplete) {
      _completionTimer?.cancel();
      _transitionPending = false;
      _showSetup = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transitionPending && _routeIsVisible) {
      _transitionPending = false;
      _scheduleDashboardTransition();
    }
  }

  bool get _routeIsVisible =>
      (ModalRoute.of(context)?.isCurrent ?? true) &&
      TickerMode.valuesOf(context).enabled;

  void _scheduleDashboardTransition() {
    _completionTimer?.cancel();
    _completionTimer = Timer(_completionWindow, () {
      if (mounted) setState(() => _showSetup = false);
    });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 625),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _showSetup
          ? KeyedSubtree(
              key: const ValueKey('cwa-setup'),
              child: widget.setupView,
            )
          : KeyedSubtree(
              key: const ValueKey('cwa-dashboard'),
              child: widget.dashboardView,
            ),
    );
  }
}

class _CwaSetupView extends StatelessWidget {
  final double bottomContentPadding;
  final GradingSystem gradingSystem;
  final bool hasCurrentCourses;
  final bool hasAcademicHistory;
  final bool targetConfirmed;
  final double target;
  final VoidCallback onAddCurrentCourses;
  final VoidCallback onAddPastResults;
  final VoidCallback onEnterCurrentScore;
  final VoidCallback onSetTarget;

  const _CwaSetupView({
    required this.bottomContentPadding,
    required this.gradingSystem,
    required this.hasCurrentCourses,
    required this.hasAcademicHistory,
    required this.targetConfirmed,
    required this.target,
    required this.onAddCurrentCourses,
    required this.onAddPastResults,
    required this.onEnterCurrentScore,
    required this.onSetTarget,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = [
      hasCurrentCourses,
      hasAcademicHistory,
      targetConfirmed,
    ].where((complete) => complete).length;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        bottomContentPadding + AppSpacing.xxl,
      ),
      children: [
        _SetupHeroCard(gradingSystem: gradingSystem),
        const SizedBox(height: AppSpacing.md),
        _SetupProgressCard(
          completedCount: completedCount,
          steps: [
            hasCurrentCourses,
            hasAcademicHistory,
            targetConfirmed,
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _SetupStepCard(
          step: 1,
          icon: LucideIcons.bookOpen,
          title: 'Add your current courses',
          description:
              'Start your semester projection with the courses you are taking now.',
          actionLabel: 'Start with my courses',
          completionLabel: 'Current courses added',
          complete: hasCurrentCourses,
          enabled: !hasCurrentCourses,
          emphasized: !hasCurrentCourses,
          onPressed: onAddCurrentCourses,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SetupStepCard(
          step: 2,
          icon: LucideIcons.history,
          title: 'Add academic history',
          description:
              'Import past results, or enter your current ${gradingSystem.cumulativeLabel} and completed credits.',
          actionLabel: 'Import past results',
          completionLabel: 'Academic history added',
          secondaryActionLabel: hasAcademicHistory
              ? null
              : 'Enter current ${gradingSystem.cumulativeLabel}',
          complete: hasAcademicHistory,
          enabled: hasCurrentCourses && !hasAcademicHistory,
          emphasized: hasCurrentCourses && !hasAcademicHistory,
          onPressed: onAddPastResults,
          onSecondaryPressed: onEnterCurrentScore,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SetupStepCard(
          step: 3,
          icon: LucideIcons.goal,
          title: 'Confirm your target',
          description: targetConfirmed
              ? 'Your target is ${gradingSystem.formatScore(target)}.'
              : 'Review the ${gradingSystem.label} you want to work toward.',
          actionLabel: 'Set my target',
          completionLabel: 'Target confirmed',
          complete: targetConfirmed,
          enabled: hasCurrentCourses && hasAcademicHistory && !targetConfirmed,
          emphasized:
              hasCurrentCourses && hasAcademicHistory && !targetConfirmed,
          onPressed: onSetTarget,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SetupCalculationCard(gradingSystem: gradingSystem),
      ],
    );
  }
}

class _SetupHeroCard extends StatelessWidget {
  final GradingSystem gradingSystem;

  const _SetupHeroCard({required this.gradingSystem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navySoft],
        ),
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.card,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final illustrationWidth =
              (constraints.maxWidth * 0.43).clamp(108.0, 148.0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Let’s set up your ${gradingSystem.label}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: illustrationWidth,
                    child: Image.asset(
                      'assets/unimate onboarding asset.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.clock3,
                    color: AppColors.goldSoft,
                    size: AppIconSizes.lg,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Takes about 2 minutes',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: AppColors.goldSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SetupProgressCard extends StatefulWidget {
  final int completedCount;
  final List<bool> steps;

  const _SetupProgressCard({
    required this.completedCount,
    required this.steps,
  });

  @override
  State<_SetupProgressCard> createState() => _SetupProgressCardState();
}

class _SetupProgressCardState extends State<_SetupProgressCard>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1625);

  late final AnimationController _controller;
  late List<bool> _previousSteps;
  late int _displayedCompletedCount;
  bool _completionPending = false;

  @override
  void initState() {
    super.initState();
    _previousSteps = List<bool>.of(widget.steps);
    _displayedCompletedCount = widget.completedCount;
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _SetupProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameSteps(oldWidget.steps, widget.steps)) {
      if (_routeIsVisible) {
        _previousSteps = List<bool>.of(oldWidget.steps);
        _displayedCompletedCount = widget.completedCount;
        _controller.forward(from: 0);
      } else {
        if (!_completionPending) {
          _previousSteps = List<bool>.of(oldWidget.steps);
        }
        _completionPending = true;
        _controller.value = 0;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_completionPending && _routeIsVisible) {
      _completionPending = false;
      _displayedCompletedCount = widget.completedCount;
      _controller.forward(from: 0);
    }
  }

  bool get _routeIsVisible =>
      (ModalRoute.of(context)?.isCurrent ?? true) &&
      TickerMode.valuesOf(context).enabled;

  bool _sameSteps(List<bool> first, List<bool> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Set-up progress',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 875),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  '$_displayedCompletedCount/3 completed',
                  key: ValueKey(_displayedCompletedCount),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = Curves.easeInOutCubic.transform(
                _controller.value,
              );

              return Row(
                children: List.generate(widget.steps.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    final stepIndex = index ~/ 2;
                    final fill = _animatedCompletion(stepIndex, progress);
                    return Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 3,
                            color: colorScheme.outlineVariant,
                          ),
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: fill,
                              child: const SizedBox(
                                width: double.infinity,
                                child: ColoredBox(
                                  color: AppColors.success,
                                  child: SizedBox(height: 3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final stepIndex = index ~/ 2;
                  final completion = _animatedCompletion(stepIndex, progress);
                  return SizedBox(
                    width: 28,
                    height: 28,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.lerp(
                              colorScheme.surfaceContainerHighest,
                              AppColors.success,
                              completion,
                            ),
                            border: Border.all(
                              color: Color.lerp(
                                colorScheme.outline,
                                AppColors.success,
                                completion,
                              )!,
                              width: 2,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 1 - completion,
                          child: Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: completion,
                          child: Transform.scale(
                            scale: 0.7 + (0.3 * completion),
                            child: const Icon(
                              LucideIcons.check,
                              size: AppIconSizes.sm,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  double _animatedCompletion(int stepIndex, double progress) {
    final wasComplete =
        stepIndex < _previousSteps.length && _previousSteps[stepIndex];
    final isComplete =
        stepIndex < widget.steps.length && widget.steps[stepIndex];
    if (wasComplete == isComplete) return isComplete ? 1 : 0;
    return isComplete ? progress : 1 - progress;
  }
}

class _SetupStepCard extends StatefulWidget {
  final int step;
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final String completionLabel;
  final String? secondaryActionLabel;
  final bool complete;
  final bool enabled;
  final bool emphasized;
  final VoidCallback onPressed;
  final VoidCallback? onSecondaryPressed;

  const _SetupStepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.completionLabel,
    required this.complete,
    required this.enabled,
    required this.emphasized,
    required this.onPressed,
    this.secondaryActionLabel,
    this.onSecondaryPressed,
  });

  @override
  State<_SetupStepCard> createState() => _SetupStepCardState();
}

class _SetupStepCardState extends State<_SetupStepCard>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1625);

  late final AnimationController _controller;
  late final Animation<double> _iconTransition;
  late final Animation<double> _contentTransition;
  late final Animation<double> _confirmationTransition;
  bool _completionPending = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      value: widget.complete ? 1 : 0,
    );
    _iconTransition = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.08, 0.58, curve: Curves.easeOutBack),
    );
    _contentTransition = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.72, curve: Curves.easeInOutCubic),
    );
    _confirmationTransition = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 1, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _SetupStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.complete && widget.complete) {
      if (_routeIsVisible) {
        _controller.forward(from: 0);
      } else {
        _completionPending = true;
        _controller.value = 0;
      }
    } else if (oldWidget.complete && !widget.complete) {
      _completionPending = false;
      _controller.reverse(from: 1);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_completionPending && _routeIsVisible) {
      _completionPending = false;
      _controller.forward(from: 0);
    }
  }

  bool get _routeIsVisible =>
      (ModalRoute.of(context)?.isCurrent ?? true) &&
      TickerMode.valuesOf(context).enabled;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 550),
      opacity: widget.complete || widget.enabled ? 1 : 0.62,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glow = Curves.easeOut.transform(
            (1 - ((2 * _controller.value) - 1).abs()).clamp(0, 1),
          );
          final completion = Curves.easeInOut.transform(_controller.value);
          final iconTransition =
              _iconTransition.value.clamp(0.0, 1.0).toDouble();

          return Container(
            decoration: BoxDecoration(
              color: Color.lerp(
                Theme.of(context).cardColor,
                AppColors.success.withValues(alpha: 0.09),
                glow,
              ),
              borderRadius: AppRadii.card,
              border: Border.all(
                color: Color.lerp(
                  colorScheme.outlineVariant,
                  AppColors.success.withValues(alpha: 0.45),
                  glow,
                )!,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.16 * glow),
                  blurRadius: 18 * glow,
                  spreadRadius: 1.5 * glow,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        colorScheme.primaryContainer,
                        AppColors.success.withValues(alpha: 0.12),
                        completion,
                      ),
                      borderRadius: AppRadii.button,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 1 - iconTransition,
                          child: Transform.scale(
                            scale: 1 - (0.18 * iconTransition),
                            child: Icon(
                              widget.icon,
                              color: colorScheme.primary,
                              size: AppIconSizes.xxl,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: iconTransition,
                          child: Transform.scale(
                            scale: 0.72 + (0.28 * iconTransition),
                            child: const Icon(
                              LucideIcons.check,
                              color: AppColors.success,
                              size: AppIconSizes.xxl,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 27,
                              height: 27,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.lerp(
                                  widget.emphasized
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHighest,
                                  AppColors.success,
                                  completion,
                                ),
                              ),
                              child: Text(
                                '${widget.step}',
                                style: TextStyle(
                                  color: widget.emphasized || completion > 0.5
                                      ? Colors.white
                                      : colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizeTransition(
                          key: ValueKey(
                            'cwa-setup-step-${widget.step}-instructions',
                          ),
                          sizeFactor: ReverseAnimation(_contentTransition),
                          axisAlignment: -1,
                          child: FadeTransition(
                            opacity: ReverseAnimation(_contentTransition),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  widget.description,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: widget.enabled
                                        ? widget.onPressed
                                        : null,
                                    child: Text(widget.actionLabel),
                                  ),
                                ),
                                if (widget.secondaryActionLabel != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: widget.enabled
                                          ? widget.onSecondaryPressed
                                          : null,
                                      child: Text(widget.secondaryActionLabel!),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizeTransition(
                          key: ValueKey(
                            'cwa-setup-step-${widget.step}-confirmation',
                          ),
                          sizeFactor: _confirmationTransition,
                          axisAlignment: -1,
                          child: FadeTransition(
                            opacity: _confirmationTransition,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSpacing.sm),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.circleCheck,
                                    color: AppColors.success,
                                    size: AppIconSizes.md,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    widget.completionLabel,
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SetupCalculationCard extends StatelessWidget {
  final GradingSystem gradingSystem;

  const _SetupCalculationCard({required this.gradingSystem});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = [
      (
        icon: LucideIcons.chartNoAxesCombined,
        label: 'Projected\nsemester ${gradingSystem.label}',
      ),
      (
        icon: LucideIcons.shieldCheck,
        label: 'Cumulative\n${gradingSystem.cumulativeLabel}',
      ),
      (
        icon: LucideIcons.goal,
        label: 'Target\nmarks',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.65),
        borderRadius: AppRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What UniMate will calculate',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: item == items.last ? 0 : AppSpacing.xs,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              item.icon,
                              color: colorScheme.primary,
                              size: AppIconSizes.xl,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
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
              ? null
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
          ? null
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
  final String? note;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const _DashboardSummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metrics,
    this.note,
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
          if (note != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              note!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
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
