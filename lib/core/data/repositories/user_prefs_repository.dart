import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';

class UserPrefsRepository {
  final Isar _isar;
  UserPrefsRepository(this._isar);

  Future<UserPrefsModel> _getOrCreate() async {
    final existing = await _isar.userPrefsModels.get(1);
    if (existing != null) return existing;
    final prefs = UserPrefsModel();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
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
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> updateLastOpened(DateTime date) async {
    final prefs = await _getOrCreate();
    prefs.lastOpenedDate = date;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  /// Returns the full prefs object (for reading notification settings).
  Future<UserPrefsModel> getPrefs() => _getOrCreate();

  Future<void> setNotificationPermissionAsked(bool value) async {
    final prefs = await _getOrCreate();
    prefs.notificationPermissionAsked = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> setNotifyStudyReminders(bool value) async {
    final prefs = await _getOrCreate();
    prefs.notifyStudyReminders = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> setNotifyStreakAlerts(bool value) async {
    final prefs = await _getOrCreate();
    prefs.notifyStreakAlerts = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> setNotifyMilestoneAlerts(bool value) async {
    final prefs = await _getOrCreate();
    prefs.notifyMilestoneAlerts = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> setNotifyWeeklyReview(bool value) async {
    final prefs = await _getOrCreate();
    prefs.notifyWeeklyReview = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> setDailyReminderTime(int hour, int minute) async {
    final prefs = await _getOrCreate();
    prefs.dailyReminderHour = hour;
    prefs.dailyReminderMinute = minute;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  // ── Weekly Review helpers ─────────────────────────────────────────────────

  Future<String?> getWeeklyNote(String weekKey) async {
    final prefs = await _getOrCreate();
    final raw = prefs.weeklyNotesJson;
    if (raw.isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(raw);
      return map[weekKey] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> setWeeklyNote(String weekKey, String note) async {
    final prefs = await _getOrCreate();
    final raw = prefs.weeklyNotesJson;
    Map<String, dynamic> map = {};
    if (raw.isNotEmpty) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {}
    }
    map[weekKey] = note;
    prefs.weeklyNotesJson = jsonEncode(map);
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> setLastReviewShownWeek(String weekKey) async {
    final prefs = await _getOrCreate();
    prefs.lastReviewShownWeek = weekKey;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  static String _toStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
