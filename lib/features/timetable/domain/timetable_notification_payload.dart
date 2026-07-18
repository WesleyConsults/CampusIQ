import 'dart:convert';

class TimetableNotificationPayload {
  const TimetableNotificationPayload({
    required this.type,
    required this.slotId,
    required this.semesterKey,
    required this.courseCode,
    required this.mode,
  });

  final String type;
  final String slotId;
  final String semesterKey;
  final String courseCode;
  final String mode;

  bool get isTimetableAlert => type == 'timetable_alert' && slotId.isNotEmpty;

  static TimetableNotificationPayload? parse(String? payload) {
    if (payload == null || payload.trim().isEmpty) return null;
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return TimetableNotificationPayload(
        type: json['type'] as String? ?? '',
        slotId: json['slotId'] as String? ?? '',
        semesterKey: json['semesterKey'] as String? ?? '',
        courseCode: json['courseCode'] as String? ?? '',
        mode: json['mode'] as String? ?? 'reminder',
      );
    } catch (_) {
      return null;
    }
  }
}
