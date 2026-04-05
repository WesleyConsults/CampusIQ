import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      CourseModelSchema,
      TimetableSlotModelSchema,
      PersonalSlotModelSchema,
      StudySessionModelSchema,
      UserPrefsModelSchema,
    ],
    directory: dir.path,
  );
});
