import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';

class UserPrefsRepository {
  final Isar _isar;
  UserPrefsRepository(this._isar);

  static const int _defaultPomodoroFocusMinutes = 25;
  static const int _defaultPomodoroShortBreakMinutes = 5;
  static const int _defaultPomodoroLongBreakMinutes = 15;
  static const int _defaultPomodoroTotalRounds = 4;
  static const int _defaultThemeModeIndex = 1;

  Future<UserPrefsModel> _getOrCreate() async {
    final existing = await _isar.userPrefsModels.get(1);
    if (existing != null) {
      await _normalizeMigratedPrefs(existing);
      return existing;
    }
    final prefs = UserPrefsModel();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
    return prefs;
  }

  Future<void> _normalizeMigratedPrefs(UserPrefsModel prefs) async {
    var changed = false;

    final focus = _validRangeOrDefault(
      prefs.defaultFocusMinutes,
      min: 10,
      max: 60,
      fallback: _defaultPomodoroFocusMinutes,
    );
    if (focus != prefs.defaultFocusMinutes) {
      prefs.defaultFocusMinutes = focus;
      changed = true;
    }

    final shortBreak = _validRangeOrDefault(
      prefs.defaultShortBreakMinutes,
      min: 5,
      max: 30,
      fallback: _defaultPomodoroShortBreakMinutes,
    );
    if (shortBreak != prefs.defaultShortBreakMinutes) {
      prefs.defaultShortBreakMinutes = shortBreak;
      changed = true;
    }

    final longBreak = _validRangeOrDefault(
      prefs.defaultLongBreakMinutes,
      min: 10,
      max: 60,
      fallback: _defaultPomodoroLongBreakMinutes,
    );
    if (longBreak != prefs.defaultLongBreakMinutes) {
      prefs.defaultLongBreakMinutes = longBreak;
      changed = true;
    }

    final rounds = _validRangeOrDefault(
      prefs.defaultTotalRounds,
      min: 2,
      max: 10,
      fallback: _defaultPomodoroTotalRounds,
    );
    if (rounds != prefs.defaultTotalRounds) {
      prefs.defaultTotalRounds = rounds;
      changed = true;
    }

    final themeMode = _validRangeOrDefault(
      prefs.themeModeIndex,
      min: 0,
      max: 2,
      fallback: _defaultThemeModeIndex,
    );
    if (themeMode != prefs.themeModeIndex) {
      prefs.themeModeIndex = themeMode;
      changed = true;
    }

    if (!changed) return;

    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  int _validRangeOrDefault(
    int value, {
    required int min,
    required int max,
    required int fallback,
  }) {
    if (value < min || value > max) return fallback;
    return value;
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

  // ── Pomodoro defaults ─────────────────────────────────────────────────────

  Future<int> getDefaultFocusMinutes() async {
    final prefs = await _getOrCreate();
    return prefs.defaultFocusMinutes;
  }

  Future<void> setDefaultFocusMinutes(int value) async {
    final prefs = await _getOrCreate();
    prefs.defaultFocusMinutes = value.clamp(10, 60).toInt();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<int> getDefaultShortBreakMinutes() async {
    final prefs = await _getOrCreate();
    return prefs.defaultShortBreakMinutes;
  }

  Future<void> setDefaultShortBreakMinutes(int value) async {
    final prefs = await _getOrCreate();
    prefs.defaultShortBreakMinutes = value.clamp(5, 30).toInt();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<int> getDefaultLongBreakMinutes() async {
    final prefs = await _getOrCreate();
    return prefs.defaultLongBreakMinutes;
  }

  Future<void> setDefaultLongBreakMinutes(int value) async {
    final prefs = await _getOrCreate();
    prefs.defaultLongBreakMinutes = value.clamp(10, 60).toInt();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<int> getDefaultTotalRounds() async {
    final prefs = await _getOrCreate();
    return prefs.defaultTotalRounds;
  }

  Future<void> setDefaultTotalRounds(int value) async {
    final prefs = await _getOrCreate();
    prefs.defaultTotalRounds = value.clamp(2, 10).toInt();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  // ── Timer feedback ────────────────────────────────────────────────────────

  Future<bool> getVibrateOnTimerEnd() async {
    final prefs = await _getOrCreate();
    return prefs.vibrateOnTimerEnd;
  }

  Future<void> setVibrateOnTimerEnd(bool value) async {
    final prefs = await _getOrCreate();
    prefs.vibrateOnTimerEnd = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<bool> getPlaySoundOnTimerEnd() async {
    final prefs = await _getOrCreate();
    return prefs.playSoundOnTimerEnd;
  }

  Future<void> setPlaySoundOnTimerEnd(bool value) async {
    final prefs = await _getOrCreate();
    prefs.playSoundOnTimerEnd = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  // ── Appearance ────────────────────────────────────────────────────────────

  Future<int> getThemeModeIndex() async {
    final prefs = await _getOrCreate();
    return prefs.themeModeIndex;
  }

  Future<void> setThemeModeIndex(int value) async {
    final prefs = await _getOrCreate();
    prefs.themeModeIndex = value.clamp(0, 2).toInt();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  // ── Active semester ───────────────────────────────────────────────────────

  Future<String> getActiveSemesterKey() async {
    final prefs = await _getOrCreate();
    final semesterKey = prefs.activeSemesterKey.trim();
    if (semesterKey.isEmpty) return AppConstants.defaultSemesterKey;
    return semesterKey;
  }

  Future<void> setActiveSemesterKey(String semesterKey) async {
    final prefs = await _getOrCreate();
    prefs.activeSemesterKey = semesterKey.trim().isEmpty
        ? AppConstants.defaultSemesterKey
        : semesterKey.trim();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<double> getTargetCwa() async {
    final prefs = await _getOrCreate();
    return prefs.targetCwa.clamp(40.0, AppConstants.maxCwa).toDouble();
  }

  Future<void> setTargetCwa(double value) async {
    final prefs = await _getOrCreate();
    prefs.targetCwa = value.clamp(40.0, AppConstants.maxCwa).toDouble();
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<String> getManualCwaDraftJson() async {
    final prefs = await _getOrCreate();
    return prefs.manualCwaDraftJson;
  }

  Future<void> setManualCwaDraftJson(String value) async {
    final prefs = await _getOrCreate();
    prefs.manualCwaDraftJson = value;
    try {
      await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    } catch (e) {
      debugPrint('🔴 Isar write failed: $e');
      rethrow;
    }
  }

  Future<void> clearManualCwaDraft() => setManualCwaDraftJson('');

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
