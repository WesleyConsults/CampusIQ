import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

class AddSlotSheet extends StatefulWidget {
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
  State<AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<AddSlotSheet> {
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
      _startMinutes = widget.prefillStartMinutes ?? TimetableConstants.gridStartMinutes + 120; // 8AM default
      _endMinutes = widget.prefillEndMinutes ?? _startMinutes + 120; // 2hr default
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

  String _minutesToTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = TimeOfDay(
      hour: (isStart ? _startMinutes : _endMinutes) ~/ 60,
      minute: (isStart ? _startMinutes : _endMinutes) % 60,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final totalMinutes = picked.hour * 60 + picked.minute;
    setState(() {
      if (isStart) {
        _startMinutes = totalMinutes;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      } else {
        _endMinutes = totalMinutes;
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
        left: 20, right: 20, top: 20,
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Day selector
              DropdownButtonFormField<int>(
                key: ValueKey(_dayIndex),
                initialValue: _dayIndex,
                decoration: const InputDecoration(labelText: 'Day'),
                items: List.generate(
                  TimetableConstants.dayFullLabels.length,
                  (i) => DropdownMenuItem(value: i, child: Text(TimetableConstants.dayFullLabels[i])),
                ),
                onChanged: (v) => setState(() => _dayIndex = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Course code (e.g. COE 456)'),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Course name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue (e.g. Hall 3)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Start time',
                      value: _minutesToTime(_startMinutes),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'End time',
                      value: _minutesToTime(_endMinutes),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(widget.existing == null ? 'Add Class' : 'Save Changes'),
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

  const _TimeTile({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
