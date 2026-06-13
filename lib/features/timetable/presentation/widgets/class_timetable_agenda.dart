import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/presentation/providers/course_reminder_provider.dart';

class ClassTimetableAgenda extends ConsumerWidget {
  final List<TimetableSlotModel> classSlots;
  final void Function(TimetableSlotModel) onClassSlotTap;

  const ClassTimetableAgenda({
    super.key,
    required this.classSlots,
    required this.onClassSlotTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final reminders = ref.watch(courseRemindersProvider).valueOrNull ?? [];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: classSlots.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final slot = classSlots[index];
        final hasAlarm = reminders.any((r) =>
            r.courseCode.toUpperCase() == slot.courseCode.toUpperCase() &&
            r.isEnabled &&
            r.isAlarm);
        final accent = Color(slot.colorValue);
        final background = isDark
            ? Color.lerp(colorScheme.surface, accent, 0.15) ?? colorScheme.surface
            : Color.lerp(Colors.white, accent, 0.08) ?? Colors.white;
        final borderColor = accent.withValues(alpha: isDark ? 0.35 : 0.18);

        return InkWell(
          onTap: () => onClassSlotTap(slot),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Ink(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Time block
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.xs2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slot.startTimeLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? colorScheme.onSurface : accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slot.endTimeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                slot.courseCode,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (hasAlarm) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.alarm,
                                size: 14,
                                color: accent,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          slot.courseName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (slot.venue.isNotEmpty || slot.slotType.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (slot.venue.isNotEmpty) ...[
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  slot.venue,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ],
                              if (slot.slotType.isNotEmpty) ...[
                                Icon(
                                  Icons.class_outlined,
                                  size: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  slot.slotType,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
