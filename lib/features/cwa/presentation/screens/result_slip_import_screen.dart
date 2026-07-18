import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/providers/connectivity_provider.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/domain/past_course_result.dart';
import 'package:campusiq/features/cwa/domain/academic_document_kind.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/result_slip_import_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/active_semester_picker.dart';
import 'package:campusiq/features/cwa/presentation/widgets/academic_import_destination_banner.dart';
import 'package:campusiq/features/cwa/presentation/widgets/wrong_academic_document_view.dart';
import 'package:campusiq/features/cwa/presentation/widgets/grade_value_dropdown.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
import 'package:campusiq/shared/widgets/import_option_grid.dart';

class ResultSlipImportScreen extends ConsumerStatefulWidget {
  final String? initialSource;

  const ResultSlipImportScreen({super.key, this.initialSource});

  @override
  ConsumerState<ResultSlipImportScreen> createState() =>
      _ResultSlipImportScreenState();
}

class _ResultSlipImportScreenState
    extends ConsumerState<ResultSlipImportScreen> {
  bool _didTriggerInitialSource = false;

  @override
  void dispose() {
    final step = ref.read(resultSlipImportNotifierProvider).step;
    if (step != ResultImportStep.idle && step != ResultImportStep.done) {
      AnalyticsService.instance.logImportAbandoned(
        importType: 'result',
        step: step.name,
      );
    }
    super.dispose();
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You're offline. Connect to use features."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _runIfOnline(Future<void> Function() action) async {
    final isOnline = await ref.read(isOnlineProvider.future);
    if (!mounted) return;
    if (!isOnline) {
      _showOfflineMessage();
      return;
    }
    await action();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didTriggerInitialSource) return;
    _didTriggerInitialSource = true;

    final source = widget.initialSource;
    if (source == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(resultSlipImportNotifierProvider.notifier);
      switch (source) {
        case 'camera':
          _runIfOnline(notifier.pickFromCamera);
          return;
        case 'gallery':
          _runIfOnline(notifier.pickFromGallery);
          return;
        case 'pdf':
          _runIfOnline(notifier.pickFromFile);
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resultSlipImportNotifierProvider);
    final notifier = ref.read(resultSlipImportNotifierProvider.notifier);
    final gradingSystem = ref.watch(gradingSystemProvider);
    final activeSemester = ActiveSemesterSelection.fromKey(
      ref.watch(activeSemesterProvider),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Past Results'),
        leading: BackButton(
          onPressed: () {
            notifier.reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: state.documentKind == AcademicDocumentKind.registrationSlip
          ? WrongAcademicDocumentView(
              detectedLabel: 'a current course registration slip',
              expectedLabel: 'Academic History — Past Results',
              actionLabel: 'Open Current Courses',
              onSwitch: () {
                notifier.reset();
                context.pushReplacement('/cwa/import/registration');
              },
              onTryAgain: notifier.reset,
            )
          : switch (state.step) {
              ResultImportStep.idle => _IdleView(
                  onCamera: () => _runIfOnline(notifier.pickFromCamera),
                  onGallery: () => _runIfOnline(notifier.pickFromGallery),
                  onPdf: () => _runIfOnline(notifier.pickFromFile),
                  onManual: () {
                    notifier.reset();
                    context.push('/cwa/manual-entry?mode=cumulative');
                  },
                  onCurrentCourses: () {
                    notifier.reset();
                    context.pushReplacement('/cwa/import/registration');
                  },
                ),
              ResultImportStep.picking ||
              ResultImportStep.parsing =>
                _LoadingView(
                  state.step == ResultImportStep.parsing
                      ? 'Uploading and reading completed results…'
                      : 'Opening your document…',
                ),
              ResultImportStep.labelling => _LabelView(
                  notifier: notifier,
                  initialSelection: activeSemester,
                  parsedAcademicYearStart: state.parsedAcademicYearStart,
                  parsedSemesterNumber: state.parsedSemesterNumber,
                  parsedLevel: state.parsedLevel,
                  parsedProgramme: state.parsedProgramme,
                ),
              ResultImportStep.reviewing => _ReviewView(
                  state: state,
                  notifier: notifier,
                  gradingSystem: gradingSystem,
                ),
              ResultImportStep.saving =>
                const _LoadingView('Saving to Academic History…'),
              ResultImportStep.done => _DoneView(
                  count: state.selectedIndexes.length,
                  label: state.semesterLabel,
                  onFinish: () {
                    notifier.reset();
                    Navigator.of(context).pop();
                  },
                ),
              ResultImportStep.error => _ErrorView(
                  message: state.errorMessage ?? 'Unknown error.',
                  onRetry: notifier.reset,
                ),
            },
    );
  }
}

// ─── Idle ─────────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onPdf;
  final VoidCallback onManual;
  final VoidCallback onCurrentCourses;

  const _IdleView({
    required this.onCamera,
    required this.onGallery,
    required this.onPdf,
    required this.onManual,
    required this.onCurrentCourses,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AcademicImportDestinationBanner(
          destination: 'Academic History — Past Results',
          description:
              'Upload official grades from a semester you have completed. Current registered courses do not belong here.',
          alternativeLabel: 'I have current courses instead',
          onAlternative: onCurrentCourses,
        ),
        const SizedBox(height: AppSpacing.lg),
        ImportOptionGrid(
          options: [
            ImportOptionGridItem(
              icon: LucideIcons.camera,
              label: 'Take Photo',
              onTap: onCamera,
            ),
            ImportOptionGridItem(
              icon: LucideIcons.image,
              label: 'Upload Image',
              onTap: onGallery,
            ),
            ImportOptionGridItem(
              icon: LucideIcons.fileText,
              label: 'Choose PDF',
              onTap: onPdf,
            ),
            ImportOptionGridItem(
              icon: LucideIcons.squarePen,
              label: 'Enter Manually',
              onTap: onManual,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Label ────────────────────────────────────────────────────────────────────

class _LabelView extends StatefulWidget {
  final ResultSlipImportNotifier notifier;
  final ActiveSemesterSelection initialSelection;
  final int? parsedAcademicYearStart;
  final int? parsedSemesterNumber;
  final int? parsedLevel;
  final String? parsedProgramme;

  const _LabelView({
    required this.notifier,
    required this.initialSelection,
    this.parsedAcademicYearStart,
    this.parsedSemesterNumber,
    this.parsedLevel,
    this.parsedProgramme,
  });

  @override
  State<_LabelView> createState() => _LabelViewState();
}

class _LabelViewState extends State<_LabelView> {
  late int _selectedStartYear;
  late AcademicTermType _selectedTermType;
  final _levelController = TextEditingController();
  final _programmeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStartYear =
        widget.parsedAcademicYearStart ?? widget.initialSelection.startYear;
    _selectedTermType = widget.parsedSemesterNumber == null
        ? widget.initialSelection.termType
        : AcademicTermType.fromSemesterNumber(widget.parsedSemesterNumber!);

    final parsedLevel = widget.parsedLevel;
    if (parsedLevel != null) {
      _levelController.text = parsedLevel.toString();
    }

    final parsedProgramme = widget.parsedProgramme;
    if (parsedProgramme != null) {
      _programmeController.text = parsedProgramme;
    }
  }

  @override
  void dispose() {
    _levelController.dispose();
    _programmeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yearOptions = _academicYearOptions(_selectedStartYear);
    final selection = ActiveSemesterSelection(
      startYear: _selectedStartYear,
      termType: _selectedTermType,
    );
    final previewLabel = _buildSemesterLabel(selection);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Which semester is this?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Pick the academic year and semester. Level and programme are optional labels for your own reference.',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 28),
        DropdownButtonFormField<int>(
          initialValue: _selectedStartYear,
          decoration: InputDecoration(
            labelText: 'Academic Year',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: yearOptions
              .map(
                (year) => DropdownMenuItem<int>(
                  value: year,
                  child: Text('$year/${year + 1}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedStartYear = value);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<AcademicTermType>(
          initialValue: _selectedTermType,
          decoration: InputDecoration(
            labelText: 'Semester',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: const [
            DropdownMenuItem<AcademicTermType>(
              value: AcademicTermType.firstSemester,
              child: Text('First Semester'),
            ),
            DropdownMenuItem<AcademicTermType>(
              value: AcademicTermType.secondSemester,
              child: Text('Second Semester'),
            ),
            DropdownMenuItem<AcademicTermType>(
              value: AcademicTermType.supplementarySemester,
              child: Text('Supplementary Semester'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedTermType = value);
          },
        ),
        if (_selectedTermType == AcademicTermType.supplementarySemester) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Use this for resits, failed courses, deferred papers, or missing-credit results.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _levelController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Level (optional)',
            hintText: 'e.g. 300',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _programmeController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Programme (optional)',
            hintText: 'e.g. Computer Engineering',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saved as',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                previewLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: const Text('Continue to Review'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  List<int> _academicYearOptions(int selectedYear) {
    final currentYear = DateTime.now().year;
    final years = <int>{
      selectedYear,
      for (var year = currentYear - 6; year <= currentYear + 1; year++) year,
    }.toList()
      ..sort((a, b) => b.compareTo(a));
    return years;
  }

  String _buildSemesterLabel(ActiveSemesterSelection selection) {
    final parts = <String>[selection.displayLabel];
    final level = _levelController.text.trim();
    final programme = _programmeController.text.trim();

    if (level.isNotEmpty) {
      final normalized =
          level.toUpperCase().startsWith('L') ? level.toUpperCase() : 'L$level';
      parts.add(normalized);
    }
    if (programme.isNotEmpty) parts.add(programme);

    return parts.join(' • ');
  }

  void _onContinue() {
    final selection = ActiveSemesterSelection(
      startYear: _selectedStartYear,
      termType: _selectedTermType,
    );
    widget.notifier.confirmSemesterIdentity(
      semesterKey: selection.key,
      semesterLabel: _buildSemesterLabel(selection),
    );
  }
}

// ─── Review ───────────────────────────────────────────────────────────────────

class _ReviewView extends StatelessWidget {
  final ResultImportState state;
  final ResultSlipImportNotifier notifier;
  final GradingSystem gradingSystem;

  const _ReviewView({
    required this.state,
    required this.notifier,
    required this.gradingSystem,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedIndexes.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: AcademicImportDestinationBanner(
            destination: 'Academic History — Past Results',
            description:
                'These courses will be stored as completed official results and included in your cumulative calculation.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.semesterLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${state.courses.length} courses found',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (state.reportedSemesterCwa != null ||
                        state.reportedCumulativeCwa != null) ...[
                      const SizedBox(height: AppSpacing.xxs2),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (state.reportedSemesterCwa != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xxs),
                              ),
                              child: Text(
                                'Reported Sem ${gradingSystem.label}: ${state.reportedSemesterCwa?.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary),
                              ),
                            ),
                          if (state.reportedCumulativeCwa != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xxs),
                              ),
                              child: Text(
                                'Reported Cum ${gradingSystem.cumulativeLabel}: ${state.reportedCumulativeCwa?.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(
                onPressed: selected == state.courses.length
                    ? notifier.deselectAll
                    : notifier.selectAll,
                child: Text(
                  selected == state.courses.length
                      ? 'Deselect all'
                      : 'Select all',
                  style: TextStyle(color: colorScheme.primary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Correct any grade or credit hours, then tap Import.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (state.skippedCourseCount > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          _ParseWarningCard(skippedCount: state.skippedCourseCount),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _showAddCourseSheet(
                context,
                notifier,
                gradingSystem,
              ),
              icon: const Icon(LucideIcons.plus, size: AppIconSizes.md),
              label: const Text('Add missing course'),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: state.courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs2),
            itemBuilder: (context, i) {
              final course = state.courses[i];
              final isSelected = state.selectedIndexes.contains(i);
              return _ReviewCourseCard(
                course: course,
                gradingSystem: gradingSystem,
                isSelected: isSelected,
                onToggle: () => notifier.toggleCourse(i),
                onCreditChanged: (v) => notifier.setCreditHours(i, v),
                onGradeChanged: (g) {
                  notifier.setGrade(i, g);
                  if (gradingSystem.usesLetterGrades) {
                    notifier.setMark(i, gradingSystem.scoreForGrade(g));
                  }
                },
                onMarkChanged: (m) => notifier.setMark(i, m),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selected == 0
                    ? null
                    : () => _confirmImport(context, notifier),
                icon: const Icon(LucideIcons.check),
                label: Text(
                  selected == 0
                      ? 'Select at least one course'
                      : 'Save to Academic History',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCourseSheet(
    BuildContext context,
    ResultSlipImportNotifier notifier,
    GradingSystem gradingSystem,
  ) async {
    final course = await showModalBottomSheet<PastCourseResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddResultCourseSheet(gradingSystem: gradingSystem),
    );
    if (course != null) {
      notifier.addManualCourse(course);
    }
  }

  Future<void> _confirmImport(
    BuildContext context,
    ResultSlipImportNotifier notifier,
  ) async {
    final duplicate = await notifier.findDuplicateSemester();
    if (duplicate != null) {
      if (!context.mounted) return;
      final shouldReplace = await showCampusConfirmDialog(
            context: context,
            title: 'Replace existing semester?',
            message:
                'You already have results for "${duplicate.semesterLabel}". Replacing it prevents this semester from being counted twice.',
            confirmLabel: 'Replace',
            cancelLabel: 'Cancel',
            destructive: true,
          ) ??
          false;
      if (!shouldReplace) return;
      await notifier.confirmImport(replaceExisting: true);
      return;
    }
    if (!context.mounted) return;
    final confirmed = await showCampusConfirmDialog(
          context: context,
          title: 'Save completed results?',
          message:
              'You are adding ${state.selectedIndexes.length} completed course result${state.selectedIndexes.length == 1 ? '' : 's'} under "${state.semesterLabel}". These will be included in your academic history and cumulative calculation.',
          confirmLabel: 'Save Past Results',
          cancelLabel: 'Review Again',
        ) ??
        false;
    if (confirmed) await notifier.confirmImport();
  }
}

class _ParseWarningCard extends StatelessWidget {
  final int skippedCount;

  const _ParseWarningCard({required this.skippedCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.triangleAlert,
            color: AppTheme.warning,
            size: AppIconSizes.lg,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '$skippedCount course row${skippedCount == 1 ? '' : 's'} could not be read cleanly. Compare this list with your slip and add any missing course before saving.',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCourseCard extends StatelessWidget {
  final PastCourseResult course;
  final GradingSystem gradingSystem;
  final bool isSelected;
  final VoidCallback onToggle;
  final ValueChanged<double> onCreditChanged;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<double?> onMarkChanged;

  const _ReviewCourseCard({
    required this.course,
    required this.gradingSystem,
    required this.isSelected,
    required this.onToggle,
    required this.onCreditChanged,
    required this.onGradeChanged,
    required this.onMarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? Theme.of(context).cardColor : colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      elevation: isSelected ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
              ),
              const SizedBox(width: AppSpacing.xxs2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseCode.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      course.courseName,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: AppSpacing.xs2),
                      Row(
                        children: [
                          Text(
                            gradingSystem.usesLetterGrades ? 'Points' : 'Mark',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs2),
                          if (gradingSystem.usesLetterGrades)
                            Text(
                              gradingSystem.formatScore(
                                course.mark ??
                                    scoreForGrade(
                                      course.grade,
                                      gradingSystem,
                                    ),
                                includeUnit: true,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            )
                          else
                            _MarkInput(
                              mark: course.mark,
                              onChanged: onMarkChanged,
                            ),
                          const Spacer(),
                          // Grade picker
                          Text(
                            'Grade',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          CompactGradeDropdown(
                            grade: course.grade,
                            gradingSystem: gradingSystem,
                            onChanged: onGradeChanged,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      Row(
                        children: [
                          // Credit hours stepper
                          Text(
                            'Credits',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _CreditStepper(
                            value: course.creditHours,
                            onChanged: onCreditChanged,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkInput extends StatefulWidget {
  final double? mark;
  final ValueChanged<double?> onChanged;

  const _MarkInput({required this.mark, required this.onChanged});

  @override
  State<_MarkInput> createState() => _MarkInputState();
}

class _MarkInputState extends State<_MarkInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.mark != null ? widget.mark!.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant _MarkInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mark != oldWidget.mark) {
      final newText =
          widget.mark != null ? widget.mark!.toStringAsFixed(0) : '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 50,
      height: 32,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: colorScheme.primary.withValues(alpha: 0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            borderSide: BorderSide.none,
          ),
          hintText: '-',
        ),
        onChanged: (val) {
          final number = double.tryParse(val);
          widget.onChanged(number);
        },
      ),
    );
  }
}

class _CreditStepper extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _CreditStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StepButton(
          icon: LucideIcons.minus,
          onTap: value > 1 ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${value.toInt()}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: colorScheme.primary,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: value < 12 ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.xxs),
        ),
        child: Icon(
          icon,
          size: AppIconSizes.md,
          color: onTap != null
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AddResultCourseSheet extends StatefulWidget {
  final GradingSystem gradingSystem;

  const _AddResultCourseSheet({required this.gradingSystem});

  @override
  State<_AddResultCourseSheet> createState() => _AddResultCourseSheetState();
}

class _AddResultCourseSheetState extends State<_AddResultCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  late final TextEditingController _markController;

  @override
  void initState() {
    super.initState();
    _markController = TextEditingController(
      text: widget.gradingSystem.usesLetterGrades
          ? widget.gradingSystem.formatScore(widget.gradingSystem.defaultTarget)
          : '',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _creditsController.dispose();
    _markController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add missing result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Course code',
                hintText: 'COE 454',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course name',
                hintText: 'Software Engineering',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _creditsController,
                    decoration: const InputDecoration(labelText: 'Credits'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateCredits,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: widget.gradingSystem.usesLetterGrades
                      ? GradeValueDropdown(
                          gradingSystem: widget.gradingSystem,
                          value: widget.gradingSystem.clampScore(
                            double.tryParse(_markController.text.trim()) ??
                                widget.gradingSystem.defaultTarget,
                          ),
                          label: 'Grade',
                          onChanged: (value) {
                            setState(() {
                              _markController.text =
                                  widget.gradingSystem.formatScore(value);
                            });
                          },
                        )
                      : TextFormField(
                          controller: _markController,
                          decoration: const InputDecoration(labelText: 'Mark'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateMark,
                        ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.gradingSystem.usesLetterGrades
                  ? 'The selected grade point will be used in the cumulative calculation.'
                  : 'Grade will be derived from the mark.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add result'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateCredits(String? value) {
    final credits = double.tryParse((value ?? '').trim());
    if (credits == null) return 'Required';
    if (credits < 1 || credits > 12) return 'Use 1-12';
    return null;
  }

  String? _validateMark(String? value) {
    final mark = double.tryParse((value ?? '').trim());
    if (mark == null) return 'Required';
    if (mark < widget.gradingSystem.minScore ||
        mark > widget.gradingSystem.maxScore) {
      return 'Use ${widget.gradingSystem.minScore.toStringAsFixed(0)}-${widget.gradingSystem.maxScore.toStringAsFixed(0)}';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final mark = double.parse(_markController.text.trim());
    Navigator.of(context).pop(
      PastCourseResult(
        courseCode: _codeController.text.trim().toUpperCase(),
        courseName: _nameController.text.trim(),
        creditHours: double.parse(_creditsController.text.trim()),
        grade: widget.gradingSystem.gradeForScore(mark),
        mark: mark,
      ),
    );
  }
}

// ─── Done ─────────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onFinish;

  const _DoneView({
    required this.count,
    required this.label,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.check,
                  color: Colors.white, size: AppIconSizes.status),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$label saved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$count course${count == 1 ? '' : 's'} added to your history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs2),
            Text(
              'Switch to Cumulative view on the CWA screen to see your true CWA.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.circleAlert,
              size: AppIconSizes.error, color: AppTheme.warning),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'We couldn\'t read this document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Try a clear, uncropped image showing course codes, official grades, and the semester heading. For PDFs, make sure the file is not password-protected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.xs2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
