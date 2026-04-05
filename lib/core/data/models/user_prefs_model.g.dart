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
    r'notifyMilestoneAlerts': PropertySchema(
      id: 4,
      name: r'notifyMilestoneAlerts',
      type: IsarType.bool,
    ),
    r'notifyStreakAlerts': PropertySchema(
      id: 5,
      name: r'notifyStreakAlerts',
      type: IsarType.bool,
    ),
    r'notifyStudyReminders': PropertySchema(
      id: 6,
      name: r'notifyStudyReminders',
      type: IsarType.bool,
    ),
    r'notifyWeeklyReview': PropertySchema(
      id: 7,
      name: r'notifyWeeklyReview',
      type: IsarType.bool,
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
  version: '3.1.0+1',
);

int _userPrefsModelEstimateSize(
  UserPrefsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.attendedDatesJson.length * 3;
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
  writer.writeBool(offsets[4], object.notifyMilestoneAlerts);
  writer.writeBool(offsets[5], object.notifyStreakAlerts);
  writer.writeBool(offsets[6], object.notifyStudyReminders);
  writer.writeBool(offsets[7], object.notifyWeeklyReview);
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
  object.notifyMilestoneAlerts = reader.readBool(offsets[4]);
  object.notifyStreakAlerts = reader.readBool(offsets[5]);
  object.notifyStudyReminders = reader.readBool(offsets[6]);
  object.notifyWeeklyReview = reader.readBool(offsets[7]);
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
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
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
}
