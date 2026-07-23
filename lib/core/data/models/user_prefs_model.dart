import 'package:isar_community/isar.dart';
import 'package:campusiq/core/constants/app_constants.dart';

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

  bool timetableLegacyNotificationsCleaned = false;
  DateTime? lastTimetableNotificationSyncAt;
  String lastTimetableNotificationSyncSummary = '';

  bool notifyStudyReminders = true;
  bool notifyStreakAlerts = true;
  bool notifyMilestoneAlerts = true;
  bool notifyWeeklyReview = true;

  /// Hour of day for the daily "haven't studied" reminder (24h). Default 20 = 8 PM.
  int dailyReminderHour = 20;

  /// Minute of hour for the daily reminder. Default 0.
  int dailyReminderMinute = 0;

  // ── CWA preferences ───────────────────────────────────────────────────────

  /// Current working semester used by semester-scoped features.
  @Name('zzActiveSemesterKey')
  String activeSemesterKey = AppConstants.defaultSemesterKey;

  /// Student's desired CWA target used by projected and cumulative gap views.
  @Name('zzTargetCwa')
  double targetCwa = AppConstants.distinctionThreshold;

  /// Whether the student has explicitly confirmed the target from the guided
  /// CWA setup screen. Onboarding's initial target does not complete this step.
  @Name('zzCwaSetupTargetConfirmed')
  bool cwaSetupTargetConfirmed = false;

  /// JSON snapshot of the in-progress CWA manual entry form.
  @Name('zzManualCwaDraftJson')
  String manualCwaDraftJson = '';

  /// Optional manually entered cumulative score used when past results have not
  /// been imported yet.
  @Name('zzzManualBaselineCwa')
  double? manualBaselineCwa;

  /// Completed credits paired with [manualBaselineCwa].
  @Name('zzzManualBaselineCredits')
  double? manualBaselineCredits;

  /// Grading system used when [manualBaselineCwa] was entered.
  @Name('zzzManualBaselineGradingSystemId')
  String? manualBaselineGradingSystemId;

  /// Selected grading system for new academic records.
  @Name('zzGradingSystemId')
  String gradingSystemId = 'cwa';

  // ── Onboarding ─────────────────────────────────────────────────────────────

  /// Whether the student has completed the first-run onboarding flow.
  @Name('zzHasCompletedOnboarding')
  bool hasCompletedOnboarding = false;

  /// Last onboarding page reached. Uses the stable [OnboardingStep] index.
  @Name('zzOnboardingStepIndex')
  int onboardingStepIndex = 0;

  /// Optional setup shortcut selected on the final onboarding page.
  /// -1 means no shortcut was selected.
  @Name('zzOnboardingStartActionIndex')
  int onboardingStartActionIndex = -1;

  /// The university the student attends (e.g. "KNUST", "University of Ghana").
  @Name('zzUniversityName')
  String? universityName;

  /// The programme the student is enrolled in (e.g. "BSc Computer Engineering").
  @Name('zzProgrammeName')
  String? programmeName;

  /// Whether the one-time welcome entrance on the first Home visit has played.
  @Name('zzHasSeenInitialHomeWelcome')
  bool hasSeenInitialHomeWelcome = false;

  // ── Pomodoro defaults ──────────────────────────────────────────────────────

  @Name('zzPomodoroFocusMinutes')
  int defaultFocusMinutes = 25;

  @Name('zzPomodoroShortBreakMinutes')
  int defaultShortBreakMinutes = 5;

  @Name('zzPomodoroLongBreakMinutes')
  int defaultLongBreakMinutes = 15;

  @Name('zzPomodoroTotalRounds')
  int defaultTotalRounds = 4;

  // ── Timer feedback ────────────────────────────────────────────────────────

  @Name('zzVibrateOnTimerEnd')
  bool vibrateOnTimerEnd = true;

  @Name('zzSoundOnTimerEnd')
  bool playSoundOnTimerEnd = true;

  // ── Appearance ────────────────────────────────────────────────────────────

  /// 0 = system, 1 = light, 2 = dark
  @Name('zzThemeModeIndex')
  int themeModeIndex = 0;

  /// Timetable grid layout orientation: 0 = Daily Grid (Vertical), 1 = Weekly Grid (Horizontal)
  @Name('zzTimetableGridLayoutIndex')
  int timetableGridLayoutIndex = 0;

  // ── Weekly Review ─────────────────────────────────────────────────────────

  /// JSON map of week key → reflection note. e.g. {"2026_W14": "focus more on maths"}
  String weeklyNotesJson = '{}';

  /// The week key for which the weekly review was last auto-shown. e.g. "2026_W14"
  String lastReviewShownWeek = '';

  UserPrefsModel();
}
