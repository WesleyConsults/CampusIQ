import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/domain/past_course_result.dart';
import 'package:campusiq/features/cwa/domain/academic_document_kind.dart';
import 'package:campusiq/features/cwa/domain/result_slip_parser.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/core/services/connectivity_service.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';

part 'result_slip_import_provider.g.dart';

enum ResultImportStep {
  idle,
  picking,
  parsing,
  labelling,
  reviewing,
  saving,
  done,
  error
}

class ResultImportState {
  final ResultImportStep step;
  final List<PastCourseResult> courses;
  final Set<int> selectedIndexes;
  final String semesterKey;
  final String semesterLabel;
  final String? errorMessage;
  final double? reportedSemesterCwa;
  final double? reportedCumulativeCwa;
  final double? cumulativeCreditsCalc;
  final double? cumulativeWeightedMarks;
  final int skippedCourseCount;
  final AcademicDocumentKind documentKind;

  /// Metadata parsed from the slip header by AI — used to pre-fill the
  /// labelling screen so the user only needs to verify, not re-enter.
  final int? parsedAcademicYearStart;
  final int? parsedSemesterNumber;
  final int? parsedLevel;
  final String? parsedProgramme;

  const ResultImportState({
    this.step = ResultImportStep.idle,
    this.courses = const [],
    this.selectedIndexes = const {},
    this.semesterKey = '',
    this.semesterLabel = '',
    this.errorMessage,
    this.reportedSemesterCwa,
    this.reportedCumulativeCwa,
    this.cumulativeCreditsCalc,
    this.cumulativeWeightedMarks,
    this.skippedCourseCount = 0,
    this.documentKind = AcademicDocumentKind.unknown,
    this.parsedAcademicYearStart,
    this.parsedSemesterNumber,
    this.parsedLevel,
    this.parsedProgramme,
  });

  ResultImportState copyWith({
    ResultImportStep? step,
    List<PastCourseResult>? courses,
    Set<int>? selectedIndexes,
    String? semesterKey,
    String? semesterLabel,
    String? errorMessage,
    double? reportedSemesterCwa,
    double? reportedCumulativeCwa,
    double? cumulativeCreditsCalc,
    double? cumulativeWeightedMarks,
    int? skippedCourseCount,
    AcademicDocumentKind? documentKind,
    int? parsedAcademicYearStart,
    int? parsedSemesterNumber,
    int? parsedLevel,
    String? parsedProgramme,
  }) =>
      ResultImportState(
        step: step ?? this.step,
        courses: courses ?? this.courses,
        selectedIndexes: selectedIndexes ?? this.selectedIndexes,
        semesterKey: semesterKey ?? this.semesterKey,
        semesterLabel: semesterLabel ?? this.semesterLabel,
        errorMessage: errorMessage,
        reportedSemesterCwa: reportedSemesterCwa ?? this.reportedSemesterCwa,
        reportedCumulativeCwa:
            reportedCumulativeCwa ?? this.reportedCumulativeCwa,
        cumulativeCreditsCalc:
            cumulativeCreditsCalc ?? this.cumulativeCreditsCalc,
        cumulativeWeightedMarks:
            cumulativeWeightedMarks ?? this.cumulativeWeightedMarks,
        skippedCourseCount: skippedCourseCount ?? this.skippedCourseCount,
        documentKind: documentKind ?? this.documentKind,
        parsedAcademicYearStart:
            parsedAcademicYearStart ?? this.parsedAcademicYearStart,
        parsedSemesterNumber: parsedSemesterNumber ?? this.parsedSemesterNumber,
        parsedLevel: parsedLevel ?? this.parsedLevel,
        parsedProgramme: parsedProgramme ?? this.parsedProgramme,
      );
}

@riverpod
class ResultSlipImportNotifier extends _$ResultSlipImportNotifier {
  @override
  ResultImportState build() => const ResultImportState();

  Future<void> pickFromCamera() async {
    const source = 'camera';
    await AnalyticsService.instance.logCourseImportStarted(
      importType: 'result',
      source: source,
    );
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
      await _parse(bytes, 'image/jpeg', source: source);
    } catch (e, stackTrace) {
      await _handleFailure(
        e,
        stackTrace,
        source: source,
        reason: 'image_picker_failed',
      );
    }
  }

  Future<void> pickFromGallery() async {
    const source = 'gallery';
    await AnalyticsService.instance.logCourseImportStarted(
      importType: 'result',
      source: source,
    );
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
      await _parse(bytes, 'image/jpeg', source: source);
    } catch (e, stackTrace) {
      await _handleFailure(
        e,
        stackTrace,
        source: source,
        reason: 'image_picker_failed',
      );
    }
  }

  Future<void> pickFromFile() async {
    const source = 'pdf';
    await AnalyticsService.instance.logCourseImportStarted(
      importType: 'result',
      source: source,
    );
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
        await AnalyticsService.instance.logCourseImportFailed(
          importType: 'result',
          source: source,
          reason: 'file_read_failed',
        );
        state = state.copyWith(
          step: ResultImportStep.error,
          errorMessage: 'Could not read file.',
        );
        return;
      }
      final mime = (file.extension ?? '').toLowerCase() == 'pdf'
          ? 'application/pdf'
          : 'image/jpeg';
      await _parse(bytes, mime, source: source);
    } catch (e, stackTrace) {
      await _handleFailure(
        e,
        stackTrace,
        source: source,
        reason: 'file_picker_failed',
      );
    }
  }

  Future<void> _parse(
    Uint8List bytes,
    String mimeType, {
    required String source,
  }) async {
    if (bytes.length > 10 * 1024 * 1024) {
      await AnalyticsService.instance.logCourseImportFailed(
        importType: 'result',
        source: source,
        reason: 'file_too_large',
      );
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: 'File too large (max 10 MB). Try compressing it first.',
      );
      return;
    }

    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) {
      await AnalyticsService.instance.logCourseImportFailed(
        importType: 'result',
        source: source,
        reason: 'offline',
      );
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage: "You're offline. Connect to use features.",
      );
      return;
    }

    state = state.copyWith(step: ResultImportStep.parsing);
    try {
      const parser = ResultSlipParser();
      final parseResult = await parser.parse(bytes, mimeType);
      if (parseResult.documentKind == AcademicDocumentKind.registrationSlip) {
        await AnalyticsService.instance.logDocumentTypeMismatch(
          expectedType: 'result_slip',
          detectedType: 'registration_slip',
        );
      }

      if (parseResult.courses.isEmpty) {
        await AnalyticsService.instance.logCourseImportFailed(
          importType: 'result',
          source: source,
          reason: 'empty_parse_result',
        );
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
        selectedIndexes:
            Set.from(List.generate(parseResult.courses.length, (i) => i)),
        reportedSemesterCwa: parseResult.reportedSemesterCwa,
        reportedCumulativeCwa: parseResult.reportedCumulativeCwa,
        cumulativeCreditsCalc: parseResult.cumulativeCreditsCalc,
        cumulativeWeightedMarks: parseResult.cumulativeWeightedMarks,
        skippedCourseCount: parseResult.skippedCourseCount,
        documentKind: parseResult.documentKind,
        parsedAcademicYearStart: parseResult.academicYearStart,
        parsedSemesterNumber: parseResult.semesterNumber,
        parsedLevel: parseResult.level,
        parsedProgramme: parseResult.programme,
      );
    } catch (e, stackTrace) {
      await _handleFailure(
        e,
        stackTrace,
        source: source,
        reason: 'result_import_failed',
      );
    }
  }

  /// Called after user confirms the academic year/semester identity.
  void confirmSemesterIdentity({
    required String semesterKey,
    required String semesterLabel,
  }) {
    state = state.copyWith(
      step: ResultImportStep.reviewing,
      semesterKey: semesterKey.trim(),
      semesterLabel: semesterLabel.trim(),
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
    updated[index] = updated[index].copyWith(creditHours: hours.clamp(1, 12));
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

  void addManualCourse(PastCourseResult course) {
    final updated = List<PastCourseResult>.from(state.courses)..add(course);
    final selected = Set<int>.from(state.selectedIndexes)
      ..add(updated.length - 1);
    state = state.copyWith(courses: updated, selectedIndexes: selected);
  }

  Future<PastSemesterModel?> findDuplicateSemester() async {
    final repo = ref.read(pastResultRepositoryProvider);
    final semesterKey = state.semesterKey.trim();
    if (repo == null || semesterKey.isEmpty) return null;
    return repo.findBySemesterKey(semesterKey);
  }

  Future<void> confirmImport({bool replaceExisting = false}) async {
    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) {
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage:
            'The local database is not ready, so the results were not saved.',
      );
      return;
    }

    state = state.copyWith(step: ResultImportStep.saving);
    try {
      final gradingSystem = ref.read(gradingSystemProvider);
      final ordered = state.selectedIndexes.toList()..sort();
      final entries = ordered.map((i) {
        final c = state.courses[i];
        final normalizedGrade = c.grade.trim().toUpperCase();
        return PastCourseEntry.create(
          courseCode: c.courseCode.trim().toUpperCase(),
          courseName: c.courseName,
          creditHours: c.creditHours,
          grade: normalizedGrade,
          mark: gradingSystem.usesLetterGrades
              ? gradingSystem.scoreForGrade(normalizedGrade)
              : c.mark,
        );
      }).toList();

      final semesterKey =
          state.semesterKey.trim().isEmpty ? null : state.semesterKey.trim();
      final model = PastSemesterModel.create(
        semesterLabel: state.semesterLabel,
        semesterKey: semesterKey,
        gradingSystemId: gradingSystem.id,
        courses: entries,
        reportedSemesterCwa: state.reportedSemesterCwa,
        reportedCumulativeCwa: state.reportedCumulativeCwa,
        cumulativeCreditsCalc: state.cumulativeCreditsCalc,
        cumulativeWeightedMarks: state.cumulativeWeightedMarks,
      );

      if (replaceExisting && semesterKey != null) {
        await repo.replaceForSemesterKey(semesterKey, model);
      } else {
        await repo.add(model);
      }

      state = state.copyWith(step: ResultImportStep.done);
      await AnalyticsService.instance.logCourseImportSucceeded(
        importType: 'result',
        source: 'review',
        count: entries.length,
        skippedCount: state.skippedCourseCount,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'result_import_save_failed',
        context: {'selected_count': state.selectedIndexes.length},
      );
      await AnalyticsService.instance.logCourseImportFailed(
        importType: 'result',
        source: 'review',
        reason: 'save_failed',
      );
      state = state.copyWith(
        step: ResultImportStep.error,
        errorMessage:
            'We read your result slip, but could not save the reviewed results.',
      );
    }
  }

  void resumeReview() => state = state.copyWith(
        step: ResultImportStep.reviewing,
        errorMessage: null,
      );

  void reset() => state = const ResultImportState();

  Future<void> _handleFailure(
    Object error,
    StackTrace stackTrace, {
    required String source,
    required String reason,
  }) async {
    await CrashReportingService.instance.recordNonFatalError(
      error,
      stackTrace,
      reason: reason,
      context: {'import_type': 'result', 'source': source},
    );
    await AnalyticsService.instance.logCourseImportFailed(
      importType: 'result',
      source: source,
      reason: reason,
    );
    state = state.copyWith(
      step: ResultImportStep.error,
      errorMessage: error.toString().replaceFirst('Exception: ', ''),
    );
  }
}
