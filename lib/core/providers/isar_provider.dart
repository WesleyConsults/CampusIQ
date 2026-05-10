import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/core/data/isar_database.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  return openCampusIqIsar();
});
