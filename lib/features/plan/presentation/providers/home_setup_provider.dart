import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/domain/home_setup_state.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeSetupPrefsProvider = StreamProvider<UserPrefsModel?>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.userPrefsModels.watchObject(1, fireImmediately: true);
});

final homeSetupStateProvider = Provider<HomeSetupState?>((ref) {
  final prefsAsync = ref.watch(homeSetupPrefsProvider);
  final coursesAsync = ref.watch(coursesProvider);
  final slotsAsync = ref.watch(allSlotsProvider);
  final historyAsync = ref.watch(pastSemestersProvider);

  if (!prefsAsync.hasValue ||
      !coursesAsync.hasValue ||
      !slotsAsync.hasValue ||
      !historyAsync.hasValue) {
    return null;
  }

  final prefs = prefsAsync.valueOrNull;
  final university = prefs?.universityName?.trim() ?? '';
  final gradingSystem = prefs?.gradingSystemId.trim() ?? '';

  return HomeSetupState(
    hasUniversityAndGradingSystem:
        university.isNotEmpty && gradingSystem.isNotEmpty,
    hasCurrentCourses: coursesAsync.valueOrNull?.isNotEmpty ?? false,
    hasTimetable: slotsAsync.valueOrNull?.isNotEmpty ?? false,
    hasAcademicHistory: historyAsync.valueOrNull?.isNotEmpty ?? false,
    hasSeenInitialWelcome: prefs?.hasSeenInitialHomeWelcome ?? false,
  );
});
