import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/domain/past_course_result.dart';
import 'package:campusiq/features/cwa/presentation/providers/result_slip_import_provider.dart';

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
          notifier.pickFromCamera();
          return;
        case 'gallery':
          notifier.pickFromGallery();
          return;
        case 'pdf':
          notifier.pickFromFile();
          return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resultSlipImportNotifierProvider);
    final notifier = ref.read(resultSlipImportNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Import Result Slip'),
        leading: BackButton(
          onPressed: () {
            notifier.reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: switch (state.step) {
        ResultImportStep.idle => _IdleView(notifier: notifier),
        ResultImportStep.picking || ResultImportStep.parsing => _LoadingView(
            state.step == ResultImportStep.parsing
                ? 'AI is reading your result slip…'
                : 'Opening file…',
          ),
        ResultImportStep.labelling => _LabelView(notifier: notifier),
        ResultImportStep.reviewing =>
          _ReviewView(state: state, notifier: notifier),
        ResultImportStep.saving => const _LoadingView('Saving results…'),
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
  final ResultSlipImportNotifier notifier;
  const _IdleView({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Import past results',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Upload a result slip and the AI will extract your grades. '
            'These will be used to calculate your true cumulative CWA.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _OptionTile(
            icon: LucideIcons.camera,
            label: 'Take a photo',
            subtitle: 'Capture your result slip with the camera',
            onTap: notifier.pickFromCamera,
          ),
          const SizedBox(height: AppSpacing.sm),
          _OptionTile(
            icon: LucideIcons.image,
            label: 'Upload image from gallery',
            subtitle: 'Pick a JPG or PNG from your photos',
            onTap: notifier.pickFromGallery,
          ),
          const SizedBox(height: AppSpacing.sm),
          _OptionTile(
            icon: LucideIcons.fileText,
            label: 'Choose a PDF',
            subtitle: 'Upload a PDF result slip',
            onTap: notifier.pickFromFile,
          ),
          const Spacer(),
          const Center(
            child: Text(
              'Grades are read from the slip.\nYou can correct them before saving.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.sm2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, color: AppTheme.primary, size: AppIconSizes.xxxl),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        )),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        )),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight,
                  color: AppTheme.textSecondary, size: AppIconSizes.xl),
            ],
          ),
        ),
      ),
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
  const _LabelView({required this.notifier});

  @override
  State<_LabelView> createState() => _LabelViewState();
}

class _LabelViewState extends State<_LabelView> {
  final _controller = TextEditingController();

  static const _suggestions = [
    'Year 1 Sem 1',
    'Year 1 Sem 2',
    'Year 2 Sem 1',
    'Year 2 Sem 2',
    'Year 3 Sem 1',
    'Year 3 Sem 2',
    'Year 4 Sem 1',
    'Year 4 Sem 2',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            'Give this result slip a label so you can identify it later.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Year 1 Sem 1',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onSubmitted: (_) => _onContinue(),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Quick-pick chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((s) {
              return ActionChip(
                label: Text(s,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textPrimary)),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade200),
                onPressed: () {
                  _controller.text = s;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: s.length),
                  );
                },
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, value, __) => ElevatedButton(
                onPressed: value.text.trim().isEmpty ? null : _onContinue,
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
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _onContinue() {
    final label = _controller.text.trim();
    if (label.isEmpty) return;
    widget.notifier.confirmLabel(label);
  }
}

// ─── Review ───────────────────────────────────────────────────────────────────

class _ReviewView extends StatelessWidget {
  final ResultImportState state;
  final ResultSlipImportNotifier notifier;

  const _ReviewView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedIndexes.length;

    return Column(
      children: [
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      '${state.courses.length} courses found',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary),
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
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadii.xxs),
                              ),
                              child: Text(
                                'Reported Sem CWA: ${state.reportedSemesterCwa?.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary),
                              ),
                            ),
                          if (state.reportedCumulativeCwa != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadii.xxs),
                              ),
                              child: Text(
                                'Reported Cum CWA: ${state.reportedCumulativeCwa?.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary),
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
                  style: const TextStyle(color: AppTheme.primary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Correct any grade or credit hours, then tap Import.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
                isSelected: isSelected,
                onToggle: () => notifier.toggleCourse(i),
                onCreditChanged: (v) => notifier.setCreditHours(i, v),
                onGradeChanged: (g) => notifier.setGrade(i, g),
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
                onPressed: selected == 0 ? null : notifier.confirmImport,
                icon: const Icon(LucideIcons.check),
                label: Text(
                  selected == 0
                      ? 'Select at least one course'
                      : 'Import $selected course${selected == 1 ? '' : 's'}',
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
}

class _ReviewCourseCard extends StatelessWidget {
  final PastCourseResult course;
  final bool isSelected;
  final VoidCallback onToggle;
  final ValueChanged<double> onCreditChanged;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<double?> onMarkChanged;

  const _ReviewCourseCard({
    required this.course,
    required this.isSelected,
    required this.onToggle,
    required this.onCreditChanged,
    required this.onGradeChanged,
    required this.onMarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white : AppTheme.surface,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      course.courseName,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textPrimary),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: AppSpacing.xs2),
                      Row(
                        children: [
                          // Mark input
                          const Text(
                            'Mark',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(width: AppSpacing.xxs2),
                          _MarkInput(
                            mark: course.mark,
                            onChanged: onMarkChanged,
                          ),
                          const Spacer(),
                          // Grade picker
                          const Text(
                            'Grade',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _GradeDropdown(
                            grade: course.grade,
                            onChanged: onGradeChanged,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      Row(
                        children: [
                          // Credit hours stepper
                          const Text(
                            'Credits',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
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

class _GradeDropdown extends StatelessWidget {
  final String grade;
  final ValueChanged<String> onChanged;

  static const _grades = ['A', 'B', 'C', 'D', 'F'];
  static const _gradeColors = {
    'A': Color(0xFF2E7D32),
    'B': Color(0xFF1565C0),
    'C': Color(0xFFF57F17),
    'D': Color(0xFFE65100),
    'F': Color(0xFFC62828),
  };

  const _GradeDropdown({required this.grade, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = _gradeColors[grade.toUpperCase()] ?? AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              _grades.contains(grade.toUpperCase()) ? grade.toUpperCase() : 'F',
          isDense: true,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
          dropdownColor: Colors.white,
          items: _grades
              .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(
                      g,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _gradeColors[g] ?? AppTheme.textSecondary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
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
    return SizedBox(
      width: 50,
      height: 32,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppTheme.primary.withValues(alpha: 0.1),
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
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppTheme.primary,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: value < 6 ? () => onChanged(value + 1) : null,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppRadii.xxs),
        ),
        child: Icon(
          icon,
          size: AppIconSizes.md,
          color: onTap != null ? AppTheme.primary : AppTheme.textSecondary,
        ),
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
              child: const Icon(LucideIcons.check, color: Colors.white, size: AppIconSizes.status),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$label saved',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$count course${count == 1 ? '' : 's'} added to your history.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxs2),
            const Text(
              'Switch to Cumulative view on the CWA screen to see your true CWA.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
          const Icon(LucideIcons.circleAlert, size: AppIconSizes.error, color: AppTheme.warning),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Something went wrong',
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
