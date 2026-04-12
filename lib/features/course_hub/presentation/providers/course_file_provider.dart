import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/course_hub/data/models/course_file_model.dart';
import 'package:campusiq/features/course_hub/data/repositories/course_file_repository.dart';

part 'course_file_provider.g.dart';

final courseFileRepositoryProvider = Provider<CourseFileRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => CourseFileRepository(isar));
});

@riverpod
Stream<List<CourseFileModel>> courseFiles(Ref ref, String courseCode) {
  final repo = ref.watch(courseFileRepositoryProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchFiles(courseCode);
}
