import 'package:flutter_test/flutter_test.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/timetable/domain/timetable_notification_payload.dart';

void main() {
  group('TimetableNotificationPayload', () {
    test('parses timetable alert payloads', () {
      final payload = TimetableNotificationPayload.parse(
        '{"type":"timetable_alert","slotId":"slot-1","semesterKey":"2026-Sem1","courseCode":"CS 201","mode":"alarm"}',
      );

      expect(payload, isNotNull);
      expect(payload!.isTimetableAlert, isTrue);
      expect(payload.slotId, 'slot-1');
      expect(payload.mode, 'alarm');
    });

    test('ignores malformed payloads', () {
      expect(TimetableNotificationPayload.parse('not json'), isNull);
      expect(TimetableNotificationPayload.parse(null), isNull);
    });

    test('test reminder id stays outside real timetable id allocation', () {
      expect(
        NotificationService.timetableTestNotificationId,
        greaterThanOrEqualTo(999000),
      );
    });
  });
}
