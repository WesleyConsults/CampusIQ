import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/app.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/ai/domain/notification_scheduler.dart';
import 'package:campusiq/features/ai/domain/deepseek_client.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/streak/domain/streak_calculator.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/data/models/subscription_model.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/data/models/exam_model.dart';
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:campusiq/features/ai/data/models/ai_chat_session_model.dart';
import 'package:campusiq/features/ai/data/models/ai_usage_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';
import 'package:campusiq/features/ai/data/models/weekly_review_model.dart';

// ── Background task entry point ──────────────────────────────────────────────
// Must be a top-level function so Workmanager can call it in a separate isolate.

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case kStreakRiskTaskName:
        await _handleStreakRiskCheck();
        break;
    }
    return true;
  });
}

/// Runs in the Workmanager background isolate (no Riverpod / Flutter widgets).
/// Opens Isar, checks if user studied today, computes streak, calls DeepSeek
/// for a personalised message, then fires notification ID 200.
Future<void> _handleStreakRiskCheck() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      CourseModelSchema,
      TimetableSlotModelSchema,
      PersonalSlotModelSchema,
      StudySessionModelSchema,
      UserPrefsModelSchema,
      DailyPlanTaskModelSchema,
      ExamModelSchema,
      SubscriptionModelSchema,
      AiChatSessionModelSchema,
      AiMessageModelSchema,
      AiUsageModelSchema,
      StudyPlanModelSchema,
      StudyPlanSlotModelSchema,
      WeeklyReviewModelSchema,
    ],
    directory: dir.path,
  );

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
    final apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
    String body;
    if (apiKey.isNotEmpty) {
      try {
        final client = DeepSeekClient(
          apiKey: apiKey,
          model: dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-chat',
        );
        body = await client.complete(
          systemPrompt:
              'You write short motivational push notification messages.',
          messages: [
            {
              'role': 'user',
              'content':
                  'Write a 1-sentence motivational notification for a student '
                      'whose study streak of ${streak.currentStreak} days is at risk. '
                      "They haven't studied yet today. Be warm and direct. "
                      'No markdown. Under 15 words.',
            }
          ],
          maxTokens: 40,
        );
        body = body.trim();
      } catch (_) {
        body =
            "Your ${streak.currentStreak}-day streak ends at midnight — keep it alive!";
      }
    } else {
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
    await isar.close();
  }
}

// ── Main ─────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await NotificationService.instance.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  runApp(const ProviderScope(child: CampusIQApp()));
}
