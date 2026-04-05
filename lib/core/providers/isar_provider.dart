import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';

/// Opens and provides a singleton Isar instance.
/// All features share this one database.
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [CourseModelSchema],
    directory: dir.path,
  );
});
