import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/registration_course_import.dart';
import 'package:campusiq/features/cwa/domain/registration_slip_parser.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';

part 'registration_slip_import_provider.g.dart';

enum SlipImportStep { idle, picking, parsing, reviewing, saving, done, error }

class SlipImportState {
  final SlipImportStep step;
  final List<RegistrationCourseImport> courses;
  final Set<int> selectedIndexes;
  final String? errorMessage;

  const SlipImportState({
    this.step = SlipImportStep.idle,
    this.courses = const [],
    this.selectedIndexes = const {},
    this.errorMessage,
  });

  SlipImportState copyWith({
    SlipImportStep? step,
    List<RegistrationCourseImport>? courses,
    Set<int>? selectedIndexes,
    String? errorMessage,
  }) =>
      SlipImportState(
        step: step ?? this.step,
        courses: courses ?? this.courses,
        selectedIndexes: selectedIndexes ?? this.selectedIndexes,
        errorMessage: errorMessage,
      );
}

@riverpod
class RegistrationSlipImportNotifier extends _$RegistrationSlipImportNotifier {
  @override
  SlipImportState build() => const SlipImportState();

  Future<void> pickFromCamera() async {
    state = state.copyWith(step: SlipImportStep.picking);
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked == null) {
        state = const SlipImportState();
        return;
      }
      final bytes = await picked.readAsBytes();
      await _parse(bytes, 'image/jpeg');
    } catch (e) {
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(step: SlipImportStep.picking);
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) {
        state = const SlipImportState();
        return;
      }
      final bytes = await picked.readAsBytes();
      await _parse(bytes, 'image/jpeg');
    } catch (e) {
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> pickFromGalleryOrFile() async {
    state = state.copyWith(step: SlipImportStep.picking);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        state = const SlipImportState();
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        state = state.copyWith(
          step: SlipImportStep.error,
          errorMessage: 'Could not read file.',
        );
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      final mime = ext == 'pdf' ? 'application/pdf' : 'image/jpeg';
      await _parse(bytes, mime);
    } catch (e) {
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _parse(Uint8List bytes, String mimeType) async {
    if (bytes.length > 10 * 1024 * 1024) {
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: 'File too large (max 10 MB). Try compressing it first.',
      );
      return;
    }

    state = state.copyWith(step: SlipImportStep.parsing);
    try {
      final apiKey = dotenv.env['OPEN_AI_API_KEY'] ?? '';
      final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o';
      final parser = RegistrationSlipParser(apiKey: apiKey, model: model);
      final courses = await parser.parse(bytes, mimeType);

      if (courses.isEmpty) {
        state = state.copyWith(
          step: SlipImportStep.error,
          errorMessage:
              'No courses found. Make sure the file clearly shows your registration slip.',
        );
        return;
      }

      state = SlipImportState(
        step: SlipImportStep.reviewing,
        courses: courses,
        selectedIndexes: Set.from(List.generate(courses.length, (i) => i)),
      );
    } catch (e) {
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void toggleCourse(int index) {
    final updated = Set<int>.from(state.selectedIndexes);
    updated.contains(index) ? updated.remove(index) : updated.add(index);
    state = state.copyWith(selectedIndexes: updated);
  }

  void selectAll() => state = state.copyWith(
        selectedIndexes:
            Set.from(List.generate(state.courses.length, (i) => i)),
      );

  void deselectAll() => state = state.copyWith(selectedIndexes: {});

  /// Update credit hours for a single course during review.
  void setCreditHours(int index, double hours) {
    final updated = List<RegistrationCourseImport>.from(state.courses);
    updated[index] = updated[index].copyWith(creditHours: hours.clamp(1, 6));
    state = state.copyWith(courses: updated);
  }

  Future<void> confirmImport() async {
    final cwaRepo = ref.read(cwaRepositoryProvider);
    if (cwaRepo == null) return;

    final semesterKey = ref.read(activeSemesterProvider);
    state = state.copyWith(step: SlipImportStep.saving);

    try {
      final ordered = state.selectedIndexes.toList()..sort();
      for (final i in ordered) {
        final course = state.courses[i];
        final code = course.courseCode.trim().toUpperCase();
        if (code.isEmpty) continue;
        final exists = await cwaRepo.courseExistsByCode(code, semesterKey);
        if (!exists) {
          await cwaRepo.addCourse(
            CourseModel.create(
              name: course.courseName,
              code: code,
              creditHours: course.creditHours,
              expectedScore: 70.0,
              semesterKey: semesterKey,
            ),
          );
        }
      }
      state = state.copyWith(step: SlipImportStep.done);
    } catch (e) {
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: 'Failed to save: ${e.toString()}',
      );
    }
  }

  void reset() => state = const SlipImportState();
}
