import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';

/// Global session state — lives above the nav shell, survives tab switches.
/// null = no session active.
class ActiveSessionNotifier extends StateNotifier<ActiveSessionState?> {
  ActiveSessionNotifier() : super(null);

  void startSession({
    required String courseCode,
    required String courseName,
    required String courseSource,
  }) {
    state = ActiveSessionState(
      courseCode: courseCode,
      courseName: courseName,
      courseSource: courseSource,
      startTime: DateTime.now(),
    );
  }

  /// Returns the completed session data then clears state.
  ActiveSessionState? stopSession() {
    final completed = state;
    state = null;
    return completed;
  }

  void cancelSession() => state = null;

  bool get isActive => state != null;
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState?>(
  (ref) => ActiveSessionNotifier(),
);
