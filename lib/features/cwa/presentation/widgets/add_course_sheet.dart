import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/widgets/grade_value_dropdown.dart';
import 'package:campusiq/shared/widgets/campus_modal_action_row.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';

class AddCourseSheet extends StatefulWidget {
  final String semesterKey;
  final CourseModel? existing;
  final GradingSystem gradingSystem;

  const AddCourseSheet({
    super.key,
    required this.semesterKey,
    this.existing,
    this.gradingSystem = GradingSystem.cwa,
  });

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _expectedScoreController = TextEditingController();
  double _creditHours = 3;
  late double _expectedScore;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _expectedScore =
        _normalizeExpectedScore(widget.gradingSystem.defaultTarget);
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _codeController.text = widget.existing!.code;
      _creditHours = widget.existing!.creditHours;
      _expectedScore = _normalizeExpectedScore(widget.existing!.expectedScore);
    }
    _syncExpectedScoreText();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _expectedScoreController.dispose();
    super.dispose();
  }

  void _setExpectedScore(double value, {bool syncText = true}) {
    final normalized = _normalizeExpectedScore(value);
    setState(() => _expectedScore = normalized);
    if (syncText) _syncExpectedScoreText();
  }

  double _normalizeExpectedScore(double value) {
    final clamped = widget.gradingSystem.clampScore(value);
    return double.parse(
      clamped.toStringAsFixed(widget.gradingSystem.displayDecimals),
    );
  }

  void _syncExpectedScoreText() {
    _expectedScoreController.text =
        _expectedScore.toStringAsFixed(widget.gradingSystem.displayDecimals);
  }

  void _handleExpectedScoreTextChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    setState(() => _expectedScore = _normalizeExpectedScore(parsed));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final typedScore = double.tryParse(_expectedScoreController.text.trim());
    if (typedScore != null) {
      _expectedScore = _normalizeExpectedScore(typedScore);
    }

    final course = widget.existing ?? CourseModel();
    course.name = _nameController.text.trim();
    course.code = _codeController.text.trim().toUpperCase();
    course.creditHours = _creditHours;
    course.expectedScore = _expectedScore;
    course.semesterKey = widget.semesterKey;
    final existingSystemId = widget.existing?.gradingSystemId ?? '';
    course.gradingSystemId = existingSystemId.isNotEmpty
        ? existingSystemId
        : widget.gradingSystem.id;

    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Form(
      key: _formKey,
      child: CampusModalSheet(
        title: isEditing ? 'Edit Course' : 'Add Course',
        subtitle: isEditing
            ? 'Update the course details and keep your projection current.'
            : 'Set up a course with its credit load and expected ${widget.gradingSystem.label}.',
        leading: const _ModalIcon(),
        scrollable: true,
        bottomBar: CampusModalActionRow(
          secondaryLabel: 'Cancel',
          onSecondaryPressed: () => Navigator.of(context).pop(),
          primaryLabel: isEditing ? 'Save Changes' : 'Add Course',
          onPrimaryPressed: _submit,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Course code',
                hintText: 'COE 456',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course name',
                hintText: 'Communication Systems',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            _MetricSliderCard(
              label: 'Credit hours',
              valueLabel: '${_creditHours.toInt()} units',
              value: _creditHours,
              min: 1,
              max: 12,
              divisions: 11,
              onChanged: (v) => setState(() => _creditHours = v),
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.gradingSystem.usesLetterGrades)
              GradeValueDropdown(
                gradingSystem: widget.gradingSystem,
                value: _expectedScore,
                onChanged: (v) => _setExpectedScore(v),
              )
            else if (isEditing)
              _EditableScoreSliderCard(
                label: widget.gradingSystem.scoreInputLabel,
                value: _expectedScore,
                controller: _expectedScoreController,
                gradingSystem: widget.gradingSystem,
                onSliderChanged: (v) => _setExpectedScore(v),
                onTextChanged: _handleExpectedScoreTextChanged,
              )
            else
              _MetricSliderCard(
                label: widget.gradingSystem.scoreInputLabel,
                valueLabel: widget.gradingSystem.formatScore(
                  _expectedScore,
                  includeUnit: true,
                ),
                value: _expectedScore,
                min: widget.gradingSystem.minScore,
                max: widget.gradingSystem.maxScore,
                divisions: widget.gradingSystem.sliderDivisions,
                onChanged: (v) => _setExpectedScore(v),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditableScoreSliderCard extends StatelessWidget {
  final String label;
  final double value;
  final TextEditingController controller;
  final GradingSystem gradingSystem;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<String> onTextChanged;

  const _EditableScoreSliderCard({
    required this.label,
    required this.value,
    required this.controller,
    required this.gradingSystem,
    required this.onSliderChanged,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxs2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.button,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 104,
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) {
                        final text = newValue.text;
                        if (text.isEmpty ||
                            RegExp(r'^\d*\.?\d{0,2}$').hasMatch(text)) {
                          return newValue;
                        }
                        return oldValue;
                      },
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: gradingSystem.scoreUnit,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                  onChanged: onTextChanged,
                  validator: (rawValue) {
                    final parsed = double.tryParse(rawValue?.trim() ?? '');
                    if (parsed == null) return 'Enter score';
                    if (parsed < gradingSystem.minScore ||
                        parsed > gradingSystem.maxScore) {
                      return '${gradingSystem.minScore.toStringAsFixed(0)}-${gradingSystem.maxScore.toStringAsFixed(0)}';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 3),
            child: Slider(
              value: value,
              min: gradingSystem.minScore,
              max: gradingSystem.maxScore,
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.outlineVariant,
              onChanged: onSliderChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalIcon extends StatelessWidget {
  const _ModalIcon();

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
        LucideIcons.bookOpen,
        color: AppTheme.primary,
        size: AppIconSizes.xl,
      ),
    );
  }
}

class _MetricSliderCard extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _MetricSliderCard({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxs2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.button,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 3),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.outlineVariant,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
