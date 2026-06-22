import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/timetable_course_candidate.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/shared/widgets/campus_modal_action_row.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<int?> showTimetableCourseImportSheet(BuildContext context) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const TimetableCourseImportSheet(),
  );
}

class TimetableCourseImportSheet extends ConsumerWidget {
  const TimetableCourseImportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(allSlotsProvider);
    final coursesAsync = ref.watch(coursesProvider);

    if ((slotsAsync.isLoading && slotsAsync.valueOrNull == null) ||
        (coursesAsync.isLoading && coursesAsync.valueOrNull == null)) {
      return const _StatusSheet(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (slotsAsync.hasError || coursesAsync.hasError) {
      return _StatusSheet(
        child: _MessageState(
          icon: LucideIcons.triangleAlert,
          title: 'Could not load courses',
          message: 'Close this sheet and try again.',
          actionLabel: 'Close',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final candidates = buildTimetableCourseCandidates(
      slots: slotsAsync.valueOrNull ?? const [],
      existingCourses: coursesAsync.valueOrNull ?? const [],
    );

    if (candidates.isEmpty) {
      final hasTimetableCourses = (slotsAsync.valueOrNull ?? const [])
          .any((slot) => slot.courseCode.trim().isNotEmpty);
      return _StatusSheet(
        child: _MessageState(
          icon: LucideIcons.calendarCheck,
          title: hasTimetableCourses
              ? 'All timetable courses are already added'
              : 'No timetable courses found',
          message: hasTimetableCourses
              ? 'Your current semester course list is already up to date.'
              : 'Import or add classes to your timetable first, then return here.',
          actionLabel: 'Close',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    return _TimetableCourseSelectionForm(
      candidates: candidates,
      semesterKey: ref.watch(activeSemesterProvider),
      gradingSystem: ref.watch(gradingSystemProvider),
    );
  }
}

class _TimetableCourseSelectionForm extends ConsumerStatefulWidget {
  final List<TimetableCourseCandidate> candidates;
  final String semesterKey;
  final GradingSystem gradingSystem;

  const _TimetableCourseSelectionForm({
    required this.candidates,
    required this.semesterKey,
    required this.gradingSystem,
  });

  @override
  ConsumerState<_TimetableCourseSelectionForm> createState() =>
      _TimetableCourseSelectionFormState();
}

class _TimetableCourseSelectionFormState
    extends ConsumerState<_TimetableCourseSelectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _selectedCodes = <String>{};
  final _creditControllers = <String, TextEditingController>{};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (final candidate in widget.candidates) {
      _selectedCodes.add(candidate.code);
      _creditControllers[candidate.code] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _creditControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedCodes.isEmpty || !_formKey.currentState!.validate()) return;
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) return;

    setState(() => _isSaving = true);
    var savedCount = 0;

    try {
      for (final candidate in widget.candidates) {
        if (!_selectedCodes.contains(candidate.code)) continue;
        final alreadyExists = await repo.courseExistsByCode(
          candidate.code,
          widget.semesterKey,
        );
        if (alreadyExists) continue;

        final credits =
            double.parse(_creditControllers[candidate.code]!.text.trim());
        await repo.addCourse(
          CourseModel.create(
            name: candidate.name,
            code: candidate.code,
            creditHours: credits,
            expectedScore: widget.gradingSystem.defaultTarget,
            semesterKey: widget.semesterKey,
            gradingSystemId: widget.gradingSystem.id,
          ),
        );
        savedCount++;
      }

      await AnalyticsService.instance.logCourseSaved(
        action: 'imported',
        source: 'timetable',
        gradingSystem: widget.gradingSystem.id,
      );
      if (mounted) Navigator.of(context).pop(savedCount);
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'course_save_failed',
        context: {'source': 'timetable'},
      );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not add timetable courses. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CampusModalSheet(
        title: 'Use Timetable Courses',
        subtitle:
            'Choose the courses to add to your current semester, then enter the correct credit hours for each one.',
        leading: const _TimetableImportIcon(),
        scrollable: true,
        maxHeightFactor: 0.94,
        bottomBar: CampusModalActionRow(
          secondaryLabel: 'Cancel',
          onSecondaryPressed:
              _isSaving ? null : () => Navigator.of(context).pop(),
          primaryLabel:
              'Add ${_selectedCodes.length} Course${_selectedCodes.length == 1 ? '' : 's'}',
          onPrimaryPressed: _selectedCodes.isEmpty || _isSaving ? null : _save,
          isPrimaryLoading: _isSaving,
        ),
        child: Column(
          children: [
            for (var index = 0; index < widget.candidates.length; index++) ...[
              _CandidateCourseRow(
                candidate: widget.candidates[index],
                selected:
                    _selectedCodes.contains(widget.candidates[index].code),
                creditController:
                    _creditControllers[widget.candidates[index].code]!,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCodes.add(widget.candidates[index].code);
                    } else {
                      _selectedCodes.remove(widget.candidates[index].code);
                    }
                  });
                },
              ),
              if (index != widget.candidates.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _CandidateCourseRow extends StatelessWidget {
  final TimetableCourseCandidate candidate;
  final bool selected;
  final TextEditingController creditController;
  final ValueChanged<bool> onSelected;

  const _CandidateCourseRow({
    required this.candidate,
    required this.selected,
    required this.creditController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.button,
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: selected,
            onChanged: (value) => onSelected(value ?? false),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.code,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  candidate.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 92,
            child: TextFormField(
              controller: creditController,
              enabled: selected,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Credits',
                hintText: '3',
                isDense: true,
              ),
              validator: (value) {
                if (!selected) return null;
                final credits = int.tryParse(value?.trim() ?? '');
                if (credits == null) return 'Required';
                if (credits < 1 || credits > 12) return '1–12 only';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSheet extends StatelessWidget {
  final Widget child;

  const _StatusSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return CampusModalSheet(
      title: 'Use Timetable Courses',
      subtitle: 'Add timetable courses to your current semester.',
      leading: const _TimetableImportIcon(),
      child: SizedBox(height: 220, child: child),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppIconSizes.hero, color: colorScheme.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _TimetableImportIcon extends StatelessWidget {
  const _TimetableImportIcon();

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
        LucideIcons.calendarDays,
        color: AppColors.navy,
        size: AppIconSizes.xl,
      ),
    );
  }
}
