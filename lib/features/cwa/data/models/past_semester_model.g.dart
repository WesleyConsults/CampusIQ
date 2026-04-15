// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'past_semester_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPastSemesterModelCollection on Isar {
  IsarCollection<PastSemesterModel> get pastSemesterModels => this.collection();
}

const PastSemesterModelSchema = CollectionSchema(
  name: r'PastSemesterModel',
  id: 5001893549736623095,
  properties: {
    r'courses': PropertySchema(
      id: 0,
      name: r'courses',
      type: IsarType.objectList,
      target: r'PastCourseEntry',
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'cumulativeCreditsCalc': PropertySchema(
      id: 2,
      name: r'cumulativeCreditsCalc',
      type: IsarType.double,
    ),
    r'cumulativeWeightedMarks': PropertySchema(
      id: 3,
      name: r'cumulativeWeightedMarks',
      type: IsarType.double,
    ),
    r'reportedCumulativeCwa': PropertySchema(
      id: 4,
      name: r'reportedCumulativeCwa',
      type: IsarType.double,
    ),
    r'reportedSemesterCwa': PropertySchema(
      id: 5,
      name: r'reportedSemesterCwa',
      type: IsarType.double,
    ),
    r'semesterLabel': PropertySchema(
      id: 6,
      name: r'semesterLabel',
      type: IsarType.string,
    )
  },
  estimateSize: _pastSemesterModelEstimateSize,
  serialize: _pastSemesterModelSerialize,
  deserialize: _pastSemesterModelDeserialize,
  deserializeProp: _pastSemesterModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'PastCourseEntry': PastCourseEntrySchema},
  getId: _pastSemesterModelGetId,
  getLinks: _pastSemesterModelGetLinks,
  attach: _pastSemesterModelAttach,
  version: '3.1.0+1',
);

int _pastSemesterModelEstimateSize(
  PastSemesterModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.courses.length * 3;
  {
    final offsets = allOffsets[PastCourseEntry]!;
    for (var i = 0; i < object.courses.length; i++) {
      final value = object.courses[i];
      bytesCount +=
          PastCourseEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.semesterLabel.length * 3;
  return bytesCount;
}

void _pastSemesterModelSerialize(
  PastSemesterModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<PastCourseEntry>(
    offsets[0],
    allOffsets,
    PastCourseEntrySchema.serialize,
    object.courses,
  );
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.cumulativeCreditsCalc);
  writer.writeDouble(offsets[3], object.cumulativeWeightedMarks);
  writer.writeDouble(offsets[4], object.reportedCumulativeCwa);
  writer.writeDouble(offsets[5], object.reportedSemesterCwa);
  writer.writeString(offsets[6], object.semesterLabel);
}

PastSemesterModel _pastSemesterModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PastSemesterModel();
  object.courses = reader.readObjectList<PastCourseEntry>(
        offsets[0],
        PastCourseEntrySchema.deserialize,
        allOffsets,
        PastCourseEntry(),
      ) ??
      [];
  object.createdAt = reader.readDateTime(offsets[1]);
  object.cumulativeCreditsCalc = reader.readDoubleOrNull(offsets[2]);
  object.cumulativeWeightedMarks = reader.readDoubleOrNull(offsets[3]);
  object.id = id;
  object.reportedCumulativeCwa = reader.readDoubleOrNull(offsets[4]);
  object.reportedSemesterCwa = reader.readDoubleOrNull(offsets[5]);
  object.semesterLabel = reader.readString(offsets[6]);
  return object;
}

P _pastSemesterModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<PastCourseEntry>(
            offset,
            PastCourseEntrySchema.deserialize,
            allOffsets,
            PastCourseEntry(),
          ) ??
          []) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pastSemesterModelGetId(PastSemesterModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pastSemesterModelGetLinks(
    PastSemesterModel object) {
  return [];
}

void _pastSemesterModelAttach(
    IsarCollection<dynamic> col, Id id, PastSemesterModel object) {
  object.id = id;
}

extension PastSemesterModelQueryWhereSort
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QWhere> {
  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PastSemesterModelQueryWhere
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QWhereClause> {
  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterWhereClause>
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

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterWhereClause>
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

extension PastSemesterModelQueryFilter
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QFilterCondition> {
  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      coursesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'courses',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      coursesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'courses',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      coursesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'courses',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      coursesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'courses',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      coursesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'courses',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      coursesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'courses',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
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

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
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

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
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

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeCreditsCalcIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cumulativeCreditsCalc',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeCreditsCalcIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cumulativeCreditsCalc',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeCreditsCalcEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cumulativeCreditsCalc',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeCreditsCalcGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cumulativeCreditsCalc',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeCreditsCalcLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cumulativeCreditsCalc',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeCreditsCalcBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cumulativeCreditsCalc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeWeightedMarksIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cumulativeWeightedMarks',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeWeightedMarksIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cumulativeWeightedMarks',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeWeightedMarksEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cumulativeWeightedMarks',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeWeightedMarksGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cumulativeWeightedMarks',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeWeightedMarksLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cumulativeWeightedMarks',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      cumulativeWeightedMarksBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cumulativeWeightedMarks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
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

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
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

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
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

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedCumulativeCwaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reportedCumulativeCwa',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedCumulativeCwaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reportedCumulativeCwa',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedCumulativeCwaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reportedCumulativeCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedCumulativeCwaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reportedCumulativeCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedCumulativeCwaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reportedCumulativeCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedCumulativeCwaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reportedCumulativeCwa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedSemesterCwaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reportedSemesterCwa',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedSemesterCwaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reportedSemesterCwa',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedSemesterCwaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reportedSemesterCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedSemesterCwaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reportedSemesterCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedSemesterCwaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reportedSemesterCwa',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      reportedSemesterCwaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reportedSemesterCwa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semesterLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'semesterLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'semesterLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'semesterLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'semesterLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'semesterLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'semesterLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'semesterLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'semesterLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      semesterLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'semesterLabel',
        value: '',
      ));
    });
  }
}

extension PastSemesterModelQueryObject
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QFilterCondition> {
  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterFilterCondition>
      coursesElement(FilterQuery<PastCourseEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'courses');
    });
  }
}

extension PastSemesterModelQueryLinks
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QFilterCondition> {}

extension PastSemesterModelQuerySortBy
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QSortBy> {
  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByCumulativeCreditsCalc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeCreditsCalc', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByCumulativeCreditsCalcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeCreditsCalc', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByCumulativeWeightedMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeWeightedMarks', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByCumulativeWeightedMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeWeightedMarks', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByReportedCumulativeCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedCumulativeCwa', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByReportedCumulativeCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedCumulativeCwa', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByReportedSemesterCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedSemesterCwa', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortByReportedSemesterCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedSemesterCwa', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortBySemesterLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterLabel', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      sortBySemesterLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterLabel', Sort.desc);
    });
  }
}

extension PastSemesterModelQuerySortThenBy
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QSortThenBy> {
  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByCumulativeCreditsCalc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeCreditsCalc', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByCumulativeCreditsCalcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeCreditsCalc', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByCumulativeWeightedMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeWeightedMarks', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByCumulativeWeightedMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cumulativeWeightedMarks', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByReportedCumulativeCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedCumulativeCwa', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByReportedCumulativeCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedCumulativeCwa', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByReportedSemesterCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedSemesterCwa', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenByReportedSemesterCwaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedSemesterCwa', Sort.desc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenBySemesterLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterLabel', Sort.asc);
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QAfterSortBy>
      thenBySemesterLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'semesterLabel', Sort.desc);
    });
  }
}

extension PastSemesterModelQueryWhereDistinct
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QDistinct> {
  QueryBuilder<PastSemesterModel, PastSemesterModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QDistinct>
      distinctByCumulativeCreditsCalc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cumulativeCreditsCalc');
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QDistinct>
      distinctByCumulativeWeightedMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cumulativeWeightedMarks');
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QDistinct>
      distinctByReportedCumulativeCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reportedCumulativeCwa');
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QDistinct>
      distinctByReportedSemesterCwa() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reportedSemesterCwa');
    });
  }

  QueryBuilder<PastSemesterModel, PastSemesterModel, QDistinct>
      distinctBySemesterLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semesterLabel',
          caseSensitive: caseSensitive);
    });
  }
}

extension PastSemesterModelQueryProperty
    on QueryBuilder<PastSemesterModel, PastSemesterModel, QQueryProperty> {
  QueryBuilder<PastSemesterModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PastSemesterModel, List<PastCourseEntry>, QQueryOperations>
      coursesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courses');
    });
  }

  QueryBuilder<PastSemesterModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PastSemesterModel, double?, QQueryOperations>
      cumulativeCreditsCalcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cumulativeCreditsCalc');
    });
  }

  QueryBuilder<PastSemesterModel, double?, QQueryOperations>
      cumulativeWeightedMarksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cumulativeWeightedMarks');
    });
  }

  QueryBuilder<PastSemesterModel, double?, QQueryOperations>
      reportedCumulativeCwaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reportedCumulativeCwa');
    });
  }

  QueryBuilder<PastSemesterModel, double?, QQueryOperations>
      reportedSemesterCwaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reportedSemesterCwa');
    });
  }

  QueryBuilder<PastSemesterModel, String, QQueryOperations>
      semesterLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semesterLabel');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PastCourseEntrySchema = Schema(
  name: r'PastCourseEntry',
  id: -7445753306170429153,
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
    r'creditHours': PropertySchema(
      id: 2,
      name: r'creditHours',
      type: IsarType.double,
    ),
    r'grade': PropertySchema(
      id: 3,
      name: r'grade',
      type: IsarType.string,
    ),
    r'mark': PropertySchema(
      id: 4,
      name: r'mark',
      type: IsarType.double,
    ),
    r'score': PropertySchema(
      id: 5,
      name: r'score',
      type: IsarType.double,
    )
  },
  estimateSize: _pastCourseEntryEstimateSize,
  serialize: _pastCourseEntrySerialize,
  deserialize: _pastCourseEntryDeserialize,
  deserializeProp: _pastCourseEntryDeserializeProp,
);

int _pastCourseEntryEstimateSize(
  PastCourseEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.courseCode.length * 3;
  bytesCount += 3 + object.courseName.length * 3;
  bytesCount += 3 + object.grade.length * 3;
  return bytesCount;
}

void _pastCourseEntrySerialize(
  PastCourseEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.courseCode);
  writer.writeString(offsets[1], object.courseName);
  writer.writeDouble(offsets[2], object.creditHours);
  writer.writeString(offsets[3], object.grade);
  writer.writeDouble(offsets[4], object.mark);
  writer.writeDouble(offsets[5], object.score);
}

PastCourseEntry _pastCourseEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PastCourseEntry();
  object.courseCode = reader.readString(offsets[0]);
  object.courseName = reader.readString(offsets[1]);
  object.creditHours = reader.readDouble(offsets[2]);
  object.grade = reader.readString(offsets[3]);
  object.mark = reader.readDoubleOrNull(offsets[4]);
  return object;
}

P _pastCourseEntryDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PastCourseEntryQueryFilter
    on QueryBuilder<PastCourseEntry, PastCourseEntry, QFilterCondition> {
  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeEqualTo(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeLessThan(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeBetween(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeEndsWith(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courseCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courseCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courseCode',
        value: '',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameEqualTo(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameLessThan(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameBetween(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameEndsWith(
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

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courseName',
        value: '',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      courseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courseName',
        value: '',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      creditHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creditHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      creditHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creditHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      creditHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creditHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      creditHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creditHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grade',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grade',
        value: '',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      gradeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grade',
        value: '',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      markIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      markIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      markEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mark',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      markGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mark',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      markLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mark',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      markBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mark',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      scoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      scoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      scoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PastCourseEntry, PastCourseEntry, QAfterFilterCondition>
      scoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension PastCourseEntryQueryObject
    on QueryBuilder<PastCourseEntry, PastCourseEntry, QFilterCondition> {}
