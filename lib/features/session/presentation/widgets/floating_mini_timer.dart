import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';

/// Floating pill shown at the bottom of every screen when a session is active.
/// Positioned above the bottom nav bar inside the AppShell Stack.
class FloatingMiniTimer extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  const FloatingMiniTimer({super.key, required this.onTap});

  @override
  ConsumerState<FloatingMiniTimer> createState() => _FloatingMiniTimerState();
}

class _FloatingMiniTimerState extends ConsumerState<FloatingMiniTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);
    if (session == null) return const SizedBox.shrink();

    final isPomodoro = session.isPomodoroMode;
    final isBreak = isPomodoro && session.isBreak;
    final pillColor = isBreak ? AppTheme.success : AppTheme.primary;

    // Mini label: "R2 Focus" or "R2 Break"
    String? pomodoroLabel;
    String timerDisplay;
    if (isPomodoro && !session.isComplete) {
      final phase = isBreak ? 'Break' : 'Focus';
      pomodoroLabel = 'R${session.currentRound} $phase';
      timerDisplay = session.formattedPhaseRemaining;
    } else if (isPomodoro && session.isComplete) {
      pomodoroLabel = 'Done!';
      timerDisplay = '${session.pomodoroRoundsCompleted}×25m';
    } else {
      timerDisplay = session.formattedElapsed;
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 12,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: pillColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _PulsingDot(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.courseCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (pomodoroLabel != null)
                      Text(
                        pomodoroLabel,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 10),
                      )
                    else
                      Text(
                        session.courseName,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                timerDisplay,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration:
            const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      ),
    );
  }
}
