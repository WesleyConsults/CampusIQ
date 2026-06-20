import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
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
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
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
  CourseReminderModelSchema,
];

const _isarOpenRetryDelays = [
  Duration(milliseconds: 100),
  Duration(milliseconds: 250),
  Duration(milliseconds: 500),
];

class CampusIqIsarHandle {
  const CampusIqIsarHandle({
    required this.isar,
    required this.shouldClose,
  });

  final Isar isar;
  final bool shouldClose;
}

Future<Isar> openCampusIqIsar() async {
  final handle = await openCampusIqIsarHandle();
  return handle.isar;
}

Future<CampusIqIsarHandle> openCampusIqIsarHandle() async {
  final existing = Isar.getInstance();
  if (existing != null) {
    return CampusIqIsarHandle(isar: existing, shouldClose: false);
  }

  final dir = await getApplicationDocumentsDirectory();

  Object? lastError;
  StackTrace? lastStackTrace;

  for (var attempt = 0; attempt <= _isarOpenRetryDelays.length; attempt++) {
    try {
      final isar = await Isar.open(
        kCampusIqIsarSchemas,
        directory: dir.path,
      );
      return CampusIqIsarHandle(isar: isar, shouldClose: true);
    } catch (error, stackTrace) {
      lastError = error;
      lastStackTrace = stackTrace;

      final canRetry =
          attempt < _isarOpenRetryDelays.length && _isMdbxTryAgain(error);
      if (!canRetry) break;

      await Future<void>.delayed(_isarOpenRetryDelays[attempt]);
    }
  }

  final error = lastError!;
  final stackTrace = lastStackTrace!;

  debugPrint('🔴 Failed to open Isar: $error');
  debugPrint('$stackTrace');
  await CrashReportingService.instance.recordNonFatalError(
    error,
    stackTrace,
    reason: 'isar_open_failed',
  );
  Error.throwWithStackTrace(error, stackTrace);
}

bool _isMdbxTryAgain(Object error) {
  if (error is! IsarError) return false;
  return error.toString().contains('MdbxError (11): Try again');
}
