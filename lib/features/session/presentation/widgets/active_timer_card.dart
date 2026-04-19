import 'dart:async';
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';

/// Large timer card shown at the top of the Sessions screen when a session is active.
/// Handles both Normal (count-up) and Pomodoro (count-down with rounds) modes.
class ActiveTimerCard extends StatefulWidget {
  final ActiveSessionState session;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback? onPhaseExpired; // called once when countdown hits zero
  final VoidCallback? onSkipBreak;

  const ActiveTimerCard({
    super.key,
    required this.session,
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
  DateTime? _lastFiredPhaseEnd; // guards against double-firing per phase

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
    final s = widget.session;
    if (!s.isPomodoroMode || s.isComplete) return;
    if (s.phaseRemaining == Duration.zero &&
        _lastFiredPhaseEnd != s.phaseEndsAt) {
      _lastFiredPhaseEnd = s.phaseEndsAt;
      widget.onPhaseExpired?.call();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return s.isPomodoroMode ? _buildPomodoro(s) : _buildNormal(s);
  }

  // ── Normal mode ───────────────────────────────────────────────────────────

  Widget _buildNormal(ActiveSessionState s) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(s.courseCode,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          Text(s.courseName,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 24),
          Text(s.formattedElapsed,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 52,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              )),
          const SizedBox(height: 8),
          Text('Session in progress',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          const SizedBox(height: 24),
          _actionRow(
            cancelLabel: 'Cancel',
            onCancel: widget.onCancel,
            onStop: widget.onStop,
          ),
        ],
      ),
    );
  }

  // ── Pomodoro mode ─────────────────────────────────────────────────────────

  Widget _buildPomodoro(ActiveSessionState s) {
    if (s.isComplete) return _buildComplete(s);

    final isBreak = s.isBreak;
    final cardColor = isBreak ? AppTheme.success : AppTheme.primary;
    final timerColor = isBreak ? Colors.white : AppTheme.accent;
    final phaseLabel = isBreak
        ? (s.isLongBreak ? 'Long Break' : 'Short Break')
        : 'Focus';
    final roundLabel = 'Round ${s.currentRound} of ${s.totalRounds}  ·  $phaseLabel';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Course info
          Text(s.courseCode,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          Text(s.courseName,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 24),

          // Round progress dots
          _RoundDots(
              current: s.currentRound,
              total: s.totalRounds,
              isBreak: isBreak),
          const SizedBox(height: 16),

          // Countdown
          Text(s.formattedPhaseRemaining,
              style: TextStyle(
                color: timerColor,
                fontSize: 52,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
          const SizedBox(height: 6),
          Text(roundLabel,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),

          const SizedBox(height: 24),

          // Buttons
          if (isBreak)
            _actionRow(
              cancelLabel: 'Skip Break',
              onCancel: widget.onSkipBreak ?? () {},
              onStop: widget.onStop,
            )
          else
            _actionRow(
              cancelLabel: 'Cancel',
              onCancel: widget.onCancel,
              onStop: widget.onStop,
            ),
        ],
      ),
    );
  }

  Widget _buildComplete(ActiveSessionState s) {
    final rounds = s.pomodoroRoundsCompleted;
    final mins = s.elapsedMinutes;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(s.courseCode,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          Text(s.courseName,
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 24),
          const Text('Session Complete!',
              style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            '$rounds ${rounds == 1 ? 'round' : 'rounds'} · ${mins}m focused',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Stop & Save',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required String cancelLabel,
    required VoidCallback onCancel,
    required VoidCallback onStop,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white54,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(cancelLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onStop,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Stop & Save',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ── Round progress indicator ──────────────────────────────────────────────────

class _RoundDots extends StatelessWidget {
  final int current;
  final int total;
  final bool isBreak;

  const _RoundDots(
      {required this.current, required this.total, required this.isBreak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final filled = i < current;
        final isCurrent = i == current - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 12 : 8,
          height: isCurrent ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? (isBreak ? Colors.white : AppTheme.accent)
                : Colors.white24,
          ),
        );
      }),
    );
  }
}
