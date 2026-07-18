import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:campusiq/core/data/isar_database.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/providers/connectivity_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';
import 'package:campusiq/features/ai/domain/deepseek_client.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/features/ai/presentation/providers/study_plan_provider.dart';
import 'package:campusiq/features/plan/domain/plan_generator.dart';

class _MockDeepSeekClient extends Fake implements DeepSeekClient {
  String responseText = '';

  @override
  Future<String> complete({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    int maxTokens = 800,
  }) async {
    return responseText;
  }
}

void main() {
  late Isar isar;
  late _MockDeepSeekClient mockDeepSeekClient;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: {
        Abi.current():
            '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/'
                'isar_community_flutter_libs-3.3.0-dev.1/macos/libisar.dylib',
      },
    );
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('campusiq_ai_test_');
    isar = await Isar.open(
      kCampusIqIsarSchemas,
      directory: tempDir.path,
      name: 'campusiq_ai_test',
    );
    mockDeepSeekClient = _MockDeepSeekClient();
  });

  tearDown(() async {
    await isar.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
      'StudyPlanNotifier rejects/rewrites hallucinated course names/codes and uses exact course info',
      () async {
    final course1 = CourseModel.create(
      name: '',
      code: 'ER-125',
      creditHours: 3.0,
      expectedScore: 80.0,
      semesterKey: '2024-Sem2',
    );

    final course2 = CourseModel.create(
      name: 'Introduction to Computer Science',
      code: 'CS-101',
      creditHours: 4.0,
      expectedScore: 85.0,
      semesterKey: '2024-Sem2',
    );

    // Add a third course to create an ambiguous match for CS100
    final course3 = CourseModel.create(
      name: 'Advanced CS',
      code: 'CS-102',
      creditHours: 4.0,
      expectedScore: 90.0,
      semesterKey: '2024-Sem2',
    );

    await isar.writeTxn(() async {
      await isar.courseModels.putAll([course1, course2, course3]);
    });

    final container = ProviderContainer(
      overrides: [
        isarProvider.overrideWith((ref) => isar),
        deepseekClientProvider.overrideWith((ref) async => mockDeepSeekClient),
        isOnlineProvider.overrideWith((ref) async => true),
      ],
    );

    mockDeepSeekClient.responseText = '''
    [
      {
        "day": "Monday",
        "courseCode": "ER-125",
        "courseName": "Aerospace Engineering",
        "startTime": "09:00",
        "durationMinutes": 90,
        "reason": "Prioritize"
      },
      {
        "day": "Tuesday",
        "courseCode": "CS101",
        "courseName": "Intro to CS",
        "startTime": "10:00",
        "durationMinutes": 90,
        "reason": "Review"
      },
      {
        "day": "Wednesday",
        "courseCode": "ME-201",
        "courseName": "Mechanical Design",
        "startTime": "11:00",
        "durationMinutes": 60,
        "reason": "Hallucinated completely"
      },
      {
        "day": "Thursday",
        "courseCode": "CS100",
        "courseName": "Introduction to Computers",
        "startTime": "12:00",
        "durationMinutes": 90,
        "reason": "Ambiguous match (CS-101 and CS-102 both have distance 1)"
      }
    ]
    ''';

    await container.read(studyPlanProvider.notifier).generatePlan();

    final slots = await isar.studyPlanSlotModels.where().findAll();

    expect(slots.length, 4);

    final slot1 = slots.firstWhere((s) => s.day == 'Monday');
    expect(slot1.courseCode, 'ER-125');
    expect(slot1.courseName, 'ER-125');

    final slot2 = slots.firstWhere((s) => s.day == 'Tuesday');
    expect(slot2.courseCode, 'CS-101');
    expect(slot2.courseName, 'Introduction to Computer Science');

    final slot3 = slots.firstWhere((s) => s.day == 'Wednesday');
    expect(slot3.courseCode, 'STUDY');
    expect(slot3.courseName, 'Study Session');

    final slot4 = slots.firstWhere((s) => s.day == 'Thursday');
    expect(slot4.courseCode, 'STUDY');
    expect(slot4.courseName, 'Study Session');
  });

  test('PlanGenerator fallback to course code when course name is empty', () {
    final course = CourseModel.create(
      name: '  ',
      code: 'ER-125',
      creditHours: 3.0,
      expectedScore: 80.0,
      semesterKey: '2024-Sem2',
    );

    // Provide at least one slot to detect free blocks
    final slot = TimetableSlotModel()
      ..courseCode = 'CS-101'
      ..courseName = 'Intro'
      ..dayIndex = 0
      ..venue = 'Engineering Block A'
      ..slotType = 'Lecture'
      ..startMinutes = 600 // 10:00 AM
      ..endMinutes = 720; // 12:00 PM

    final generator = PlanGenerator(
      todaySlots: [slot],
      courses: [course],
      recentSessions: [],
      dailyStudyGoalMinutes: 120,
    );

    final date = DateTime(2024, 7, 5); // Friday
    final tasks = generator.generate(date);

    final studyTask = tasks.firstWhere((t) => t.courseCode == 'ER-125');
    expect(studyTask.label, 'Study ER-125');
  });
}
