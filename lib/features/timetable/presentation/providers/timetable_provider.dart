import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';

/// Currently viewed day index (0=Mon … 6=Sun). Drives the paged grid.
final activeDayProvider = StateProvider<int>((ref) {
  /// Default to today's day index. weekday 1=Mon…7=Sun maps directly to index 0…6.
  return DateTime.now().weekday - 1;
});

/// Repository provider.
final timetableRepositoryProvider = Provider<TimetableRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => TimetableRepository(isar));
});

/// Live stream of ALL slots for the active semester.
final allSlotsProvider = StreamProvider<List<TimetableSlotModel>>((ref) {
  final repo = ref.watch(timetableRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAllSlots(semester);
});

/// Slots filtered to the active day — what the grid renders.
final activeDaySlotsProvider = Provider<List<TimetableSlotModel>>((ref) {
  final allSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];
  final day = ref.watch(activeDayProvider);
  final sorted = allSlots.where((s) => s.dayIndex == day).toList()
    ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  return sorted;
});

/// Free blocks for the active day, derived from class slots.
final activeDayFreeBlocksProvider = Provider<List<FreeBlock>>((ref) {
  final slots = ref.watch(activeDaySlotsProvider);
  final day = ref.watch(activeDayProvider);
  return FreeTimeDetector.detect(dayIndex: day, slots: slots);
});

/// Slot count for color assignment.
final slotCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(timetableRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return 0;
  return repo.countSlots(semester);
});
