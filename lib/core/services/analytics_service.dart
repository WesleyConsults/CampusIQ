import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  Future<void> logScreenView(String screenName) async {
    await _guard(
      () => _analytics.logScreenView(screenName: screenName),
      'logScreenView:$screenName',
    );
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _guard(
      () => _analytics.logEvent(
        name: name,
        parameters: parameters,
      ),
      'logEvent:$name',
    );
  }

  Future<void> setUserProperty(String name, String? value) async {
    await _guard(
      () => _analytics.setUserProperty(name: name, value: value),
      'setUserProperty:$name',
    );
  }

  Future<void> setCoreUserProperties({
    String? gradingSystem,
    String? themeMode,
    bool? notificationsEnabled,
    bool? onboardingCompleted,
    bool? universitySet,
  }) async {
    final futures = <Future<void>>[];
    if (gradingSystem != null) {
      futures.add(setUserProperty('grading_system', gradingSystem));
    }
    if (themeMode != null) {
      futures.add(setUserProperty('theme_mode', themeMode));
    }
    if (notificationsEnabled != null) {
      futures.add(setUserProperty(
        'notifications_enabled',
        notificationsEnabled.toString(),
      ));
    }
    if (onboardingCompleted != null) {
      futures.add(setUserProperty(
        'onboarding_completed',
        onboardingCompleted.toString(),
      ));
    }
    if (universitySet != null) {
      futures.add(setUserProperty('university_set', universitySet.toString()));
    }
    await Future.wait(futures);
  }

  Future<void> logOnboardingStarted() => logEvent('onboarding_started');

  Future<void> logOnboardingSetupChoice(String choice) => logEvent(
        'onboarding_setup_choice',
        parameters: {'choice': choice},
      );

  Future<void> logOnboardingCompleted({
    required String gradingSystem,
    required bool universitySet,
    required bool notificationsEnabled,
    required bool skipped,
  }) =>
      logEvent(
        skipped ? 'onboarding_skipped' : 'onboarding_completed',
        parameters: {
          'grading_system': gradingSystem,
          'university_set': universitySet.toString(),
          'notifications_enabled': notificationsEnabled.toString(),
        },
      );

  Future<void> logGradingSystemSelected(String gradingSystem) => logEvent(
        'grading_system_selected',
        parameters: {'grading_system': gradingSystem},
      );

  Future<void> logThemeChanged(String themeMode) => logEvent(
        'settings_theme_changed',
        parameters: {'theme_mode': themeMode},
      );

  Future<void> logCourseSaved({
    required String action,
    required String source,
    required String gradingSystem,
    int? count,
  }) =>
      logEvent(
        action == 'created' ? 'course_added' : 'course_updated',
        parameters: {
          'action': action,
          'source': source,
          'grading_system': gradingSystem,
          if (count != null) 'count': count,
        },
      );

  Future<void> logCourseImportStarted({
    required String importType,
    required String source,
  }) =>
      logEvent(
        'course_import_started',
        parameters: {
          'import_type': importType,
          'source': source,
        },
      );

  Future<void> logCourseImportSucceeded({
    required String importType,
    required String source,
    required int count,
    required int skippedCount,
  }) =>
      logEvent(
        'course_import_succeeded',
        parameters: {
          'import_type': importType,
          'source': source,
          'count': count,
          'skipped_count': skippedCount,
        },
      );

  Future<void> logCourseImportFailed({
    required String importType,
    required String source,
    required String reason,
  }) =>
      logEvent(
        'course_import_failed',
        parameters: {
          'import_type': importType,
          'source': source,
          'reason': reason,
        },
      );

  Future<void> logImportAbandoned({
    required String importType,
    required String step,
  }) =>
      logEvent(
        'import_abandoned',
        parameters: {'import_type': importType, 'step': step},
      );

  Future<void> logDocumentTypeMismatch({
    required String expectedType,
    required String detectedType,
  }) =>
      logEvent(
        'document_type_mismatch',
        parameters: {
          'expected_type': expectedType,
          'detected_type': detectedType,
        },
      );

  Future<void> logFeedbackOpened() => logEvent('feedback_opened');

  Future<void> logFeedbackPrepared({required String category}) => logEvent(
        'feedback_prepared',
        parameters: {'category': category},
      );

  Future<void> logTimetableSlotSaved({required String action}) => logEvent(
        action == 'created' ? 'timetable_slot_added' : 'timetable_slot_updated',
        parameters: {'action': action},
      );

  Future<void> logTimetableImportStarted({required String source}) => logEvent(
        'timetable_import_started',
        parameters: {'source': source},
      );

  Future<void> logTimetableImportSucceeded({
    required String source,
    required int count,
  }) =>
      logEvent(
        'timetable_import_succeeded',
        parameters: {'source': source, 'count': count},
      );

  Future<void> logTimetableImportFailed({
    required String source,
    required String reason,
  }) =>
      logEvent(
        'timetable_import_failed',
        parameters: {'source': source, 'reason': reason},
      );

  Future<void> logInitialHomeViewed({required int completedStepCount}) =>
      logEvent(
        'initial_home_viewed',
        parameters: {'completed_step_count': completedStepCount},
      );

  Future<void> logHomeSetupAction({
    required String eventName,
    required String action,
    required int completedStepCount,
    required String destination,
  }) =>
      logEvent(
        eventName,
        parameters: {
          'action': action,
          'completed_step_count': completedStepCount,
          'destination': destination,
        },
      );

  Future<void> logStudySessionStarted({
    required String mode,
    required String source,
  }) =>
      logEvent(
        mode == 'pomodoro' ? 'pomodoro_started' : 'study_session_started',
        parameters: {'mode': mode, 'source': source},
      );

  Future<void> logStudySessionCompleted({
    required String mode,
    required int durationMinutes,
    required bool wasPlanned,
    int? roundsCompleted,
  }) =>
      logEvent(
        mode == 'pomodoro' ? 'pomodoro_completed' : 'study_session_completed',
        parameters: {
          'mode': mode,
          'duration_minutes': durationMinutes,
          'was_planned': wasPlanned.toString(),
          if (roundsCompleted != null) 'rounds_completed': roundsCompleted,
        },
      );

  Future<void> logAiGenerationSucceeded({
    required String feature,
    int? itemCount,
  }) =>
      logEvent(
        '${feature}_generated',
        parameters: {if (itemCount != null) 'item_count': itemCount},
      );

  Future<void> logAiGenerationFailed({
    required String feature,
    required String reason,
  }) =>
      logEvent(
        '${feature}_failed',
        parameters: {'reason': reason},
      );

  Future<void> _guard(
    Future<void> Function() action,
    String label,
  ) async {
    try {
      if (Firebase.apps.isEmpty) return;
      await action();
    } catch (error) {
      debugPrint('AnalyticsService $label failed: $error');
    }
  }
}

class TrackedScreen extends StatefulWidget {
  final String screenName;
  final Widget child;

  const TrackedScreen({
    super.key,
    required this.screenName,
    required this.child,
  });

  @override
  State<TrackedScreen> createState() => _TrackedScreenState();
}

class _TrackedScreenState extends State<TrackedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.instance.logScreenView(widget.screenName);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
