// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudyPlanModelCollection on Isar {
  IsarCollection<StudyPlanModel> get studyPlanModels => this.collection();
}

const StudyPlanModelSchema = CollectionSchema(
  name: r'StudyPlanModel',
  id: 130124752497021979,
  properties: {
    r'generatedAt': PropertySchema(
      id: 0,
      name: r'generatedAt',
      type: IsarType.dateTime,
    ),
    r'weekStartDate': PropertySchema(
      id: 1,
      name: r'weekStartDate',
      type: IsarType.string,
    )
  },
  estimateSize: _studyPlanModelEstimateSize,
  serialize: _studyPlanModelSerialize,
  deserialize: _studyPlanModelDeserialize,
  deserializeProp: _studyPlanModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'slots': LinkSchema(
      id: -1930223042059432797,
      name: r'slots',
      target: r'StudyPlanSlotModel',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _studyPlanModelGetId,
  getLinks: _studyPlanModelGetLinks,
  attach: _studyPlanModelAttach,
  version: '3.1.0+1',
);

int _studyPlanModelEstimateSize(
  StudyPlanModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.weekStartDate.length * 3;
  return bytesCount;
}

void _studyPlanModelSerialize(
  StudyPlanModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.generatedAt);
  writer.writeString(offsets[1], object.weekStartDate);
}

StudyPlanModel _studyPlanModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudyPlanModel();
  object.generatedAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.weekStartDate = reader.readString(offsets[1]);
  return object;
}

P _studyPlanModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studyPlanModelGetId(StudyPlanModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studyPlanModelGetLinks(StudyPlanModel object) {
  return [object.slots];
}

void _studyPlanModelAttach(
    IsarCollection<dynamic> col, Id id, StudyPlanModel object) {
  object.id = id;
  object.slots
      .attach(col, col.isar.collection<StudyPlanSlotModel>(), r'slots', id);
}

extension StudyPlanModelQueryWhereSort
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QWhere> {
  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StudyPlanModelQueryWhere
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QWhereClause> {
  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterWhereClause> idBetween(
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

extension StudyPlanModelQueryFilter
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QFilterCondition> {
  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      generatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      generatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      generatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
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

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStartDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekStartDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekStartDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weekStartDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weekStartDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weekStartDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weekStartDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStartDate',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      weekStartDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weekStartDate',
        value: '',
      ));
    });
  }
}

extension StudyPlanModelQueryObject
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QFilterCondition> {}

extension StudyPlanModelQueryLinks
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QFilterCondition> {
  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition> slots(
      FilterQuery<StudyPlanSlotModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'slots');
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      slotsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'slots', length, true, length, true);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      slotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'slots', 0, true, 0, true);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      slotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'slots', 0, false, 999999, true);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      slotsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'slots', 0, true, length, include);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      slotsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'slots', length, include, 999999, true);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterFilterCondition>
      slotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'slots', lower, includeLower, upper, includeUpper);
    });
  }
}

extension StudyPlanModelQuerySortBy
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QSortBy> {
  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      sortByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      sortByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension StudyPlanModelQuerySortThenBy
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QSortThenBy> {
  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      thenByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QAfterSortBy>
      thenByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }
}

extension StudyPlanModelQueryWhereDistinct
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QDistinct> {
  QueryBuilder<StudyPlanModel, StudyPlanModel, QDistinct>
      distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<StudyPlanModel, StudyPlanModel, QDistinct>
      distinctByWeekStartDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStartDate',
          caseSensitive: caseSensitive);
    });
  }
}

extension StudyPlanModelQueryProperty
    on QueryBuilder<StudyPlanModel, StudyPlanModel, QQueryProperty> {
  QueryBuilder<StudyPlanModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudyPlanModel, DateTime, QQueryOperations>
      generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<StudyPlanModel, String, QQueryOperations>
      weekStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStartDate');
    });
  }
}
