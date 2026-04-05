import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/personal_slot_category.dart';
import 'package:campusiq/features/timetable/domain/recurrence_type.dart';

class PersonalSlotDetailSheet extends StatelessWidget {
  final PersonalSlotModel slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PersonalSlotDetailSheet({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = PersonalSlotCategory.fromString(slot.categoryName);
    final color = Color(category.colorValue);
    final recurrence = RecurrenceType.fromString(slot.recurrenceTypeName);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                slot.displayLabel,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  recurrence.label,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Row(icon: Icons.access_time, label: '${slot.startTimeLabel} – ${slot.endTimeLabel}'),
          if (recurrence == RecurrenceType.oneOff && slot.specificDate != null) ...[
            const SizedBox(height: 8),
            _Row(icon: Icons.calendar_today_outlined, label: slot.specificDate!),
          ],
          if (recurrence == RecurrenceType.weekly && slot.weeklyDays.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(
              icon: Icons.repeat,
              label: slot.weeklyDays
                  .map((d) => ['Mon','Tue','Wed','Thu','Fri','Sat'][d])
                  .join(', '),
            ),
          ],
          if (recurrence == RecurrenceType.daily) ...[
            const SizedBox(height: 8),
            const _Row(icon: Icons.repeat, label: 'Every day'),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { Navigator.pop(context); onDelete(); },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () { Navigator.pop(context); onEdit(); },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Row({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}
