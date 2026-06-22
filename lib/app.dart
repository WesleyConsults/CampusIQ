import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/router/app_router.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/core/services/notification_service.dart';

import 'package:campusiq/features/settings/presentation/providers/settings_provider.dart';
import 'package:campusiq/features/review/presentation/providers/review_provider.dart';
import 'package:campusiq/features/review/presentation/widgets/weekly_review_sheet.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/presentation/providers/course_reminder_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';

class CampusIQApp extends ConsumerStatefulWidget {
  const CampusIQApp({super.key});

  @override
  ConsumerState<CampusIQApp> createState() => _CampusIQAppState();
}

class _CampusIQAppState extends ConsumerState<CampusIQApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleNotifications();
      _maybeShowWeeklyReview();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleNotifications();
      _maybeShowWeeklyReview();
    }
  }

  Future<void> _maybeShowWeeklyReview() async {
    final now = DateTime.now();
    if (now.weekday != DateTime.monday) return;

    final navContext = appRouter.routerDelegate.navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;

    final currentRoute =
        appRouter.routerDelegate.currentConfiguration.uri.toString();
    if (currentRoute.contains('/import')) return;

    final prefsRepo = ref.read(userPrefsRepositoryProvider);
    if (prefsRepo == null) return;

    final prefs = await prefsRepo.getPrefs();
    final key = weekKey(_mondayOf(now));
    if (prefs.lastReviewShownWeek == key) return;

    // Wait for the first emission of sessions
    final sessions = await ref.read(allSessionsProvider.future);
    
    // Check if the user has study sessions logged in the past week
    final previousWeekStart = _mondayOf(now).subtract(const Duration(days: 7));
    final previousWeekEndInclusive = DateTime(
      previousWeekStart.year,
      previousWeekStart.month,
      previousWeekStart.day + 6,
      23,
      59,
      59,
    );

    final hasSessionsLastWeek = sessions.any((s) {
      return !s.startTime.isBefore(previousWeekStart) &&
          !s.startTime.isAfter(previousWeekEndInclusive);
    });

    if (!hasSessionsLastWeek) return;

    await prefsRepo.setLastReviewShownWeek(key);
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final currentNavContext = appRouter.routerDelegate.navigatorKey.currentContext;
    if (currentNavContext == null || !currentNavContext.mounted) return;

    showModalBottomSheet(
      context: currentNavContext,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WeeklyReviewSheet(),
    );
  }

  DateTime _mondayOf(DateTime date) {
    final d = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(d.year, d.month, d.day);
  }

  Future<void> _scheduleNotifications() async {
    final prefsRepo = ref.read(userPrefsRepositoryProvider);
    if (prefsRepo == null) return;

    final prefs = await prefsRepo.getPrefs();
    await AnalyticsService.instance.setCoreUserProperties(
      gradingSystem: prefs.gradingSystemId,
      themeMode: _themeModeKey(prefs.themeModeIndex),
      notificationsEnabled: prefs.notifyStudyReminders ||
          prefs.notifyStreakAlerts ||
          prefs.notifyMilestoneAlerts ||
          prefs.notifyWeeklyReview,
      onboardingCompleted: prefs.hasCompletedOnboarding,
      universitySet: (prefs.universityName ?? '').trim().isNotEmpty,
    );
    final streak = ref.read(studyStreakProvider);
    final now = DateTime.now();

    // Free block reminders
    if (prefs.notifyStudyReminders) {
      final todayIndex = now.weekday <= 6 ? now.weekday - 1 : 0;
      final allSlots = ref.read(allSlotsProvider).valueOrNull ?? [];
      final todaySlots =
          allSlots.where((s) => s.dayIndex == todayIndex).toList();
      final freeBlocks =
          FreeTimeDetector.detect(dayIndex: todayIndex, slots: todaySlots);
      try {
        await NotificationService.instance
            .scheduleFreeBlockReminders(freeBlocks);
      } catch (error, stackTrace) {
        await CrashReportingService.instance.recordNonFatalError(
          error,
          stackTrace,
          reason: 'free_block_notification_schedule_failed',
        );
      }

      // Daily "haven't studied" alert at user's chosen time
      try {
        await NotificationService.instance.scheduleHaventStudiedAlert(
          hour: prefs.dailyReminderHour,
          minute: prefs.dailyReminderMinute,
        );
      } catch (error, stackTrace) {
        await CrashReportingService.instance.recordNonFatalError(
          error,
          stackTrace,
          reason: 'daily_reminder_notification_schedule_failed',
        );
      }
    }

    try {
      await refreshCourseReminderNotifications(ref);
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'course_reminder_notification_schedule_failed',
      );
      // Course reminders are best-effort and should not block app startup.
    }

    // Streak at-risk alert
    if (prefs.notifyStreakAlerts && !streak.studiedToday) {
      try {
        await NotificationService.instance
            .scheduleStreakAtRiskAlert(streak.currentStreak);
      } catch (error, stackTrace) {
        await CrashReportingService.instance.recordNonFatalError(
          error,
          stackTrace,
          reason: 'streak_notification_schedule_failed',
        );
      }
    } else {
      await NotificationService.instance.cancelNotification(200);
    }

    // Milestone alert
    if (prefs.notifyMilestoneAlerts && streak.nextMilestone != null) {
      try {
        await NotificationService.instance.scheduleMilestoneAlert(
          streak.daysToNextMilestone,
          streak.nextMilestone!.days,
        );
      } catch (error, stackTrace) {
        await CrashReportingService.instance.recordNonFatalError(
          error,
          stackTrace,
          reason: 'milestone_notification_schedule_failed',
        );
      }
    }

    // Weekly review prompt — schedule on Mondays
    if (prefs.notifyWeeklyReview && now.weekday == DateTime.monday) {
      try {
        await NotificationService.instance.scheduleWeeklyReviewPrompt();
      } catch (error, stackTrace) {
        await CrashReportingService.instance.recordNonFatalError(
          error,
          stackTrace,
          reason: 'weekly_review_notification_schedule_failed',
        );
      }
    }
  }

  String _themeModeKey(int index) {
    switch (index) {
      case 1:
        return 'light';
      case 2:
        return 'dark';
      default:
        return 'system';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
