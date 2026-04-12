import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/course_hub/data/models/course_note_model.dart';
import 'package:campusiq/features/course_hub/data/repositories/course_note_repository.dart';

part 'course_note_provider.g.dart';

final courseNoteRepositoryProvider = Provider<CourseNoteRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => CourseNoteRepository(isar));
});

@riverpod
Stream<List<CourseNoteModel>> courseNotes(Ref ref, String courseCode) {
  final repo = ref.watch(courseNoteRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchNotes(courseCode);
}
