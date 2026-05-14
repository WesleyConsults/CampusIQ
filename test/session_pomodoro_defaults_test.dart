import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pomodoro session start falls back from invalid timer defaults', () {
    final notifier = ActiveSessionNotifier();

    notifier.startSession(
      courseCode: 'MATH101',
      courseName: 'Engineering Maths',
      courseSource: 'manual',
      focusDuration: const Duration(minutes: -1),
      shortBreakDuration: const Duration(minutes: -1),
      longBreakDuration: const Duration(minutes: -1),
      totalRounds: -9223372036854775808,
    );

    final session = notifier.state;
    expect(session, isNotNull);
    expect(session!.focusDuration, const Duration(minutes: 25));
    expect(session.shortBreakDuration, const Duration(minutes: 5));
    expect(session.longBreakDuration, const Duration(minutes: 15));
    expect(session.totalRounds, 4);
  });
}
