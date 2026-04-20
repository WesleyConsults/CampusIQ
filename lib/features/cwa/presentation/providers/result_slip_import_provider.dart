import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/domain/past_course_result.dart';
import 'package:campusiq/features/cwa/domain/result_slip_parser.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/core/services/connectivity_service.dart';

part 'result_slip_import_provider.g.dart';

enum ResultImportStep { idle, picking, parsing, labelling, reviewing, saving, done, error }

class ResultImportState {
  final ResultImportStep step;
  final List<PastCourseResult> courses;
  final Set<int> selectedIndexes;
  final String semesterLabel;
  final String? errorMessage;
  final double? reportedSemesterCwa;
  final double? reportedCumulativeCwa;
  final double? cumulativeCreditsCalc;
  final double? cumulativeWeightedMarks;

  const ResultImportState({
    this.step = ResultImportStep.idle,
    this.courses = const [],
    this.selectedIndexes = const {},
    this.semesterLabel = '',
    this.errorMessage,
    this.reportedSemesterCwa,
    this.reportedCumulativeCwa,
    this.cumulativeCreditsCalc,
    this.cumulativeWeightedMarks,
  });

  ResultImportState copyWith({
    ResultImportStep? step,
    List<PastCourseResult>? courses,
    Set<int>? selectedIndexes,
    String? semesterLabel,
    String? errorMessage,
    double? reportedSemesterCwa,
    double? reportedCumulativeCwa,
    double? cumulativeCreditsCalc,
    double? cumulativeWeightedMarks,
  }) =>
      ResultImportState(
        step: step ?? this.step,
        courses: courses ?? this.courses,
        selectedIndexes: selectedIndexes ?? this.selectedIndexes,
        semesterLabel: semesterLabel ?? this.semesterLabel,
        errorMessage: errorMessage,
        reportedSemesterCwa: reportedSemesterCwa ?? this.reportedSemesterCwa,
        reportedCumulativeCwa: reportedCumulativeCwa ?? this.reportedCumulativeCwa,
        cumulativeCreditsCalc: cumulativeCreditsCalc ?? this.cumulativeCreditsCalc,
        cumulativeWeightedMarks: cumulativeWeightedMarks ?? this.cumulativeWeightedMarks,
      );
}

@riverpod
class ResultSlipImportNotifier extends _$ResultSlipImportNotifier {
  @override
  ResultImportState build() => const ResultImportState();

  Future<void> pickFromCamera() async {
    state = state.copyWith(step: ResultImportStep.picking);
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked == null) {
        state = const ResultImportState();
        return;
      }
      final bytes = await picked.readAsBytes();
      await _parse(bytes, 'image/jpeg');
    } catch (e) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(step: ResultImportStep.picking);
    try {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) {
        state = const ResultImportState();
        return;
      }
      final bytes = await picked.readAsBytes();
      await _parse(bytes, 'image/jpeg');
    } catch (e) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> pickFromFile() async {
    state = state.copyWith(step: ResultImportStep.picking);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        state = const ResultImportState();
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        state = state.copyWith(
          step: ResultImportStep.error,
          errorMessage: 'Could not read file.',
        );
        return;
      }
      final mime =
          (file.extension ?? '').toLowerCase() == 'pdf' ? 'application/pdf' : 'image/jpeg';
      await _parse(bytes, mime);
    } catch (e) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _parse(Uint8List bytes, String mimeType) async {
    if (bytes.length > 10 * 1024 * 1024) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: 'File too large (max 10 MB). Try compressing it first.',
      );
      return;
    }

    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: 'You are offline. AI features require a connection.',
      );
      return;
    }

    state = state.copyWith(step: ResultImportStep.parsing);
    try {
      final apiKey = dotenv.env['OPEN_AI_API_KEY'] ?? '';
      final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o';
      final parser = ResultSlipParser(apiKey: apiKey, model: model);
      final parseResult = await parser.parse(bytes, mimeType);

      if (parseResult.courses.isEmpty) {
        state = state.copyWith(
          step: ResultImportStep.error,
          errorMessage:
              'No courses found. Make sure the file clearly shows your result slip.',
        );
        return;
      }

      state = ResultImportState(
        step: ResultImportStep.labelling,
        courses: parseResult.courses,
        selectedIndexes: Set.from(List.generate(parseResult.courses.length, (i) => i)),
        reportedSemesterCwa: parseResult.reportedSemesterCwa,
        reportedCumulativeCwa: parseResult.reportedCumulativeCwa,
        cumulativeCreditsCalc: parseResult.cumulativeCreditsCalc,
        cumulativeWeightedMarks: parseResult.cumulativeWeightedMarks,
      );
    } catch (e) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Called after user types a semester label and taps Continue.
  void confirmLabel(String label) {
    state = state.copyWith(
      step: ResultImportStep.reviewing,
      semesterLabel: label.trim(),
    );
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

  void setCreditHours(int index, double hours) {
    final updated = List<PastCourseResult>.from(state.courses);
    updated[index] = updated[index].copyWith(creditHours: hours.clamp(1, 6));
    state = state.copyWith(courses: updated);
  }

  void setGrade(int index, String grade) {
    final updated = List<PastCourseResult>.from(state.courses);
    updated[index] = updated[index].copyWith(grade: grade);
    state = state.copyWith(courses: updated);
  }

  void setMark(int index, double? mark) {
    final updated = List<PastCourseResult>.from(state.courses);
    updated[index] = updated[index].copyWith(mark: mark);
    state = state.copyWith(courses: updated);
  }

  Future<void> confirmImport() async {
    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) return;

    state = state.copyWith(step: ResultImportStep.saving);
    try {
      final ordered = state.selectedIndexes.toList()..sort();
      final entries = ordered.map((i) {
        final c = state.courses[i];
        return PastCourseEntry.create(
          courseCode: c.courseCode.trim().toUpperCase(),
          courseName: c.courseName,
          creditHours: c.creditHours,
          grade: c.grade.trim().toUpperCase(),
          mark: c.mark,
        );
      }).toList();

      await repo.add(PastSemesterModel.create(
        semesterLabel: state.semesterLabel,
        courses: entries,
        reportedSemesterCwa: state.reportedSemesterCwa,
        reportedCumulativeCwa: state.reportedCumulativeCwa,
        cumulativeCreditsCalc: state.cumulativeCreditsCalc,
        cumulativeWeightedMarks: state.cumulativeWeightedMarks,
      ));

      state = state.copyWith(step: ResultImportStep.done);
    } catch (e) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: 'Failed to save: ${e.toString()}',
      );
    }
  }

  void reset() => state = const ResultImportState();
}
