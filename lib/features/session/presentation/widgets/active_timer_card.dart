import 'dart:async';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Large timer card shown at the top of the Sessions screen when a session is active.
/// Handles both Normal (count-up) and Pomodoro (count-down with rounds) modes.
class ActiveTimerCard extends StatefulWidget {
  final ActiveSessionState session;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback? onPhaseExpired;
  final VoidCallback? onSkipBreak;

  const ActiveTimerCard({
    super.key,
    required this.session,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onCancel,
    this.onPhaseExpired,
    this.onSkipBreak,
  });

  @override
  State<ActiveTimerCard> createState() => _ActiveTimerCardState();
}

class _ActiveTimerCardState extends State<ActiveTimerCard> {
  Timer? _ticker;
  DateTime? _lastFiredPhaseEnd;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _checkPhaseExpiry();
    });
  }

  void _checkPhaseExpiry() {
    final session = widget.session;
    if (!session.isPomodoroMode ||
        session.isComplete ||
        session.isPaused ||
        session.phaseRemaining != Duration.zero) {
      return;
    }
    if (_lastFiredPhaseEnd == session.phaseEndsAt) return;
    _lastFiredPhaseEnd = session.phaseEndsAt;
    widget.onPhaseExpired?.call();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return session.isPomodoroMode
        ? _buildPomodoro(session)
        : _buildNormal(session);
  }

  Widget _buildNormal(ActiveSessionState session) {
    return _HeroShell(
      eyebrow: session.isPaused ? 'Session paused' : 'You are in focus mode',
      title: session.courseName,
      courseCode: session.courseCode,
      timer: session.formattedElapsed,
      timerCaption: session.isPaused
          ? 'Tap resume when you are ready'
          : 'Elapsed focus time',
      timerColor: AppTheme.accent,
      accentColor: AppTheme.accent,
      statusLabel: session.isPaused ? 'Paused' : 'Active',
      statusColor: session.isPaused ? AppTheme.accent : const Color(0xFFBFD8C5),
      secondaryDetails: [
        'Started ${_formatTime(session.startTime)}',
        'Normal session',
      ],
      actions: _buildActionRows(
        isPaused: session.isPaused,
        onPause: widget.onPause,
        onResume: widget.onResume,
        onStop: widget.onStop,
        onCancel: widget.onCancel,
      ),
    );
  }

  Widget _buildPomodoro(ActiveSessionState session) {
    if (session.isComplete) {
      return _HeroShell(
        eyebrow: 'Pomodoro complete',
        title: session.courseName,
        courseCode: session.courseCode,
        timer: '${session.elapsedMinutes}m',
        timerCaption:
            '${session.pomodoroRoundsCompleted} ${session.pomodoroRoundsCompleted == 1 ? 'round' : 'rounds'} completed',
        timerColor: AppTheme.accent,
        accentColor: AppTheme.accent,
        statusLabel: 'Complete',
        statusColor: const Color(0xFFBFD8C5),
        secondaryDetails: [
          'Started ${_formatTime(session.startTime)}',
          'Ready to save to history',
        ],
        actions: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: widget.onStop,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.primary,
                    ),
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: const Text('Stop & Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Discard session'),
              ),
            ),
          ],
        ),
        footer: _PomodoroRounds(
          current: session.currentRound,
          total: session.totalRounds,
          isBreak: false,
        ),
      );
    }

    final isBreak = session.isBreak;
    final statusColor = session.isPaused
        ? AppTheme.accent
        : isBreak
            ? const Color(0xFFBFE5D3)
            : const Color(0xFFF3D897);
    final timerColor = isBreak ? Colors.white : AppTheme.accent;
    final caption = session.isPaused
        ? '${session.currentPhaseLabel} paused'
        : 'Round ${session.currentRound} of ${session.totalRounds} · ${session.currentPhaseLabel}';

    return _HeroShell(
      eyebrow: session.isPaused
          ? 'Pomodoro paused'
          : isBreak
              ? 'Take a short reset'
              : 'Stay with this round',
      title: session.courseName,
      courseCode: session.courseCode,
      timer: session.formattedPhaseRemaining,
      timerCaption: caption,
      timerColor: timerColor,
      accentColor: timerColor,
      statusLabel: session.isPaused
          ? 'Paused'
          : isBreak
              ? 'Break'
              : 'Focus',
      statusColor: statusColor,
      secondaryDetails: [
        'Started ${_formatTime(session.startTime)}',
        '${session.focusDuration.inMinutes}m focus · ${session.shortBreakDuration.inMinutes}m short break',
      ],
      actions: _buildPomodoroActions(session),
      footer: _PomodoroRounds(
        current: session.currentRound,
        total: session.totalRounds,
        isBreak: session.isBreak,
      ),
    );
  }

  Widget _buildPomodoroActions(ActiveSessionState session) {
    if (session.isPaused) {
      return _buildActionRows(
        isPaused: true,
        onPause: widget.onPause,
        onResume: widget.onResume,
        onStop: widget.onStop,
        onCancel: widget.onCancel,
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    session.isBreak ? widget.onSkipBreak : widget.onPause,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                icon: Icon(
                  session.isBreak ? LucideIcons.forward : LucideIcons.pause,
                  size: 16,
                ),
                label: Text(session.isBreak ? 'Skip Break' : 'Pause'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.onStop,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.primary,
                ),
                icon: const Icon(LucideIcons.square, size: 16),
                label: const Text('End & Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Discard session'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRows({
    required bool isPaused,
    required VoidCallback onPause,
    required VoidCallback onResume,
    required VoidCallback onStop,
    required VoidCallback onCancel,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isPaused ? onResume : onPause,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                icon: Icon(
                  isPaused ? LucideIcons.play : LucideIcons.pause,
                  size: 16,
                ),
                label: Text(isPaused ? 'Resume' : 'Pause'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: onStop,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.primary,
                ),
                icon: const Icon(LucideIcons.square, size: 16),
                label: const Text('End & Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Discard session'),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$displayHour:$minute $suffix';
  }
}

class _HeroShell extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String courseCode;
  final String timer;
  final String timerCaption;
  final Color timerColor;
  final Color accentColor;
  final String statusLabel;
  final Color statusColor;
  final List<String> secondaryDetails;
  final Widget actions;
  final Widget? footer;

  const _HeroShell({
    required this.eyebrow,
    required this.title,
    required this.courseCode,
    required this.timer,
    required this.timerCaption,
    required this.timerColor,
    required this.accentColor,
    required this.statusLabel,
    required this.statusColor,
    required this.secondaryDetails,
    required this.actions,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadii.card,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            AppColors.navySoft,
          ],
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _StatusBadge(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaChip(
                icon: LucideIcons.bookOpen,
                label: courseCode,
              ),
              ...secondaryDetails.map(
                (detail) => _MetaChip(
                  icon: LucideIcons.dot,
                  label: detail,
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            timer,
            style: TextStyle(
              color: timerColor,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            timerCaption,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.lg),
            footer!,
          ],
          const SizedBox(height: AppSpacing.xl),
          actions,
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppRadii.pill,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 14, color: Colors.white70),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 11 : 12,
              fontWeight: compact ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PomodoroRounds extends StatelessWidget {
  final int current;
  final int total;
  final bool isBreak;

  const _PomodoroRounds({
    required this.current,
    required this.total,
    required this.isBreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final filled = index < current;
        final isCurrent = index == current - 1;
        return Container(
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          width: isCurrent ? 22 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: filled
                ? (isBreak ? Colors.white : AppTheme.accent)
                : Colors.white.withValues(alpha: 0.18),
          ),
        );
      }),
    );
  }
}
