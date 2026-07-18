class TimetableTimeParseResult {
  const TimetableTimeParseResult._({
    required this.rawValue,
    required this.minutes,
    required this.error,
  });

  factory TimetableTimeParseResult.success(String rawValue, int minutes) {
    return TimetableTimeParseResult._(
      rawValue: rawValue,
      minutes: minutes,
      error: null,
    );
  }

  factory TimetableTimeParseResult.failure(String rawValue, String error) {
    return TimetableTimeParseResult._(
      rawValue: rawValue,
      minutes: null,
      error: error,
    );
  }

  final String rawValue;
  final int? minutes;
  final String? error;

  bool get isValid => minutes != null;
}

TimetableTimeParseResult parseTimetableTime(String rawValue) {
  final original = rawValue;
  var value = rawValue.trim().replaceAll('\u00A0', ' ');
  if (value.isEmpty) {
    return TimetableTimeParseResult.failure(original, 'Missing time');
  }

  value = value.toUpperCase().replaceAll(RegExp(r'\s+'), '');
  final meridiemMatch = RegExp(r'(AM|PM)$').firstMatch(value);
  final meridiem = meridiemMatch?.group(1);
  if (meridiem != null) {
    value = value.substring(0, value.length - meridiem.length);
  }

  final match = RegExp(r'^(\d{1,2})(?:[:.](\d{1,2}))?$').firstMatch(value);
  if (match == null) {
    return TimetableTimeParseResult.failure(original, 'Unrecognised time');
  }

  var hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2) ?? '0');
  if (hour == null || minute == null) {
    return TimetableTimeParseResult.failure(original, 'Unrecognised time');
  }
  if (minute < 0 || minute > 59) {
    return TimetableTimeParseResult.failure(original, 'Invalid minute');
  }

  if (meridiem != null) {
    if (hour < 1 || hour > 12) {
      return TimetableTimeParseResult.failure(original, 'Invalid 12-hour time');
    }
    if (hour == 12) {
      hour = meridiem == 'AM' ? 0 : 12;
    } else if (meridiem == 'PM') {
      hour += 12;
    }
  } else if (hour < 0 || hour > 23) {
    return TimetableTimeParseResult.failure(original, 'Invalid 24-hour time');
  }

  return TimetableTimeParseResult.success(original, hour * 60 + minute);
}
