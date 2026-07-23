import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores the saved onboarding step and partial choices', () {
    final prefs = UserPrefsModel()
      ..onboardingStepIndex = OnboardingStep.notifications.index
      ..onboardingStartActionIndex =
          OnboardingStartAction.importPastResults.index
      ..universityName = 'University of Ghana'
      ..programmeName = 'BSc Computer Science'
      ..gradingSystemId = 'gpa_4pt'
      ..targetCwa = 3.6
      ..notifyStudyReminders = false
      ..notifyStreakAlerts = true
      ..notifyMilestoneAlerts = false
      ..notifyWeeklyReview = true;

    final restored = OnboardingState.fromPrefs(prefs);

    expect(restored.step, OnboardingStep.notifications);
    expect(restored.startAction, OnboardingStartAction.importPastResults);
    expect(restored.university?.abbreviation, 'UG');
    expect(restored.programme, 'BSc Computer Science');
    expect(restored.gradingSystemId, 'gpa_4pt');
    expect(restored.target, 3.6);
    expect(restored.notifyStudyReminders, isFalse);
    expect(restored.notifyMilestoneAlerts, isFalse);
    expect(restored.isRestoring, isFalse);
  });

  test('invalid persisted indexes safely fall back to welcome', () {
    final prefs = UserPrefsModel()
      ..onboardingStepIndex = 999
      ..onboardingStartActionIndex = 999;

    final restored = OnboardingState.fromPrefs(prefs);

    expect(restored.step, OnboardingStep.welcome);
    expect(restored.startAction, isNull);
  });
}
