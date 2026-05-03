import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
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
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: TimetableConstants.dayLabels.length,
        itemBuilder: (context, i) {
          final isActive = i == activeDay;
          final hasSlots = allSlots.any((s) => s.dayIndex == i);

          return GestureDetector(
            onTap: () => ref.read(activeDayProvider.notifier).state = i,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : Colors.white,
                borderRadius: AppRadii.pill,
                border: Border.all(
                  color: isActive ? AppTheme.primary : AppColors.border,
                  width: 1,
                ),
                boxShadow: isActive ? AppShadows.soft : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimetableConstants.dayLabels[i],
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (hasSlots) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : AppTheme.accent,
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
