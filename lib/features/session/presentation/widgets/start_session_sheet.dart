import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/course_picker_sheet.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum SessionFocusMode { quick, deep, open }

class StartSessionSetup {
  final PickedCourse course;
  final String? objective;
  final SessionFocusMode mode;

  const StartSessionSetup({
    required this.course,
    required this.objective,
    required this.mode,
  });
}

/// A single purposeful setup step: course, optional intention, and focus mode.
class StartSessionSheet extends ConsumerStatefulWidget {
  final PickedCourse? initialCourse;
  final SessionFocusMode initialMode;

  const StartSessionSheet({
    super.key,
    this.initialCourse,
    this.initialMode = SessionFocusMode.quick,
  });

  @override
  ConsumerState<StartSessionSheet> createState() => _StartSessionSheetState();
}

class _StartSessionSheetState extends ConsumerState<StartSessionSheet> {
  final _objectiveController = TextEditingController();
  final _customCodeController = TextEditingController();
  final _customNameController = TextEditingController();
  PickedCourse? _selectedCourse;
  late SessionFocusMode _mode;
  bool _useCustomCourse = false;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.initialCourse;
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _objectiveController.dispose();
    _customCodeController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cwaCourses = ref.watch(coursesProvider).valueOrNull ?? [];
    final todaySlots = ref.watch(activeDaySlotsProvider);
    final available = <PickedCourse>[];
    final seen = <String>{};

    void addCourse(PickedCourse course) {
      if (seen.add(course.courseCode.toUpperCase())) available.add(course);
    }

    for (final slot in todaySlots) {
      addCourse(PickedCourse(
        courseCode: slot.courseCode,
        courseName: slot.courseName,
        source: 'timetable',
      ));
    }
    for (final course in cwaCourses) {
      addCourse(PickedCourse(
        courseCode: course.code,
        courseName: course.name,
        source: 'cwa',
      ));
    }
    addCourse(const PickedCourse(
      courseCode: 'GENERAL',
      courseName: 'General study',
      source: 'custom',
    ));

    if (_selectedCourse != null &&
        !available.any(
          (course) => course.courseCode == _selectedCourse!.courseCode,
        )) {
      available.insert(0, _selectedCourse!);
    }

    return CampusModalSheet(
      title: 'Start a focus session',
      subtitle: 'Choose what you will work on, then begin.',
      maxHeightFactor: 0.9,
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Close',
        icon: const Icon(LucideIcons.x),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Course', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue:
                  _useCustomCourse ? '__custom__' : _selectedCourse?.courseCode,
              isExpanded: true,
              hint: const Text('Select a course'),
              items: [
                ...available.map(
                  (course) => DropdownMenuItem(
                    value: course.courseCode,
                    child: Text(
                      '${course.courseCode} · ${course.courseName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const DropdownMenuItem(
                  value: '__custom__',
                  child: Text('Other course…'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _useCustomCourse = value == '__custom__';
                  if (!_useCustomCourse) {
                    _selectedCourse = available.firstWhere(
                      (course) => course.courseCode == value,
                    );
                  }
                });
              },
            ),
            if (_useCustomCourse) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _customCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Course code'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _customNameController,
                decoration: const InputDecoration(labelText: 'Course name'),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'What will you accomplish? (optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _objectiveController,
              maxLength: 100,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'e.g. Complete questions 1–10',
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Focus mode', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<SessionFocusMode>(
              segments: const [
                ButtonSegment(
                  value: SessionFocusMode.quick,
                  label: Text('Quick 25'),
                  icon: Icon(LucideIcons.zap),
                ),
                ButtonSegment(
                  value: SessionFocusMode.deep,
                  label: Text('Deep 50'),
                  icon: Icon(LucideIcons.brain),
                ),
                ButtonSegment(
                  value: SessionFocusMode.open,
                  label: Text('Open'),
                  icon: Icon(LucideIcons.infinity),
                ),
              ],
              selected: {_mode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() => _mode = selection.first);
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              switch (_mode) {
                SessionFocusMode.quick => '25 minutes of focused study',
                SessionFocusMode.deep => '50 minutes of deep focus',
                SessionFocusMode.open => 'A count-up timer with no fixed end',
              },
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(LucideIcons.play),
              label: const Text('Start session'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    PickedCourse? course = _selectedCourse;
    if (_useCustomCourse) {
      final code = _customCodeController.text.trim();
      final name = _customNameController.text.trim();
      if (code.isEmpty || name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a course code and name.')),
        );
        return;
      }
      course = PickedCourse(
        courseCode: code.toUpperCase(),
        courseName: name,
        source: 'custom',
      );
    }
    if (course == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a course to continue.')),
      );
      return;
    }

    final objective = _objectiveController.text.trim();
    Navigator.of(context).pop(
      StartSessionSetup(
        course: course,
        objective: objective.isEmpty ? null : objective,
        mode: _mode,
      ),
    );
  }
}
