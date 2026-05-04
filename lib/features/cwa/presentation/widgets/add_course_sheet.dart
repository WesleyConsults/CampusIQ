import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existing == null ? 'Add Course' : 'Edit Course',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                  labelText: 'Course code (e.g. COE 456)'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Course name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Credit hours',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('${_creditHours.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            Slider(
              value: _creditHours,
              min: 1,
              max: 6,
              divisions: 5,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _creditHours = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expected score',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                Text('${_expectedScore.toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            Slider(
              value: _expectedScore,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => _expectedScore = v),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.xs2)),
                ),
                child: Text(
                    widget.existing == null ? 'Add Course' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
