import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/shared/widgets/campus_modal_action_row.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';

class AddCourseSheet extends StatefulWidget {
  final String semesterKey;
  final CourseModel? existing;

  const AddCourseSheet({super.key, required this.semesterKey, this.existing});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  double _creditHours = 3;
  double _expectedScore = 70;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameController.text = widget.existing!.name;
      _codeController.text = widget.existing!.code;
      _creditHours = widget.existing!.creditHours;
      _expectedScore = widget.existing!.expectedScore;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final course = widget.existing ?? CourseModel();
    course.name = _nameController.text.trim();
    course.code = _codeController.text.trim().toUpperCase();
    course.creditHours = _creditHours;
    course.expectedScore = _expectedScore;
    course.semesterKey = widget.semesterKey;

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
            : 'Set up a course with its credit load and expected score.',
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
              helper: 'Adjust this to match the weight used in your semester.',
              value: _creditHours,
              min: 1,
              max: 6,
              divisions: 5,
              onChanged: (v) => setState(() => _creditHours = v),
            ),
            const SizedBox(height: AppSpacing.md),
            _MetricSliderCard(
              label: 'Expected score',
              valueLabel: '${_expectedScore.toInt()}%',
              helper: 'CampusIQ uses this to update your live CWA forecast.',
              value: _expectedScore,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (v) => setState(() => _expectedScore = v),
            ),
          ],
        ),
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
  final String helper;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _MetricSliderCard({
    required this.label,
    required this.valueLabel,
    required this.helper,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      helper,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primary,
                    ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.primary,
            inactiveColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
