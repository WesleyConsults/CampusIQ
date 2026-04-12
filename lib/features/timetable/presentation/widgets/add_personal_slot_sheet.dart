import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/personal_slot_category.dart';
import 'package:campusiq/features/timetable/domain/recurrence_type.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

class AddPersonalSlotSheet extends StatefulWidget {
  final int dayIndex;
  final String semesterKey;
  final PersonalSlotModel? existing;
  final int? prefillStartMinutes;
  final int? prefillEndMinutes;

  const AddPersonalSlotSheet({
    super.key,
    required this.dayIndex,
    required this.semesterKey,
    this.existing,
    this.prefillStartMinutes,
    this.prefillEndMinutes,
  });

  @override
  State<AddPersonalSlotSheet> createState() => _AddPersonalSlotSheetState();
}

class _AddPersonalSlotSheetState extends State<AddPersonalSlotSheet> {
  final _customLabelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late PersonalSlotCategory _category;
  late RecurrenceType _recurrence;
  late int _startMinutes;
  late int _endMinutes;
  late List<int> _weeklyDays;
  DateTime? _specificDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _category    = PersonalSlotCategory.fromString(e.categoryName);
      _recurrence  = RecurrenceType.fromString(e.recurrenceTypeName);
      _startMinutes = e.startMinutes;
      _endMinutes   = e.endMinutes;
      _weeklyDays   = List.from(e.weeklyDays);
      _customLabelController.text = e.customLabel;
      if (e.specificDate != null) _specificDate = DateTime.tryParse(e.specificDate!);
    } else {
      _category     = PersonalSlotCategory.study;
      _recurrence   = RecurrenceType.oneOff;
      _startMinutes = widget.prefillStartMinutes ?? TimetableConstants.gridStartMinutes + 120;
      _endMinutes   = widget.prefillEndMinutes   ?? _startMinutes + 60;
      _weeklyDays   = [widget.dayIndex];
      _specificDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    super.dispose();
  }

  String _minutesToTime(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final mins = isStart ? _startMinutes : _endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: mins ~/ 60, minute: mins % 60),
    );
    if (picked == null) return;
    final total = picked.hour * 60 + picked.minute;
    setState(() {
      if (isStart) {
        _startMinutes = total;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      } else {
        _endMinutes = total;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _specificDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_endMinutes <= _startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    if (_recurrence == RecurrenceType.weekly && _weeklyDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }

    final slot = widget.existing ?? PersonalSlotModel();
    slot.categoryName      = _category.name;
    slot.customLabel       = _customLabelController.text.trim();
    slot.startMinutes      = _startMinutes;
    slot.endMinutes        = _endMinutes;
    slot.recurrenceTypeName = _recurrence.name;
    slot.weeklyDays        = _recurrence == RecurrenceType.weekly ? _weeklyDays : [];
    slot.specificDate      = _recurrence == RecurrenceType.oneOff && _specificDate != null
        ? '${_specificDate!.year}-${_specificDate!.month.toString().padLeft(2,'0')}-${_specificDate!.day.toString().padLeft(2,'0')}'
        : null;
    slot.semesterKey = widget.semesterKey;

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
                widget.existing == null ? 'Add Personal Block' : 'Edit Personal Block',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Category chips
              const Text('Category', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PersonalSlotCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  final color = Color(cat.colorValue);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha:0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(
                        '${cat.emoji} ${cat.label}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? color : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Custom label (only shown for custom category)
              if (_category == PersonalSlotCategory.custom) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customLabelController,
                  decoration: const InputDecoration(labelText: 'Custom label'),
                  validator: (v) => (_category == PersonalSlotCategory.custom &&
                      (v == null || v.trim().isEmpty))
                      ? 'Enter a label'
                      : null,
                ),
              ],

              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(child: _TimeTile(label: 'Start', value: _minutesToTime(_startMinutes), onTap: () => _pickTime(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _TimeTile(label: 'End', value: _minutesToTime(_endMinutes), onTap: () => _pickTime(false))),
                ],
              ),
              const SizedBox(height: 16),

              // Recurrence
              const Text('Repeat', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              ...RecurrenceType.values.map((type) {
                final isSelected = _recurrence == type;
                return InkWell(
                  onTap: () => setState(() => _recurrence = type),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                              width: isSelected ? 5 : 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(type.label, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }),

              // One-off date picker
              if (_recurrence == RecurrenceType.oneOff) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          _specificDate == null
                              ? 'Pick date'
                              : '${_specificDate!.day}/${_specificDate!.month}/${_specificDate!.year}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Weekly day picker
              if (_recurrence == RecurrenceType.weekly) ...[
                const SizedBox(height: 12),
                const Text('Days', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final isSelected = _weeklyDays.contains(i);
                    return GestureDetector(
                      onTap: () => setState(() {
                        isSelected ? _weeklyDays.remove(i) : _weeklyDays.add(i);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],

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
                  child: Text(widget.existing == null ? 'Add Block' : 'Save Changes'),
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
