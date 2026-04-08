// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExamModelCollection on Isar {
  IsarCollection<ExamModel> get examModels => this.collection();
}

const ExamModelSchema = CollectionSchema(
  name: r'ExamModel',
  id: -3354466809222718766,
  properties: {
    r'courseCode': PropertySchema(
      id: 0,
      name: r'courseCode',
      type: IsarType.string,
    ),
    r'courseName': PropertySchema(
      id: 1,
      name: r'courseName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'creditHours': PropertySchema(
      id: 3,
      name: r'creditHours',
      type: IsarType.long,
    ),
    r'examDate': PropertySchema(
      id: 4,
      name: r'examDate',
      type: IsarType.dateTime,
    ),
    r'examHall': PropertySchema(
      id: 5,
      name: r'examHall',
      type: IsarType.string,
    ),
    r'examStartHour': PropertySchema(
      id: 6,
      name: r'examStartHour',
      type: IsarType.long,
    ),
    r'isComplete': PropertySchema(
      id: 7,
      name: r'isComplete',
      type: IsarType.bool,
    ),
    r'topicsJson': PropertySchema(
      id: 8,
      name: r'topicsJson',
      type: IsarType.string,
    )
  },
  estimateSize: _examModelEstimateSize,
  serialize: _examModelSerialize,
  deserialize: _examModelDeserialize,
  deserializeProp: _examModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _examModelGetId,
  getLinks: _examModelGetLinks,
  attach: _examModelAttach,
  version: '3.1.0+1',
);

int _examModelEstimateSize(
  ExamModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.courseCode.length * 3;
  bytesCount += 3 + object.courseName.length * 3;
  {
    final value = object.examHall;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.topicsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _examModelSerialize(
  ExamModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.courseCode);
  writer.writeString(offsets[1], object.courseName);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.creditHours);
  writer.writeDateTime(offsets[4], object.examDate);
  writer.writeString(offsets[5], object.examHall);
  writer.writeLong(offsets[6], object.examStartHour);
  writer.writeBool(offsets[7], object.isComplete);
  writer.writeString(offsets[8], object.topicsJson);
}

ExamModel _examModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExamModel();
  object.courseCode = reader.readString(offsets[0]);
  object.courseName = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.creditHours = reader.readLong(offsets[3]);
  object.examDate = reader.readDateTime(offsets[4]);
  object.examHall = reader.readStringOrNull(offsets[5]);
  object.examStartHour = reader.readLong(offsets[6]);
  object.id = id;
  object.isComplete = reader.readBool(offsets[7]);
  object.topicsJson = reader.readStringOrNull(offsets[8]);
  return object;
}

P _examModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _examModelGetId(ExamModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _examModelGetLinks(ExamModel object) {
  return [];
}

void _examModelAttach(IsarCollection<dynamic> col, Id id, ExamModel object) {
  object.id = id;
}

extension ExamModelQueryWhereSort
    on QueryBuilder<ExamModel, ExamModel, QWhere> {
  QueryBuilder<ExamModel, ExamModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExamModelQueryWhere
    on QueryBuilder<ExamModel, ExamModel, QWhereClause> {
  QueryBuilder<ExamModel, ExamModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ExamModel, ExamModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterWhereClause> idBetween(
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

extension ExamModelQueryFilter
    on QueryBuilder<ExamModel, ExamModel, QFilterCondition> {
  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courseCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courseCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courseName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> courseNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      courseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courseName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
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

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> creditHoursEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditHours',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      creditHoursGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creditHours',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> creditHoursLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creditHours',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> creditHoursBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creditHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'examDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'examDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'examDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'examHall',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      examHallIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'examHall',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examHall',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'examHall',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'examHall',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'examHall',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'examHall',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'examHall',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'examHall',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'examHall',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> examHallIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examHall',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      examHallIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'examHall',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      examStartHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      examStartHourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'examStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      examStartHourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'examStartHour',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      examStartHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'examStartHour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> isCompleteEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isComplete',
        value: value,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> topicsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'topicsJson',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      topicsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'topicsJson',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> topicsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      topicsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> topicsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> topicsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topicsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      topicsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> topicsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> topicsJsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition> topicsJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topicsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      topicsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterFilterCondition>
      topicsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topicsJson',
        value: '',
      ));
    });
  }
}

extension ExamModelQueryObject
    on QueryBuilder<ExamModel, ExamModel, QFilterCondition> {}

extension ExamModelQueryLinks
    on QueryBuilder<ExamModel, ExamModel, QFilterCondition> {}

extension ExamModelQuerySortBy on QueryBuilder<ExamModel, ExamModel, QSortBy> {
  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCourseCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCourseCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCourseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCourseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCreditHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditHours', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByCreditHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditHours', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByExamDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByExamHall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examHall', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByExamHallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examHall', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByExamStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examStartHour', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByExamStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examStartHour', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByIsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByTopicsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> sortByTopicsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.desc);
    });
  }
}

extension ExamModelQuerySortThenBy
    on QueryBuilder<ExamModel, ExamModel, QSortThenBy> {
  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCourseCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCourseCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseCode', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCourseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCourseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courseName', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCreditHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditHours', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByCreditHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creditHours', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByExamDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByExamHall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examHall', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByExamHallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examHall', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByExamStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examStartHour', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByExamStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examStartHour', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByIsCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isComplete', Sort.desc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByTopicsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.asc);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QAfterSortBy> thenByTopicsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.desc);
    });
  }
}

extension ExamModelQueryWhereDistinct
    on QueryBuilder<ExamModel, ExamModel, QDistinct> {
  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByCourseCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByCourseName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByCreditHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creditHours');
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examDate');
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByExamHall(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examHall', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByExamStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examStartHour');
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByIsComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isComplete');
    });
  }

  QueryBuilder<ExamModel, ExamModel, QDistinct> distinctByTopicsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topicsJson', caseSensitive: caseSensitive);
    });
  }
}

extension ExamModelQueryProperty
    on QueryBuilder<ExamModel, ExamModel, QQueryProperty> {
  QueryBuilder<ExamModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExamModel, String, QQueryOperations> courseCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseCode');
    });
  }

  QueryBuilder<ExamModel, String, QQueryOperations> courseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courseName');
    });
  }

  QueryBuilder<ExamModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExamModel, int, QQueryOperations> creditHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creditHours');
    });
  }

  QueryBuilder<ExamModel, DateTime, QQueryOperations> examDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examDate');
    });
  }

  QueryBuilder<ExamModel, String?, QQueryOperations> examHallProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examHall');
    });
  }

  QueryBuilder<ExamModel, int, QQueryOperations> examStartHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examStartHour');
    });
  }

  QueryBuilder<ExamModel, bool, QQueryOperations> isCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isComplete');
    });
  }

  QueryBuilder<ExamModel, String?, QQueryOperations> topicsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topicsJson');
    });
  }
}
