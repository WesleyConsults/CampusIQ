import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
import 'package:campusiq/features/timetable/data/repositories/course_reminder_repository.dart';
import 'package:campusiq/features/timetable/domain/timetable_notification_coordinator.dart';

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

Future<TimetableNotificationSyncResult> refreshCourseReminderNotifications(
  WidgetRef ref, {
  String reason = 'course_reminder_refresh',
}) async {
  final isar = await ref.read(isarProvider.future);
  return TimetableNotificationCoordinator(isar: isar).reconcile(
    reason: reason,
  );
}
