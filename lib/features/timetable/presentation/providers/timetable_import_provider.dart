import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';
import 'package:campusiq/features/timetable/domain/timetable_vision_parser.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';

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
    state = state.copyWith(step: ImportStep.picking);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);

      if (picked == null) {
        state = const TimetableImportState(); // cancelled → back to idle
        return;
      }

      state = state.copyWith(step: ImportStep.parsing);

      final file = File(picked.path);
      final bytes = await file.readAsBytes();

      if (bytes.length > 4 * 1024 * 1024) {
        state = state.copyWith(
          step: ImportStep.error,
          errorMessage: 'Image too large. Try a lower-resolution photo.',
        );
        return;
      }

      final base64Image = base64Encode(bytes);
      final apiKey = dotenv.env['OPEN_AI_API_KEY'] ?? '';
      final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o';
      final slots = await TimetableVisionParser(apiKey: apiKey, model: model)
          .parse(base64Image);

      if (slots.isEmpty) {
        state = state.copyWith(
          step: ImportStep.error,
          errorMessage: 'No timetable slots found. Try a clearer photo.',
        );
        return;
      }

      state = TimetableImportState(
        step: ImportStep.reviewing,
        slots: slots,
        selectedIndexes: Set<int>.from(List.generate(slots.length, (i) => i)),
      );
    } catch (e) {
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
      selectedIndexes:
          Set<int>.from(List.generate(state.slots.length, (i) => i)),
    );
  }

  void deselectAll() {
    state = state.copyWith(selectedIndexes: {});
  }

  Future<void> confirmImport() async {
    final repo = ref.read(timetableRepositoryProvider);
    if (repo == null) return;

    final semesterKey = ref.read(activeSemesterProvider);

    state = state.copyWith(step: ImportStep.saving);

    try {
      final ordered = state.selectedIndexes.toList()..sort();
      for (var i = 0; i < ordered.length; i++) {
        final slot = state.slots[ordered[i]];
        final color = TimetableConstants.colorForIndex(i);
        await repo
            .addSlot(slot.toModel(colorValue: color, semesterKey: semesterKey));
      }
      state = state.copyWith(step: ImportStep.done);
    } catch (e) {
      state = state.copyWith(
        step: ImportStep.error,
        errorMessage: 'Failed to save: ${e.toString()}',
      );
    }
  }

  void reset() => state = const TimetableImportState();
}
