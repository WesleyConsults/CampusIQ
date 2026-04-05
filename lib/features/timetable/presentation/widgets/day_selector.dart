import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

/// Horizontal scrollable day pill selector shown above the grid.
class DaySelector extends ConsumerWidget {
  const DaySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDay = ref.watch(activeDayProvider);
    final allSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: TimetableConstants.dayLabels.length,
        itemBuilder: (context, i) {
          final isActive = i == activeDay;
          final hasSlots = allSlots.any((s) => s.dayIndex == i);

          return GestureDetector(
            onTap: () => ref.read(activeDayProvider.notifier).state = i,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppTheme.primary : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimetableConstants.dayLabels[i],
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  if (hasSlots) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white60 : AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
