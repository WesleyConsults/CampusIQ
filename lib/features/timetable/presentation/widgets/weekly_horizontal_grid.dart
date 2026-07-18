import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/providers/course_reminder_provider.dart';

class WeeklyHorizontalGrid extends ConsumerWidget {
  final List<TimetableSlotModel> allSlots;
  final void Function(TimetableSlotModel) onClassSlotTap;

  const WeeklyHorizontalGrid({
    super.key,
    required this.allSlots,
    required this.onClassSlotTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(courseRemindersProvider).valueOrNull ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimeLabels(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  List.generate(TimetableConstants.dayLabels.length, (dayIdx) {
                final daySlots =
                    allSlots.where((s) => s.dayIndex == dayIdx).toList();
                return _DayColumn(
                  dayIndex: dayIdx,
                  slots: daySlots,
                  reminders: reminders,
                  onClassSlotTap: onClassSlotTap,
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  final int dayIndex;
  final List<TimetableSlotModel> slots;
  final List<dynamic> reminders;
  final void Function(TimetableSlotModel) onClassSlotTap;

  const _DayColumn({
    required this.dayIndex,
    required this.slots,
    required this.reminders,
    required this.onClassSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayLabel = TimetableConstants.dayLabels[dayIndex];
    final todayIndex = DateTime.now().weekday - 1;
    final isToday = dayIndex == todayIndex;

    const double columnWidth = 150.0;

    return Container(
      width: columnWidth,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isToday
                  ? colorScheme.secondaryContainer
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: isToday
                    ? colorScheme.secondary
                    : colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Text(
              dayLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isToday
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;

              final classPositions = _assignColumns(
                slots
                    .map((s) =>
                        (id: s.id, start: s.startMinutes, end: s.endMinutes))
                    .toList(),
              );

              return Container(
                height: TimetableConstants.totalGridHeight +
                    TimetableConstants.gridTopPadding,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    const _HourLines(),
                    ...slots.map((s) {
                      const laneGap = 4.0;
                      final pos =
                          classPositions[s.id] ?? const _OverlapPos(0, 1);
                      final laneWidth = totalWidth / pos.totalColumns;
                      final cardWidth = laneWidth - laneGap;
                      final hasAlarm = reminders.any((r) =>
                          normalizeCourseCode(r.courseCode) ==
                              normalizeCourseCode(s.courseCode) &&
                          r.isEnabled &&
                          r.isAlarm);

                      return TimetableSlotCard(
                        slot: s,
                        left: (pos.columnIndex * laneWidth) + (laneGap / 2),
                        width: cardWidth,
                        hasAlarm: hasAlarm,
                        onTap: () => onClassSlotTap(s),
                        onLongPress: () => onClassSlotTap(s),
                      );
                    }),
                    if (isToday) const _CurrentTimeIndicator(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Overlap detection ─────────────────────────────────────────────────────────

class _OverlapPos {
  final int columnIndex;
  final int totalColumns;
  const _OverlapPos(this.columnIndex, this.totalColumns);
}

Map<int, _OverlapPos> _assignColumns(
  List<({int id, int start, int end})> items,
) {
  if (items.isEmpty) return {};

  final sorted = [...items]..sort((a, b) => a.start.compareTo(b.start));
  final colAssign = <int, int>{};
  final colEnds = <int>[];

  for (final item in sorted) {
    int col = -1;
    for (int i = 0; i < colEnds.length; i++) {
      if (colEnds[i] <= item.start) {
        col = i;
        colEnds[i] = item.end;
        break;
      }
    }
    if (col == -1) {
      col = colEnds.length;
      colEnds.add(item.end);
    }
    colAssign[item.id] = col;
  }

  final result = <int, _OverlapPos>{};
  for (final item in sorted) {
    int maxCol = colAssign[item.id]!;
    for (final other in sorted) {
      if (other.start < item.end && other.end > item.start) {
        final c = colAssign[other.id]!;
        if (c > maxCol) maxCol = c;
      }
    }
    result[item.id] = _OverlapPos(colAssign[item.id]!, maxCol + 1);
  }

  return result;
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _TimeLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = List.generate(
      TimetableConstants.gridEndHour - TimetableConstants.gridStartHour,
      (i) => TimetableConstants.gridStartHour + i,
    );
    return SizedBox(
      width: TimetableConstants.timeLabelWidth,
      height: TimetableConstants.totalGridHeight +
          TimetableConstants.gridTopPadding,
      child: Stack(
        children: hours.map((hour) {
          final top = (hour - TimetableConstants.gridStartHour) *
                  TimetableConstants.hourRowHeight +
              TimetableConstants.gridTopPadding;
          final label = hour == 0
              ? '12 AM'
              : hour < 12
                  ? '$hour AM'
                  : hour == 12
                      ? '12 PM'
                      : '${hour - 12} PM';
          return Positioned(
            top: top - 8,
            left: 0,
            right: 4,
            child: Text(label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
          );
        }).toList(),
      ),
    );
  }
}

class _HourLines extends StatelessWidget {
  const _HourLines();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const hours =
        TimetableConstants.gridEndHour - TimetableConstants.gridStartHour;
    return SizedBox(
      height: TimetableConstants.totalGridHeight +
          TimetableConstants.gridTopPadding,
      child: Stack(
        children: List.generate(hours, (i) {
          final top = i * TimetableConstants.hourRowHeight +
              TimetableConstants.gridTopPadding;
          return Positioned(
            top: top,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.75),
            ),
          );
        }),
      ),
    );
  }
}

class _CurrentTimeIndicator extends StatelessWidget {
  const _CurrentTimeIndicator();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    if (nowMins < TimetableConstants.gridStartMinutes ||
        nowMins > TimetableConstants.gridEndMinutes) {
      return const SizedBox.shrink();
    }
    final top = (nowMins - TimetableConstants.gridStartMinutes) *
            TimetableConstants.pixelsPerMinute +
        TimetableConstants.gridTopPadding;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppTheme.warning,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.warning.withValues(alpha: 0.6),
          ),
        ),
      ]),
    );
  }
}
