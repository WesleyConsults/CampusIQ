// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_timetable_notification_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScheduledTimetableNotificationModelCollection on Isar {
  IsarCollection<ScheduledTimetableNotificationModel>
      get scheduledTimetableNotificationModels => this.collection();
}

const ScheduledTimetableNotificationModelSchema = CollectionSchema(
  name: r'ScheduledTimetableNotificationModel',
  id: -8748151160392898942,
  properties: {
    r'body': PropertySchema(
      id: 0,
      name: r'body',
      type: IsarType.string,
    ),
    r'classStartMinutes': PropertySchema(
      id: 1,
      name: r'classStartMinutes',
      type: IsarType.long,
    ),
    r'dayIndex': PropertySchema(
      id: 2,
      name: r'dayIndex',
      type: IsarType.long,
    ),
    r'isAlarm': PropertySchema(
      id: 3,
      name: r'isAlarm',
      type: IsarType.bool,
    ),
    r'logicalKey': PropertySchema(
      id: 4,
      name: r'logicalKey',
      type: IsarType.string,
    ),
    r'normalizedCourseCode': PropertySchema(
      id: 5,
      name: r'normalizedCourseCode',
      type: IsarType.string,
    ),
    r'notificationId': PropertySchema(
      id: 6,
      name: r'notificationId',
      type: IsarType.long,
    ),
    r'payload': PropertySchema(
      id: 7,
      name: r'payload',
      type: IsarType.string,
    ),
    r'reminderMinutesBefore': PropertySchema(
      id: 8,
      name: r'reminderMinutesBefore',
      type: IsarType.long,
    ),
    r'scheduledHour': PropertySchema(
      id: 9,
      name: r'scheduledHour',
      type: IsarType.long,
    ),
    r'scheduledMinute': PropertySchema(
      id: 10,
      name: r'scheduledMinute',
      type: IsarType.long,
    ),
    r'scheduledWeekday': PropertySchema(
      id: 11,
      name: r'scheduledWeekday',
      type: IsarType.long,
    ),
    r'semesterKey': PropertySchema(
      id: 12,
      name: r'semesterKey',
      type: IsarType.string,
    ),
    r'slotId': PropertySchema(
      id: 13,
      name: r'slotId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 14,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _scheduledTimetableNotificationModelEstimateSize,
  serialize: _scheduledTimetableNotificationModelSerialize,
  deserialize: _scheduledTimetableNotificationModelDeserialize,
  deserializeProp: _scheduledTimetableNotificationModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'logicalKey': IndexSchema(
      id: 6546083245400626417,
      name: r'logicalKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'logicalKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'notificationId': IndexSchema(
      id: 1533036797414670656,
      name: r'notificationId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'notificationId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'slotId': IndexSchema(
      id: -665048265905431799,
      name: r'slotId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'slotId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'semesterKey': IndexSchema(
      id: 5443052311775989410,
      name: r'semesterKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'semesterKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'normalizedCourseCode': IndexSchema(
      id: 2161616251008618838,
      name: r'normalizedCourseCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedCourseCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _scheduledTimetableNotificationModelGetId,
  getLinks: _scheduledTimetableNotificationModelGetLinks,
  attach: _scheduledTimetableNotificationModelAttach,
  version: '3.3.0-dev.1',
);

int _scheduledTimetableNotificationModelEstimateSize(
  ScheduledTimetableNotificationModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.body.length * 3;
  bytesCount += 3 + object.logicalKey.length * 3;
  bytesCount += 3 + object.normalizedCourseCode.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  bytesCount += 3 + object.semesterKey.length * 3;
  bytesCount += 3 + object.slotId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _scheduledTimetableNotificationModelSerialize(
  ScheduledTimetableNotificationModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.body);
  writer.writeLong(offsets[1], object.classStartMinutes);
  writer.writeLong(offsets[2], object.dayIndex);
  writer.writeBool(offsets[3], object.isAlarm);
  writer.writeString(offsets[4], object.logicalKey);
  writer.writeString(offsets[5], object.normalizedCourseCode);
  writer.writeLong(offsets[6], object.notificationId);
  writer.writeString(offsets[7], object.payload);
  writer.writeLong(offsets[8], object.reminderMinutesBefore);
  writer.writeLong(offsets[9], object.scheduledHour);
  writer.writeLong(offsets[10], object.scheduledMinute);
  writer.writeLong(offsets[11], object.scheduledWeekday);
  writer.writeString(offsets[12], object.semesterKey);
  writer.writeString(offsets[13], object.slotId);
  writer.writeString(offsets[14], object.title);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

ScheduledTimetableNotificationModel
    _scheduledTimetableNotificationModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScheduledTimetableNotificationModel();
  object.body = reader.readString(offsets[0]);
  object.classStartMinutes = reader.readLong(offsets[1]);
  object.dayIndex = reader.readLong(offsets[2]);
  object.id = id;
  object.isAlarm = reader.readBool(offsets[3]);
  object.logicalKey = reader.readString(offsets[4]);
  object.normalizedCourseCode = reader.readString(offsets[5]);
  object.notificationId = reader.readLong(offsets[6]);
  object.payload = reader.readString(offsets[7]);
  object.reminderMinutesBefore = reader.readLong(offsets[8]);
  object.scheduledHour = reader.readLong(offsets[9]);
  object.scheduledMinute = reader.readLong(offsets[10]);
  object.scheduledWeekday = reader.readLong(offsets[11]);
  object.semesterKey = reader.readString(offsets[12]);
  object.slotId = reader.readString(offsets[13]);
  object.title = reader.readString(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _scheduledTimetableNotificationModelDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scheduledTimetableNotificationModelGetId(
    ScheduledTimetableNotificationModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scheduledTimetableNotificationModelGetLinks(
    ScheduledTimetableNotificationModel object) {
  return [];
}

void _scheduledTimetableNotificationModelAttach(IsarCollection<dynamic> col,
    Id id, ScheduledTimetableNotificationModel object) {
  object.id = id;
}

extension ScheduledTimetableNotificationModelByIndex
    on IsarCollection<ScheduledTimetableNotificationModel> {
  Future<ScheduledTimetableNotificationModel?> getByLogicalKey(
      String logicalKey) {
    return getByIndex(r'logicalKey', [logicalKey]);
  }

  ScheduledTimetableNotificationModel? getByLogicalKeySync(String logicalKey) {
    return getByIndexSync(r'logicalKey', [logicalKey]);
  }

  Future<bool> deleteByLogicalKey(String logicalKey) {
    return deleteByIndex(r'logicalKey', [logicalKey]);
  }

  bool deleteByLogicalKeySync(String logicalKey) {
    return deleteByIndexSync(r'logicalKey', [logicalKey]);
  }

  Future<List<ScheduledTimetableNotificationModel?>> getAllByLogicalKey(
      List<String> logicalKeyValues) {
    final values = logicalKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'logicalKey', values);
  }

  List<ScheduledTimetableNotificationModel?> getAllByLogicalKeySync(
      List<String> logicalKeyValues) {
    final values = logicalKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'logicalKey', values);
  }

  Future<int> deleteAllByLogicalKey(List<String> logicalKeyValues) {
    final values = logicalKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'logicalKey', values);
  }

  int deleteAllByLogicalKeySync(List<String> logicalKeyValues) {
    final values = logicalKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'logicalKey', values);
  }

  Future<Id> putByLogicalKey(ScheduledTimetableNotificationModel object) {
    return putByIndex(r'logicalKey', object);
  }

  Id putByLogicalKeySync(ScheduledTimetableNotificationModel object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'logicalKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLogicalKey(
      List<ScheduledTimetableNotificationModel> objects) {
    return putAllByIndex(r'logicalKey', objects);
  }

  List<Id> putAllByLogicalKeySync(
      List<ScheduledTimetableNotificationModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'logicalKey', objects, saveLinks: saveLinks);
  }

  Future<ScheduledTimetableNotificationModel?> getByNotificationId(
      int notificationId) {
    return getByIndex(r'notificationId', [notificationId]);
  }

  ScheduledTimetableNotificationModel? getByNotificationIdSync(
      int notificationId) {
    return getByIndexSync(r'notificationId', [notificationId]);
  }

  Future<bool> deleteByNotificationId(int notificationId) {
    return deleteByIndex(r'notificationId', [notificationId]);
  }

  bool deleteByNotificationIdSync(int notificationId) {
    return deleteByIndexSync(r'notificationId', [notificationId]);
  }

  Future<List<ScheduledTimetableNotificationModel?>> getAllByNotificationId(
      List<int> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'notificationId', values);
  }

  List<ScheduledTimetableNotificationModel?> getAllByNotificationIdSync(
      List<int> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'notificationId', values);
  }

  Future<int> deleteAllByNotificationId(List<int> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'notificationId', values);
  }

  int deleteAllByNotificationIdSync(List<int> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'notificationId', values);
  }

  Future<Id> putByNotificationId(ScheduledTimetableNotificationModel object) {
    return putByIndex(r'notificationId', object);
  }

  Id putByNotificationIdSync(ScheduledTimetableNotificationModel object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'notificationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNotificationId(
      List<ScheduledTimetableNotificationModel> objects) {
    return putAllByIndex(r'notificationId', objects);
  }

  List<Id> putAllByNotificationIdSync(
      List<ScheduledTimetableNotificationModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'notificationId', objects, saveLinks: saveLinks);
  }
}

extension ScheduledTimetableNotificationModelQueryWhereSort on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QWhere> {
  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterWhere> anyNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'notificationId'),
      );
    });
  }
}

extension ScheduledTimetableNotificationModelQueryWhere on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QWhereClause> {
  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> logicalKeyEqualTo(String logicalKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'logicalKey',
        value: [logicalKey],
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> logicalKeyNotEqualTo(String logicalKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logicalKey',
              lower: [],
              upper: [logicalKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logicalKey',
              lower: [logicalKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logicalKey',
              lower: [logicalKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'logicalKey',
              lower: [],
              upper: [logicalKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> notificationIdEqualTo(int notificationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'notificationId',
        value: [notificationId],
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> notificationIdNotEqualTo(int notificationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [],
              upper: [notificationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [notificationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [notificationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [],
              upper: [notificationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> notificationIdGreaterThan(
    int notificationId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'notificationId',
        lower: [notificationId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> notificationIdLessThan(
    int notificationId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'notificationId',
        lower: [],
        upper: [notificationId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> notificationIdBetween(
    int lowerNotificationId,
    int upperNotificationId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'notificationId',
        lower: [lowerNotificationId],
        includeLower: includeLower,
        upper: [upperNotificationId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> slotIdEqualTo(String slotId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'slotId',
        value: [slotId],
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> slotIdNotEqualTo(String slotId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slotId',
              lower: [],
              upper: [slotId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slotId',
              lower: [slotId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slotId',
              lower: [slotId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'slotId',
              lower: [],
              upper: [slotId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> semesterKeyEqualTo(String semesterKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'semesterKey',
        value: [semesterKey],
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterWhereClause> semesterKeyNotEqualTo(String semesterKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semesterKey',
              lower: [],
              upper: [semesterKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semesterKey',
              lower: [semesterKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semesterKey',
              lower: [semesterKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'semesterKey',
              lower: [],
              upper: [semesterKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterWhereClause>
      normalizedCourseCodeEqualTo(String normalizedCourseCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedCourseCode',
        value: [normalizedCourseCode],
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterWhereClause>
      normalizedCourseCodeNotEqualTo(String normalizedCourseCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedCourseCode',
              lower: [],
              upper: [normalizedCourseCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedCourseCode',
              lower: [normalizedCourseCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedCourseCode',
              lower: [normalizedCourseCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedCourseCode',
              lower: [],
              upper: [normalizedCourseCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ScheduledTimetableNotificationModelQueryFilter on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QFilterCondition> {
  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> bodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> bodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> bodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> bodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'body',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> bodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> bodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      bodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'body',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      bodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'body',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'body',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> classStartMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classStartMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> classStartMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classStartMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> classStartMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classStartMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> classStartMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classStartMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> dayIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> dayIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> dayIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> dayIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> isAlarmEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAlarm',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logicalKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      logicalKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      logicalKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logicalKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logicalKey',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> logicalKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logicalKey',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedCourseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'normalizedCourseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'normalizedCourseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'normalizedCourseCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'normalizedCourseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'normalizedCourseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      normalizedCourseCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'normalizedCourseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      normalizedCourseCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'normalizedCourseCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedCourseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> normalizedCourseCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'normalizedCourseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> notificationIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationId',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> notificationIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationId',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> notificationIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationId',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> notificationIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      payloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payload',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      payloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payload',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payload',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> reminderMinutesBeforeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reminderMinutesBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> reminderMinutesBeforeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reminderMinutesBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> reminderMinutesBeforeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reminderMinutesBefore',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> reminderMinutesBeforeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reminderMinutesBefore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledHour',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledHour',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledHour',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledMinuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledMinuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledMinute',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledMinute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledWeekdayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledWeekday',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledWeekdayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledWeekday',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledWeekdayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledWeekday',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> scheduledWeekdayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledWeekday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'semesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'semesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'semesterKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'semesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'semesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      semesterKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'semesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      semesterKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'semesterKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semesterKey',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> semesterKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'semesterKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> slotIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> slotIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'slotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> slotIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'slotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> slotIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'slotId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> slotIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'slotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> slotIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'slotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      slotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'slotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      slotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'slotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> slotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slotId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> slotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'slotId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
          ScheduledTimetableNotificationModel, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ScheduledTimetableNotificationModelQueryObject on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QFilterCondition> {}

extension ScheduledTimetableNotificationModelQueryLinks on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QFilterCondition> {}

extension ScheduledTimetableNotificationModelQuerySortBy on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QSortBy> {
  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByClassStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classStartMinutes', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByClassStartMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classStartMinutes', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByDayIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByDayIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByIsAlarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlarm', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByIsAlarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlarm', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByLogicalKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logicalKey', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByLogicalKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logicalKey', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByNormalizedCourseCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedCourseCode', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByNormalizedCourseCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedCourseCode', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByReminderMinutesBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByScheduledHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledHour', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByScheduledHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledHour', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByScheduledMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledMinute', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByScheduledMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledMinute', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByScheduledWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledWeekday', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortByScheduledWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledWeekday', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortBySemesterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> sortBySemesterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortBySlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slotId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortBySlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slotId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ScheduledTimetableNotificationModelQuerySortThenBy on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QSortThenBy> {
  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'body', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByClassStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classStartMinutes', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByClassStartMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classStartMinutes', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByDayIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByDayIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayIndex', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByIsAlarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlarm', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByIsAlarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAlarm', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByLogicalKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logicalKey', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByLogicalKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logicalKey', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByNormalizedCourseCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedCourseCode', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByNormalizedCourseCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedCourseCode', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payload', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByReminderMinutesBeforeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reminderMinutesBefore', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByScheduledHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledHour', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByScheduledHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledHour', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByScheduledMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledMinute', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByScheduledMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledMinute', Sort.desc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByScheduledWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledWeekday', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenByScheduledWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledWeekday', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenBySemesterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.asc);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QAfterSortBy> thenBySemesterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenBySlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slotId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenBySlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slotId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ScheduledTimetableNotificationModelQueryWhereDistinct on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QDistinct> {
  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByBody({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'body', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByClassStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classStartMinutes');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QDistinct> distinctByDayIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayIndex');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QDistinct> distinctByIsAlarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAlarm');
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByLogicalKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logicalKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByNormalizedCourseCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'normalizedCourseCode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationId');
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByReminderMinutesBefore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reminderMinutesBefore');
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByScheduledHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledHour');
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByScheduledMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledMinute');
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByScheduledWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledWeekday');
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctBySemesterKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semesterKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctBySlotId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slotId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel,
      QDistinct> distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel,
      ScheduledTimetableNotificationModel, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ScheduledTimetableNotificationModelQueryProperty on QueryBuilder<
    ScheduledTimetableNotificationModel,
    ScheduledTimetableNotificationModel,
    QQueryProperty> {
  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, String, QQueryOperations>
      bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'body');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      classStartMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classStartMinutes');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      dayIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayIndex');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, bool, QQueryOperations>
      isAlarmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAlarm');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, String, QQueryOperations>
      logicalKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logicalKey');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, String, QQueryOperations>
      normalizedCourseCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedCourseCode');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      notificationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationId');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, String, QQueryOperations>
      payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      reminderMinutesBeforeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reminderMinutesBefore');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      scheduledHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledHour');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      scheduledMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledMinute');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, int, QQueryOperations>
      scheduledWeekdayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledWeekday');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, String, QQueryOperations>
      semesterKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semesterKey');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, String, QQueryOperations>
      slotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slotId');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, String, QQueryOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<ScheduledTimetableNotificationModel, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
