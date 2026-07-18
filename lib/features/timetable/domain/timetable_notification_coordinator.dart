import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
import 'package:campusiq/features/timetable/data/models/scheduled_timetable_notification_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/repositories/course_reminder_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/scheduled_timetable_notification_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

class TimetableNotificationSyncResult {
  const TimetableNotificationSyncResult({
    required this.desiredCount,
    required this.scheduledCount,
    required this.cancelledCount,
    required this.unchangedCount,
    required this.pendingTimetableCount,
    required this.legacyCancelledCount,
    required this.notificationsEnabled,
    required this.exactAlarmAvailable,
    required this.failedCount,
    required this.warnings,
    required this.failures,
  });

  final int desiredCount;
  final int scheduledCount;
  final int cancelledCount;
  final int unchangedCount;
  final int pendingTimetableCount;
  final int legacyCancelledCount;
  final bool notificationsEnabled;
  final bool exactAlarmAvailable;
  final int failedCount;
  final List<String> warnings;
  final List<TimetableNotificationFailure> failures;

  bool get hasPermissionFailure => failures
      .any((failure) => failure.reason == 'notification_permission_denied');

  bool get hasExactAlarmFailure =>
      failures.any((failure) => failure.reason == 'exact_alarms_not_permitted');

  String get summary {
    if (hasPermissionFailure) return 'Notification permission is required';
    if (hasExactAlarmFailure) return 'Exact alarm access is required';
    if (desiredCount == 0) return 'No matching timetable slots were found';
    final activeCount = scheduledCount + unchangedCount;
    if (failedCount > 0) {
      return '$activeCount of $desiredCount reminders scheduled';
    }
    return '$activeCount weekly class${activeCount == 1 ? '' : 'es'} scheduled';
  }
}

class TimetableNotificationFailure {
  const TimetableNotificationFailure({
    required this.logicalKey,
    required this.reason,
  });

  final String logicalKey;
  final String reason;
}

class TimetableNotificationCoordinator {
  TimetableNotificationCoordinator({
    required Isar isar,
    NotificationService? notificationService,
  })  : _notificationService =
            notificationService ?? NotificationService.instance,
        _timetableRepo = TimetableRepository(isar),
        _reminderRepo = CourseReminderRepository(isar),
        _registryRepo = ScheduledTimetableNotificationRepository(isar),
        _prefsRepo = UserPrefsRepository(isar);

  final NotificationService _notificationService;
  final TimetableRepository _timetableRepo;
  final CourseReminderRepository _reminderRepo;
  final ScheduledTimetableNotificationRepository _registryRepo;
  final UserPrefsRepository _prefsRepo;

  Future<TimetableNotificationSyncResult> reconcile({String? reason}) async {
    final warnings = <String>[];
    final failures = <TimetableNotificationFailure>[];
    var scheduledCount = 0;
    var cancelledCount = 0;
    var unchangedCount = 0;
    var legacyCancelledCount = 0;
    var pendingTimetableCount = 0;
    var notificationsEnabled = false;
    var exactAlarmAvailable = true;

    try {
      await _timetableRepo.getAllSlotsAcrossSemesters();
      final prefs = await _prefsRepo.getPrefs();
      if (!prefs.timetableLegacyNotificationsCleaned) {
        legacyCancelledCount =
            await _notificationService.cancelLegacyTimetableNotifications();
        await _prefsRepo.setTimetableLegacyNotificationsCleaned(true);
        debugPrint(
          'Timetable notification legacy cleanup cancelled $legacyCancelledCount ids.',
        );
      }

      final semesterKey = await _prefsRepo.getActiveSemesterKey();
      final slots = await _timetableRepo.getAllSlotsOnce(semesterKey);
      final reminders = await _reminderRepo.getReminders(semesterKey);
      final existingRecords = await _registryRepo.getAll();
      final existingByKey = {
        for (final record in existingRecords) record.logicalKey: record,
      };
      notificationsEnabled =
          await _notificationService.areNotificationsEnabled();
      exactAlarmAvailable = await _notificationService.canScheduleExactAlarms();
      final pendingIds = (await _notificationService.pendingNotifications())
          .map((request) => request.id)
          .toSet();
      pendingTimetableCount = existingRecords
          .where((record) => pendingIds.contains(record.notificationId))
          .length;

      final desired = <_DesiredTimetableNotification>[];
      final enabledReminders =
          reminders.where((reminder) => reminder.isEnabled);
      for (final reminder in enabledReminders) {
        final reminderCode = _normalizedReminderCode(reminder);
        if (reminderCode.isEmpty) {
          warnings.add('Skipped reminder with empty course code.');
          continue;
        }
        final matchingSlots = slots.where((slot) {
          final slotCode = _normalizedSlotCode(slot);
          return slotCode == reminderCode;
        }).toList()
          ..sort((a, b) {
            final day = a.dayIndex.compareTo(b.dayIndex);
            if (day != 0) return day;
            return a.startMinutes.compareTo(b.startMinutes);
          });

        for (final slot in matchingSlots) {
          final validationError = _slotValidationError(slot);
          if (validationError != null) {
            warnings.add('${slot.courseCode}: $validationError');
            continue;
          }
          desired.add(_DesiredTimetableNotification.from(
            slot: slot,
            reminder: reminder,
            normalizedCourseCode: reminderCode,
          ));
        }
      }

      if (!exactAlarmAvailable && desired.any((item) => item.isAlarm)) {
        failures.add(const TimetableNotificationFailure(
          logicalKey: 'exact_alarm',
          reason: 'exact_alarms_not_permitted',
        ));
        warnings.add('Exact alarm access is required for alarm mode.');
      }

      const iosPendingSafetyLimit = 56;
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          desired.length > iosPendingSafetyLimit) {
        warnings.add(
          'Only the first $iosPendingSafetyLimit timetable alerts were scheduled to protect the iOS pending notification limit.',
        );
        desired.removeRange(iosPendingSafetyLimit, desired.length);
      }

      final desiredKeys = desired.map((item) => item.logicalKey).toSet();
      final staleRecords = existingRecords
          .where((record) => !desiredKeys.contains(record.logicalKey))
          .toList();

      for (final record in staleRecords) {
        await _notificationService.cancelNotification(record.notificationId);
        cancelledCount++;
      }
      await _registryRepo.deleteByIds(staleRecords.map((r) => r.id).toList());

      if (!notificationsEnabled && desired.isNotEmpty) {
        failures.add(const TimetableNotificationFailure(
          logicalKey: 'permission',
          reason: 'notification_permission_denied',
        ));
        warnings.add('Notification permission is required.');
        final result = _buildResult(
          desiredCount: desired.length,
          scheduledCount: scheduledCount,
          cancelledCount: cancelledCount,
          unchangedCount: unchangedCount,
          pendingTimetableCount: pendingTimetableCount,
          legacyCancelledCount: legacyCancelledCount,
          notificationsEnabled: notificationsEnabled,
          exactAlarmAvailable: exactAlarmAvailable,
          warnings: warnings,
          failures: failures,
        );
        await _prefsRepo.setLastTimetableNotificationSync(
          syncedAt: DateTime.now(),
          summary: result.summary,
        );
        return result;
      }

      final recordsToSave = <ScheduledTimetableNotificationModel>[];
      final allocationPool = existingRecords
          .where((record) => desiredKeys.contains(record.logicalKey))
          .toList();

      for (final item in desired) {
        final existing = existingByKey[item.logicalKey];
        final record = existing ?? item.toRecord();
        if (existing == null) {
          record.notificationId = _registryRepo.allocateNotificationId(
            allocationPool,
          );
          allocationPool.add(record);
        }

        final changed = existing == null || item.isDifferentFrom(record);
        final missingFromOs = !pendingIds.contains(record.notificationId);

        if (!changed && !missingFromOs) {
          unchangedCount++;
          continue;
        }

        item.applyToRecord(record);
        try {
          await _notificationService.scheduleTimetableCourseAlert(
            id: record.notificationId,
            title: item.title,
            body: item.body,
            scheduledAt: item.scheduledAt,
            isAlarm: item.isAlarm,
            payload: item.payload,
          );
          scheduledCount++;
          recordsToSave.add(record);
        } on PlatformException catch (error, stackTrace) {
          failures.add(TimetableNotificationFailure(
            logicalKey: item.logicalKey,
            reason: error.code,
          ));
          if (missingFromOs && existing != null) {
            await _registryRepo.deleteById(existing.id);
          }
          await CrashReportingService.instance.recordNonFatalError(
            error,
            stackTrace,
            reason: 'timetable_notification_schedule_failed',
            context: {'sync_reason': reason ?? 'unknown'},
          );
        } catch (error, stackTrace) {
          failures.add(TimetableNotificationFailure(
            logicalKey: item.logicalKey,
            reason: error.toString(),
          ));
          if (missingFromOs && existing != null) {
            await _registryRepo.deleteById(existing.id);
          }
          await CrashReportingService.instance.recordNonFatalError(
            error,
            stackTrace,
            reason: 'timetable_notification_schedule_failed',
            context: {'sync_reason': reason ?? 'unknown'},
          );
        }
      }

      await _registryRepo.putAll(recordsToSave);

      final result = _buildResult(
        desiredCount: desired.length,
        scheduledCount: scheduledCount,
        cancelledCount: cancelledCount,
        unchangedCount: unchangedCount,
        pendingTimetableCount: pendingTimetableCount,
        legacyCancelledCount: legacyCancelledCount,
        notificationsEnabled: notificationsEnabled,
        exactAlarmAvailable: exactAlarmAvailable,
        warnings: warnings,
        failures: failures,
      );
      await _prefsRepo.setLastTimetableNotificationSync(
        syncedAt: DateTime.now(),
        summary: result.summary,
      );
      debugPrint('Timetable notification sync (${reason ?? 'unknown'}): '
          '${result.summary}; desired=${result.desiredCount}, '
          'scheduled=${result.scheduledCount}, unchanged=${result.unchangedCount}, '
          'failed=${result.failedCount}');
      return result;
    } catch (error, stackTrace) {
      debugPrint('Timetable notification sync failed: $error');
      await CrashReportingService.instance.recordNonFatalError(
        error,
        stackTrace,
        reason: 'timetable_notification_sync_failed',
        context: {'sync_reason': reason ?? 'unknown'},
      );
      return TimetableNotificationSyncResult(
        desiredCount: 0,
        scheduledCount: scheduledCount,
        cancelledCount: cancelledCount,
        unchangedCount: unchangedCount,
        pendingTimetableCount: pendingTimetableCount,
        legacyCancelledCount: legacyCancelledCount,
        notificationsEnabled: notificationsEnabled,
        exactAlarmAvailable: exactAlarmAvailable,
        failedCount: failures.length + 1,
        warnings: warnings,
        failures: [
          ...failures,
          TimetableNotificationFailure(
            logicalKey: 'reconcile',
            reason: error.toString(),
          ),
        ],
      );
    }
  }

  TimetableNotificationSyncResult _buildResult({
    required int desiredCount,
    required int scheduledCount,
    required int cancelledCount,
    required int unchangedCount,
    required int pendingTimetableCount,
    required int legacyCancelledCount,
    required bool notificationsEnabled,
    required bool exactAlarmAvailable,
    required List<String> warnings,
    required List<TimetableNotificationFailure> failures,
  }) {
    return TimetableNotificationSyncResult(
      desiredCount: desiredCount,
      scheduledCount: scheduledCount,
      cancelledCount: cancelledCount,
      unchangedCount: unchangedCount,
      pendingTimetableCount: pendingTimetableCount,
      legacyCancelledCount: legacyCancelledCount,
      notificationsEnabled: notificationsEnabled,
      exactAlarmAvailable: exactAlarmAvailable,
      failedCount: failures.length,
      warnings: warnings,
      failures: failures,
    );
  }

  String _normalizedSlotCode(TimetableSlotModel slot) {
    return slot.normalizedCourseCode.trim().isNotEmpty
        ? slot.normalizedCourseCode
        : normalizeCourseCode(slot.courseCode);
  }

  String _normalizedReminderCode(CourseReminderModel reminder) {
    return reminder.normalizedCourseCode.trim().isNotEmpty
        ? reminder.normalizedCourseCode
        : normalizeCourseCode(reminder.courseCode);
  }

  String? _slotValidationError(TimetableSlotModel slot) {
    if (slot.slotId.trim().isEmpty) return 'Missing slot identity';
    if (_normalizedSlotCode(slot).isEmpty) return 'Missing course code';
    if (slot.dayIndex < 0 ||
        slot.dayIndex >= TimetableConstants.dayLabels.length) {
      return 'Invalid day';
    }
    if (slot.startMinutes < 0 || slot.startMinutes >= 24 * 60) {
      return 'Invalid start time';
    }
    if (slot.endMinutes <= slot.startMinutes || slot.endMinutes > 24 * 60) {
      return 'Invalid end time';
    }
    return null;
  }
}

class _DesiredTimetableNotification {
  _DesiredTimetableNotification({
    required this.logicalKey,
    required this.slotId,
    required this.semesterKey,
    required this.normalizedCourseCode,
    required this.dayIndex,
    required this.classStartMinutes,
    required this.reminderMinutesBefore,
    required this.isAlarm,
    required this.scheduledAt,
    required this.title,
    required this.body,
    required this.payload,
  });

  factory _DesiredTimetableNotification.from({
    required TimetableSlotModel slot,
    required CourseReminderModel reminder,
    required String normalizedCourseCode,
  }) {
    final scheduledAt = nextWeeklyCourseReminderTime(
      now: DateTime.now(),
      dayIndex: slot.dayIndex,
      classStartMinutes: slot.startMinutes,
      offsetMinutes: reminder.offsetMinutes,
    );
    final day = TimetableConstants.dayLabels[slot.dayIndex];
    final start = TimetableConstants.minutesToLabel(slot.startMinutes);
    final isAlarm = reminder.isAlarm;
    final payload = jsonEncode({
      'type': 'timetable_alert',
      'slotId': slot.slotId,
      'semesterKey': slot.semesterKey,
      'courseCode': slot.courseCode,
      'mode': isAlarm ? 'alarm' : 'reminder',
    });

    return _DesiredTimetableNotification(
      logicalKey: 'course-alert:${slot.slotId}',
      slotId: slot.slotId,
      semesterKey: slot.semesterKey,
      normalizedCourseCode: normalizedCourseCode,
      dayIndex: slot.dayIndex,
      classStartMinutes: slot.startMinutes,
      reminderMinutesBefore: reminder.offsetMinutes,
      isAlarm: isAlarm,
      scheduledAt: scheduledAt,
      title: isAlarm
          ? '${slot.courseCode} Class Starts Soon'
          : '${slot.courseCode} starts soon',
      body: isAlarm
          ? '${slot.courseName} starts in ${reminder.offsetMinutes} mins. Tap to dismiss.'
          : '${slot.courseName} is at $start on $day.',
      payload: payload,
    );
  }

  final String logicalKey;
  final String slotId;
  final String semesterKey;
  final String normalizedCourseCode;
  final int dayIndex;
  final int classStartMinutes;
  final int reminderMinutesBefore;
  final bool isAlarm;
  final DateTime scheduledAt;
  final String title;
  final String body;
  final String payload;

  bool isDifferentFrom(ScheduledTimetableNotificationModel record) {
    return record.slotId != slotId ||
        record.semesterKey != semesterKey ||
        record.normalizedCourseCode != normalizedCourseCode ||
        record.dayIndex != dayIndex ||
        record.classStartMinutes != classStartMinutes ||
        record.reminderMinutesBefore != reminderMinutesBefore ||
        record.isAlarm != isAlarm ||
        record.scheduledWeekday != scheduledAt.weekday ||
        record.scheduledHour != scheduledAt.hour ||
        record.scheduledMinute != scheduledAt.minute ||
        record.title != title ||
        record.body != body ||
        record.payload != payload;
  }

  ScheduledTimetableNotificationModel toRecord() {
    return ScheduledTimetableNotificationModel()..logicalKey = logicalKey;
  }

  void applyToRecord(ScheduledTimetableNotificationModel record) {
    record
      ..logicalKey = logicalKey
      ..slotId = slotId
      ..semesterKey = semesterKey
      ..normalizedCourseCode = normalizedCourseCode
      ..dayIndex = dayIndex
      ..classStartMinutes = classStartMinutes
      ..reminderMinutesBefore = reminderMinutesBefore
      ..isAlarm = isAlarm
      ..scheduledWeekday = scheduledAt.weekday
      ..scheduledHour = scheduledAt.hour
      ..scheduledMinute = scheduledAt.minute
      ..title = title
      ..body = body
      ..payload = payload
      ..updatedAt = DateTime.now();
  }
}
