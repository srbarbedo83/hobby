// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_point.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetPricePointCollection on Isar {
  IsarCollection<PricePoint> get pricePoints => this.collection();
}

const PricePointSchema = CollectionSchema(
  name: r'PricePoint',
  id: -7490004459955284096,
  properties: {
    r'positionKey': PropertySchema(
      id: 0,
      name: r'positionKey',
      type: IsarType.string,
    ),
    r'tick': PropertySchema(id: 1, name: r'tick', type: IsarType.long),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _pricePointEstimateSize,
  serialize: _pricePointSerialize,
  deserialize: _pricePointDeserialize,
  deserializeProp: _pricePointDeserializeProp,
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

  getId: _pricePointGetId,
  getLinks: _pricePointGetLinks,
  attach: _pricePointAttach,
  version: '3.4.1',
);

int _pricePointEstimateSize(
  PricePoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.positionKey.length * 3;
  return bytesCount;
}

void _pricePointSerialize(
  PricePoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.positionKey);
  writer.writeLong(offsets[1], object.tick);
  writer.writeDateTime(offsets[2], object.timestamp);
}

PricePoint _pricePointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PricePoint();
  object.id = id;
  object.positionKey = reader.readString(offsets[0]);
  object.tick = reader.readLong(offsets[1]);
  object.timestamp = reader.readDateTime(offsets[2]);
  return object;
}

P _pricePointDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pricePointGetId(PricePoint object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pricePointGetLinks(PricePoint object) {
  return [];
}

void _pricePointAttach(IsarCollection<dynamic> col, Id id, PricePoint object) {
  object.id = id;
}

extension PricePointQueryWhereSort
    on QueryBuilder<PricePoint, PricePoint, QWhere> {
  QueryBuilder<PricePoint, PricePoint, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PricePointQueryWhere
    on QueryBuilder<PricePoint, PricePoint, QWhereClause> {
  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause> idBetween(
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause>
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause>
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause>
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause>
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause>
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause>
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

  QueryBuilder<PricePoint, PricePoint, QAfterWhereClause>
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

extension PricePointQueryFilter
    on QueryBuilder<PricePoint, PricePoint, QFilterCondition> {
  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
  positionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
  positionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> tickEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tick', value: value),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> tickGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> tickLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> tickBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tick',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> timestampEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition>
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<PricePoint, PricePoint, QAfterFilterCondition> timestampBetween(
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

extension PricePointQueryObject
    on QueryBuilder<PricePoint, PricePoint, QFilterCondition> {}

extension PricePointQueryLinks
    on QueryBuilder<PricePoint, PricePoint, QFilterCondition> {}

extension PricePointQuerySortBy
    on QueryBuilder<PricePoint, PricePoint, QSortBy> {
  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> sortByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> sortByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> sortByTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tick', Sort.asc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> sortByTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tick', Sort.desc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension PricePointQuerySortThenBy
    on QueryBuilder<PricePoint, PricePoint, QSortThenBy> {
  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenByTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tick', Sort.asc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenByTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tick', Sort.desc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension PricePointQueryWhereDistinct
    on QueryBuilder<PricePoint, PricePoint, QDistinct> {
  QueryBuilder<PricePoint, PricePoint, QDistinct> distinctByPositionKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PricePoint, PricePoint, QDistinct> distinctByTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tick');
    });
  }

  QueryBuilder<PricePoint, PricePoint, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension PricePointQueryProperty
    on QueryBuilder<PricePoint, PricePoint, QQueryProperty> {
  QueryBuilder<PricePoint, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PricePoint, String, QQueryOperations> positionKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionKey');
    });
  }

  QueryBuilder<PricePoint, int, QQueryOperations> tickProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tick');
    });
  }

  QueryBuilder<PricePoint, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
