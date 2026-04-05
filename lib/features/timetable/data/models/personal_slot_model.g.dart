// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_slot_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPersonalSlotModelCollection on Isar {
  IsarCollection<PersonalSlotModel> get personalSlotModels => this.collection();
}

const PersonalSlotModelSchema = CollectionSchema(
  name: r'PersonalSlotModel',
  id: -8098209229521992991,
  properties: {
    r'categoryName': PropertySchema(
      id: 0,
      name: r'categoryName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customLabel': PropertySchema(
      id: 2,
      name: r'customLabel',
      type: IsarType.string,
    ),
    r'displayLabel': PropertySchema(
      id: 3,
      name: r'displayLabel',
      type: IsarType.string,
    ),
    r'durationMinutes': PropertySchema(
      id: 4,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'endMinutes': PropertySchema(
      id: 5,
      name: r'endMinutes',
      type: IsarType.long,
    ),
    r'endTimeLabel': PropertySchema(
      id: 6,
      name: r'endTimeLabel',
      type: IsarType.string,
    ),
    r'recurrenceTypeName': PropertySchema(
      id: 7,
      name: r'recurrenceTypeName',
      type: IsarType.string,
    ),
    r'semesterKey': PropertySchema(
      id: 8,
      name: r'semesterKey',
      type: IsarType.string,
    ),
    r'specificDate': PropertySchema(
      id: 9,
      name: r'specificDate',
      type: IsarType.string,
    ),
    r'startMinutes': PropertySchema(
      id: 10,
      name: r'startMinutes',
      type: IsarType.long,
    ),
    r'startTimeLabel': PropertySchema(
      id: 11,
      name: r'startTimeLabel',
      type: IsarType.string,
    ),
    r'weeklyDays': PropertySchema(
      id: 12,
      name: r'weeklyDays',
      type: IsarType.longList,
    )
  },
  estimateSize: _personalSlotModelEstimateSize,
  serialize: _personalSlotModelSerialize,
  deserialize: _personalSlotModelDeserialize,
  deserializeProp: _personalSlotModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _personalSlotModelGetId,
  getLinks: _personalSlotModelGetLinks,
  attach: _personalSlotModelAttach,
  version: '3.1.0+1',
);

int _personalSlotModelEstimateSize(
  PersonalSlotModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categoryName.length * 3;
  bytesCount += 3 + object.customLabel.length * 3;
  bytesCount += 3 + object.displayLabel.length * 3;
  bytesCount += 3 + object.endTimeLabel.length * 3;
  bytesCount += 3 + object.recurrenceTypeName.length * 3;
  bytesCount += 3 + object.semesterKey.length * 3;
  {
    final value = object.specificDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.startTimeLabel.length * 3;
  bytesCount += 3 + object.weeklyDays.length * 8;
  return bytesCount;
}

void _personalSlotModelSerialize(
  PersonalSlotModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.categoryName);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.customLabel);
  writer.writeString(offsets[3], object.displayLabel);
  writer.writeLong(offsets[4], object.durationMinutes);
  writer.writeLong(offsets[5], object.endMinutes);
  writer.writeString(offsets[6], object.endTimeLabel);
  writer.writeString(offsets[7], object.recurrenceTypeName);
  writer.writeString(offsets[8], object.semesterKey);
  writer.writeString(offsets[9], object.specificDate);
  writer.writeLong(offsets[10], object.startMinutes);
  writer.writeString(offsets[11], object.startTimeLabel);
  writer.writeLongList(offsets[12], object.weeklyDays);
}

PersonalSlotModel _personalSlotModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PersonalSlotModel();
  object.categoryName = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.customLabel = reader.readString(offsets[2]);
  object.endMinutes = reader.readLong(offsets[5]);
  object.id = id;
  object.recurrenceTypeName = reader.readString(offsets[7]);
  object.semesterKey = reader.readString(offsets[8]);
  object.specificDate = reader.readStringOrNull(offsets[9]);
  object.startMinutes = reader.readLong(offsets[10]);
  object.weeklyDays = reader.readLongList(offsets[12]) ?? [];
  return object;
}

P _personalSlotModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _personalSlotModelGetId(PersonalSlotModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _personalSlotModelGetLinks(
    PersonalSlotModel object) {
  return [];
}

void _personalSlotModelAttach(
    IsarCollection<dynamic> col, Id id, PersonalSlotModel object) {
  object.id = id;
}

extension PersonalSlotModelQueryWhereSort
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QWhere> {
  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PersonalSlotModelQueryWhere
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QWhereClause> {
  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterWhereClause>
      idBetween(
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

extension PersonalSlotModelQueryFilter
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QFilterCondition> {
  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoryName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryName',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      categoryNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryName',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      customLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      displayLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      durationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      durationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTimeLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endTimeLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTimeLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      endTimeLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endTimeLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceTypeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrenceTypeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrenceTypeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrenceTypeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recurrenceTypeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recurrenceTypeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recurrenceTypeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recurrenceTypeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceTypeName',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      recurrenceTypeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recurrenceTypeName',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyEqualTo(
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyGreaterThan(
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyLessThan(
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyBetween(
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyStartsWith(
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyEndsWith(
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

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'semesterKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'semesterKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semesterKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      semesterKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'semesterKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'specificDate',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'specificDate',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'specificDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'specificDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'specificDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'specificDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'specificDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'specificDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'specificDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'specificDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'specificDate',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      specificDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'specificDate',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTimeLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'startTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'startTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'startTimeLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'startTimeLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTimeLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      startTimeLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'startTimeLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyDays',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyDays',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyDays',
        value: value,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyDays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyDays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyDays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyDays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyDays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterFilterCondition>
      weeklyDaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyDays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PersonalSlotModelQueryObject
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QFilterCondition> {}

extension PersonalSlotModelQueryLinks
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QFilterCondition> {}

extension PersonalSlotModelQuerySortBy
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QSortBy> {
  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByCustomLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByCustomLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customLabel', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByDisplayLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByDisplayLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayLabel', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByEndMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinutes', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByEndMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinutes', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByEndTimeLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTimeLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByEndTimeLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTimeLabel', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByRecurrenceTypeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceTypeName', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByRecurrenceTypeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceTypeName', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortBySemesterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortBySemesterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortBySpecificDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specificDate', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortBySpecificDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specificDate', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinutes', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByStartMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinutes', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByStartTimeLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTimeLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      sortByStartTimeLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTimeLabel', Sort.desc);
    });
  }
}

extension PersonalSlotModelQuerySortThenBy
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QSortThenBy> {
  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByCustomLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByCustomLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customLabel', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByDisplayLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByDisplayLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayLabel', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByEndMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinutes', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByEndMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMinutes', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByEndTimeLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTimeLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByEndTimeLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTimeLabel', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByRecurrenceTypeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceTypeName', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByRecurrenceTypeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceTypeName', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenBySemesterKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenBySemesterKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterKey', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenBySpecificDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specificDate', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenBySpecificDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'specificDate', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinutes', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByStartMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMinutes', Sort.desc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByStartTimeLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTimeLabel', Sort.asc);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QAfterSortBy>
      thenByStartTimeLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTimeLabel', Sort.desc);
    });
  }
}

extension PersonalSlotModelQueryWhereDistinct
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct> {
  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByCategoryName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByCustomLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByDisplayLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByEndMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMinutes');
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByEndTimeLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTimeLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByRecurrenceTypeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceTypeName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctBySemesterKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semesterKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctBySpecificDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'specificDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByStartMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMinutes');
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByStartTimeLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTimeLabel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PersonalSlotModel, PersonalSlotModel, QDistinct>
      distinctByWeeklyDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyDays');
    });
  }
}

extension PersonalSlotModelQueryProperty
    on QueryBuilder<PersonalSlotModel, PersonalSlotModel, QQueryProperty> {
  QueryBuilder<PersonalSlotModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PersonalSlotModel, String, QQueryOperations>
      categoryNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryName');
    });
  }

  QueryBuilder<PersonalSlotModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PersonalSlotModel, String, QQueryOperations>
      customLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customLabel');
    });
  }

  QueryBuilder<PersonalSlotModel, String, QQueryOperations>
      displayLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayLabel');
    });
  }

  QueryBuilder<PersonalSlotModel, int, QQueryOperations>
      durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<PersonalSlotModel, int, QQueryOperations> endMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMinutes');
    });
  }

  QueryBuilder<PersonalSlotModel, String, QQueryOperations>
      endTimeLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTimeLabel');
    });
  }

  QueryBuilder<PersonalSlotModel, String, QQueryOperations>
      recurrenceTypeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceTypeName');
    });
  }

  QueryBuilder<PersonalSlotModel, String, QQueryOperations>
      semesterKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semesterKey');
    });
  }

  QueryBuilder<PersonalSlotModel, String?, QQueryOperations>
      specificDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'specificDate');
    });
  }

  QueryBuilder<PersonalSlotModel, int, QQueryOperations>
      startMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMinutes');
    });
  }

  QueryBuilder<PersonalSlotModel, String, QQueryOperations>
      startTimeLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTimeLabel');
    });
  }

  QueryBuilder<PersonalSlotModel, List<int>, QQueryOperations>
      weeklyDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyDays');
    });
  }
}
