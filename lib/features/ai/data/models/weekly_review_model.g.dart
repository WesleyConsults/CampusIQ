// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_review_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeeklyReviewModelCollection on Isar {
  IsarCollection<WeeklyReviewModel> get weeklyReviewModels => this.collection();
}

const WeeklyReviewModelSchema = CollectionSchema(
  name: r'WeeklyReviewModel',
  id: 513745547046949510,
  properties: {
    r'focusText': PropertySchema(
      id: 0,
      name: r'focusText',
      type: IsarType.string,
    ),
    r'generatedAt': PropertySchema(
      id: 1,
      name: r'generatedAt',
      type: IsarType.dateTime,
    ),
    r'summaryText': PropertySchema(
      id: 2,
      name: r'summaryText',
      type: IsarType.string,
    ),
    r'watchText': PropertySchema(
      id: 3,
      name: r'watchText',
      type: IsarType.string,
    ),
    r'weekStartDate': PropertySchema(
      id: 4,
      name: r'weekStartDate',
      type: IsarType.string,
    ),
    r'wellText': PropertySchema(
      id: 5,
      name: r'wellText',
      type: IsarType.string,
    )
  },
  estimateSize: _weeklyReviewModelEstimateSize,
  serialize: _weeklyReviewModelSerialize,
  deserialize: _weeklyReviewModelDeserialize,
  deserializeProp: _weeklyReviewModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'weekStartDate': IndexSchema(
      id: 7906057668223877157,
      name: r'weekStartDate',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'weekStartDate',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _weeklyReviewModelGetId,
  getLinks: _weeklyReviewModelGetLinks,
  attach: _weeklyReviewModelAttach,
  version: '3.1.0+1',
);

int _weeklyReviewModelEstimateSize(
  WeeklyReviewModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.focusText.length * 3;
  bytesCount += 3 + object.summaryText.length * 3;
  bytesCount += 3 + object.watchText.length * 3;
  bytesCount += 3 + object.weekStartDate.length * 3;
  bytesCount += 3 + object.wellText.length * 3;
  return bytesCount;
}

void _weeklyReviewModelSerialize(
  WeeklyReviewModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.focusText);
  writer.writeDateTime(offsets[1], object.generatedAt);
  writer.writeString(offsets[2], object.summaryText);
  writer.writeString(offsets[3], object.watchText);
  writer.writeString(offsets[4], object.weekStartDate);
  writer.writeString(offsets[5], object.wellText);
}

WeeklyReviewModel _weeklyReviewModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeeklyReviewModel();
  object.focusText = reader.readString(offsets[0]);
  object.generatedAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.summaryText = reader.readString(offsets[2]);
  object.watchText = reader.readString(offsets[3]);
  object.weekStartDate = reader.readString(offsets[4]);
  object.wellText = reader.readString(offsets[5]);
  return object;
}

P _weeklyReviewModelDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weeklyReviewModelGetId(WeeklyReviewModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weeklyReviewModelGetLinks(
    WeeklyReviewModel object) {
  return [];
}

void _weeklyReviewModelAttach(
    IsarCollection<dynamic> col, Id id, WeeklyReviewModel object) {
  object.id = id;
}

extension WeeklyReviewModelByIndex on IsarCollection<WeeklyReviewModel> {
  Future<WeeklyReviewModel?> getByWeekStartDate(String weekStartDate) {
    return getByIndex(r'weekStartDate', [weekStartDate]);
  }

  WeeklyReviewModel? getByWeekStartDateSync(String weekStartDate) {
    return getByIndexSync(r'weekStartDate', [weekStartDate]);
  }

  Future<bool> deleteByWeekStartDate(String weekStartDate) {
    return deleteByIndex(r'weekStartDate', [weekStartDate]);
  }

  bool deleteByWeekStartDateSync(String weekStartDate) {
    return deleteByIndexSync(r'weekStartDate', [weekStartDate]);
  }

  Future<List<WeeklyReviewModel?>> getAllByWeekStartDate(
      List<String> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return getAllByIndex(r'weekStartDate', values);
  }

  List<WeeklyReviewModel?> getAllByWeekStartDateSync(
      List<String> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'weekStartDate', values);
  }

  Future<int> deleteAllByWeekStartDate(List<String> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'weekStartDate', values);
  }

  int deleteAllByWeekStartDateSync(List<String> weekStartDateValues) {
    final values = weekStartDateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'weekStartDate', values);
  }

  Future<Id> putByWeekStartDate(WeeklyReviewModel object) {
    return putByIndex(r'weekStartDate', object);
  }

  Id putByWeekStartDateSync(WeeklyReviewModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'weekStartDate', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByWeekStartDate(List<WeeklyReviewModel> objects) {
    return putAllByIndex(r'weekStartDate', objects);
  }

  List<Id> putAllByWeekStartDateSync(List<WeeklyReviewModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'weekStartDate', objects, saveLinks: saveLinks);
  }
}

extension WeeklyReviewModelQueryWhereSort
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QWhere> {
  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WeeklyReviewModelQueryWhere
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QWhereClause> {
  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhereClause>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhereClause>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhereClause>
      weekStartDateEqualTo(String weekStartDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'weekStartDate',
        value: [weekStartDate],
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterWhereClause>
      weekStartDateNotEqualTo(String weekStartDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [],
              upper: [weekStartDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [weekStartDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [weekStartDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'weekStartDate',
              lower: [],
              upper: [weekStartDate],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WeeklyReviewModelQueryFilter
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QFilterCondition> {
  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focusText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'focusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'focusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'focusText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'focusText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focusText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      focusTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'focusText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      generatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summaryText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summaryText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      summaryTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summaryText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'watchText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'watchText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'watchText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'watchText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'watchText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'watchText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'watchText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'watchText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'watchText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      watchTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'watchText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
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

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      weekStartDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weekStartDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      weekStartDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weekStartDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      weekStartDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekStartDate',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      weekStartDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weekStartDate',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wellText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wellText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wellText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wellText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'wellText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'wellText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'wellText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'wellText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wellText',
        value: '',
      ));
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterFilterCondition>
      wellTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'wellText',
        value: '',
      ));
    });
  }
}

extension WeeklyReviewModelQueryObject
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QFilterCondition> {}

extension WeeklyReviewModelQueryLinks
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QFilterCondition> {}

extension WeeklyReviewModelQuerySortBy
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QSortBy> {
  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByFocusText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByFocusTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortBySummaryText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortBySummaryTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByWatchText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByWatchTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByWellText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      sortByWellTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellText', Sort.desc);
    });
  }
}

extension WeeklyReviewModelQuerySortThenBy
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QSortThenBy> {
  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByFocusText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByFocusTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'focusText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenBySummaryText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenBySummaryTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summaryText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByWatchText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByWatchTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchText', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByWeekStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByWeekStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekStartDate', Sort.desc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByWellText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellText', Sort.asc);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QAfterSortBy>
      thenByWellTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellText', Sort.desc);
    });
  }
}

extension WeeklyReviewModelQueryWhereDistinct
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QDistinct> {
  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QDistinct>
      distinctByFocusText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'focusText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QDistinct>
      distinctByGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedAt');
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QDistinct>
      distinctBySummaryText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summaryText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QDistinct>
      distinctByWatchText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'watchText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QDistinct>
      distinctByWeekStartDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekStartDate',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QDistinct>
      distinctByWellText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wellText', caseSensitive: caseSensitive);
    });
  }
}

extension WeeklyReviewModelQueryProperty
    on QueryBuilder<WeeklyReviewModel, WeeklyReviewModel, QQueryProperty> {
  QueryBuilder<WeeklyReviewModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeeklyReviewModel, String, QQueryOperations>
      focusTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'focusText');
    });
  }

  QueryBuilder<WeeklyReviewModel, DateTime, QQueryOperations>
      generatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedAt');
    });
  }

  QueryBuilder<WeeklyReviewModel, String, QQueryOperations>
      summaryTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summaryText');
    });
  }

  QueryBuilder<WeeklyReviewModel, String, QQueryOperations>
      watchTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'watchText');
    });
  }

  QueryBuilder<WeeklyReviewModel, String, QQueryOperations>
      weekStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekStartDate');
    });
  }

  QueryBuilder<WeeklyReviewModel, String, QQueryOperations> wellTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wellText');
    });
  }
}
