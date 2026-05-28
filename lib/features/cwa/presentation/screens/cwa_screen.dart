import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/layout/shell_overlay_padding.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/cwa_summary_bar.dart';
import 'package:campusiq/features/cwa/presentation/widgets/course_card.dart';
import 'package:campusiq/features/cwa/presentation/widgets/add_course_sheet.dart';
import 'package:campusiq/features/cwa/presentation/widgets/active_semester_picker.dart';
import 'package:campusiq/features/cwa/presentation/screens/complete_semester_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/shared/widgets/campus_button.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';

class CwaScreen extends ConsumerWidget {
  static const double _compactSectionGap = AppSpacing.md;
  static const double _compactListGap = AppSpacing.xs2;

  const CwaScreen({super.key});

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref,
      {CourseModel? existing}) async {
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
        source: 'planner_sheet',
        gradingSystem: selectedSystem.id,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'course_save_failed',
        context: {'source': 'planner_sheet'},
      );
      debugPrint('🔴 CwaScreen _openAddSheet failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not save course. Please try again.')),
        );
      }
    }
  }

  void _openHistory(BuildContext context) {
    context.pushNamed('cwa-history');
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
    final viewMode = ref.watch(cwaViewModeProvider);
    final gradingSystem = ref.watch(gradingSystemProvider);
    final hasActiveSession = ref.watch(activeSessionProvider) != null;
    final bottomContentPadding = shellOverlayBottomPadding(
      context,
      hasActiveSession: hasActiveSession,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          gradingSystem.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Import courses or results',
            child: TextButton.icon(
              onPressed: () => _showImportSheet(context, viewMode),
              icon: const Icon(LucideIcons.fileUp, size: AppIconSizes.lg),
              label: const Text('Import'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                minimumSize: const Size(0, 44),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          PopupMenuButton<_CwaMenuAction>(
            tooltip: 'More options',
            icon: const Icon(LucideIcons.ellipsisVertical),
            onSelected: (action) {
              switch (action) {
                case _CwaMenuAction.semester:
                  showActiveSemesterDialog(
                    context,
                    ref,
                    ref.read(activeSemesterProvider),
                  );
                  return;
                case _CwaMenuAction.target:
                  _showTargetDialog(
                    context,
                    ref,
                    ref.read(targetCwaProvider),
                    gradingSystem,
                  );
                  return;
                case _CwaMenuAction.history:
                  _openHistory(context);
                  return;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _CwaMenuAction.semester,
                child: Text('Change active semester'),
              ),
              const PopupMenuItem(
                value: _CwaMenuAction.target,
                child: Text('Set target'),
              ),
              if (viewMode == CwaViewMode.cumulative)
                const PopupMenuItem(
                  value: _CwaMenuAction.history,
                  child: Text('Manage result history'),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: _ViewToggle(
              mode: viewMode,
              onChanged: (m) =>
                  ref.read(cwaViewModeProvider.notifier).state = m,
            ),
          ),
          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: viewMode == CwaViewMode.semester
                ? _SemesterView(
                    onOpenAddSheet: _openAddSheet,
                    onOpenCompleteSemester: _openCompleteSemester,
                    bottomContentPadding: bottomContentPadding,
                  )
                : _CumulativeView(
                    onOpenHistory: _openHistory,
                    bottomContentPadding: bottomContentPadding,
                  ),
          ),
        ],
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
    final subtitle = viewMode == CwaViewMode.semester
        ? 'Bring in your current semester courses from a slip, photo, or manual entry.'
        : 'Add a completed semester from a result slip, image, PDF, or manual entry.';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ImportOptionsSheet(
        title: title,
        subtitle: subtitle,
        options: [
          _ImportOption(
            icon: LucideIcons.camera,
            label: 'Take Photo',
            subtitle: 'Capture a registration or result slip now.',
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openImportScreen(context, viewMode, initialSource: 'camera');
            },
          ),
          _ImportOption(
            icon: LucideIcons.imageUp,
            label: 'Upload Image',
            subtitle: 'Pick an existing screenshot or scanned slip.',
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openImportScreen(context, viewMode, initialSource: 'gallery');
            },
          ),
          _ImportOption(
            icon: LucideIcons.fileText,
            label: 'Choose PDF',
            subtitle: 'Import a PDF copy of your registration or results.',
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openImportScreen(context, viewMode, initialSource: 'pdf');
            },
          ),
          _ImportOption(
            icon: LucideIcons.squarePen,
            label: 'Enter Manually',
            subtitle: 'Type the course details in yourself.',
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

// ─── Toggle widget ────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final CwaViewMode mode;
  final ValueChanged<CwaViewMode> onChanged;

  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.button,
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: 'Semester',
            active: mode == CwaViewMode.semester,
            onTap: () => onChanged(CwaViewMode.semester),
          ),
          _ToggleTab(
            label: 'Cumulative',
            active: mode == CwaViewMode.cumulative,
            onTap: () => onChanged(CwaViewMode.cumulative),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: active ? colorScheme.primary : Colors.transparent,
              borderRadius: AppRadii.button,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _CwaMenuAction { semester, target, history }

class _ImportOption {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ImportOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
}

class _ImportOptionsSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_ImportOption> options;

  const _ImportOptionsSheet({
    required this.title,
    required this.subtitle,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return CampusModalSheet(
      title: title,
      subtitle: subtitle,
      leading: const _ImportSheetIcon(),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
        tooltip: 'Close',
      ),
      scrollable: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final option in options) ...[
            _ImportOptionTile(option: option),
            if (option != options.last) const SizedBox(height: AppSpacing.xs2),
          ],
        ],
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

class _ImportOptionTile extends StatelessWidget {
  final _ImportOption option;

  const _ImportOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: EdgeInsets.zero,
      color: AppColors.surfaceMuted,
      onTap: option.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm2,
          vertical: AppSpacing.sm2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AppRadii.button,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(
                option.icon,
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
                    option.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    option.subtitle,
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

class _SupportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final IconData icon;

  const _SupportCard({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child:
                Icon(icon, color: colorScheme.primary, size: AppIconSizes.xl),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.xs2),
          Wrap(
            spacing: AppSpacing.xs2,
            runSpacing: AppSpacing.xs2,
            children: actions,
          ),
        ],
      ),
    );
  }
}

class _CumulativeSnapshotCard extends StatelessWidget {
  final double cumulative;
  final double totalCredits;
  final double gap;
  final GradingSystem gradingSystem;
  final bool hasData;

  const _CumulativeSnapshotCard({
    required this.cumulative,
    required this.totalCredits,
    required this.gap,
    required this.gradingSystem,
    required this.hasData,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOnTrack = gap <= 0;

    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              LucideIcons.trendingUp,
              color: colorScheme.primary,
              size: AppIconSizes.xl,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gradingSystem.cumulativeMetricLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasData ? gradingSystem.formatScore(cumulative) : '--',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                hasData
                    ? '${totalCredits.toInt()} cr • ${isOnTrack ? 'On track' : 'Gap ${gradingSystem.formatDelta(gap)}'}'
                    : 'No data yet',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SemesterSummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _collapsedHeight = 96;
  static const double _expandedHeight = 308;

  final double projected;
  final double target;
  final double gap;
  final double cumulative;
  final double cumulativeCredits;
  final double cumulativeGap;
  final double semesterCredits;
  final int courseCount;
  final GradingSystem gradingSystem;
  final bool hasCourses;
  final bool hasCumulativeData;

  const _SemesterSummaryHeaderDelegate({
    required this.projected,
    required this.target,
    required this.gap,
    required this.cumulative,
    required this.cumulativeCredits,
    required this.cumulativeGap,
    required this.semesterCredits,
    required this.courseCount,
    required this.gradingSystem,
    required this.hasCourses,
    required this.hasCumulativeData,
  });

  @override
  double get minExtent => _collapsedHeight;

  @override
  double get maxExtent => _expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress =
        (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0).toDouble();
    final expandedOpacity = (1 - (progress * 1.7)).clamp(0.0, 1.0).toDouble();
    final collapsedOpacity =
        ((progress - 0.38) / 0.62).clamp(0.0, 1.0).toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: progress > 0.45,
            child: Opacity(
              opacity: expandedOpacity,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xxs,
                    AppSpacing.xl,
                    AppSpacing.xxs,
                  ),
                  child: Column(
                    children: [
                      _CwaOverviewPanel(
                        projected: projected,
                        target: target,
                        gap: gap,
                        gradingSystem: gradingSystem,
                        label: gradingSystem.projectedLabel,
                        eyebrow: 'Current semester',
                        hasData: hasCourses,
                        stats: [
                          _QuickStatItem(
                            label: 'Courses',
                            value: '$courseCount',
                            icon: LucideIcons.bookOpen,
                          ),
                          _QuickStatItem(
                            label: 'Credits',
                            value: '${semesterCredits.toInt()} cr',
                            icon: LucideIcons.chartColumn,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _CumulativeSnapshotCard(
                        cumulative: cumulative,
                        totalCredits: cumulativeCredits,
                        gap: cumulativeGap,
                        gradingSystem: gradingSystem,
                        hasData: hasCumulativeData,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: collapsedOpacity == 0,
            child: Opacity(
              opacity: collapsedOpacity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxs2,
                  AppSpacing.xl,
                  AppSpacing.xxs2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _PinnedSummaryMetricCard(
                        label: gradingSystem.label,
                        value: hasCourses
                            ? gradingSystem.formatScore(projected)
                            : '--',
                        detail: hasCourses
                            ? _gapLabel(gap, gradingSystem)
                            : '$courseCount courses',
                        icon: LucideIcons.gauge,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs2),
                    Expanded(
                      child: _PinnedSummaryMetricCard(
                        label: gradingSystem.cumulativeLabel,
                        value: hasCumulativeData
                            ? gradingSystem.formatScore(cumulative)
                            : '--',
                        detail: hasCumulativeData
                            ? _gapLabel(cumulativeGap, gradingSystem)
                            : 'No data yet',
                        icon: LucideIcons.trendingUp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _gapLabel(double value, GradingSystem gradingSystem) {
    if (value <= 0) return 'On track';
    return 'Gap ${gradingSystem.formatDelta(value)}';
  }

  @override
  bool shouldRebuild(covariant _SemesterSummaryHeaderDelegate oldDelegate) {
    return projected != oldDelegate.projected ||
        target != oldDelegate.target ||
        gap != oldDelegate.gap ||
        cumulative != oldDelegate.cumulative ||
        cumulativeCredits != oldDelegate.cumulativeCredits ||
        cumulativeGap != oldDelegate.cumulativeGap ||
        semesterCredits != oldDelegate.semesterCredits ||
        courseCount != oldDelegate.courseCount ||
        gradingSystem != oldDelegate.gradingSystem ||
        hasCourses != oldDelegate.hasCourses ||
        hasCumulativeData != oldDelegate.hasCumulativeData;
  }
}

class _PinnedSummaryMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;

  const _PinnedSummaryMetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.xs2),
            ),
            child:
                Icon(icon, color: colorScheme.primary, size: AppIconSizes.md),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    height: 1.1,
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

class _QuickStatsGrid extends StatelessWidget {
  final List<_QuickStatItem> items;

  const _QuickStatsGrid({required this.items});

  /// Scales with profile — reduce for compact, increase for comfortable.
  static const double _quickStatCardHeight = 80;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.xs2,
        crossAxisSpacing: AppSpacing.xs2,
        mainAxisExtent: _quickStatCardHeight,
      ),
      itemBuilder: (context, index) => _QuickStatCard(item: items[index]),
    );
  }
}

class _QuickStatItem {
  final String label;
  final String value;
  final IconData icon;

  const _QuickStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _QuickStatCard extends StatelessWidget {
  final _QuickStatItem item;

  const _QuickStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(item.icon,
                  size: AppIconSizes.sm, color: colorScheme.primary),
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                item.value,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CwaOverviewPanel extends StatelessWidget {
  static const double _wideLayoutMinWidth = 320;
  static const double _wideLayoutGap = AppSpacing.xs2;
  static const double _wideQuickStatCardHeight = 84;
  static const double _wideLayoutHeight =
      (_wideQuickStatCardHeight * 2) + _wideLayoutGap;

  final double projected;
  final double target;
  final double gap;
  final GradingSystem gradingSystem;
  final String label;
  final String eyebrow;
  final bool hasData;
  final String? emptyStateMessage;
  final List<_QuickStatItem> stats;

  const _CwaOverviewPanel({
    required this.projected,
    required this.target,
    required this.gap,
    required this.gradingSystem,
    required this.label,
    required this.eyebrow,
    required this.hasData,
    required this.stats,
    this.emptyStateMessage,
  }) : assert(stats.length >= 2);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _wideLayoutMinWidth) {
          return Column(
            children: [
              CwaSummaryBar(
                projected: projected,
                target: target,
                gap: gap,
                gradingSystem: gradingSystem,
                label: label,
                eyebrow: eyebrow,
                hasData: hasData,
                emptyStateMessage: emptyStateMessage,
                compact: true,
                centerHero: true,
              ),
              const SizedBox(height: AppSpacing.xs2),
              _QuickStatsGrid(items: stats),
            ],
          );
        }

        final statRailWidth = constraints.maxWidth < 360 ? 108.0 : 118.0;

        return SizedBox(
          height: _wideLayoutHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CwaSummaryBar(
                  projected: projected,
                  target: target,
                  gap: gap,
                  gradingSystem: gradingSystem,
                  label: label,
                  eyebrow: eyebrow,
                  hasData: hasData,
                  emptyStateMessage: emptyStateMessage,
                  compact: true,
                  centerHero: true,
                  showInsight: false,
                ),
              ),
              const SizedBox(width: _wideLayoutGap),
              SizedBox(
                width: statRailWidth,
                child: Column(
                  children: [
                    SizedBox(
                      height: _wideQuickStatCardHeight,
                      child: _QuickStatCard(item: stats[0]),
                    ),
                    const SizedBox(height: _wideLayoutGap),
                    SizedBox(
                      height: _wideQuickStatCardHeight,
                      child: _QuickStatCard(item: stats[1]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const _StateCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: AppIconSizes.xxxl,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs2),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
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

class _BottomCta extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _BottomCta({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: CampusButton(
        onPressed: onPressed,
        icon: Icon(icon, size: AppIconSizes.md),
        child: Text(label),
      ),
    );
  }
}

class _SectionNote extends StatelessWidget {
  final String text;

  const _SectionNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.35,
      ),
    );
  }
}

// ─── Semester view (existing behaviour) ──────────────────────────────────────

class _SemesterView extends ConsumerWidget {
  final Future<void> Function(BuildContext, WidgetRef, {CourseModel? existing})
      onOpenAddSheet;
  final Future<void> Function(BuildContext, WidgetRef, List<CourseModel>)
      onOpenCompleteSemester;
  final double bottomContentPadding;

  const _SemesterView({
    required this.onOpenAddSheet,
    required this.onOpenCompleteSemester,
    required this.bottomContentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final selectedGradingSystem = ref.watch(gradingSystemProvider);
    final projected = ref.watch(projectedCwaProvider);
    final cumulativeCwa = ref.watch(cumulativeCwaProvider);
    final cumulativeCredits = ref.watch(totalCreditsProvider);
    final cumulativeGap = ref.watch(cumulativeGapProvider);
    final pastSemestersAsync = ref.watch(pastSemestersProvider);
    final activeSemesterKey = ref.watch(activeSemesterProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cwaGapProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return coursesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: AppSpacing.screenPadding,
        child: ErrorRetryWidget(
          message: 'We could not load your courses right now.\n$e',
          onRetry: () => ref.invalidate(coursesProvider),
        ),
      ),
      data: (courses) {
        final gradingSystem =
            _gradingSystemForCourses(courses, selectedGradingSystem);
        final pairs = courses
            .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
            .toList();
        final highImpactIndices =
            CwaCalculator.highestImpactCourseIndices(pairs);
        final totalCredits =
            courses.fold<double>(0, (sum, course) => sum + course.creditHours);
        final hasCourses = courses.isNotEmpty;
        final pastSemesters = pastSemestersAsync.valueOrNull ?? [];
        final activeSemesterAlreadyRecorded = pastSemesters
            .any((semester) => semester.semesterKey == activeSemesterKey);
        final currentCoursesCounted =
            hasCourses && !activeSemesterAlreadyRecorded;
        final hasCumulativeData =
            pastSemesters.isNotEmpty || currentCoursesCounted;
        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SemesterSummaryHeaderDelegate(
                projected: projected,
                target: target,
                gap: gap,
                cumulative: cumulativeCwa,
                cumulativeCredits: cumulativeCredits,
                cumulativeGap: cumulativeGap,
                semesterCredits: totalCredits,
                courseCount: courses.length,
                gradingSystem: gradingSystem,
                hasCourses: hasCourses,
                hasCumulativeData: hasCumulativeData,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxs,
                  AppSpacing.xl,
                  0,
                ),
                child: CampusSectionHeader(
                  title: 'Course performance',
                  subtitle: hasCourses
                      ? '${courses.length} course${courses.length == 1 ? '' : 's'}'
                      : 'No courses yet',
                ),
              ),
            ),
            if (!hasCourses)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _StateCard(
                    icon: LucideIcons.bookOpen,
                    title: 'No courses added yet',
                    action: _BottomCta(
                      label: 'Add Course',
                      icon: LucideIcons.plus,
                      onPressed: () => onOpenAddSheet(context, ref),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final course = courses[i];
                    final repo = ref.read(cwaRepositoryProvider);
                    return CourseCard(
                      course: course,
                      gradingSystem:
                          _gradingSystemForCourse(course, gradingSystem),
                      isHighImpact: highImpactIndices.contains(i),
                      onEdit: () =>
                          onOpenAddSheet(context, ref, existing: course),
                      onDelete: () async {
                        final confirm = await showCampusConfirmDialog(
                          context: context,
                          title: 'Delete course?',
                          message:
                              'Remove ${course.code} from this semester projection? This only deletes the course entry from your current CWA setup.',
                          confirmLabel: 'Delete',
                          destructive: true,
                        );
                        if (confirm != true) return;

                        try {
                          await repo?.deleteCourse(course.id);
                        } catch (e) {
                          debugPrint('🔴 CwaScreen deleteCourse failed: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Could not delete course. Please try again.')),
                            );
                          }
                        }
                      },
                      onScoreChanged: (newScore) {
                        ref
                            .read(inFlightScoreAdjustmentsProvider.notifier)
                            .update((state) => {...state, course.id: newScore});
                      },
                      onDragEnd: (newScore) async {
                        ref
                            .read(inFlightScoreAdjustmentsProvider.notifier)
                            .update((state) {
                          final copy = Map<int, double>.from(state);
                          copy.remove(course.id);
                          return copy;
                        });
                        course.expectedScore = newScore;
                        await repo?.updateCourse(course);
                      },
                    );
                  },
                  childCount: courses.length,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  CwaScreen._compactListGap,
                  AppSpacing.xl,
                  AppSpacing.xs2,
                ),
                child: _BottomCta(
                  label: 'Add Course',
                  icon: LucideIcons.plus,
                  onPressed: () => onOpenAddSheet(context, ref),
                ),
              ),
            ),
            if (hasCourses)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xs2,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        onOpenCompleteSemester(context, ref, courses),
                    icon: const Icon(LucideIcons.badgeCheck),
                    label: const Text('Finish Semester'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: bottomContentPadding),
            ),
          ],
        );
      },
    );
  }
}

// ─── Cumulative view ──────────────────────────────────────────────────────────

class _CumulativeView extends ConsumerWidget {
  final void Function(BuildContext context) onOpenHistory;
  final double bottomContentPadding;

  const _CumulativeView({
    required this.onOpenHistory,
    required this.bottomContentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semestersAsync = ref.watch(pastSemestersProvider);
    final pendingSemesters = ref.watch(pendingPastSemestersProvider);
    final currentCoursesAsync = ref.watch(coursesProvider);
    final gradingSystem = ref.watch(gradingSystemProvider);
    final cumulativeCwa = ref.watch(cumulativeCwaProvider);
    final officialRecordedCwa = ref.watch(officialRecordedCwaProvider);
    final totalCredits = ref.watch(totalCreditsProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cumulativeGapProvider);
    final activeSemesterKey = ref.watch(activeSemesterProvider);
    final progression = ref.watch(semesterProgressionProvider);

    return semestersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: AppSpacing.screenPadding,
        child: ErrorRetryWidget(
          message: 'We could not load your academic history right now.\n$e',
          onRetry: () => ref.invalidate(pastSemestersProvider),
        ),
      ),
      data: (semesters) {
        final currentCourses = currentCoursesAsync.valueOrNull ?? [];
        final pendingCount = pendingSemesters.length;

        final hasPast = semesters.isNotEmpty;
        final hasCurrent = currentCourses.isNotEmpty;
        final activeSemesterAlreadyRecorded = semesters
            .any((semester) => semester.semesterKey == activeSemesterKey);
        final currentCoursesCounted =
            hasCurrent && !activeSemesterAlreadyRecorded;
        final hasAnyData = hasPast || currentCoursesCounted;
        final hasPending = pendingCount > 0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  CwaScreen._compactSectionGap,
                  AppSpacing.xl,
                  0,
                ),
                child: _CwaOverviewPanel(
                  projected: cumulativeCwa,
                  target: target,
                  gap: gap,
                  gradingSystem: gradingSystem,
                  label: gradingSystem.cumulativeMetricLabel,
                  eyebrow: currentCoursesCounted || hasPending
                      ? 'Estimated with current + pending data'
                      : 'From recorded semesters',
                  hasData: hasAnyData,
                  emptyStateMessage:
                      'Import past result slips to build your academic history and unlock your cumulative ${gradingSystem.cumulativeLabel}.',
                  stats: [
                    _QuickStatItem(
                      label: 'Semester records',
                      value: '${semesters.length}',
                      icon: LucideIcons.briefcase,
                    ),
                    _QuickStatItem(
                      label: 'Total credits',
                      value: '${totalCredits.toInt()} cr',
                      icon: LucideIcons.chartColumn,
                    ),
                  ],
                ),
              ),
            ),
            if (progression.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    CwaScreen._compactSectionGap,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _SemesterProgressionCard(entries: progression),
                ),
              ),
            if (hasPending)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    CwaScreen._compactSectionGap,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _SupportCard(
                    icon: LucideIcons.badgeAlert,
                    title: 'Pending results are still estimates',
                    subtitle:
                        '$pendingCount semester record${pendingCount == 1 ? '' : 's'} ${pendingCount == 1 ? 'is' : 'are'} still awaiting official results. Your main cumulative number includes those archived projections, while recorded results only currently sit at ${gradingSystem.formatScore(officialRecordedCwa)}.',
                    actions: [
                      _InlineActionButton(
                        label: 'Review History',
                        primary: false,
                        icon: LucideIcons.bookOpen,
                        onPressed: () => onOpenHistory(context),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  CwaScreen._compactSectionGap,
                  AppSpacing.xl,
                  0,
                ),
                child: _SupportCard(
                  icon: LucideIcons.fileUp,
                  title: 'Build academic history',
                  subtitle:
                      'Import past result slips or open your saved semester records to understand your full academic picture.',
                  actions: [
                    _InlineActionButton(
                      label: 'Open History',
                      primary: false,
                      icon: LucideIcons.bookOpen,
                      onPressed: () => onOpenHistory(context),
                    ),
                    _InlineActionButton(
                      label: 'Import',
                      icon: LucideIcons.fileUp,
                      onPressed: () => context.pushNamed('cwa-import-results'),
                    ),
                  ],
                ),
              ),
            ),
            if (!hasPast)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    CwaScreen._compactSectionGap,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _StateCard(
                    icon: LucideIcons.fileUp,
                    title: 'No cumulative history yet',
                    subtitle:
                        'Import your previous result slips to see your true cumulative ${gradingSystem.cumulativeLabel} across all semesters.',
                    action: _InlineActionButton(
                      label: 'Import Results',
                      icon: LucideIcons.fileUp,
                      onPressed: () => context.pushNamed('cwa-import-results'),
                    ),
                  ),
                ),
              ),
            if (hasPast) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    CwaScreen._compactSectionGap,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: CampusSectionHeader(
                    title: 'Academic history',
                    subtitle:
                        '${semesters.length} semester record${semesters.length == 1 ? '' : 's'}',
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: 4,
                    ),
                    child: _PastSemesterSummaryCard(semester: semesters[i]),
                  ),
                  childCount: semesters.length,
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  CwaScreen._compactSectionGap,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: CampusSectionHeader(
                  title: 'Current semester',
                  subtitle: hasCurrent
                      ? '${currentCourses.length} course${currentCourses.length == 1 ? '' : 's'} in progress'
                      : 'No current courses added',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'In progress',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!hasCurrent)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: _SectionNote(
                    text:
                        'Switch to Semester view to add current courses and keep your cumulative view up to date.',
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final c = currentCourses[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: 4,
                      ),
                      child: _CurrentCourseRow(course: c),
                    );
                  },
                  childCount: currentCourses.length,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  CwaScreen._compactSectionGap,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: _BottomCta(
                  label: 'Add Semester',
                  icon: LucideIcons.plus,
                  onPressed: () => onOpenHistory(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: bottomContentPadding),
            ),
          ],
        );
      },
    );
  }
}

// ─── Semester progression ────────────────────────────────────────────────────

class _SemesterProgressionCard extends StatelessWidget {
  final List<SemesterProgressionEntry> entries;

  const _SemesterProgressionCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latest = entries.last;
    final latestDelta = latest.cumulativeDelta;

    return CampusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(
                  LucideIcons.trendingUp,
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
                      'Semester progression',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      latestDelta == null
                          ? 'Your first recorded semester is now on the timeline.'
                          : 'Latest cumulative move: ${_signed(latestDelta)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _DeltaPill(delta: latestDelta),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ProgressionSparkBars(entries: entries),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xs),
          ...entries.map(
            (entry) => _ProgressionRow(entry: entry),
          ),
        ],
      ),
    );
  }
}

class _ProgressionSparkBars extends StatelessWidget {
  final List<SemesterProgressionEntry> entries;

  const _ProgressionSparkBars({required this.entries});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: entries.map((entry) {
            final normalized =
                entry.semesterCwa.clamp(0.0, 100.0).toDouble() / 100;
            final height = 18 + (normalized * 48);
            final color = _deltaColor(entry.semesterDelta);

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Tooltip(
                message:
                    '${entry.semester.semesterLabel}: ${entry.semesterCwa.toStringAsFixed(2)}',
                child: Container(
                  width: 28,
                  height: height,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(AppRadii.xxs),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ProgressionRow extends StatelessWidget {
  final SemesterProgressionEntry entry;

  const _ProgressionRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pending = entry.semester.isPendingResults;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: pending
                    ? AppTheme.warning
                    : _deltaColor(entry.semesterDelta),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.semester.semesterLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  '${entry.semester.courses.length} courses'
                  '${pending ? ' • Pending official marks' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Sem ${entry.semesterCwa.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                'Cum ${entry.cumulativeCwa.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          _DeltaPill(delta: entry.semesterDelta),
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  final double? delta;

  const _DeltaPill({required this.delta});

  @override
  Widget build(BuildContext context) {
    final value = delta;
    final color = value == null || value.abs() < 0.05
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : _deltaColor(value);
    final icon = value == null
        ? LucideIcons.minus
        : value > 0
            ? LucideIcons.trendingUp
            : value < 0
                ? LucideIcons.trendingDown
                : LucideIcons.minus;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.xs, color: color),
          const SizedBox(width: 3),
          Text(
            value == null ? 'Start' : _signed(value),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

Color _deltaColor(double? delta) {
  if (delta == null || delta.abs() < 0.05) return AppTheme.textSecondary;
  if (delta > 0) return AppTheme.success;
  return AppTheme.warning;
}

String _signed(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}';
}

// ─── Past semester summary card (read-only, collapsible) ─────────────────────

class _PastSemesterSummaryCard extends StatefulWidget {
  final PastSemesterModel semester;
  const _PastSemesterSummaryCard({required this.semester});

  @override
  State<_PastSemesterSummaryCard> createState() =>
      _PastSemesterSummaryCardState();
}

class _PastSemesterSummaryCardState extends State<_PastSemesterSummaryCard> {
  bool _expanded = false;

  double get _semCwa {
    if (widget.semester.courses.isEmpty) return 0;
    double w = 0, cr = 0;
    for (final c in widget.semester.courses) {
      w += c.creditHours * c.score;
      cr += c.creditHours;
    }
    return cr == 0 ? 0 : w / cr;
  }

  @override
  Widget build(BuildContext context) {
    final cwa = _semCwa;
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: AppRadii.card,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm2,
                AppSpacing.sm2,
                AppSpacing.sm2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.semester.semesterLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${widget.semester.courses.length} courses'
                          '${widget.semester.reportedSemesterCwa != null ? ' • Slip: ${widget.semester.reportedSemesterCwa!.toStringAsFixed(2)}' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      cwa.toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: AppIconSizes.xl,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, indent: 20, endIndent: 20),
            ...widget.semester.courses.map(
              (c) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs2,
                  AppSpacing.md,
                  2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(c.courseCode,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.4)),
                        ),
                        _ScorePill(mark: c.mark, score: c.score),
                        const SizedBox(width: AppSpacing.xxs),
                        _GradePill(grade: c.grade),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(c.courseName,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          '${c.creditHours.toInt()} cr',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

// ─── Current course row (read-only in cumulative view) ────────────────────────

class _CurrentCourseRow extends StatelessWidget {
  final CourseModel course;
  const _CurrentCourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${course.creditHours.toInt()} cr',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${course.expectedScore.toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score pill (shows exact mark or grade approximation with warning) ────────

class _ScorePill extends StatelessWidget {
  /// Null means no mark was imported; [score] is then a grade midpoint estimate.
  final double? mark;
  final double score;

  const _ScorePill({required this.mark, required this.score});

  @override
  Widget build(BuildContext context) {
    final isApprox = mark == null;
    final colorScheme = Theme.of(context).colorScheme;
    final warningColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFFFFB05C)
        : const Color(0xFFF57F17);
    return Tooltip(
      message: isApprox
          ? 'Estimated from grade — enter the exact mark in Result History for accuracy'
          : 'Exact mark used in CWA calculation',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isApprox
              ? warningColor.withValues(alpha: 0.14)
              : colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isApprox
                ? warningColor.withValues(alpha: 0.38)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isApprox ? warningColor : colorScheme.primary,
              ),
            ),
            if (isApprox) ...[
              const SizedBox(width: AppSpacing.xxxs),
              Icon(Icons.warning_amber_rounded, size: 10, color: warningColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Grade pill ───────────────────────────────────────────────────────────────

class _GradePill extends StatelessWidget {
  final String grade;

  static const _colors = {
    'A': Color(0xFF2E7D32),
    'B': Color(0xFF1565C0),
    'C': Color(0xFFF57F17),
    'D': Color(0xFFE65100),
    'F': Color(0xFFC62828),
  };

  const _GradePill({required this.grade});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _gradeAccentColor(
      grade,
      colorScheme.brightness == Brightness.dark,
      colorScheme.onSurfaceVariant,
    );
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      alignment: Alignment.center,
      child: Text(
        grade.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _gradeAccentColor(String grade, bool isDark, Color fallback) {
    if (!isDark) return _colors[grade.toUpperCase()] ?? fallback;
    return switch (grade.toUpperCase()) {
      'A' => const Color(0xFF63D28A),
      'B' => const Color(0xFF8DB5FF),
      'C' => const Color(0xFFFFC15E),
      'D' => const Color(0xFFFFA05A),
      'F' => const Color(0xFFFF7A7A),
      _ => fallback,
    };
  }
}
