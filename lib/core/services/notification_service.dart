import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Channel IDs ──────────────────────────────────────────────────────────
  static const String _channelStudyReminder = 'study_reminder';
  static const String _channelStreakAlert   = 'streak_alert';
  static const String _channelMilestone     = 'milestone_alert';
  static const String _channelWeeklyReview  = 'weekly_review';

  // ── ID ranges ────────────────────────────────────────────────────────────
  // Free block reminders : 100–199
  // Streak at risk       : 200
  // Haven't studied      : 201
  // Milestone approaching: 300–399
  // Weekly review        : 400
  // Session reminders    : 500–599

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // ── Internal helpers ─────────────────────────────────────────────────────

  AndroidNotificationDetails _androidDetails(
          String channelId, String channelName) =>
      AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      );

  Future<void> _schedule(
    int id,
    String title,
    String body,
    DateTime scheduledAt,
    String channelId,
    String channelName,
  ) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: NotificationDetails(
          android: _androidDetails(channelId, channelName)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ── Public scheduling methods ─────────────────────────────────────────────

  /// Schedule free-block reminders for today.
  /// [freeBlocks] come from FreeTimeDetector — startMinutes is minutes from midnight.
  Future<void> scheduleFreeBlockReminders(List<FreeBlock> freeBlocks) async {
    for (int i = 100; i < 200; i++) {
      await _plugin.cancel(id: i);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int notifId = 100;

    for (final block in freeBlocks) {
      if (notifId >= 200) break;
      if (block.durationMinutes < 30) continue;

      final blockStart =
          today.add(Duration(minutes: block.startMinutes));
      final notifTime =
          blockStart.subtract(const Duration(minutes: 5));
      if (notifTime.isBefore(now)) continue;

      await _schedule(
        notifId,
        'Free time coming up',
        'You have ${block.durationMinutes} min free — good time to study.',
        notifTime,
        _channelStudyReminder,
        'Study Reminders',
      );
      notifId++;
    }
  }

  /// Schedule a streak-at-risk alert at 8:30 PM today.
  Future<void> scheduleStreakAtRiskAlert(int currentStreak) async {
    await _plugin.cancel(id: 200);
    if (currentStreak <= 0) return;

    final now = DateTime.now();
    final target =
        DateTime(now.year, now.month, now.day, 20, 30);
    if (target.isBefore(now)) return;

    await _schedule(
      200,
      'Your streak is at risk 🔥',
      "You haven't studied today. "
          'Your $currentStreak-day streak ends at midnight.',
      target,
      _channelStreakAlert,
      'Streak Alerts',
    );
  }

  /// Schedule a "haven't studied" alert at the user's chosen time (default 8 PM).
  Future<void> scheduleHaventStudiedAlert({
    int hour = 20,
    int minute = 0,
  }) async {
    await _plugin.cancel(id: 201);

    final now = DateTime.now();
    final target =
        DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) return;

    await _schedule(
      201,
      'No study session yet',
      "You haven't logged a session today. Even 30 minutes counts.",
      target,
      _channelStudyReminder,
      'Study Reminders',
    );
  }

  /// Schedule a milestone-approaching alert for tomorrow at 9 AM.
  Future<void> scheduleMilestoneAlert(
      int daysToNextMilestone, int nextMilestone) async {
    await _plugin.cancel(id: 300);
    if (daysToNextMilestone <= 0 || daysToNextMilestone > 3) return;

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final target =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);

    await _schedule(
      300,
      'Milestone approaching 🏆',
      "You're $daysToNextMilestone day(s) away from your "
          '$nextMilestone-day milestone. Keep going.',
      target,
      _channelMilestone,
      'Milestone Alerts',
    );
  }

  /// Schedule weekly review prompt for next Monday at 8 AM.
  Future<void> scheduleWeeklyReviewPrompt() async {
    await _plugin.cancel(id: 400);

    final now = DateTime.now();
    int daysUntilMonday = DateTime.monday - now.weekday;
    if (daysUntilMonday <= 0) daysUntilMonday += 7;
    final nextMonday = DateTime(
        now.year, now.month, now.day + daysUntilMonday, 8, 0);

    await _schedule(
      400,
      'Your weekly review is ready',
      'Tap to see how your study week went.',
      nextMonday,
      _channelWeeklyReview,
      'Weekly Review',
    );
  }

  /// Schedule a 10-min reminder before a planned study task.
  Future<void> schedulePlannedSessionReminder(
      DailyPlanTaskModel task) async {
    if (task.taskType != 'study' || task.startTime == null) return;

    final notifTime =
        task.startTime!.subtract(const Duration(minutes: 10));
    if (notifTime.isBefore(DateTime.now())) return;

    final notifId = (500 + (task.id % 100)).clamp(500, 599);

    await _schedule(
      notifId,
      'Study session starting soon',
      '${task.label} is scheduled to start in 10 minutes.',
      notifTime,
      _channelStudyReminder,
      'Study Reminders',
    );
  }

  /// Cancel notification IDs 200 and 201 (used when a session is logged).
  Future<void> cancelStudiedTodayAlerts() async {
    await _plugin.cancel(id: 200);
    await _plugin.cancel(id: 201);
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }
}
