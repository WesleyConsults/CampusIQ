import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/registration_course_import.dart';
import 'package:campusiq/features/cwa/domain/registration_slip_parser.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/core/services/connectivity_service.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';

part 'registration_slip_import_provider.g.dart';

enum SlipImportStep { idle, picking, parsing, reviewing, saving, done, error }

class SlipImportState {
  final SlipImportStep step;
  final List<RegistrationCourseImport> courses;
  final Set<int> selectedIndexes;
  final String? errorMessage;
  final int skippedCourseCount;
  final int duplicateCourseCount;

  const SlipImportState({
    this.step = SlipImportStep.idle,
    this.courses = const [],
    this.selectedIndexes = const {},
    this.errorMessage,
    this.skippedCourseCount = 0,
    this.duplicateCourseCount = 0,
  });

  SlipImportState copyWith({
    SlipImportStep? step,
    List<RegistrationCourseImport>? courses,
    Set<int>? selectedIndexes,
    String? errorMessage,
    int? skippedCourseCount,
    int? duplicateCourseCount,
  }) =>
      SlipImportState(
        step: step ?? this.step,
        courses: courses ?? this.courses,
        selectedIndexes: selectedIndexes ?? this.selectedIndexes,
        errorMessage: errorMessage,
        skippedCourseCount: skippedCourseCount ?? this.skippedCourseCount,
        duplicateCourseCount: duplicateCourseCount ?? this.duplicateCourseCount,
      );
}

@riverpod
class RegistrationSlipImportNotifier extends _$RegistrationSlipImportNotifier {
  @override
  SlipImportState build() => const SlipImportState();

  Future<void> pickFromCamera() async {
    const source = 'camera';
    await AnalyticsService.instance.logCourseImportStarted(
      importType: 'registration',
      source: source,
    );
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
      importType: 'registration',
      source: source,
    );
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

  Future<void> pickFromGalleryOrFile() async {
    const source = 'pdf';
    await AnalyticsService.instance.logCourseImportStarted(
      importType: 'registration',
      source: source,
    );
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
        await AnalyticsService.instance.logCourseImportFailed(
          importType: 'registration',
          source: source,
          reason: 'file_read_failed',
        );
        state = state.copyWith(
          step: SlipImportStep.error,
          errorMessage: 'Could not read file.',
        );
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      final mime = ext == 'pdf' ? 'application/pdf' : 'image/jpeg';
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
        importType: 'registration',
        source: source,
        reason: 'file_too_large',
      );
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: 'File too large (max 10 MB). Try compressing it first.',
      );
      return;
    }

    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) {
      await AnalyticsService.instance.logCourseImportFailed(
        importType: 'registration',
        source: source,
        reason: 'offline',
      );
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: "You're offline. Connect to use features.",
      );
      return;
    }

    state = state.copyWith(step: SlipImportStep.parsing);
    try {
      const parser = RegistrationSlipParser();
      final parseResult = await parser.parse(bytes, mimeType);
      final gradingSystem = ref.read(gradingSystemProvider);
      final courses = parseResult.courses.map((course) {
        final score = gradingSystem.usesLetterGrades
            ? gradingSystem.defaultTarget
            : course.expectedScore;
        return course.copyWith(
          expectedScore: gradingSystem.clampScore(score),
        );
      }).toList();

      if (courses.isEmpty) {
        await AnalyticsService.instance.logCourseImportFailed(
          importType: 'registration',
          source: source,
          reason: 'empty_parse_result',
        );
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
        skippedCourseCount: parseResult.skippedCourseCount,
      );
    } catch (e, stackTrace) {
      await _handleFailure(
        e,
        stackTrace,
        source: source,
        reason: 'registration_import_failed',
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
    updated[index] = updated[index].copyWith(creditHours: hours.clamp(1, 12));
    state = state.copyWith(courses: updated);
  }

  /// Update expected score for a single course during review.
  void setExpectedScore(int index, double score) {
    final gradingSystem = ref.read(gradingSystemProvider);
    final updated = List<RegistrationCourseImport>.from(state.courses);
    updated[index] = updated[index].copyWith(
      expectedScore: gradingSystem.clampScore(score),
    );
    state = state.copyWith(courses: updated);
  }

  void addManualCourse(RegistrationCourseImport course) {
    final updated = List<RegistrationCourseImport>.from(state.courses)
      ..add(course);
    final selected = Set<int>.from(state.selectedIndexes)
      ..add(updated.length - 1);
    state = state.copyWith(courses: updated, selectedIndexes: selected);
  }

  Future<void> confirmImport() async {
    final cwaRepo = ref.read(cwaRepositoryProvider);
    if (cwaRepo == null) return;

    final semesterKey = ref.read(activeSemesterProvider);
    final gradingSystem = ref.read(gradingSystemProvider);
    state = state.copyWith(step: SlipImportStep.saving);

    try {
      final ordered = state.selectedIndexes.toList()..sort();
      int duplicateCount = 0;
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
              expectedScore: gradingSystem.clampScore(course.expectedScore),
              semesterKey: semesterKey,
              gradingSystemId: gradingSystem.id,
            ),
          );
        } else {
          duplicateCount++;
        }
      }
      state = state.copyWith(
        step: SlipImportStep.done,
        duplicateCourseCount: duplicateCount,
      );
      await AnalyticsService.instance.logCourseImportSucceeded(
        importType: 'registration',
        source: 'review',
        count: ordered.length - duplicateCount,
        skippedCount: state.skippedCourseCount,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'registration_import_save_failed',
        context: {'selected_count': state.selectedIndexes.length},
      );
      await AnalyticsService.instance.logCourseImportFailed(
        importType: 'registration',
        source: 'review',
        reason: 'save_failed',
      );
      state = state.copyWith(
        step: SlipImportStep.error,
        errorMessage: 'Failed to save: ${e.toString()}',
      );
    }
  }

  void reset() => state = const SlipImportState();

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
      context: {'import_type': 'registration', 'source': source},
    );
    await AnalyticsService.instance.logCourseImportFailed(
      importType: 'registration',
      source: source,
      reason: reason,
    );
    state = state.copyWith(
      step: SlipImportStep.error,
      errorMessage: error.toString().replaceFirst('Exception: ', ''),
    );
  }
}
