import 'package:isar/isar.dart';

part 'user_prefs_model.g.dart';

/// Single-row key/value store for lightweight persistent app preferences.
/// Only one instance ever exists (id = 1).
@collection
class UserPrefsModel {
  Id id = 1; // always 1 — single row

  /// JSON-encoded list of ISO date strings the student marked attendance.
  /// e.g. '["2024-11-04","2024-11-05"]'
  String attendedDatesJson = '[]';

  /// Last date the app was opened — used for streak alive check.
  DateTime? lastOpenedDate;

  UserPrefsModel();
}
