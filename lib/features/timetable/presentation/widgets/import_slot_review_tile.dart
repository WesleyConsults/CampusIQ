import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_import_provider.dart';

class ImportSlotReviewTile extends ConsumerWidget {
  final int index;
  final TimetableSlotImport slot;
  final bool isSelected;

  const ImportSlotReviewTile({
    super.key,
    required this.index,
    required this.slot,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayLabel = TimetableConstants.dayFullLabels[slot.dayIndex];
    final startLabel = TimetableConstants.minutesToLabel(slot.startMinutes);
    final endLabel = TimetableConstants.minutesToLabel(slot.endMinutes);

    final chipColor = switch (slot.slotType) {
      'Practical' => Colors.teal,
      'Tutorial' => Colors.orange,
      _ => AppTheme.primary,
    };

    return InkWell(
      onTap: () =>
          ref.read(timetableImportNotifierProvider.notifier).toggleSlot(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: AppTheme.primary,
              onChanged: (_) => ref
                  .read(timetableImportNotifierProvider.notifier)
                  .toggleSlot(index),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.courseCode.isNotEmpty
                        ? '${slot.courseCode} — ${slot.courseName}'
                        : slot.courseName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      dayLabel,
                      '$startLabel – $endLabel',
                      if (slot.venue.isNotEmpty) slot.venue,
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                slot.slotType,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: chipColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
