import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

class AddSlotSheet extends ConsumerStatefulWidget {
  final int dayIndex;
  final String semesterKey;
  final int colorValue;
  final TimetableSlotModel? existing;

  /// If opened from a free block, pre-fill these times
  final int? prefillStartMinutes;
  final int? prefillEndMinutes;

  const AddSlotSheet({
    super.key,
    required this.dayIndex,
    required this.semesterKey,
    required this.colorValue,
    this.existing,
    this.prefillStartMinutes,
    this.prefillEndMinutes,
  });

  @override
  ConsumerState<AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends ConsumerState<AddSlotSheet> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late int _startMinutes;
  late int _endMinutes;
  late String _slotType;
  late int _dayIndex;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _codeController.text = existing.courseCode;
      _nameController.text = existing.courseName;
      _venueController.text = existing.venue;
      _startMinutes = existing.startMinutes;
      _endMinutes = existing.endMinutes;
      _slotType = existing.slotType;
      _dayIndex = existing.dayIndex;
    } else {
      _startMinutes = widget.prefillStartMinutes ??
          TimetableConstants.gridStartMinutes + 120; // 8AM default
      _endMinutes =
          widget.prefillEndMinutes ?? _startMinutes + 120; // 2hr default
      _slotType = TimetableConstants.slotTypes.first;
      _dayIndex = widget.dayIndex;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final currentMinutes = isStart ? _startMinutes : _endMinutes;
    final initial =
        TimeOfDay(hour: currentMinutes ~/ 60, minute: currentMinutes % 60);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    int total = picked.hour * 60 + picked.minute;
    // Auto-promote sub-grid times (before 6 AM) to PM only when the picker
    // opened in AM mode. If the picker opened in PM the user explicitly
    // switched to AM — honour that choice.
    final openedInAm = currentMinutes < 12 * 60;
    if (total < TimetableConstants.gridStartMinutes && openedInAm) {
      total += 12 * 60;
    }
    setState(() {
      if (isStart) {
        _startMinutes = total;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      } else {
        _endMinutes = total;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_endMinutes <= _startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final slot = widget.existing ?? TimetableSlotModel();
    slot.courseCode = _codeController.text.trim().toUpperCase();
    slot.courseName = _nameController.text.trim();
    slot.venue = _venueController.text.trim();
    slot.startMinutes = _startMinutes;
    slot.endMinutes = _endMinutes;
    slot.slotType = _slotType;
    slot.dayIndex = _dayIndex;
    slot.semesterKey = widget.semesterKey;
    slot.colorValue = widget.colorValue;

    Navigator.of(context).pop(slot);
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Add Class' : 'Edit Class',
                style:
                    Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Fast selection from CWA courses
              ref.watch(coursesProvider).when(
                    data: (courses) {
                      if (courses.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select from My Courses:',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: courses.map((course) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ActionChip(
                                    label: Text(course.code),
                                    backgroundColor:
                                        AppTheme.primary.withValues(alpha: 0.1),
                                    side: BorderSide.none,
                                    onPressed: () {
                                      setState(() {
                                        _codeController.text = course.code;
                                        _nameController.text = course.name;
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

              // Day selector
              DropdownButtonFormField<int>(
                key: ValueKey(_dayIndex),
                initialValue: _dayIndex,
                decoration: const InputDecoration(labelText: 'Day'),
                items: List.generate(
                  TimetableConstants.dayFullLabels.length,
                  (i) => DropdownMenuItem(
                      value: i,
                      child: Text(TimetableConstants.dayFullLabels[i])),
                ),
                onChanged: (v) => setState(() => _dayIndex = v!),
              ),
              const SizedBox(height: AppSpacing.sm),

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
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _venueController,
                decoration:
                    const InputDecoration(labelText: 'Venue (e.g. Hall 3)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Start time',
                      value: TimetableConstants.minutesToLabel(_startMinutes),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TimeTile(
                      label: 'End time',
                      value: TimetableConstants.minutesToLabel(_endMinutes),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Slot type
              DropdownButtonFormField<String>(
                key: ValueKey(_slotType),
                initialValue: _slotType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TimetableConstants.slotTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _slotType = v!),
              ),
              const SizedBox(height: AppSpacing.lg),

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
                      widget.existing == null ? 'Add Class' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeTile(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xs2),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: AppSpacing.xxs),
            Text(value,
                style:
                    Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
