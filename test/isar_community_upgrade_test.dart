import 'dart:ffi';
import 'dart:io';

import 'package:campusiq/core/data/isar_database.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  const fixturePath = 'test/fixtures/isar_v13/default.isar';

  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: {
        Abi.current():
            '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/'
            'isar_community_flutter_libs-3.3.0-dev.1/macos/libisar.dylib',
      },
    );
  });

  test('opens and updates the version-13 Isar database without data loss',
      () async {
    final testDirectory =
        await Directory.systemTemp.createTemp('campusiq_isar_upgrade_');
    addTearDown(() => testDirectory.deleteSync(recursive: true));

    File(fixturePath).copySync('${testDirectory.path}/default.isar');

    var isar = await Isar.open(
      kCampusIqIsarSchemas,
      directory: testDirectory.path,
      name: 'default',
    );

    final course = await isar.courseModels.get(101);
    expect(course, isNotNull);
    expect(course!.code, 'MATH 151');
    expect(course.expectedScore, 82);

    final semester = await isar.pastSemesterModels.get(202);
    expect(semester, isNotNull);
    expect(semester!.semesterKey, '2025-Sem2');
    expect(semester.courses.single.courseCode, 'CS 101');
    expect(semester.courses.single.mark, 84);

    final slot = await isar.timetableSlotModels.get(303);
    expect(slot, isNotNull);
    expect(slot!.venue, 'Engineering Block A');

    final prefs = await isar.userPrefsModels.get(1);
    expect(prefs, isNotNull);
    expect(prefs!.universityName, 'KNUST');
    expect(prefs.hasCompletedOnboarding, isTrue);

    course.expectedScore = 86;
    await isar.writeTxn(() => isar.courseModels.put(course));
    await isar.close();

    isar = await Isar.open(
      kCampusIqIsarSchemas,
      directory: testDirectory.path,
      name: 'default',
    );

    final updatedCourse = await isar.courseModels.get(101);
    expect(updatedCourse, isNotNull);
    expect(updatedCourse!.expectedScore, 86);
    expect((await isar.pastSemesterModels.get(202))!.courses.single.mark, 84);
    expect((await isar.timetableSlotModels.get(303))!.courseCode, 'MATH 151');
    expect((await isar.userPrefsModels.get(1))!.programmeName,
        'BSc Computer Engineering');

    await isar.close();
  });
}
