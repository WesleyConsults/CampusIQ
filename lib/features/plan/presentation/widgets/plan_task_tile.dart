import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';

class PlanTaskTile extends ConsumerWidget {
  final DailyPlanTaskModel task;

  const PlanTaskTile({super.key, required this.task});

  Color _accentColor() {
    switch (task.taskType) {
      case 'attend':
        return const Color(0xFF1565C0); // blue
      case 'study':
        return const Color(0xFF1D9E75); // green
      case 'personal':
        return const Color(0xFFF59E0B); // amber
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final suffix = h < 12 ? 'AM' : 'PM';
    final hour = h == 0
        ? 12
        : h > 12
            ? h - 12
            : h;
    return '$hour:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(planRepositoryProvider);
    final accent = _accentColor();
    final done = task.isCompleted;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade100,
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => repo?.deleteTask(task.id),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left colour accent strip
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Check icon
            GestureDetector(
              onTap: () => repo?.markComplete(task.id, !done),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color:
                      done ? const Color(0xFF1D9E75) : const Color(0xFF6B7280),
                  size: AppIconSizes.xxxl,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Label + chips
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: done
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF1A1A2E),
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF6B7280),
                      ),
                    ),
                    if (task.isManual) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(AppRadii.xs),
                        ),
                        child: const Text(
                          'custom',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Trailing: time + duration
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: SizedBox(
                width: 78,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (task.startTime != null)
                      Text(
                        _formatTime(task.startTime!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    Text(
                      '${task.durationMinutes} min',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
