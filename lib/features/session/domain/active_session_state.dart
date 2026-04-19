/// Represents an in-progress session held in global provider state.
/// Uses DateTime anchor — never a running counter — for Android reliability.
class ActiveSessionState {
  final String courseCode;
  final String courseName;
  final String courseSource; // "cwa" | "timetable" | "custom"
  final DateTime startTime;

  // ── Pomodoro ─────────────────────────────────────────────────────────────
  final bool isPomodoroMode;
  final int currentRound;           // 1-based: which focus round we're on
  final int totalRounds;            // default 4
  final bool isBreak;               // true = currently in a break phase
  final bool isComplete;            // true = all rounds + final break done
  final DateTime phaseEndsAt;       // when the current phase countdown ends
  final DateTime phaseStartedAt;    // when the current phase began
  final int accumulatedFocusSeconds; // focus seconds from completed rounds
  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;

  ActiveSessionState({
    required this.courseCode,
    required this.courseName,
    required this.courseSource,
    required this.startTime,
    this.isPomodoroMode = false,
    this.currentRound = 1,
    this.totalRounds = 4,
    this.isBreak = false,
    this.isComplete = false,
    DateTime? phaseEndsAt,
    DateTime? phaseStartedAt,
    this.accumulatedFocusSeconds = 0,
    this.focusDuration = const Duration(minutes: 25),
    this.shortBreakDuration = const Duration(minutes: 5),
    this.longBreakDuration = const Duration(minutes: 15),
  })  : phaseEndsAt = phaseEndsAt ?? DateTime(0),
        phaseStartedAt = phaseStartedAt ?? DateTime(0);

  ActiveSessionState copyWith({
    String? courseCode,
    String? courseName,
    String? courseSource,
    DateTime? startTime,
    bool? isPomodoroMode,
    int? currentRound,
    int? totalRounds,
    bool? isBreak,
    bool? isComplete,
    DateTime? phaseEndsAt,
    DateTime? phaseStartedAt,
    int? accumulatedFocusSeconds,
    Duration? focusDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
  }) {
    return ActiveSessionState(
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      courseSource: courseSource ?? this.courseSource,
      startTime: startTime ?? this.startTime,
      isPomodoroMode: isPomodoroMode ?? this.isPomodoroMode,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      isBreak: isBreak ?? this.isBreak,
      isComplete: isComplete ?? this.isComplete,
      phaseEndsAt: phaseEndsAt ?? this.phaseEndsAt,
      phaseStartedAt: phaseStartedAt ?? this.phaseStartedAt,
      accumulatedFocusSeconds:
          accumulatedFocusSeconds ?? this.accumulatedFocusSeconds,
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
    );
  }

  // ── Normal mode: wall-clock elapsed ──────────────────────────────────────
  Duration get elapsed => DateTime.now().difference(startTime);

  // ── Focus minutes saved at stop (Pomodoro: focus only, not breaks) ───────
  int get elapsedMinutes {
    if (!isPomodoroMode) return elapsed.inMinutes;
    final extraSeconds = (!isBreak && !isComplete)
        ? DateTime.now().difference(phaseStartedAt).inSeconds
        : 0;
    return (accumulatedFocusSeconds + extraSeconds) ~/ 60;
  }

  // ── Pomodoro: time remaining in current phase ─────────────────────────────
  Duration get phaseRemaining {
    final rem = phaseEndsAt.difference(DateTime.now());
    return rem.isNegative ? Duration.zero : rem;
  }

  bool get isLongBreak => isBreak && currentRound >= totalRounds;

  // How many complete focus rounds are banked
  int get pomodoroRoundsCompleted =>
      accumulatedFocusSeconds ~/ focusDuration.inSeconds;

  // ── Formatted strings ─────────────────────────────────────────────────────
  String get formattedElapsed {
    final d = elapsed;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedPhaseRemaining {
    final d = phaseRemaining;
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
