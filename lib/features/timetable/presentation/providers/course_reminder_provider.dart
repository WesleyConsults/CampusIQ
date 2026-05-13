import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
import 'package:campusiq/features/timetable/data/repositories/course_reminder_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';

final courseReminderRepositoryProvider =
    Provider<CourseReminderRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => CourseReminderRepository(isar));
});

final courseRemindersProvider =
    StreamProvider<List<CourseReminderModel>>((ref) async* {
  final semester = ref.watch(activeSemesterProvider);
  final isar = await ref.watch(isarProvider.future);
  yield* CourseReminderRepository(isar).watchReminders(semester);
});

final activeCourseReminderCountProvider = Provider<int>((ref) {
  final reminders = ref.watch(courseRemindersProvider).valueOrNull ?? [];
  return reminders.where((reminder) => reminder.isEnabled).length;
});

Future<void> refreshCourseReminderNotifications(WidgetRef ref) async {
  final isar = await ref.read(isarProvider.future);
  final semester = ref.read(activeSemesterProvider);
  final reminderRepo = CourseReminderRepository(isar);
  final timetableRepo = TimetableRepository(isar);

  final reminders = await reminderRepo.getReminders(semester);
  final slots = await timetableRepo.getAllSlotsOnce(semester);

  await NotificationService.instance.scheduleCourseReminderNotifications(
    reminders: reminders,
    slots: slots,
  );
}
