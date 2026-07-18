import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/domain/timetable_notification_coordinator.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';
import 'package:campusiq/features/timetable/domain/timetable_vision_parser.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/core/services/connectivity_service.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/core/providers/isar_provider.dart';

part 'timetable_import_provider.g.dart';

enum ImportStep { idle, picking, parsing, reviewing, saving, done, error }

class TimetableImportState {
  final ImportStep step;
  final List<TimetableSlotImport> slots;
  final Set<int> selectedIndexes;
  final String? errorMessage;

  const TimetableImportState({
    this.step = ImportStep.idle,
    this.slots = const [],
    this.selectedIndexes = const {},
    this.errorMessage,
  });

  TimetableImportState copyWith({
    ImportStep? step,
    List<TimetableSlotImport>? slots,
    Set<int>? selectedIndexes,
    String? errorMessage,
  }) =>
      TimetableImportState(
        step: step ?? this.step,
        slots: slots ?? this.slots,
        selectedIndexes: selectedIndexes ?? this.selectedIndexes,
        errorMessage: errorMessage,
      );
}

@riverpod
class TimetableImportNotifier extends _$TimetableImportNotifier {
  @override
  TimetableImportState build() => const TimetableImportState();

  Future<void> pickAndParse(ImageSource source) async {
    final sourceLabel = source == ImageSource.camera ? 'camera' : 'gallery';
    await AnalyticsService.instance
        .logTimetableImportStarted(source: sourceLabel);
    state = state.copyWith(step: ImportStep.picking);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);

      if (picked == null) {
        state = const TimetableImportState(); // cancelled → back to idle
        return;
      }

      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline) {
        await AnalyticsService.instance.logTimetableImportFailed(
          source: sourceLabel,
          reason: 'offline',
        );
        state = state.copyWith(
          step: ImportStep.error,
          errorMessage: "You're offline. Connect to use features.",
        );
        return;
      }

      state = state.copyWith(step: ImportStep.parsing);

      final file = File(picked.path);
      final bytes = await file.readAsBytes();

      if (bytes.length > 4 * 1024 * 1024) {
        await AnalyticsService.instance.logTimetableImportFailed(
          source: sourceLabel,
          reason: 'file_too_large',
        );
        state = state.copyWith(
          step: ImportStep.error,
          errorMessage: 'Image too large. Try a lower-resolution photo.',
        );
        return;
      }

      final base64Image = base64Encode(bytes);
      const parser = TimetableVisionParser();
      final slots = await parser.parse(base64Image);

      if (slots.isEmpty) {
        await AnalyticsService.instance.logTimetableImportFailed(
          source: sourceLabel,
          reason: 'empty_parse_result',
        );
        state = state.copyWith(
          step: ImportStep.error,
          errorMessage:
              'No timetable slots could be detected. Try a clearer image.',
        );
        return;
      }

      state = TimetableImportState(
        step: ImportStep.reviewing,
        slots: slots,
        selectedIndexes: Set<int>.from(
          List.generate(slots.length, (i) => i)
              .where((index) => slots[index].isValid),
        ),
      );
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'timetable_import_failed',
        context: {'source': sourceLabel},
      );
      await AnalyticsService.instance.logTimetableImportFailed(
        source: sourceLabel,
        reason: 'parse_failed',
      );
      state = state.copyWith(
        step: ImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void toggleSlot(int index) {
    final updated = Set<int>.from(state.selectedIndexes);
    updated.contains(index) ? updated.remove(index) : updated.add(index);
    state = state.copyWith(selectedIndexes: updated);
  }

  void selectAll() {
    state = state.copyWith(
      selectedIndexes: Set<int>.from(
        List.generate(state.slots.length, (i) => i)
            .where((index) => state.slots[index].isValid),
      ),
    );
  }

  void deselectAll() {
    state = state.copyWith(selectedIndexes: {});
  }

  void updateSlotTimes({
    required int index,
    required int startMinutes,
    required int endMinutes,
  }) {
    if (index < 0 || index >= state.slots.length) return;
    final slots = [...state.slots];
    final validationError =
        endMinutes <= startMinutes ? 'End time must be after start time' : null;
    slots[index] = slots[index].copyWith(
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      rawStartTime: '',
      rawEndTime: '',
      validationError: validationError,
    );
    final selected = Set<int>.from(state.selectedIndexes);
    if (validationError == null) {
      selected.add(index);
    } else {
      selected.remove(index);
    }
    state = state.copyWith(slots: slots, selectedIndexes: selected);
  }

  Future<void> confirmImport() async {
    final repo = ref.read(timetableRepositoryProvider);
    if (repo == null) return;

    final semesterKey = ref.read(activeSemesterProvider);

    state = state.copyWith(step: ImportStep.saving);

    try {
      final ordered = state.selectedIndexes.toList()..sort();
      final invalidSelected =
          ordered.where((index) => !state.slots[index].isValid).toList();
      if (invalidSelected.isNotEmpty) {
        state = state.copyWith(
          step: ImportStep.reviewing,
          errorMessage:
              'Fix or deselect invalid timetable rows before importing.',
        );
        return;
      }
      for (var i = 0; i < ordered.length; i++) {
        final slot = state.slots[ordered[i]];
        final color = TimetableConstants.colorForIndex(i);
        await repo
            .addSlot(slot.toModel(colorValue: color, semesterKey: semesterKey));
      }

      final isar = await ref.read(isarProvider.future);
      await TimetableNotificationCoordinator(isar: isar).reconcile(
        reason: 'timetable_import',
      );

      state = state.copyWith(step: ImportStep.done);
      await AnalyticsService.instance.logTimetableImportSucceeded(
        source: 'review',
        count: ordered.length,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'timetable_import_save_failed',
        context: {'selected_count': state.selectedIndexes.length},
      );
      await AnalyticsService.instance.logTimetableImportFailed(
        source: 'review',
        reason: 'save_failed',
      );
      state = state.copyWith(
        step: ImportStep.error,
        errorMessage: 'Failed to save: ${e.toString()}',
      );
    }
  }

  void reset() => state = const TimetableImportState();
}
