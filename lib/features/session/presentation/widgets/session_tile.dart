import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

class SessionTile extends StatelessWidget {
  final StudySessionModel session;
  final VoidCallback onDelete;

  const SessionTile({super.key, required this.session, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hour = session.startTime.hour;
    final suffix = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final timeLabel =
        '$displayHour:${session.startTime.minute.toString().padLeft(2, '0')} $suffix';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        child: Text(
          session.courseCode.length >= 2
              ? session.courseCode.substring(0, 2)
              : session.courseCode,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(session.courseCode,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(
        '$timeLabel · ${session.wasPlanned ? "Planned" : "Spontaneous"}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (session.isPomodoro)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.hourglass_bottom_rounded,
                  size: 13, color: AppTheme.textSecondary),
            ),
          Text(
            session.formattedDuration,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppTheme.textSecondary),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
