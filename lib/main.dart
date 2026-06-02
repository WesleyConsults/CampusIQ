import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';
import 'package:campusiq/app.dart';
import 'package:campusiq/core/data/isar_database.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/ai/domain/notification_scheduler.dart';
import 'package:campusiq/features/ai/domain/deepseek_client.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/streak/domain/streak_calculator.dart';
import 'package:campusiq/firebase_options.dart';

// ── Background task entry point ──────────────────────────────────────────────
// Must be a top-level function so Workmanager can call it in a separate isolate.

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    try {
      switch (taskName) {
        case kStreakRiskTaskName:
          await _handleStreakRiskCheck();
          break;
      }
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'workmanager_task_failed',
        context: {'task_name': taskName},
      );
    }
    return true;
  });
}

/// Runs in the Workmanager background isolate (no Riverpod / Flutter widgets).
/// Opens Isar, checks if user studied today, computes streak, calls DeepSeek
/// for a personalised message, then fires notification ID 200.
Future<void> _handleStreakRiskCheck() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarHandle = await openCampusIqIsarHandle();
  final isar = isarHandle.isar;

  try {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Skip if user already has a session today — streak is safe
    final todaySessions = await isar.studySessionModels
        .filter()
        .startTimeBetween(todayStart, todayEnd)
        .findAll();
    if (todaySessions.isNotEmpty) return;

    // Calculate current streak from all sessions
    final allSessions = await isar.studySessionModels.where().findAll();
    final streak = StreakCalculator.calculate(
      activeDates: allSessions.map((s) => s.startTime).toList(),
    );
    if (streak.currentStreak <= 0) return;

    // Ask DeepSeek for a personalised 1-sentence motivational message
    String body;
    try {
      const client = DeepSeekClient();
      body = await client.complete(
        systemPrompt:
            'You write short motivational push notification messages.',
        messages: [
          {
            'role': 'user',
            'content': 'Write a 1-sentence motivational notification for a student '
                'whose study streak of ${streak.currentStreak} days is at risk. '
                "They haven't studied yet today. Be warm and direct. "
                'No markdown. Under 15 words.',
          }
        ],
        maxTokens: 40,
      );
      body = body.trim();
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'streak_notification_ai_failed',
      );
      body =
          "Your ${streak.currentStreak}-day streak ends at midnight — keep it alive!";
    }

    await NotificationService.instance.init();
    await NotificationService.instance.showImmediate(
      id: 200,
      title: 'Streak at risk 🔥',
      body: body,
      channelId: 'streak_alert',
      channelName: 'Streak Alerts',
    );
  } finally {
    if (isarHandle.shouldClose) {
      await isar.close();
    }
  }
}

// ── Main ─────────────────────────────────────────────────────────────────────

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    FlutterError.onError = (details) {
      unawaited(
        CrashReportingService.instance.recordFlutterFatalError(details),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        CrashReportingService.instance.recordFatalError(
          error,
          stack,
          reason: 'platform_dispatcher_error',
        ),
      );
      return true;
    };

    await NotificationService.instance.init();
    await Workmanager().initialize(callbackDispatcher);
    await NotificationScheduler.scheduleStreakRiskCheck();

    runApp(const ProviderScope(child: CampusIQApp()));
  }, (error, stackTrace) {
    debugPrint('🔴 UNCAUGHT ERROR: $error');
    debugPrint('$stackTrace');
    unawaited(
      CrashReportingService.instance.recordFatalError(
        error,
        stackTrace,
        reason: 'run_zoned_guarded_error',
      ),
    );
  });
}
