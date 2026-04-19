import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';

/// Global session state — lives above the nav shell, survives tab switches.
/// null = no session active.
class ActiveSessionNotifier extends StateNotifier<ActiveSessionState?> {
  ActiveSessionNotifier() : super(null);

  void startSession({
    required String courseCode,
    required String courseName,
    required String courseSource,
    bool isPomodoroMode = false,
    Duration focusDuration = const Duration(minutes: 25),
    Duration shortBreakDuration = const Duration(minutes: 5),
    Duration longBreakDuration = const Duration(minutes: 15),
  }) {
    final now = DateTime.now();
    final s = ActiveSessionState(
      courseCode: courseCode,
      courseName: courseName,
      courseSource: courseSource,
      startTime: now,
      isPomodoroMode: isPomodoroMode,
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      phaseEndsAt: isPomodoroMode ? now.add(focusDuration) : null,
      phaseStartedAt: isPomodoroMode ? now : null,
    );
    state = s;
    if (isPomodoroMode) {
      NotificationService.instance.schedulePomodoroPhaseEnd(
        phaseEndsAt: s.phaseEndsAt,
        isBreak: false,
        isLongBreak: false,
        round: 1,
        totalRounds: s.totalRounds,
      );
    }
  }

  /// Transitions focus→break or break→focus (or marks complete after final break).
  void advancePhase() {
    final s = state;
    if (s == null || !s.isPomodoroMode || s.isComplete) return;
    final now = DateTime.now();

    if (!s.isBreak) {
      // Focus phase ended → enter break
      final newAccumulated =
          s.accumulatedFocusSeconds + s.focusDuration.inSeconds;
      final isLong = s.currentRound >= s.totalRounds;
      final breakDuration = isLong ? s.longBreakDuration : s.shortBreakDuration;
      final next = s.copyWith(
        isBreak: true,
        phaseEndsAt: now.add(breakDuration),
        phaseStartedAt: now,
        accumulatedFocusSeconds: newAccumulated,
      );
      state = next;
      NotificationService.instance.schedulePomodoroPhaseEnd(
        phaseEndsAt: next.phaseEndsAt,
        isBreak: true,
        isLongBreak: isLong,
        round: s.currentRound,
        totalRounds: s.totalRounds,
      );
    } else {
      // Break ended → next focus round or session complete
      if (s.currentRound >= s.totalRounds) {
        state = s.copyWith(isComplete: true, isBreak: false);
        NotificationService.instance.cancelPomodoroPhaseNotification();
      } else {
        final next = s.copyWith(
          currentRound: s.currentRound + 1,
          isBreak: false,
          phaseEndsAt: now.add(s.focusDuration),
          phaseStartedAt: now,
        );
        state = next;
        NotificationService.instance.schedulePomodoroPhaseEnd(
          phaseEndsAt: next.phaseEndsAt,
          isBreak: false,
          isLongBreak: false,
          round: next.currentRound,
          totalRounds: next.totalRounds,
        );
      }
    }
  }

  void skipBreak() {
    final s = state;
    if (s == null || !s.isPomodoroMode || !s.isBreak) return;
    advancePhase();
  }

  /// Returns completed session data then clears state.
  ActiveSessionState? stopSession() {
    final completed = state;
    state = null;
    NotificationService.instance.cancelPomodoroPhaseNotification();
    return completed;
  }

  void cancelSession() {
    state = null;
    NotificationService.instance.cancelPomodoroPhaseNotification();
  }

  bool get isActive => state != null;
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState?>(
  (ref) => ActiveSessionNotifier(),
);
