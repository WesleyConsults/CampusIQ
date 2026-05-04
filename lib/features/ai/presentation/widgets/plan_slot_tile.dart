import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';

class PlanSlotTile extends StatelessWidget {
  final StudyPlanSlotModel slot;

  const PlanSlotTile({super.key, required this.slot});

  int? _parseStartMinutes(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }

  String _timeRangeLabel() {
    final startMinutes = _parseStartMinutes(slot.startTime);
    if (startMinutes == null) return 'Time not set';

    final endMinutes = startMinutes + slot.durationMinutes;
    final h = endMinutes ~/ 60;
    final m = endMinutes % 60;
    final endTime =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    return '${slot.startTime} - $endTime';
  }

  @override
  Widget build(BuildContext context) {
    final courseName =
        slot.courseName.trim().isEmpty ? 'Planned session' : slot.courseName;
    final reason = slot.reason.trim().isEmpty ? 'Details not set' : slot.reason;
    final durationLabel = slot.durationMinutes > 0
        ? '${slot.durationMinutes} min'
        : 'Duration not set';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4, right: 10),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        courseName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      _timeRangeLabel(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Text(
                  '$durationLabel · $reason',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
