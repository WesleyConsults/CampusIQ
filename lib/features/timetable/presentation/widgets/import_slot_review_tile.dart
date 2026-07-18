import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final dayLabel = TimetableConstants.dayFullLabels[slot.dayIndex];
    final startLabel = slot.isValid
        ? TimetableConstants.minutesToLabel(slot.startMinutes)
        : (slot.rawStartTime.trim().isEmpty
            ? 'Invalid start'
            : slot.rawStartTime);
    final endLabel = slot.isValid
        ? TimetableConstants.minutesToLabel(slot.endMinutes)
        : (slot.rawEndTime.trim().isEmpty ? 'Invalid end' : slot.rawEndTime);

    final chipColor = switch (slot.slotType) {
      'Practical' => Colors.teal,
      'Tutorial' => Colors.orange,
      _ => colorScheme.primary,
    };

    Future<void> fixTime() async {
      final initialStart = slot.startMinutes > 0 ? slot.startMinutes : 8 * 60;
      final start = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: initialStart ~/ 60,
          minute: initialStart % 60,
        ),
      );
      if (start == null || !context.mounted) return;

      final initialEnd =
          slot.endMinutes > initialStart ? slot.endMinutes : initialStart + 60;
      final end = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: (initialEnd ~/ 60).clamp(0, 23),
          minute: initialEnd % 60,
        ),
      );
      if (end == null) return;

      ref.read(timetableImportNotifierProvider.notifier).updateSlotTimes(
            index: index,
            startMinutes: start.hour * 60 + start.minute,
            endMinutes: end.hour * 60 + end.minute,
          );
    }

    return InkWell(
      onTap: slot.isValid
          ? () => ref
              .read(timetableImportNotifierProvider.notifier)
              .toggleSlot(index)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: colorScheme.primary,
              onChanged: slot.isValid
                  ? (_) => ref
                      .read(timetableImportNotifierProvider.notifier)
                      .toggleSlot(index)
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.courseCode.isNotEmpty
                        ? '${slot.courseCode} — ${slot.courseName}'
                        : slot.courseName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxxs),
                  Text(
                    [
                      dayLabel,
                      '$startLabel – $endLabel',
                      if (slot.venue.isNotEmpty) slot.venue,
                      if (slot.lecturerName.isNotEmpty) slot.lecturerName,
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!slot.isValid) ...[
                    const SizedBox(height: AppSpacing.xxxs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            slot.validationError ?? 'Invalid timetable time',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: fixTime,
                          child: const Text('Fix time'),
                        ),
                      ],
                    ),
                  ] else if (slot.validationError != null) ...[
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      slot.validationError!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.xxs),
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
