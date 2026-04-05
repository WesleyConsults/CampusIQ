import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/data/repositories/personal_slot_repository.dart';
import 'package:campusiq/features/timetable/domain/slot_expander.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

/// Repository provider
final personalSlotRepositoryProvider = Provider<PersonalSlotRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => PersonalSlotRepository(isar));
});

/// Live stream of ALL stored personal slots for the semester
final allPersonalSlotsProvider = StreamProvider<List<PersonalSlotModel>>((ref) {
  final repo = ref.watch(personalSlotRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAllSlots(semester);
});

/// Expanded personal slots for the active day — runs SlotExpander
final activeDayPersonalSlotsProvider = Provider<List<PersonalSlotModel>>((ref) {
  final allStored = ref.watch(allPersonalSlotsProvider).valueOrNull ?? [];
  final dayIndex  = ref.watch(activeDayProvider);

  // Derive the actual date for the active day this week
  final now = DateTime.now();
  // weekday: Mon=1 … Sun=7. dayIndex: Mon=0 … Sat=5
  final daysFromToday = dayIndex - (now.weekday - 1);
  final targetDate = now.add(Duration(days: daysFromToday));

  return SlotExpander.expandForDay(
    stored: allStored,
    targetDate: targetDate,
    dayIndex: dayIndex,
  );
});

/// Which timetable page is active: 0=Class, 1=Both, 2=Personal
final timetablePageProvider = StateProvider<int>((ref) => 1);
