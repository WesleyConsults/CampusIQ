import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/domain/university_defaults.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';

enum OnboardingStep {
  welcome,
  about,
  university,
  target,
  notifications,
  gradesImport,
}

enum OnboardingStartAction {
  importCourses,
  importPastResults,
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
  final bool isRestoring;

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
    this.isRestoring = false,
  });

  factory OnboardingState.fromPrefs(UserPrefsModel prefs) {
    final savedStepIndex = prefs.onboardingStepIndex;
    final stepIndex =
        savedStepIndex >= 0 && savedStepIndex < OnboardingStep.values.length
            ? savedStepIndex
            : 0;
    final actionIndex = prefs.onboardingStartActionIndex;
    final startAction =
        actionIndex >= 0 && actionIndex < OnboardingStartAction.values.length
            ? OnboardingStartAction.values[actionIndex]
            : null;
    final savedUniversity = prefs.universityName?.trim();

    return OnboardingState(
      step: OnboardingStep.values[stepIndex],
      university: savedUniversity == null || savedUniversity.isEmpty
          ? null
          : universityByName(savedUniversity),
      programme: prefs.programmeName ?? '',
      gradingSystemId: GradingSystem.byId(prefs.gradingSystemId).id,
      target: prefs.targetCwa,
      startAction: startAction,
      notifyStudyReminders: prefs.notifyStudyReminders,
      notifyStreakAlerts: prefs.notifyStreakAlerts,
      notifyMilestoneAlerts: prefs.notifyMilestoneAlerts,
      notifyWeeklyReview: prefs.notifyWeeklyReview,
    );
  }

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
    bool? isRestoring,
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
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }

  GradingSystem get gradingSystem => GradingSystem.byId(gradingSystemId);

  bool get canAdvance {
    switch (step) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.about:
        return true;
      case OnboardingStep.university:
        return university != null;
      case OnboardingStep.target:
        return true;
      case OnboardingStep.gradesImport:
        return true;
      case OnboardingStep.notifications:
        return true;
    }
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final UserPrefsRepository _repo;
  final Ref _ref;
  Future<void> _persistenceQueue = Future<void>.value();

  OnboardingNotifier(this._repo, this._ref)
      : super(const OnboardingState(isRestoring: true)) {
    unawaited(AnalyticsService.instance.logOnboardingStarted());
    unawaited(_restoreProgress());
  }

  Future<void> goNext() async {
    if (!state.canAdvance) return;
    const steps = OnboardingStep.values;
    final currentIdx = steps.indexOf(state.step);
    if (currentIdx < steps.length - 1) {
      state = state.copyWith(step: steps[currentIdx + 1]);
      _queueProgressSave();
      await _persistenceQueue;
    }
  }

  Future<void> goBack() async {
    const steps = OnboardingStep.values;
    final currentIdx = steps.indexOf(state.step);
    if (currentIdx > 0) {
      state = state.copyWith(step: steps[currentIdx - 1]);
      _queueProgressSave();
      await _persistenceQueue;
    }
  }

  void setUniversity(University uni) {
    final system = uni.gradingSystem;
    state = state.copyWith(
      university: uni,
      gradingSystemId: system.id,
      target: system.defaultTarget,
    );
    _queueProgressSave();
  }

  void setProgramme(String programme) {
    state = state.copyWith(programme: programme);
    _queueProgressSave();
  }

  void setGradingSystemId(String id) {
    final system = GradingSystem.byId(id);
    state = state.copyWith(
      gradingSystemId: system.id,
      target: system.defaultTarget,
    );
    unawaited(AnalyticsService.instance.logGradingSystemSelected(system.id));
    _queueProgressSave();
  }

  void setTarget(double target) {
    state = state.copyWith(target: target);
    _queueProgressSave();
  }

  void setStartAction(OnboardingStartAction action) {
    state = state.copyWith(startAction: action);
    unawaited(
      AnalyticsService.instance.logOnboardingSetupChoice(action.name),
    );
    _queueProgressSave();
  }

  void clearStartAction() {
    state = state.copyWith(startAction: null);
    unawaited(
      AnalyticsService.instance.logOnboardingSetupChoice('skip_for_now'),
    );
    _queueProgressSave();
  }

  void toggleStartAction(OnboardingStartAction action) {
    state = state.copyWith(
      startAction: state.startAction == action ? null : action,
    );
    _queueProgressSave();
  }

  void setNotifyStudyReminders(bool v) {
    state = state.copyWith(notifyStudyReminders: v);
    _queueProgressSave();
  }

  void setNotifyStreakAlerts(bool v) {
    state = state.copyWith(notifyStreakAlerts: v);
    _queueProgressSave();
  }

  void setNotifyMilestoneAlerts(bool v) {
    state = state.copyWith(notifyMilestoneAlerts: v);
    _queueProgressSave();
  }

  void setNotifyWeeklyReview(bool v) {
    state = state.copyWith(notifyWeeklyReview: v);
    _queueProgressSave();
  }

  Future<void> skip() async {
    state = state.copyWith(isLoading: true);
    try {
      await _persistenceQueue;
      await _repo.setHasCompletedOnboarding(true);
      await _repo.clearOnboardingProgress();
      _ref.read(onboardingCompletedProvider.notifier).state = true;
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
      await _persistenceQueue;
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
      await _repo.clearOnboardingProgress();
      _ref.read(onboardingCompletedProvider.notifier).state = true;
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

  Future<void> _restoreProgress() async {
    try {
      final prefs = await _repo.getPrefs();
      if (prefs.hasCompletedOnboarding) {
        if (mounted) state = state.copyWith(isRestoring: false);
        return;
      }

      if (!mounted) return;
      state = OnboardingState.fromPrefs(prefs);
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'onboarding_progress_restore_failed',
      );
      if (mounted) {
        state = const OnboardingState(isRestoring: false);
      }
    }
  }

  void _queueProgressSave() {
    _persistenceQueue = _persistenceQueue.then((_) => _persistProgress());
  }

  Future<void> _persistProgress() async {
    final snapshot = state;
    if (snapshot.isRestoring) return;
    try {
      await _repo.saveOnboardingProgress(
        stepIndex: snapshot.step.index,
        universityName: snapshot.university?.name,
        programmeName: snapshot.programme,
        gradingSystemId: snapshot.gradingSystemId,
        target: snapshot.target,
        startActionIndex: snapshot.startAction?.index ?? -1,
        notifyStudyReminders: snapshot.notifyStudyReminders,
        notifyStreakAlerts: snapshot.notifyStreakAlerts,
        notifyMilestoneAlerts: snapshot.notifyMilestoneAlerts,
        notifyWeeklyReview: snapshot.notifyWeeklyReview,
      );
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'onboarding_progress_save_failed',
        context: {'step': snapshot.step.name},
      );
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) {
    final isarAsync = ref.watch(isarProvider);
    final isar = isarAsync.requireValue;
    final repo = UserPrefsRepository(isar);
    return OnboardingNotifier(repo, ref);
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

final onboardingCompletedProvider = StateProvider<bool?>((ref) {
  final streamVal = ref.watch(hasCompletedOnboardingProvider).valueOrNull;
  return streamVal;
});
