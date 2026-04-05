import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';

class UserPrefsRepository {
  final Isar _isar;
  UserPrefsRepository(this._isar);

  Future<UserPrefsModel> _getOrCreate() async {
    final existing = await _isar.userPrefsModels.get(1);
    if (existing != null) return existing;
    final prefs = UserPrefsModel();
    await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    return prefs;
  }

  Stream<UserPrefsModel?> watchPrefs() {
    return _isar.userPrefsModels.watchObject(1, fireImmediately: true);
  }

  /// Returns the list of dates the student marked attendance.
  Future<List<DateTime>> getAttendedDates() async {
    final prefs = await _getOrCreate();
    final List<dynamic> decoded = jsonDecode(prefs.attendedDatesJson);
    return decoded
        .map((s) => DateTime.tryParse(s as String))
        .whereType<DateTime>()
        .toList();
  }

  /// Toggles attendance for a date (adds if absent, removes if present).
  Future<void> toggleAttendance(DateTime date) async {
    final prefs = await _getOrCreate();
    final dates = await getAttendedDates();
    final dateStr = _toStr(date);
    final strList = dates.map(_toStr).toList();

    if (strList.contains(dateStr)) {
      strList.remove(dateStr);
    } else {
      strList.add(dateStr);
    }

    prefs.attendedDatesJson = jsonEncode(strList);
    await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
  }

  Future<void> updateLastOpened(DateTime date) async {
    final prefs = await _getOrCreate();
    prefs.lastOpenedDate = date;
    await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
  }

  static String _toStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
