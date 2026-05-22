import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/domain/university_defaults.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';

enum OnboardingStep {
  welcome,
  university,
  target,
  gradesImport,
  timetableImport,
  notifications,
}

enum OnboardingStartAction {
  importCourses,
  addTimetable,
}

const _unset = Object();

class OnboardingState {
  final OnboardingStep step;
  final University? university;
  final String programme;
  final String gradingSystemId;
  final double target;
  final OnboardingStartAction? startAction;
  final bool notifyStudyReminders;
  final bool notifyStreakAlerts;
  final bool notifyMilestoneAlerts;
  final bool notifyWeeklyReview;
  final bool isLoading;

  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.university,
    this.programme = '',
    this.gradingSystemId = 'cwa',
    this.target = 70,
    this.startAction,
    this.notifyStudyReminders = true,
    this.notifyStreakAlerts = true,
    this.notifyMilestoneAlerts = true,
    this.notifyWeeklyReview = true,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    OnboardingStep? step,
    University? university,
    String? programme,
    String? gradingSystemId,
    double? target,
    Object? startAction = _unset,
    bool? notifyStudyReminders,
    bool? notifyStreakAlerts,
    bool? notifyMilestoneAlerts,
    bool? notifyWeeklyReview,
    bool? isLoading,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      university: university ?? this.university,
      programme: programme ?? this.programme,
      gradingSystemId: gradingSystemId ?? this.gradingSystemId,
      target: target ?? this.target,
      startAction: startAction == _unset
          ? this.startAction
          : startAction as OnboardingStartAction?,
      notifyStudyReminders: notifyStudyReminders ?? this.notifyStudyReminders,
      notifyStreakAlerts: notifyStreakAlerts ?? this.notifyStreakAlerts,
      notifyMilestoneAlerts:
          notifyMilestoneAlerts ?? this.notifyMilestoneAlerts,
      notifyWeeklyReview: notifyWeeklyReview ?? this.notifyWeeklyReview,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  GradingSystem get gradingSystem => GradingSystem.byId(gradingSystemId);

  bool get canAdvance {
    switch (step) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.university:
        return university != null;
      case OnboardingStep.target:
        return true;
      case OnboardingStep.gradesImport:
        return true;
      case OnboardingStep.timetableImport:
        return true;
      case OnboardingStep.notifications:
        return true;
    }
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final UserPrefsRepository _repo;

  OnboardingNotifier(this._repo) : super(const OnboardingState()) {
    unawaited(AnalyticsService.instance.logOnboardingStarted());
  }

  void goNext() {
    if (!state.canAdvance) return;
    const steps = OnboardingStep.values;
    final currentIdx = steps.indexOf(state.step);
    if (currentIdx < steps.length - 1) {
      state = state.copyWith(step: steps[currentIdx + 1]);
    }
  }

  void goBack() {
    const steps = OnboardingStep.values;
    final currentIdx = steps.indexOf(state.step);
    if (currentIdx > 0) {
      state = state.copyWith(step: steps[currentIdx - 1]);
    }
  }

  void setUniversity(University uni) {
    final system = uni.gradingSystem;
    state = state.copyWith(
      university: uni,
      gradingSystemId: system.id,
      target: system.defaultTarget,
    );
  }

  void setProgramme(String programme) {
    state = state.copyWith(programme: programme);
  }

  void setGradingSystemId(String id) {
    final system = GradingSystem.byId(id);
    state = state.copyWith(
      gradingSystemId: system.id,
      target: system.defaultTarget,
    );
    unawaited(AnalyticsService.instance.logGradingSystemSelected(system.id));
  }

  void setTarget(double target) {
    state = state.copyWith(target: target);
  }

  void setStartAction(OnboardingStartAction action) {
    state = state.copyWith(startAction: action);
  }

  void toggleStartAction(OnboardingStartAction action) {
    state = state.copyWith(
      startAction: state.startAction == action ? null : action,
    );
  }

  void setNotifyStudyReminders(bool v) {
    state = state.copyWith(notifyStudyReminders: v);
  }

  void setNotifyStreakAlerts(bool v) {
    state = state.copyWith(notifyStreakAlerts: v);
  }

  void setNotifyMilestoneAlerts(bool v) {
    state = state.copyWith(notifyMilestoneAlerts: v);
  }

  void setNotifyWeeklyReview(bool v) {
    state = state.copyWith(notifyWeeklyReview: v);
  }

  Future<void> skip() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.setHasCompletedOnboarding(true);
      await AnalyticsService.instance.logOnboardingCompleted(
        gradingSystem: state.gradingSystemId,
        universitySet: state.university != null,
        notificationsEnabled: state.notifyStudyReminders ||
            state.notifyStreakAlerts ||
            state.notifyMilestoneAlerts ||
            state.notifyWeeklyReview,
        skipped: true,
      );
      await AnalyticsService.instance.setCoreUserProperties(
        gradingSystem: state.gradingSystemId,
        notificationsEnabled: state.notifyStudyReminders ||
            state.notifyStreakAlerts ||
            state.notifyMilestoneAlerts ||
            state.notifyWeeklyReview,
        onboardingCompleted: true,
        universitySet: state.university != null,
      );
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'onboarding_skip_failed',
      );
      rethrow;
    }
  }

  Future<void> complete() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.setUniversityName(state.university?.name);
      await _repo.setProgrammeName(
        state.programme.trim().isEmpty ? null : state.programme.trim(),
      );
      await _repo.setGradingSystemId(state.gradingSystemId);
      await _repo.setTargetCwa(state.target);
      await _repo.setNotifyStudyReminders(state.notifyStudyReminders);
      await _repo.setNotifyStreakAlerts(state.notifyStreakAlerts);
      await _repo.setNotifyMilestoneAlerts(state.notifyMilestoneAlerts);
      await _repo.setNotifyWeeklyReview(state.notifyWeeklyReview);
      await _repo.setHasCompletedOnboarding(true);
      await AnalyticsService.instance.logOnboardingCompleted(
        gradingSystem: state.gradingSystemId,
        universitySet: state.university != null,
        notificationsEnabled: state.notifyStudyReminders ||
            state.notifyStreakAlerts ||
            state.notifyMilestoneAlerts ||
            state.notifyWeeklyReview,
        skipped: false,
      );
      await AnalyticsService.instance.setCoreUserProperties(
        gradingSystem: state.gradingSystemId,
        notificationsEnabled: state.notifyStudyReminders ||
            state.notifyStreakAlerts ||
            state.notifyMilestoneAlerts ||
            state.notifyWeeklyReview,
        onboardingCompleted: true,
        universitySet: state.university != null,
      );
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'onboarding_complete_failed',
      );
      rethrow;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) {
    final isarAsync = ref.watch(isarProvider);
    final isar = isarAsync.requireValue;
    final repo = UserPrefsRepository(isar);
    return OnboardingNotifier(repo);
  },
);

/// Watches the onboarding-completed flag for GoRouter redirect guard.
final hasCompletedOnboardingProvider = StreamProvider<bool>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  final repo = UserPrefsRepository(isar);
  await repo.getPrefs();

  await for (final prefs in repo.watchPrefs()) {
    yield prefs?.hasCompletedOnboarding ?? false;
  }
});
