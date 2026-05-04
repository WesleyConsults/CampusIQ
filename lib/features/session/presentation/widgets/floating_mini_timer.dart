import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Floating pill shown at the bottom of every screen when a session is active.
/// Placement is handled by the AppShell so the widget stays reusable.
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
    final isPaused = session.isPaused;
    final accentColor = isPaused
        ? AppTheme.accent
        : isBreak
            ? AppTheme.success
            : AppTheme.primary;

    String? secondaryLabel;
    String timerDisplay;
    if (isPomodoro && !session.isComplete) {
      final phase = isBreak ? 'Break' : 'Focus';
      secondaryLabel = isPaused
          ? 'Paused · R${session.currentRound} $phase'
          : 'R${session.currentRound} $phase';
      timerDisplay = session.formattedPhaseRemaining;
    } else if (isPomodoro && session.isComplete) {
      secondaryLabel = 'Done!';
      timerDisplay = '${session.pomodoroRoundsCompleted}×25m';
    } else {
      secondaryLabel = isPaused ? 'Paused' : session.courseName;
      timerDisplay = session.formattedElapsed;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.98),
          borderRadius: AppRadii.pill,
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _StatusIndicator(
              color: accentColor,
              isPaused: isPaused,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    session.courseCode,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    secondaryLabel,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: AppRadii.pill,
              ),
              child: Text(
                timerDisplay,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              LucideIcons.chevronRight,
              color: AppTheme.textSecondary,
              size: AppIconSizes.md,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatefulWidget {
  final Color color;
  final bool isPaused;

  const _StatusIndicator({
    required this.color,
    required this.isPaused,
  });

  @override
  State<_StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<_StatusIndicator>
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
    if (widget.isPaused) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.pause,
          size: 10,
          color: widget.color,
        ),
      );
    }

    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
