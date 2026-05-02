import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// 7-day attendance row — student taps each day to mark attendance.
class AttendanceTracker extends StatelessWidget {
  final StreakResult attendanceStreak;
  final List<DateTime> attendedDates;
  final void Function(DateTime date) onToggle;

  const AttendanceTracker({
    super.key,
    required this.attendanceStreak,
    required this.attendedDates,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      return DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i));
    });
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Attendance streak',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Row(
                  children: [
                    const Text('🎓', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${attendanceStreak.currentStreak}d',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap a day to mark class attendance',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final isToday = day.day == today.day &&
                    day.month == today.month &&
                    day.year == today.year;
                final isFuture = day.isAfter(today);
                final isAttended = attendedDates.any((d) =>
                    d.year == day.year &&
                    d.month == day.month &&
                    d.day == day.day);
                final label = dayLabels[day.weekday - 1];

                return GestureDetector(
                  onTap: isFuture ? null : () => onToggle(day),
                  child: Column(
                    children: [
                      Text(
                        label.substring(0, 1),
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isAttended
                              ? AppTheme.primary
                              : isFuture
                                  ? Colors.grey.shade100
                                  : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(color: AppTheme.primary, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isAttended
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isFuture
                                      ? Colors.grey.shade300
                                      : AppTheme.textSecondary,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
