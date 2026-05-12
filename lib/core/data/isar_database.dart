import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/core/data/models/subscription_model.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';
import 'package:campusiq/features/ai/data/models/weekly_review_model.dart';
import 'package:campusiq/features/course_hub/data/models/course_note_model.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

const List<CollectionSchema<dynamic>> kCampusIqIsarSchemas = [
  CourseModelSchema,
  PastSemesterModelSchema,
  TimetableSlotModelSchema,
  StudySessionModelSchema,
  UserPrefsModelSchema,
  DailyPlanTaskModelSchema,
  SubscriptionModelSchema,
  StudyPlanModelSchema,
  StudyPlanSlotModelSchema,
  WeeklyReviewModelSchema,
  CourseNoteModelSchema,
];

Future<Isar> openCampusIqIsar() async {
  final dir = await getApplicationDocumentsDirectory();

  try {
    return await Isar.open(
      kCampusIqIsarSchemas,
      directory: dir.path,
    );
  } catch (error, stackTrace) {
    debugPrint('🔴 Failed to open Isar: $error');
    debugPrint('$stackTrace');
    Error.throwWithStackTrace(error, stackTrace);
  }
}
