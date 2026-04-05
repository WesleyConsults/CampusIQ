import 'package:isar/isar.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

class CwaRepository {
  final Isar _isar;
  CwaRepository(this._isar);

  /// Live stream — re-emits whenever courses change in Isar.
  Stream<List<CourseModel>> watchCourses(String semesterKey) {
    return _isar.courseModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .watch(fireImmediately: true);
  }

  Future<void> addCourse(CourseModel course) async {
    await _isar.writeTxn(() => _isar.courseModels.put(course));
  }

  Future<void> updateCourse(CourseModel course) async {
    await _isar.writeTxn(() => _isar.courseModels.put(course));
  }

  Future<void> deleteCourse(Id id) async {
    await _isar.writeTxn(() => _isar.courseModels.delete(id));
  }
}
