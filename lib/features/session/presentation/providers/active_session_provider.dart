import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';

/// Global session state — lives above the nav shell, survives tab switches.
/// null = no session active.
class ActiveSessionNotifier extends StateNotifier<ActiveSessionState?> {
  ActiveSessionNotifier() : super(null);

  bool _vibrateOnTimerEnd = true;
  bool _playSoundOnTimerEnd = true;

  void startSession({
    required String courseCode,
    required String courseName,
    required String courseSource,
    bool isPomodoroMode = false,
    Duration focusDuration = const Duration(minutes: 25),
    Duration shortBreakDuration = const Duration(minutes: 5),
    Duration longBreakDuration = const Duration(minutes: 15),
    int totalRounds = 4,
    bool vibrateOnTimerEnd = true,
    bool playSoundOnTimerEnd = true,
  }) {
    _vibrateOnTimerEnd = vibrateOnTimerEnd;
    _playSoundOnTimerEnd = playSoundOnTimerEnd;

    final normalizedFocusDuration = _validDurationOrDefault(
      focusDuration,
      minMinutes: 10,
      maxMinutes: 60,
      fallback: const Duration(minutes: 25),
    );
    final normalizedShortBreakDuration = _validDurationOrDefault(
      shortBreakDuration,
      minMinutes: 5,
      maxMinutes: 30,
      fallback: const Duration(minutes: 5),
    );
    final normalizedLongBreakDuration = _validDurationOrDefault(
      longBreakDuration,
      minMinutes: 10,
      maxMinutes: 60,
      fallback: const Duration(minutes: 15),
    );
    final normalizedTotalRounds =
        totalRounds < 2 || totalRounds > 10 ? 4 : totalRounds;

    final now = DateTime.now();
    final s = ActiveSessionState(
      courseCode: courseCode,
      courseName: courseName,
      courseSource: courseSource,
      startTime: now,
      isPomodoroMode: isPomodoroMode,
      focusDuration: normalizedFocusDuration,
      shortBreakDuration: normalizedShortBreakDuration,
      longBreakDuration: normalizedLongBreakDuration,
      totalRounds: normalizedTotalRounds,
      phaseEndsAt: isPomodoroMode ? now.add(normalizedFocusDuration) : null,
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
        vibrate: _vibrateOnTimerEnd,
        playSound: _playSoundOnTimerEnd,
      );
    }
  }

  /// Transitions focus→break or break→focus (or marks complete after final break).
  void advancePhase() {
    final s = state;
    if (s == null || !s.isPomodoroMode || s.isComplete || s.isPaused) return;
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
        vibrate: _vibrateOnTimerEnd,
        playSound: _playSoundOnTimerEnd,
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
          vibrate: _vibrateOnTimerEnd,
          playSound: _playSoundOnTimerEnd,
        );
      }
    }
  }

  void skipBreak() {
    final s = state;
    if (s == null || !s.isPomodoroMode || !s.isBreak || s.isPaused) return;
    advancePhase();
  }

  void pauseSession() {
    final s = state;
    if (s == null || s.isPaused || s.isComplete) return;

    state = s.copyWith(
      isPaused: true,
      pausedAt: DateTime.now(),
      pausedPhaseRemaining: s.isPomodoroMode ? s.phaseRemaining : null,
    );
    if (s.isPomodoroMode) {
      NotificationService.instance.cancelPomodoroPhaseNotification();
    }
  }

  void resumeSession() {
    final s = state;
    if (s == null || !s.isPaused || s.isComplete) return;

    final now = DateTime.now();
    final pausedDuration =
        s.pausedAt == null ? Duration.zero : now.difference(s.pausedAt!);
    final accumulatedPausedSeconds =
        s.accumulatedPausedSeconds + pausedDuration.inSeconds;

    if (!s.isPomodoroMode) {
      state = s.copyWith(
        isPaused: false,
        pausedAt: null,
        pausedPhaseRemaining: null,
        accumulatedPausedSeconds: accumulatedPausedSeconds,
      );
      return;
    }

    final remaining = s.pausedPhaseRemaining ?? s.phaseRemaining;
    final totalPhaseDuration = s.isBreak
        ? (s.isLongBreak ? s.longBreakDuration : s.shortBreakDuration)
        : s.focusDuration;
    final progressedSeconds =
        totalPhaseDuration.inSeconds - remaining.inSeconds;
    final next = s.copyWith(
      isPaused: false,
      pausedAt: null,
      pausedPhaseRemaining: null,
      accumulatedPausedSeconds: accumulatedPausedSeconds,
      phaseEndsAt: now.add(remaining),
      phaseStartedAt: now.subtract(
        Duration(
            seconds: progressedSeconds.clamp(0, totalPhaseDuration.inSeconds)),
      ),
    );
    state = next;
    NotificationService.instance.schedulePomodoroPhaseEnd(
      phaseEndsAt: next.phaseEndsAt,
      isBreak: next.isBreak,
      isLongBreak: next.isLongBreak,
      round: next.currentRound,
      totalRounds: next.totalRounds,
      vibrate: _vibrateOnTimerEnd,
      playSound: _playSoundOnTimerEnd,
    );
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

  Duration _validDurationOrDefault(
    Duration duration, {
    required int minMinutes,
    required int maxMinutes,
    required Duration fallback,
  }) {
    final minutes = duration.inMinutes;
    if (minutes < minMinutes || minutes > maxMinutes) return fallback;
    return duration;
  }
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState?>(
  (ref) => ActiveSessionNotifier(),
);
