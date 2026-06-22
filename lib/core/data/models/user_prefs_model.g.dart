// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_prefs_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPrefsModelCollection on Isar {
  IsarCollection<UserPrefsModel> get userPrefsModels => this.collection();
}

const UserPrefsModelSchema = CollectionSchema(
  name: r'UserPrefsModel',
  id: 606924911293826107,
  properties: {
    r'attendedDatesJson': PropertySchema(
      id: 0,
      name: r'attendedDatesJson',
      type: IsarType.string,
    ),
    r'dailyReminderHour': PropertySchema(
      id: 1,
      name: r'dailyReminderHour',
      type: IsarType.long,
    ),
    r'dailyReminderMinute': PropertySchema(
      id: 2,
      name: r'dailyReminderMinute',
      type: IsarType.long,
    ),
    r'lastOpenedDate': PropertySchema(
      id: 3,
      name: r'lastOpenedDate',
      type: IsarType.dateTime,
    ),
    r'lastReviewShownWeek': PropertySchema(
      id: 4,
      name: r'lastReviewShownWeek',
      type: IsarType.string,
    ),
    r'notificationPermissionAsked': PropertySchema(
      id: 5,
      name: r'notificationPermissionAsked',
      type: IsarType.bool,
    ),
    r'notifyMilestoneAlerts': PropertySchema(
      id: 6,
      name: r'notifyMilestoneAlerts',
      type: IsarType.bool,
    ),
    r'notifyStreakAlerts': PropertySchema(
      id: 7,
      name: r'notifyStreakAlerts',
      type: IsarType.bool,
    ),
    r'notifyStudyReminders': PropertySchema(
      id: 8,
      name: r'notifyStudyReminders',
      type: IsarType.bool,
    ),
    r'notifyWeeklyReview': PropertySchema(
      id: 9,
      name: r'notifyWeeklyReview',
      type: IsarType.bool,
    ),
    r'weeklyNotesJson': PropertySchema(
      id: 10,
      name: r'weeklyNotesJson',
      type: IsarType.string,
    ),
    r'zzActiveSemesterKey': PropertySchema(
      id: 11,
      name: r'zzActiveSemesterKey',
      type: IsarType.string,
    ),
    r'zzCwaSetupTargetConfirmed': PropertySchema(
      id: 12,
      name: r'zzCwaSetupTargetConfirmed',
      type: IsarType.bool,
    ),
    r'zzGradingSystemId': PropertySchema(
      id: 13,
      name: r'zzGradingSystemId',
      type: IsarType.string,
    ),
    r'zzHasCompletedOnboarding': PropertySchema(
      id: 14,
      name: r'zzHasCompletedOnboarding',
      type: IsarType.bool,
    ),
    r'zzManualCwaDraftJson': PropertySchema(
      id: 15,
      name: r'zzManualCwaDraftJson',
      type: IsarType.string,
    ),
    r'zzPomodoroFocusMinutes': PropertySchema(
      id: 16,
      name: r'zzPomodoroFocusMinutes',
      type: IsarType.long,
    ),
    r'zzPomodoroLongBreakMinutes': PropertySchema(
      id: 17,
      name: r'zzPomodoroLongBreakMinutes',
      type: IsarType.long,
    ),
    r'zzPomodoroShortBreakMinutes': PropertySchema(
      id: 18,
      name: r'zzPomodoroShortBreakMinutes',
      type: IsarType.long,
    ),
    r'zzPomodoroTotalRounds': PropertySchema(
      id: 19,
      name: r'zzPomodoroTotalRounds',
      type: IsarType.long,
    ),
    r'zzProgrammeName': PropertySchema(
      id: 20,
      name: r'zzProgrammeName',
      type: IsarType.string,
    ),
    r'zzSoundOnTimerEnd': PropertySchema(
      id: 21,
      name: r'zzSoundOnTimerEnd',
      type: IsarType.bool,
    ),
    r'zzTargetCwa': PropertySchema(
      id: 22,
      name: r'zzTargetCwa',
      type: IsarType.double,
    ),
    r'zzThemeModeIndex': PropertySchema(
      id: 23,
      name: r'zzThemeModeIndex',
      type: IsarType.long,
    ),
    r'zzTimetableGridLayoutIndex': PropertySchema(
      id: 24,
      name: r'zzTimetableGridLayoutIndex',
      type: IsarType.long,
    ),
    r'zzUniversityName': PropertySchema(
      id: 25,
      name: r'zzUniversityName',
      type: IsarType.string,
    ),
    r'zzVibrateOnTimerEnd': PropertySchema(
      id: 26,
      name: r'zzVibrateOnTimerEnd',
      type: IsarType.bool,
    ),
    r'zzzManualBaselineCredits': PropertySchema(
      id: 27,
      name: r'zzzManualBaselineCredits',
      type: IsarType.double,
    ),
    r'zzzManualBaselineCwa': PropertySchema(
      id: 28,
      name: r'zzzManualBaselineCwa',
      type: IsarType.double,
    ),
    r'zzzManualBaselineGradingSystemId': PropertySchema(
      id: 29,
      name: r'zzzManualBaselineGradingSystemId',
      type: IsarType.string,
    )
  },
  estimateSize: _userPrefsModelEstimateSize,
  serialize: _userPrefsModelSerialize,
  deserialize: _userPrefsModelDeserialize,
  deserializeProp: _userPrefsModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userPrefsModelGetId,
  getLinks: _userPrefsModelGetLinks,
  attach: _userPrefsModelAttach,
  version: '3.3.0-dev.1',
);

int _userPrefsModelEstimateSize(
  UserPrefsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.attendedDatesJson.length * 3;
  bytesCount += 3 + object.lastReviewShownWeek.length * 3;
  bytesCount += 3 + object.weeklyNotesJson.length * 3;
  bytesCount += 3 + object.activeSemesterKey.length * 3;
  bytesCount += 3 + object.gradingSystemId.length * 3;
  bytesCount += 3 + object.manualCwaDraftJson.length * 3;
  {
    final value = object.programmeName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.universityName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.manualBaselineGradingSystemId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userPrefsModelSerialize(
  UserPrefsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.attendedDatesJson);
  writer.writeLong(offsets[1], object.dailyReminderHour);
  writer.writeLong(offsets[2], object.dailyReminderMinute);
  writer.writeDateTime(offsets[3], object.lastOpenedDate);
  writer.writeString(offsets[4], object.lastReviewShownWeek);
  writer.writeBool(offsets[5], object.notificationPermissionAsked);
  writer.writeBool(offsets[6], object.notifyMilestoneAlerts);
  writer.writeBool(offsets[7], object.notifyStreakAlerts);
  writer.writeBool(offsets[8], object.notifyStudyReminders);
  writer.writeBool(offsets[9], object.notifyWeeklyReview);
  writer.writeString(offsets[10], object.weeklyNotesJson);
  writer.writeString(offsets[11], object.activeSemesterKey);
  writer.writeBool(offsets[12], object.cwaSetupTargetConfirmed);
  writer.writeString(offsets[13], object.gradingSystemId);
  writer.writeBool(offsets[14], object.hasCompletedOnboarding);
  writer.writeString(offsets[15], object.manualCwaDraftJson);
  writer.writeLong(offsets[16], object.defaultFocusMinutes);
  writer.writeLong(offsets[17], object.defaultLongBreakMinutes);
  writer.writeLong(offsets[18], object.defaultShortBreakMinutes);
  writer.writeLong(offsets[19], object.defaultTotalRounds);
  writer.writeString(offsets[20], object.programmeName);
  writer.writeBool(offsets[21], object.playSoundOnTimerEnd);
  writer.writeDouble(offsets[22], object.targetCwa);
  writer.writeLong(offsets[23], object.themeModeIndex);
  writer.writeLong(offsets[24], object.timetableGridLayoutIndex);
  writer.writeString(offsets[25], object.universityName);
  writer.writeBool(offsets[26], object.vibrateOnTimerEnd);
  writer.writeDouble(offsets[27], object.manualBaselineCredits);
  writer.writeDouble(offsets[28], object.manualBaselineCwa);
  writer.writeString(offsets[29], object.manualBaselineGradingSystemId);
}

UserPrefsModel _userPrefsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPrefsModel();
  object.attendedDatesJson = reader.readString(offsets[0]);
  object.dailyReminderHour = reader.readLong(offsets[1]);
  object.dailyReminderMinute = reader.readLong(offsets[2]);
  object.id = id;
  object.lastOpenedDate = reader.readDateTimeOrNull(offsets[3]);
  object.lastReviewShownWeek = reader.readString(offsets[4]);
  object.notificationPermissionAsked = reader.readBool(offsets[5]);
  object.notifyMilestoneAlerts = reader.readBool(offsets[6]);
  object.notifyStreakAlerts = reader.readBool(offsets[7]);
  object.notifyStudyReminders = reader.readBool(offsets[8]);
  object.notifyWeeklyReview = reader.readBool(offsets[9]);
  object.weeklyNotesJson = reader.readString(offsets[10]);
  object.activeSemesterKey = reader.readString(offsets[11]);
  object.cwaSetupTargetConfirmed = reader.readBool(offsets[12]);
  object.gradingSystemId = reader.readString(offsets[13]);
  object.hasCompletedOnboarding = reader.readBool(offsets[14]);
  object.manualCwaDraftJson = reader.readString(offsets[15]);
  object.defaultFocusMinutes = reader.readLong(offsets[16]);
  object.defaultLongBreakMinutes = reader.readLong(offsets[17]);
  object.defaultShortBreakMinutes = reader.readLong(offsets[18]);
  object.defaultTotalRounds = reader.readLong(offsets[19]);
  object.programmeName = reader.readStringOrNull(offsets[20]);
  object.playSoundOnTimerEnd = reader.readBool(offsets[21]);
  object.targetCwa = reader.readDouble(offsets[22]);
  object.themeModeIndex = reader.readLong(offsets[23]);
  object.timetableGridLayoutIndex = reader.readLong(offsets[24]);
  object.universityName = reader.readStringOrNull(offsets[25]);
  object.vibrateOnTimerEnd = reader.readBool(offsets[26]);
  object.manualBaselineCredits = reader.readDoubleOrNull(offsets[27]);
  object.manualBaselineCwa = reader.readDoubleOrNull(offsets[28]);
  object.manualBaselineGradingSystemId = reader.readStringOrNull(offsets[29]);
  return object;
}

P _userPrefsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readDouble(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readLong(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readBool(offset)) as P;
    case 27:
      return (reader.readDoubleOrNull(offset)) as P;
    case 28:
      return (reader.readDoubleOrNull(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPrefsModelGetId(UserPrefsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPrefsModelGetLinks(UserPrefsModel object) {
  return [];
}

void _userPrefsModelAttach(
    IsarCollection<dynamic> col, Id id, UserPrefsModel object) {
  object.id = id;
}

extension UserPrefsModelQueryWhereSort
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QWhere> {
  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPrefsModelQueryWhere
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QWhereClause> {
  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserPrefsModelQueryFilter
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QFilterCondition> {
  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attendedDatesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attendedDatesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attendedDatesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attendedDatesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attendedDatesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attendedDatesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attendedDatesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attendedDatesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attendedDatesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      attendedDatesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attendedDatesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyReminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyReminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyReminderHour',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyReminderHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyReminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyReminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyReminderMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      dailyReminderMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyReminderMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastOpenedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastOpenedDate',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastOpenedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastOpenedDate',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastOpenedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastOpenedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastOpenedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastOpenedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastOpenedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastOpenedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastOpenedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastOpenedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReviewShownWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReviewShownWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReviewShownWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReviewShownWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastReviewShownWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastReviewShownWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastReviewShownWeek',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastReviewShownWeek',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReviewShownWeek',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      lastReviewShownWeekIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastReviewShownWeek',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      notificationPermissionAskedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationPermissionAsked',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      notifyMilestoneAlertsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifyMilestoneAlerts',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      notifyStreakAlertsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifyStreakAlerts',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      notifyStudyRemindersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifyStudyReminders',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      notifyWeeklyReviewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifyWeeklyReview',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyNotesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyNotesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyNotesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyNotesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weeklyNotesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weeklyNotesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weeklyNotesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weeklyNotesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyNotesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      weeklyNotesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weeklyNotesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzActiveSemesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzActiveSemesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzActiveSemesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzActiveSemesterKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zzActiveSemesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zzActiveSemesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zzActiveSemesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zzActiveSemesterKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzActiveSemesterKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      activeSemesterKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zzActiveSemesterKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      cwaSetupTargetConfirmedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzCwaSetupTargetConfirmed',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzGradingSystemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zzGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zzGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zzGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zzGradingSystemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzGradingSystemId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      gradingSystemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zzGradingSystemId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      hasCompletedOnboardingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzHasCompletedOnboarding',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzManualCwaDraftJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzManualCwaDraftJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzManualCwaDraftJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzManualCwaDraftJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zzManualCwaDraftJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zzManualCwaDraftJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zzManualCwaDraftJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zzManualCwaDraftJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzManualCwaDraftJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualCwaDraftJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zzManualCwaDraftJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultFocusMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzPomodoroFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultFocusMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzPomodoroFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultFocusMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzPomodoroFocusMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultFocusMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzPomodoroFocusMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultLongBreakMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzPomodoroLongBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultLongBreakMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzPomodoroLongBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultLongBreakMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzPomodoroLongBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultLongBreakMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzPomodoroLongBreakMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultShortBreakMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzPomodoroShortBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultShortBreakMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzPomodoroShortBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultShortBreakMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzPomodoroShortBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultShortBreakMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzPomodoroShortBreakMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultTotalRoundsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzPomodoroTotalRounds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultTotalRoundsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzPomodoroTotalRounds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultTotalRoundsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzPomodoroTotalRounds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      defaultTotalRoundsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzPomodoroTotalRounds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'zzProgrammeName',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'zzProgrammeName',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzProgrammeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzProgrammeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzProgrammeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzProgrammeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zzProgrammeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zzProgrammeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zzProgrammeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zzProgrammeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzProgrammeName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      programmeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zzProgrammeName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      playSoundOnTimerEndEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzSoundOnTimerEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      targetCwaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzTargetCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      targetCwaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzTargetCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      targetCwaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzTargetCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      targetCwaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzTargetCwa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      themeModeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzThemeModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      themeModeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzThemeModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      themeModeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzThemeModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      themeModeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzThemeModeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      timetableGridLayoutIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzTimetableGridLayoutIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      timetableGridLayoutIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzTimetableGridLayoutIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      timetableGridLayoutIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzTimetableGridLayoutIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      timetableGridLayoutIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzTimetableGridLayoutIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'zzUniversityName',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'zzUniversityName',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzUniversityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzUniversityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzUniversityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzUniversityName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zzUniversityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zzUniversityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zzUniversityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zzUniversityName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzUniversityName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      universityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zzUniversityName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      vibrateOnTimerEndEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzVibrateOnTimerEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCreditsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'zzzManualBaselineCredits',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCreditsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'zzzManualBaselineCredits',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCreditsEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzzManualBaselineCredits',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCreditsGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzzManualBaselineCredits',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCreditsLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzzManualBaselineCredits',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCreditsBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzzManualBaselineCredits',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCwaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'zzzManualBaselineCwa',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCwaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'zzzManualBaselineCwa',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCwaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzzManualBaselineCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCwaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzzManualBaselineCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCwaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzzManualBaselineCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineCwaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzzManualBaselineCwa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'zzzManualBaselineGradingSystemId',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'zzzManualBaselineGradingSystemId',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzzManualBaselineGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zzzManualBaselineGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zzzManualBaselineGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zzzManualBaselineGradingSystemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zzzManualBaselineGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zzzManualBaselineGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zzzManualBaselineGradingSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zzzManualBaselineGradingSystemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zzzManualBaselineGradingSystemId',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterFilterCondition>
      manualBaselineGradingSystemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zzzManualBaselineGradingSystemId',
        value: '',
      ));
    });
  }
}

extension UserPrefsModelQueryObject
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QFilterCondition> {}

extension UserPrefsModelQueryLinks
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QFilterCondition> {}

extension UserPrefsModelQuerySortBy
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QSortBy> {
  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByAttendedDatesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendedDatesJson', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByAttendedDatesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendedDatesJson', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDailyReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderHour', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDailyReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderHour', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDailyReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderMinute', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDailyReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderMinute', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByLastOpenedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedDate', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByLastOpenedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedDate', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByLastReviewShownWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewShownWeek', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByLastReviewShownWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewShownWeek', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotificationPermissionAsked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationPermissionAsked', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotificationPermissionAskedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationPermissionAsked', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyMilestoneAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyMilestoneAlerts', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyMilestoneAlertsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyMilestoneAlerts', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyStreakAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStreakAlerts', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyStreakAlertsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStreakAlerts', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyStudyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStudyReminders', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyStudyRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStudyReminders', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyWeeklyReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyWeeklyReview', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByNotifyWeeklyReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyWeeklyReview', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByWeeklyNotesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyNotesJson', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByWeeklyNotesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyNotesJson', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByActiveSemesterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzActiveSemesterKey', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByActiveSemesterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzActiveSemesterKey', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByCwaSetupTargetConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzCwaSetupTargetConfirmed', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByCwaSetupTargetConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzCwaSetupTargetConfirmed', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByGradingSystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzGradingSystemId', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByGradingSystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzGradingSystemId', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzHasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzHasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualCwaDraftJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzManualCwaDraftJson', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualCwaDraftJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzManualCwaDraftJson', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultLongBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroLongBreakMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultLongBreakMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroLongBreakMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultShortBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroShortBreakMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultShortBreakMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroShortBreakMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultTotalRounds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroTotalRounds', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByDefaultTotalRoundsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroTotalRounds', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByProgrammeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzProgrammeName', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByProgrammeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzProgrammeName', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByPlaySoundOnTimerEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzSoundOnTimerEnd', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByPlaySoundOnTimerEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzSoundOnTimerEnd', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy> sortByTargetCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTargetCwa', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByTargetCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTargetCwa', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzThemeModeIndex', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByThemeModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzThemeModeIndex', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByTimetableGridLayoutIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTimetableGridLayoutIndex', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByTimetableGridLayoutIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTimetableGridLayoutIndex', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByUniversityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzUniversityName', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByUniversityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzUniversityName', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByVibrateOnTimerEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzVibrateOnTimerEnd', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByVibrateOnTimerEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzVibrateOnTimerEnd', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualBaselineCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCredits', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualBaselineCreditsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCredits', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualBaselineCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCwa', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualBaselineCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCwa', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualBaselineGradingSystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineGradingSystemId', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      sortByManualBaselineGradingSystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineGradingSystemId', Sort.desc);
    });
  }
}

extension UserPrefsModelQuerySortThenBy
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QSortThenBy> {
  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByAttendedDatesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendedDatesJson', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByAttendedDatesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendedDatesJson', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDailyReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderHour', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDailyReminderHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderHour', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDailyReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderMinute', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDailyReminderMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyReminderMinute', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByLastOpenedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedDate', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByLastOpenedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOpenedDate', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByLastReviewShownWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewShownWeek', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByLastReviewShownWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReviewShownWeek', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotificationPermissionAsked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationPermissionAsked', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotificationPermissionAskedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationPermissionAsked', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyMilestoneAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyMilestoneAlerts', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyMilestoneAlertsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyMilestoneAlerts', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyStreakAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStreakAlerts', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyStreakAlertsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStreakAlerts', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyStudyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStudyReminders', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyStudyRemindersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyStudyReminders', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyWeeklyReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyWeeklyReview', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByNotifyWeeklyReviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifyWeeklyReview', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByWeeklyNotesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyNotesJson', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByWeeklyNotesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyNotesJson', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByActiveSemesterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzActiveSemesterKey', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByActiveSemesterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzActiveSemesterKey', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByCwaSetupTargetConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzCwaSetupTargetConfirmed', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByCwaSetupTargetConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzCwaSetupTargetConfirmed', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByGradingSystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzGradingSystemId', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByGradingSystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzGradingSystemId', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzHasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzHasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualCwaDraftJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzManualCwaDraftJson', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualCwaDraftJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzManualCwaDraftJson', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroFocusMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultFocusMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroFocusMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultLongBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroLongBreakMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultLongBreakMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroLongBreakMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultShortBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroShortBreakMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultShortBreakMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroShortBreakMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultTotalRounds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroTotalRounds', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByDefaultTotalRoundsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzPomodoroTotalRounds', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByProgrammeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzProgrammeName', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByProgrammeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzProgrammeName', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByPlaySoundOnTimerEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzSoundOnTimerEnd', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByPlaySoundOnTimerEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzSoundOnTimerEnd', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy> thenByTargetCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTargetCwa', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByTargetCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTargetCwa', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzThemeModeIndex', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByThemeModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzThemeModeIndex', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByTimetableGridLayoutIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTimetableGridLayoutIndex', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByTimetableGridLayoutIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzTimetableGridLayoutIndex', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByUniversityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzUniversityName', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByUniversityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzUniversityName', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByVibrateOnTimerEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzVibrateOnTimerEnd', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByVibrateOnTimerEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzVibrateOnTimerEnd', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualBaselineCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCredits', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualBaselineCreditsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCredits', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualBaselineCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCwa', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualBaselineCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineCwa', Sort.desc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualBaselineGradingSystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineGradingSystemId', Sort.asc);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QAfterSortBy>
      thenByManualBaselineGradingSystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zzzManualBaselineGradingSystemId', Sort.desc);
    });
  }
}

extension UserPrefsModelQueryWhereDistinct
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct> {
  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByAttendedDatesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attendedDatesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByDailyReminderHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyReminderHour');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByDailyReminderMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyReminderMinute');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByLastOpenedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOpenedDate');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByLastReviewShownWeek({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReviewShownWeek',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByNotificationPermissionAsked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationPermissionAsked');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByNotifyMilestoneAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifyMilestoneAlerts');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByNotifyStreakAlerts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifyStreakAlerts');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByNotifyStudyReminders() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifyStudyReminders');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByNotifyWeeklyReview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifyWeeklyReview');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByWeeklyNotesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyNotesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByActiveSemesterKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzActiveSemesterKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByCwaSetupTargetConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzCwaSetupTargetConfirmed');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByGradingSystemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzGradingSystemId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzHasCompletedOnboarding');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByManualCwaDraftJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzManualCwaDraftJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByDefaultFocusMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzPomodoroFocusMinutes');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByDefaultLongBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzPomodoroLongBreakMinutes');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByDefaultShortBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzPomodoroShortBreakMinutes');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByDefaultTotalRounds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzPomodoroTotalRounds');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByProgrammeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzProgrammeName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByPlaySoundOnTimerEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzSoundOnTimerEnd');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByTargetCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzTargetCwa');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzThemeModeIndex');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByTimetableGridLayoutIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzTimetableGridLayoutIndex');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByUniversityName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzUniversityName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByVibrateOnTimerEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzVibrateOnTimerEnd');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByManualBaselineCredits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzzManualBaselineCredits');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByManualBaselineCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzzManualBaselineCwa');
    });
  }

  QueryBuilder<UserPrefsModel, UserPrefsModel, QDistinct>
      distinctByManualBaselineGradingSystemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zzzManualBaselineGradingSystemId',
          caseSensitive: caseSensitive);
    });
  }
}

extension UserPrefsModelQueryProperty
    on QueryBuilder<UserPrefsModel, UserPrefsModel, QQueryProperty> {
  QueryBuilder<UserPrefsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPrefsModel, String, QQueryOperations>
      attendedDatesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attendedDatesJson');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations>
      dailyReminderHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyReminderHour');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations>
      dailyReminderMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyReminderMinute');
    });
  }

  QueryBuilder<UserPrefsModel, DateTime?, QQueryOperations>
      lastOpenedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOpenedDate');
    });
  }

  QueryBuilder<UserPrefsModel, String, QQueryOperations>
      lastReviewShownWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReviewShownWeek');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      notificationPermissionAskedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationPermissionAsked');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      notifyMilestoneAlertsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifyMilestoneAlerts');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      notifyStreakAlertsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifyStreakAlerts');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      notifyStudyRemindersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifyStudyReminders');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      notifyWeeklyReviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifyWeeklyReview');
    });
  }

  QueryBuilder<UserPrefsModel, String, QQueryOperations>
      weeklyNotesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyNotesJson');
    });
  }

  QueryBuilder<UserPrefsModel, String, QQueryOperations>
      activeSemesterKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzActiveSemesterKey');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      cwaSetupTargetConfirmedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzCwaSetupTargetConfirmed');
    });
  }

  QueryBuilder<UserPrefsModel, String, QQueryOperations>
      gradingSystemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzGradingSystemId');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      hasCompletedOnboardingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzHasCompletedOnboarding');
    });
  }

  QueryBuilder<UserPrefsModel, String, QQueryOperations>
      manualCwaDraftJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzManualCwaDraftJson');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations>
      defaultFocusMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzPomodoroFocusMinutes');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations>
      defaultLongBreakMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzPomodoroLongBreakMinutes');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations>
      defaultShortBreakMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzPomodoroShortBreakMinutes');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations>
      defaultTotalRoundsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzPomodoroTotalRounds');
    });
  }

  QueryBuilder<UserPrefsModel, String?, QQueryOperations>
      programmeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzProgrammeName');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      playSoundOnTimerEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzSoundOnTimerEnd');
    });
  }

  QueryBuilder<UserPrefsModel, double, QQueryOperations> targetCwaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzTargetCwa');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations> themeModeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzThemeModeIndex');
    });
  }

  QueryBuilder<UserPrefsModel, int, QQueryOperations>
      timetableGridLayoutIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzTimetableGridLayoutIndex');
    });
  }

  QueryBuilder<UserPrefsModel, String?, QQueryOperations>
      universityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzUniversityName');
    });
  }

  QueryBuilder<UserPrefsModel, bool, QQueryOperations>
      vibrateOnTimerEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzVibrateOnTimerEnd');
    });
  }

  QueryBuilder<UserPrefsModel, double?, QQueryOperations>
      manualBaselineCreditsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzzManualBaselineCredits');
    });
  }

  QueryBuilder<UserPrefsModel, double?, QQueryOperations>
      manualBaselineCwaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzzManualBaselineCwa');
    });
  }

  QueryBuilder<UserPrefsModel, String?, QQueryOperations>
      manualBaselineGradingSystemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zzzManualBaselineGradingSystemId');
    });
  }
}
