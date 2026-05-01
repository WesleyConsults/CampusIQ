import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/data/models/subscription_model.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';

import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:campusiq/features/ai/data/models/ai_chat_session_model.dart';
import 'package:campusiq/features/ai/data/models/ai_usage_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';
import 'package:campusiq/features/ai/data/models/weekly_review_model.dart';
import 'package:campusiq/features/course_hub/data/models/course_note_model.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      CourseModelSchema,
      PastSemesterModelSchema,
      TimetableSlotModelSchema,

      StudySessionModelSchema,
      UserPrefsModelSchema,
      DailyPlanTaskModelSchema,

      SubscriptionModelSchema,
      AiChatSessionModelSchema,
      AiMessageModelSchema,
      AiUsageModelSchema,
      StudyPlanModelSchema,
      StudyPlanSlotModelSchema,
      WeeklyReviewModelSchema,
      CourseNoteModelSchema,
    ],
    directory: dir.path,
  );
});
