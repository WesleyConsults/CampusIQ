import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/router/app_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/review/presentation/providers/review_provider.dart';
import 'package:campusiq/features/review/presentation/widgets/weekly_review_sheet.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

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

    final prefsRepo = ref.read(userPrefsRepositoryProvider);
    if (prefsRepo == null) return;

    final prefs = await prefsRepo.getPrefs();
    final key = weekKey(_mondayOf(now));
    if (prefs.lastReviewShownWeek == key) return;

    await prefsRepo.setLastReviewShownWeek(key);
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final navContext = appRouter.routerDelegate.navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;

    showModalBottomSheet(
      context: navContext,
      isScrollControlled: true,
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
      await NotificationService.instance
          .scheduleFreeBlockReminders(freeBlocks);

      // Daily "haven't studied" alert at user's chosen time
      await NotificationService.instance.scheduleHaventStudiedAlert(
        hour: prefs.dailyReminderHour,
        minute: prefs.dailyReminderMinute,
      );
    }

    // Streak at-risk alert
    if (prefs.notifyStreakAlerts && !streak.studiedToday) {
      await NotificationService.instance
          .scheduleStreakAtRiskAlert(streak.currentStreak);
    } else {
      await NotificationService.instance.cancelNotification(200);
    }

    // Milestone alert
    if (prefs.notifyMilestoneAlerts && streak.nextMilestone != null) {
      await NotificationService.instance.scheduleMilestoneAlert(
        streak.daysToNextMilestone,
        streak.nextMilestone!.days,
      );
    }

    // Weekly review prompt — schedule on Mondays
    if (prefs.notifyWeeklyReview && now.weekday == DateTime.monday) {
      await NotificationService.instance.scheduleWeeklyReviewPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
