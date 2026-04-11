import 'package:isar/isar.dart';

part 'user_prefs_model.g.dart';

/// Single-row key/value store for lightweight persistent app preferences.
/// Only one instance ever exists (id = 1).
@collection
class UserPrefsModel {
  Id id = 1; // always 1 — single row

  /// JSON-encoded list of ISO date strings the student marked attendance.
  /// e.g. '["2024-11-04","2024-11-05"]'
  String attendedDatesJson = '[]';

  /// Last date the app was opened — used for streak alive check.
  DateTime? lastOpenedDate;

  // ── Notification preferences ─────────────────────────────────────────────

  /// Whether the user has already been shown the notification permission dialog.
  /// Set to true after they tap either "Allow" or "Not now".
  bool notificationPermissionAsked = false;

  bool notifyStudyReminders = true;
  bool notifyStreakAlerts = true;
  bool notifyMilestoneAlerts = true;
  bool notifyWeeklyReview = true;

  /// Hour of day for the daily "haven't studied" reminder (24h). Default 20 = 8 PM.
  int dailyReminderHour = 20;

  /// Minute of hour for the daily reminder. Default 0.
  int dailyReminderMinute = 0;

  // ── Weekly Review ─────────────────────────────────────────────────────────

  /// JSON map of week key → reflection note. e.g. {"2026_W14": "focus more on maths"}
  String weeklyNotesJson = '{}';

  /// The week key for which the weekly review was last auto-shown. e.g. "2026_W14"
  String lastReviewShownWeek = '';

  // ── Exam Mode ─────────────────────────────────────────────────────────────

  /// Whether Exam Mode is currently active.
  bool examModeActive = false;

  /// Start of the exam period (set when activating).
  DateTime? examModeStart;

  /// End of the exam period — last exam date.
  DateTime? examModeEnd;

  /// Daily study goal in minutes while in Exam Mode. Default 360 = 6 h.
  int examDailyGoalMinutes = 360;

  UserPrefsModel();
}
