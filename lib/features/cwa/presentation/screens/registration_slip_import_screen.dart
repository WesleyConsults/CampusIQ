import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/providers/connectivity_provider.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/domain/registration_course_import.dart';
import 'package:campusiq/features/cwa/domain/academic_term.dart';
import 'package:campusiq/features/cwa/domain/academic_document_kind.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/registration_slip_import_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/grade_value_dropdown.dart';
import 'package:campusiq/features/cwa/presentation/widgets/academic_import_destination_banner.dart';
import 'package:campusiq/features/cwa/presentation/widgets/wrong_academic_document_view.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
import 'package:campusiq/shared/widgets/import_option_grid.dart';

class RegistrationSlipImportScreen extends ConsumerStatefulWidget {
  final String? initialSource;

  const RegistrationSlipImportScreen({super.key, this.initialSource});

  @override
  ConsumerState<RegistrationSlipImportScreen> createState() =>
      _RegistrationSlipImportScreenState();
}

class _RegistrationSlipImportScreenState
    extends ConsumerState<RegistrationSlipImportScreen> {
  bool _didTriggerInitialSource = false;

  @override
  void dispose() {
    final step = ref.read(registrationSlipImportNotifierProvider).step;
    if (step != SlipImportStep.idle && step != SlipImportStep.done) {
      AnalyticsService.instance.logImportAbandoned(
        importType: 'registration',
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
      final notifier =
          ref.read(registrationSlipImportNotifierProvider.notifier);
      switch (source) {
        case 'camera':
          _runIfOnline(notifier.pickFromCamera);
          return;
        case 'gallery':
          _runIfOnline(notifier.pickFromGallery);
          return;
        case 'pdf':
          _runIfOnline(notifier.pickFromGalleryOrFile);
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationSlipImportNotifierProvider);
    final notifier = ref.read(registrationSlipImportNotifierProvider.notifier);
    final gradingSystem = ref.watch(gradingSystemProvider);
    final activeSemesterLabel = formatAcademicTermLabel(
      ref.watch(activeSemesterProvider),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Current Courses'),
        leading: BackButton(
          onPressed: () {
            notifier.reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: state.documentKind == AcademicDocumentKind.resultSlip
          ? WrongAcademicDocumentView(
              detectedLabel: 'a completed result slip',
              expectedLabel: 'Current Semester Courses',
              actionLabel: 'Open Past Results',
              onSwitch: () {
                notifier.reset();
                context.pushReplacement('/cwa/import/results');
              },
              onTryAgain: notifier.reset,
            )
          : switch (state.step) {
              SlipImportStep.idle => _IdleView(
                  activeSemesterLabel: activeSemesterLabel,
                  onCamera: () => _runIfOnline(notifier.pickFromCamera),
                  onGallery: () => _runIfOnline(notifier.pickFromGallery),
                  onPdf: () => _runIfOnline(notifier.pickFromGalleryOrFile),
                  onManual: () {
                    notifier.reset();
                    context.push('/cwa/manual-entry?mode=semester');
                  },
                  onPastResults: () {
                    notifier.reset();
                    context.pushReplacement('/cwa/import/results');
                  },
                ),
              SlipImportStep.picking || SlipImportStep.parsing => _LoadingView(
                  state.step == SlipImportStep.parsing
                      ? 'Uploading and reading current courses…'
                      : 'Opening your document…',
                ),
              SlipImportStep.reviewing => _ReviewView(
                  state: state,
                  notifier: notifier,
                  gradingSystem: gradingSystem,
                  activeSemesterLabel: activeSemesterLabel,
                ),
              SlipImportStep.saving =>
                const _LoadingView('Saving to Current Semester…'),
              SlipImportStep.done => _DoneView(
                  count:
                      state.selectedIndexes.length - state.duplicateCourseCount,
                  duplicateCount: state.duplicateCourseCount,
                  onFinish: () {
                    notifier.reset();
                    Navigator.of(context).pop();
                  },
                ),
              SlipImportStep.error => _ErrorView(
                  message: state.errorMessage ?? 'Unknown error.',
                  onRetry: notifier.reset,
                ),
            },
    );
  }
}

// ─── Idle ─────────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final String activeSemesterLabel;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onPdf;
  final VoidCallback onManual;
  final VoidCallback onPastResults;

  const _IdleView({
    required this.activeSemesterLabel,
    required this.onCamera,
    required this.onGallery,
    required this.onPdf,
    required this.onManual,
    required this.onPastResults,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AcademicImportDestinationBanner(
          destination: 'Current Semester — $activeSemesterLabel',
          description:
              'Upload only courses you are studying now. Do not upload official results from a completed semester here.',
          alternativeLabel: 'I have completed results instead',
          onAlternative: onPastResults,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review ───────────────────────────────────────────────────────────────────

class _ReviewView extends StatelessWidget {
  final SlipImportState state;
  final RegistrationSlipImportNotifier notifier;
  final GradingSystem gradingSystem;
  final String activeSemesterLabel;

  const _ReviewView({
    required this.state,
    required this.notifier,
    required this.gradingSystem,
    required this.activeSemesterLabel,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedIndexes.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: AcademicImportDestinationBanner(
            destination: 'Current Semester — $activeSemesterLabel',
            description:
                'These should be in-progress courses, not official grades from a completed semester.',
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${state.courses.length} courses found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
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
            'Adjust expected scores and credit hours if needed, then tap Import.',
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

        // Course list
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
                onExpectedScoreChanged: (v) => notifier.setExpectedScore(i, v),
              );
            },
          ),
        ),

        // Confirm button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selected == 0
                    ? null
                    : () => _confirmImport(context, selected),
                icon: const Icon(LucideIcons.check),
                label: Text(
                  selected == 0
                      ? 'Select at least one course'
                      : 'Save to Current Semester',
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

  Future<void> _confirmImport(BuildContext context, int selected) async {
    final confirmed = await showCampusConfirmDialog(
          context: context,
          title: 'Save current courses?',
          message:
              'You are adding $selected course${selected == 1 ? '' : 's'} to $activeSemesterLabel. These courses should still be in progress and should not be official past results.',
          confirmLabel: 'Save Current Courses',
          cancelLabel: 'Review Again',
        ) ??
        false;
    if (confirmed) await notifier.confirmImport();
  }

  Future<void> _showAddCourseSheet(
    BuildContext context,
    RegistrationSlipImportNotifier notifier,
    GradingSystem gradingSystem,
  ) async {
    final course = await showModalBottomSheet<RegistrationCourseImport>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddRegistrationCourseSheet(
        gradingSystem: gradingSystem,
      ),
    );
    if (course != null) {
      notifier.addManualCourse(course);
    }
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
  final RegistrationCourseImport course;
  final GradingSystem gradingSystem;
  final bool isSelected;
  final VoidCallback onToggle;
  final ValueChanged<double> onCreditChanged;
  final ValueChanged<double> onExpectedScoreChanged;

  const _ReviewCourseCard({
    required this.course,
    required this.gradingSystem,
    required this.isSelected,
    required this.onToggle,
    required this.onCreditChanged,
    required this.onExpectedScoreChanged,
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
                            'Credit hours',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          _CreditStepper(
                            value: course.creditHours,
                            onChanged: onCreditChanged,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      Row(
                        children: [
                          Text(
                            gradingSystem.scoreInputLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            gradingSystem.formatScore(
                              course.expectedScore,
                              includeUnit: true,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (gradingSystem.usesLetterGrades)
                        GradeValueDropdown(
                          gradingSystem: gradingSystem,
                          value: gradingSystem.clampScore(course.expectedScore),
                          onChanged: onExpectedScoreChanged,
                        )
                      else
                        Slider(
                          value: gradingSystem.clampScore(course.expectedScore),
                          min: gradingSystem.minScore,
                          max: gradingSystem.maxScore,
                          divisions: gradingSystem.sliderDivisions,
                          label: gradingSystem.formatScore(
                            course.expectedScore,
                            includeUnit: true,
                          ),
                          onChanged: onExpectedScoreChanged,
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
          icon: LucideIcons.plus,
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

class _AddRegistrationCourseSheet extends StatefulWidget {
  final GradingSystem gradingSystem;

  const _AddRegistrationCourseSheet({required this.gradingSystem});

  @override
  State<_AddRegistrationCourseSheet> createState() =>
      _AddRegistrationCourseSheetState();
}

class _AddRegistrationCourseSheetState
    extends State<_AddRegistrationCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  late final TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text:
          widget.gradingSystem.formatScore(widget.gradingSystem.defaultTarget),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _creditsController.dispose();
    _scoreController.dispose();
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
              'Add missing course',
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
                            double.tryParse(_scoreController.text.trim()) ??
                                widget.gradingSystem.defaultTarget,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _scoreController.text =
                                  widget.gradingSystem.formatScore(value);
                            });
                          },
                        )
                      : TextFormField(
                          controller: _scoreController,
                          decoration: InputDecoration(
                            labelText: widget.gradingSystem.scoreInputLabel,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validateScore,
                        ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add course'),
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

  String? _validateScore(String? value) {
    final score = double.tryParse((value ?? '').trim());
    if (score == null) return 'Required';
    if (score < widget.gradingSystem.minScore ||
        score > widget.gradingSystem.maxScore) {
      return 'Use ${widget.gradingSystem.minScore.toStringAsFixed(0)}-${widget.gradingSystem.maxScore.toStringAsFixed(0)}';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      RegistrationCourseImport(
        courseCode: _codeController.text.trim().toUpperCase(),
        courseName: _nameController.text.trim(),
        creditHours: double.parse(_creditsController.text.trim()),
        expectedScore: widget.gradingSystem.clampScore(
          double.parse(_scoreController.text.trim()),
        ),
      ),
    );
  }
}

// ─── Done ─────────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final int count;
  final int duplicateCount;
  final VoidCallback onFinish;

  const _DoneView({
    required this.count,
    required this.duplicateCount,
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
              '$count current course${count == 1 ? '' : 's'} added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            if (duplicateCount > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$duplicateCount already existed and w'
                '${duplicateCount == 1 ? 'as' : 'ere'} skipped.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your semester projection now uses these courses. You can edit expected scores from Current Semester.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.circleAlert,
              size: 56, color: AppTheme.warning),
          const SizedBox(height: AppSpacing.md),
          Text(
            'We couldn\'t read this document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try a clear, uncropped image with readable course codes. For PDFs, make sure the file opens normally and is not password-protected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
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
