// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetFeeSnapshotCollection on Isar {
  IsarCollection<FeeSnapshot> get feeSnapshots => this.collection();
}

const FeeSnapshotSchema = CollectionSchema(
  name: r'FeeSnapshot',
  id: -9131577397856827098,
  properties: {
    r'feesUsdDelta': PropertySchema(
      id: 0,
      name: r'feesUsdDelta',
      type: IsarType.double,
    ),
    r'positionKey': PropertySchema(
      id: 1,
      name: r'positionKey',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _feeSnapshotEstimateSize,
  serialize: _feeSnapshotSerialize,
  deserialize: _feeSnapshotDeserialize,
  deserializeProp: _feeSnapshotDeserializeProp,
  idName: r'id',
  indexes: {
    r'positionKey_timestamp': IndexSchema(
      id: 2369976054682906759,
      name: r'positionKey_timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'positionKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _feeSnapshotGetId,
  getLinks: _feeSnapshotGetLinks,
  attach: _feeSnapshotAttach,
  version: '3.4.1',
);

int _feeSnapshotEstimateSize(
  FeeSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.positionKey.length * 3;
  return bytesCount;
}

void _feeSnapshotSerialize(
  FeeSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.feesUsdDelta);
  writer.writeString(offsets[1], object.positionKey);
  writer.writeDateTime(offsets[2], object.timestamp);
}

FeeSnapshot _feeSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FeeSnapshot();
  object.feesUsdDelta = reader.readDouble(offsets[0]);
  object.id = id;
  object.positionKey = reader.readString(offsets[1]);
  object.timestamp = reader.readDateTime(offsets[2]);
  return object;
}

P _feeSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _feeSnapshotGetId(FeeSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _feeSnapshotGetLinks(FeeSnapshot object) {
  return [];
}

void _feeSnapshotAttach(
  IsarCollection<dynamic> col,
  Id id,
  FeeSnapshot object,
) {
  object.id = id;
}

extension FeeSnapshotQueryWhereSort
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QWhere> {
  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FeeSnapshotQueryWhere
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QWhereClause> {
  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause>
  positionKeyEqualToAnyTimestamp(String positionKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'positionKey_timestamp',
          value: [positionKey],
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause>
  positionKeyNotEqualToAnyTimestamp(String positionKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [],
                upper: [positionKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [positionKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [positionKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [],
                upper: [positionKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause>
  positionKeyTimestampEqualTo(String positionKey, DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'positionKey_timestamp',
          value: [positionKey, timestamp],
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause>
  positionKeyEqualToTimestampNotEqualTo(
    String positionKey,
    DateTime timestamp,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [positionKey],
                upper: [positionKey, timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [positionKey, timestamp],
                includeLower: false,
                upper: [positionKey],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [positionKey, timestamp],
                includeLower: false,
                upper: [positionKey],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey_timestamp',
                lower: [positionKey],
                upper: [positionKey, timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause>
  positionKeyEqualToTimestampGreaterThan(
    String positionKey,
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'positionKey_timestamp',
          lower: [positionKey, timestamp],
          includeLower: include,
          upper: [positionKey],
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause>
  positionKeyEqualToTimestampLessThan(
    String positionKey,
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'positionKey_timestamp',
          lower: [positionKey],
          upper: [positionKey, timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterWhereClause>
  positionKeyEqualToTimestampBetween(
    String positionKey,
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'positionKey_timestamp',
          lower: [positionKey, lowerTimestamp],
          includeLower: includeLower,
          upper: [positionKey, upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FeeSnapshotQueryFilter
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QFilterCondition> {
  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  feesUsdDeltaEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feesUsdDelta',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  feesUsdDeltaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feesUsdDelta',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  feesUsdDeltaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feesUsdDelta',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  feesUsdDeltaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feesUsdDelta',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'positionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'positionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'positionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'positionKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'positionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'positionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'positionKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'positionKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  positionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FeeSnapshotQueryObject
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QFilterCondition> {}

extension FeeSnapshotQueryLinks
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QFilterCondition> {}

extension FeeSnapshotQuerySortBy
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QSortBy> {
  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> sortByFeesUsdDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUsdDelta', Sort.asc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy>
  sortByFeesUsdDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUsdDelta', Sort.desc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> sortByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> sortByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension FeeSnapshotQuerySortThenBy
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QSortThenBy> {
  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> thenByFeesUsdDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUsdDelta', Sort.asc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy>
  thenByFeesUsdDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUsdDelta', Sort.desc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> thenByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> thenByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension FeeSnapshotQueryWhereDistinct
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QDistinct> {
  QueryBuilder<FeeSnapshot, FeeSnapshot, QDistinct> distinctByFeesUsdDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feesUsdDelta');
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QDistinct> distinctByPositionKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeeSnapshot, FeeSnapshot, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension FeeSnapshotQueryProperty
    on QueryBuilder<FeeSnapshot, FeeSnapshot, QQueryProperty> {
  QueryBuilder<FeeSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FeeSnapshot, double, QQueryOperations> feesUsdDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feesUsdDelta');
    });
  }

  QueryBuilder<FeeSnapshot, String, QQueryOperations> positionKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionKey');
    });
  }

  QueryBuilder<FeeSnapshot, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
