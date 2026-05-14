import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SessionTile extends StatelessWidget {
  final StudySessionModel session;
  final VoidCallback onDelete;

  const SessionTile({
    super.key,
    required this.session,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hour = session.startTime.hour;
    final suffix = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final timeLabel =
        '$displayHour:${session.startTime.minute.toString().padLeft(2, '0')} $suffix';
    final dateLabel =
        '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadii.button,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: colorScheme.brightness == Brightness.dark ? 0.18 : 0.07,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            alignment: Alignment.center,
            child: Text(
              session.courseCode.length >= 2
                  ? session.courseCode.substring(0, 2)
                  : session.courseCode,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ).copyWith(color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.courseCode,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    Text(
                      session.formattedDuration,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  session.courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _HistoryPill(
                      icon: LucideIcons.clock3,
                      label: '$dateLabel · $timeLabel',
                    ),
                    _HistoryPill(
                      icon: session.wasPlanned
                          ? LucideIcons.calendarCheck2
                          : LucideIcons.sparkles,
                      label: session.wasPlanned ? 'Planned' : 'Spontaneous',
                    ),
                    if (session.isPomodoro)
                      const _HistoryPill(
                        icon: LucideIcons.timerReset,
                        label: 'Pomodoro',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              LucideIcons.trash2,
              size: AppIconSizes.lg,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Delete session',
          ),
        ],
      ),
    );
  }
}

class _HistoryPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HistoryPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
