// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubscriptionModelCollection on Isar {
  IsarCollection<SubscriptionModel> get subscriptionModels => this.collection();
}

const SubscriptionModelSchema = CollectionSchema(
  name: r'SubscriptionModel',
  id: 1910962846492805114,
  properties: {
    r'expiresAt': PropertySchema(
      id: 0,
      name: r'expiresAt',
      type: IsarType.string,
    ),
    r'plan': PropertySchema(
      id: 1,
      name: r'plan',
      type: IsarType.string,
    ),
    r'purchasedAt': PropertySchema(
      id: 2,
      name: r'purchasedAt',
      type: IsarType.string,
    ),
    r'tier': PropertySchema(
      id: 3,
      name: r'tier',
      type: IsarType.string,
    ),
    r'transactionRef': PropertySchema(
      id: 4,
      name: r'transactionRef',
      type: IsarType.string,
    )
  },
  estimateSize: _subscriptionModelEstimateSize,
  serialize: _subscriptionModelSerialize,
  deserialize: _subscriptionModelDeserialize,
  deserializeProp: _subscriptionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _subscriptionModelGetId,
  getLinks: _subscriptionModelGetLinks,
  attach: _subscriptionModelAttach,
  version: '3.1.0+1',
);

int _subscriptionModelEstimateSize(
  SubscriptionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.expiresAt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.plan;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.purchasedAt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tier.length * 3;
  {
    final value = object.transactionRef;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _subscriptionModelSerialize(
  SubscriptionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.expiresAt);
  writer.writeString(offsets[1], object.plan);
  writer.writeString(offsets[2], object.purchasedAt);
  writer.writeString(offsets[3], object.tier);
  writer.writeString(offsets[4], object.transactionRef);
}

SubscriptionModel _subscriptionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubscriptionModel();
  object.expiresAt = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.plan = reader.readStringOrNull(offsets[1]);
  object.purchasedAt = reader.readStringOrNull(offsets[2]);
  object.tier = reader.readString(offsets[3]);
  object.transactionRef = reader.readStringOrNull(offsets[4]);
  return object;
}

P _subscriptionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subscriptionModelGetId(SubscriptionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subscriptionModelGetLinks(
    SubscriptionModel object) {
  return [];
}

void _subscriptionModelAttach(
    IsarCollection<dynamic> col, Id id, SubscriptionModel object) {
  object.id = id;
}

extension SubscriptionModelQueryWhereSort
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QWhere> {
  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubscriptionModelQueryWhere
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QWhereClause> {
  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterWhereClause>
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

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterWhereClause>
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

extension SubscriptionModelQueryFilter
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QFilterCondition> {
  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiresAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiresAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiresAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiresAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'expiresAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'expiresAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'expiresAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'expiresAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiresAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      expiresAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'expiresAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
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

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'plan',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'plan',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'plan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'plan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'plan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'plan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plan',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      planIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'plan',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purchasedAt',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purchasedAt',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchasedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchasedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchasedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchasedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'purchasedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'purchasedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'purchasedAt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'purchasedAt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchasedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      purchasedAtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'purchasedAt',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tier',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tier',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tier',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      tierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tier',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'transactionRef',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'transactionRef',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transactionRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transactionRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transactionRef',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'transactionRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'transactionRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'transactionRef',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'transactionRef',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionRef',
        value: '',
      ));
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterFilterCondition>
      transactionRefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'transactionRef',
        value: '',
      ));
    });
  }
}

extension SubscriptionModelQueryObject
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QFilterCondition> {}

extension SubscriptionModelQueryLinks
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QFilterCondition> {}

extension SubscriptionModelQuerySortBy
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QSortBy> {
  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByPlan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByPlanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByTransactionRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRef', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      sortByTransactionRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRef', Sort.desc);
    });
  }
}

extension SubscriptionModelQuerySortThenBy
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QSortThenBy> {
  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByPlan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByPlanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plan', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByTransactionRef() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRef', Sort.asc);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QAfterSortBy>
      thenByTransactionRefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionRef', Sort.desc);
    });
  }
}

extension SubscriptionModelQueryWhereDistinct
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QDistinct> {
  QueryBuilder<SubscriptionModel, SubscriptionModel, QDistinct>
      distinctByExpiresAt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QDistinct> distinctByPlan(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plan', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QDistinct>
      distinctByPurchasedAt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchasedAt', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QDistinct> distinctByTier(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubscriptionModel, SubscriptionModel, QDistinct>
      distinctByTransactionRef({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionRef',
          caseSensitive: caseSensitive);
    });
  }
}

extension SubscriptionModelQueryProperty
    on QueryBuilder<SubscriptionModel, SubscriptionModel, QQueryProperty> {
  QueryBuilder<SubscriptionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubscriptionModel, String?, QQueryOperations>
      expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<SubscriptionModel, String?, QQueryOperations> planProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plan');
    });
  }

  QueryBuilder<SubscriptionModel, String?, QQueryOperations>
      purchasedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchasedAt');
    });
  }

  QueryBuilder<SubscriptionModel, String, QQueryOperations> tierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tier');
    });
  }

  QueryBuilder<SubscriptionModel, String?, QQueryOperations>
      transactionRefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionRef');
    });
  }
}
