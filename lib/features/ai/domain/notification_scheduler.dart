import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;

/// Task names used by Workmanager. Must match callbackDispatcher in main.dart.
const kStreakRiskTaskName = 'streak_risk_check';

class NotificationScheduler {
  /// Register a daily Workmanager periodic task that fires a streak-at-risk
  /// check. First fire is delayed until 8 PM today (or 8 PM tomorrow if it
  /// has already passed).
  static Future<void> scheduleStreakRiskCheck() async {
    await Workmanager().registerPeriodicTask(
      kStreakRiskTaskName,
      kStreakRiskTaskName,
      frequency: const Duration(hours: 24),
      initialDelay: _timeUntil8pm(),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// Cancel the streak-risk background task.
  static Future<void> cancelStreakRiskCheck() async {
    await Workmanager().cancelByUniqueName(kStreakRiskTaskName);
  }

  static Duration _timeUntil8pm() {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);
    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }
}
