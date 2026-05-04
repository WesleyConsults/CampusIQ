import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/layout/shell_overlay_padding.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/cwa_summary_bar.dart';
import 'package:campusiq/features/cwa/presentation/widgets/course_card.dart';
import 'package:campusiq/features/cwa/presentation/widgets/add_course_sheet.dart';
import 'package:campusiq/features/cwa/presentation/widgets/cwa_coach_sheet.dart';
import 'package:campusiq/features/cwa/presentation/screens/registration_slip_import_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/result_slip_import_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/past_semesters_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/shared/widgets/campus_button.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';

class CwaScreen extends ConsumerWidget {
  const CwaScreen({super.key});

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref,
      {CourseModel? existing}) async {
    final result = await showModalBottomSheet<CourseModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCourseSheet(
        semesterKey: ref.read(activeSemesterProvider),
        existing: existing,
      ),
    );

    if (result == null) return;
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) return;

    try {
      existing == null
          ? await repo.addCourse(result)
          : await repo.updateCourse(result);
    } catch (e) {
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PastSemestersScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(cwaViewModeProvider);
    final hasActiveSession = ref.watch(activeSessionProvider) != null;
    final bottomContentPadding = shellOverlayBottomPadding(
      context,
      hasActiveSession: hasActiveSession,
    );

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('CWA', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Semantics(
            button: true,
            label: 'Import courses or results',
            child: TextButton.icon(
              onPressed: () => _showImportSheet(context, viewMode),
              icon: const Icon(LucideIcons.fileUp, size: AppIconSizes.lg),
              label: const Text('Import'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
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
                case _CwaMenuAction.target:
                  _showTargetDialog(
                    context,
                    ref,
                    ref.read(targetCwaProvider),
                  );
                  return;
                case _CwaMenuAction.history:
                  _openHistory(context);
                  return;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _CwaMenuAction.target,
                child: Text('Set target CWA'),
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
              AppSpacing.sm,
              AppSpacing.xl,
              0,
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

  void _showTargetDialog(BuildContext context, WidgetRef ref, double current) {
    double temp = current;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Target CWA'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppTheme.primary,
                    iconSize: 32,
                    onPressed: temp > 40
                        ? () => setState(() => temp = (temp - 1).clamp(40, 100))
                        : null,
                  ),
                  Text(
                    '${temp.toInt()}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppTheme.primary,
                    iconSize: 32,
                    onPressed: temp < 100
                        ? () => setState(() => temp = (temp + 1).clamp(40, 100))
                        : null,
                  ),
                ],
              ),
              Slider(
                value: temp,
                min: 40,
                max: 100,
                divisions: 60,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => temp = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(targetCwaProvider.notifier).state = temp;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set'),
          ),
        ],
      ),
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
            label: 'Take photo',
            subtitle: 'Capture a registration or result slip now.',
            onTap: () {
              Navigator.of(sheetContext).pop();
              _openImportScreen(context, viewMode, initialSource: 'camera');
            },
          ),
          _ImportOption(
            icon: LucideIcons.imageUp,
            label: 'Upload image',
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
            label: 'Enter manually',
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => viewMode == CwaViewMode.semester
            ? RegistrationSlipImportScreen(initialSource: initialSource)
            : ResultSlipImportScreen(initialSource: initialSource),
      ),
    );
  }
}

// ─── Toggle widget ────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final CwaViewMode mode;
  final ValueChanged<CwaViewMode> onChanged;

  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.button,
        border: Border.all(
          color: AppColors.border,
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
              color: active ? AppTheme.primary : Colors.transparent,
              borderRadius: AppRadii.button,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _CwaMenuAction { target, history }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final option in options) ...[
            _ImportOptionTile(option: option),
            if (option != options.last) const SizedBox(height: AppSpacing.sm),
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
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: AppRadii.button,
      ),
      child: const Icon(
        LucideIcons.fileUp,
        color: AppTheme.primary,
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
    return CampusCard(
      padding: EdgeInsets.zero,
      color: AppColors.surfaceMuted,
      onTap: option.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.button,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                option.icon,
                color: AppTheme.primary,
                size: AppIconSizes.xl,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: AppTheme.textSecondary,
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
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: AppTheme.primary, size: AppIconSizes.xl),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: actions,
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
  static const double _quickStatCardHeight = 92;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
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
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 15, color: AppTheme.primary),
          const Spacer(),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(icon, color: AppTheme.primary, size: AppIconSizes.xxxl),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
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
      style: const TextStyle(
        fontSize: 13,
        color: AppTheme.textSecondary,
        height: 1.45,
      ),
    );
  }
}

// ─── Semester view (existing behaviour) ──────────────────────────────────────

class _SemesterView extends ConsumerWidget {
  final Future<void> Function(BuildContext, WidgetRef, {CourseModel? existing})
      onOpenAddSheet;
  final double bottomContentPadding;

  const _SemesterView({
    required this.onOpenAddSheet,
    required this.bottomContentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final projected = ref.watch(projectedCwaProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cwaGapProvider);

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
        final pairs = courses
            .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
            .toList();
        final highImpactIndices =
            CwaCalculator.highestImpactCourseIndices(pairs);
        final totalCredits =
            courses.fold<double>(0, (sum, course) => sum + course.creditHours);
        final hasCourses = courses.isNotEmpty;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  0,
                ),
                child: CwaSummaryBar(
                  projected: projected,
                  target: target,
                  gap: gap,
                  label: 'Projected CWA',
                  eyebrow: 'Current semester',
                  hasData: hasCourses,
                  emptyStateMessage:
                      'Add your courses to see your semester projection and where to improve.',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  0,
                ),
                child: _QuickStatsGrid(
                  items: [
                    _QuickStatItem(
                      label: 'Courses',
                      value: '${courses.length}',
                      icon: LucideIcons.bookOpen,
                    ),
                    _QuickStatItem(
                      label: 'Credits',
                      value: '${totalCredits.toInt()} cr',
                      icon: LucideIcons.chartColumn,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xs,
                  AppSpacing.xl,
                  0,
                ),
                child: _SupportCard(
                  icon: LucideIcons.fileUp,
                  title: 'Import courses',
                  subtitle:
                      'Scan your registration slip or add courses manually without rebuilding this semester from scratch.',
                  actions: [
                    _InlineActionButton(
                      label: 'Import',
                      icon: LucideIcons.fileUp,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegistrationSlipImportScreen(),
                        ),
                      ),
                    ),
                    _InlineActionButton(
                      label: 'Add manually',
                      primary: false,
                      icon: LucideIcons.plus,
                      onPressed: () =>
                          context.push('/cwa/manual-entry?mode=semester'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  0,
                ),
                child: CampusSectionHeader(
                  title: 'Course performance',
                  subtitle: hasCourses
                      ? '${courses.length} course${courses.length == 1 ? '' : 's'}'
                      : 'No courses yet',
                  trailing: TextButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const CwaCoachSheet(),
                    ),
                    icon: const Icon(LucideIcons.sparkles, size: AppIconSizes.md),
                    label: const Text('Coach'),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  6,
                  AppSpacing.xl,
                  AppSpacing.xs,
                ),
                child: _SectionNote(
                  text: hasCourses
                      ? 'Adjust only the courses you want to focus on. Your projected CWA updates live as you edit.'
                      : 'Start with one course and CampusIQ will calculate the rest from there.',
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
                    subtitle:
                        'Add your semester courses to see your projected CWA, target gap, and which courses need more attention.',
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
                      onScoreChanged: (newScore) async {
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
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: _BottomCta(
                  label: 'Add Course',
                  icon: LucideIcons.plus,
                  onPressed: () => onOpenAddSheet(context, ref),
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
    final currentCoursesAsync = ref.watch(coursesProvider);
    final cumulativeCwa = ref.watch(cumulativeCwaProvider);
    final totalCredits = ref.watch(totalCreditsProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cumulativeGapProvider);

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

        final hasPast = semesters.isNotEmpty;
        final hasCurrent = currentCourses.isNotEmpty;
        final hasAnyData = hasPast || hasCurrent;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  0,
                ),
                child: CwaSummaryBar(
                  projected: cumulativeCwa,
                  target: target,
                  gap: gap,
                  label: 'Cumulative CWA',
                  eyebrow: 'Across all semesters',
                  hasData: hasAnyData,
                  emptyStateMessage:
                      'Import past result slips to build your academic history and unlock your cumulative CWA.',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  0,
                ),
                child: _QuickStatsGrid(
                  items: [
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
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
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ResultSlipImportScreen(),
                        ),
                      ),
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
                    AppSpacing.lg,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _StateCard(
                    icon: LucideIcons.fileUp,
                    title: 'No cumulative history yet',
                    subtitle:
                        'Import your previous result slips to see your true cumulative CWA across all semesters.',
                    action: _InlineActionButton(
                      label: 'Import Results',
                      icon: LucideIcons.fileUp,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ResultSlipImportScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (hasPast) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
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
                      vertical: 6,
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
                  AppSpacing.xl,
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
                      vertical: 6,
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
                        vertical: 6,
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
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
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

    return CampusCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: AppRadii.card,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.semester.semesterLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${widget.semester.courses.length} courses'
                          '${widget.semester.reportedSemesterCwa != null ? ' • Slip: ${widget.semester.reportedSemesterCwa!.toStringAsFixed(2)}' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      cwa.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: AppIconSizes.xl,
                    color: AppTheme.textSecondary,
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
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(c.courseCode,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
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
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          '${c.creditHours.toInt()} cr',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
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
    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${course.creditHours.toInt()} cr',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${course.expectedScore.toInt()}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppTheme.primary,
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
    return Tooltip(
      message: isApprox
          ? 'Estimated from grade — enter the exact mark in Result History for accuracy'
          : 'Exact mark used in CWA calculation',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isApprox
              ? const Color(0xFFF57F17).withValues(alpha: 0.10)
              : AppTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isApprox
                ? const Color(0xFFF57F17).withValues(alpha: 0.35)
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
                color: isApprox ? const Color(0xFFF57F17) : AppTheme.primary,
              ),
            ),
            if (isApprox) ...[
              const SizedBox(width: AppSpacing.xxxs),
              const Icon(Icons.warning_amber_rounded,
                  size: 10, color: Color(0xFFF57F17)),
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
    final color = _colors[grade.toUpperCase()] ?? AppTheme.textSecondary;
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
}
