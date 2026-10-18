// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetPositionEventCollection on Isar {
  IsarCollection<PositionEvent> get positionEvents => this.collection();
}

const PositionEventSchema = CollectionSchema(
  name: r'PositionEvent',
  id: 6241448243911223720,
  properties: {
    r'amountUsd': PropertySchema(
      id: 0,
      name: r'amountUsd',
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
    r'txHash': PropertySchema(id: 3, name: r'txHash', type: IsarType.string),
    r'type': PropertySchema(
      id: 4,
      name: r'type',
      type: IsarType.string,
      enumMap: _PositionEventtypeEnumValueMap,
    ),
  },

  estimateSize: _positionEventEstimateSize,
  serialize: _positionEventSerialize,
  deserialize: _positionEventDeserialize,
  deserializeProp: _positionEventDeserializeProp,
  idName: r'id',
  indexes: {
    r'positionKey': IndexSchema(
      id: -5085134367502655195,
      name: r'positionKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'positionKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
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

  getId: _positionEventGetId,
  getLinks: _positionEventGetLinks,
  attach: _positionEventAttach,
  version: '3.4.1',
);

int _positionEventEstimateSize(
  PositionEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.positionKey.length * 3;
  {
    final value = object.txHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _positionEventSerialize(
  PositionEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amountUsd);
  writer.writeString(offsets[1], object.positionKey);
  writer.writeDateTime(offsets[2], object.timestamp);
  writer.writeString(offsets[3], object.txHash);
  writer.writeString(offsets[4], object.type.name);
}

PositionEvent _positionEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PositionEvent();
  object.amountUsd = reader.readDouble(offsets[0]);
  object.id = id;
  object.positionKey = reader.readString(offsets[1]);
  object.timestamp = reader.readDateTime(offsets[2]);
  object.txHash = reader.readStringOrNull(offsets[3]);
  object.type =
      _PositionEventtypeValueEnumMap[reader.readStringOrNull(offsets[4])] ??
      PositionEventType.mint;
  return object;
}

P _positionEventDeserializeProp<P>(
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
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (_PositionEventtypeValueEnumMap[reader.readStringOrNull(offset)] ??
              PositionEventType.mint)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PositionEventtypeEnumValueMap = {
  r'mint': r'mint',
  r'increaseLiquidity': r'increaseLiquidity',
  r'decreaseLiquidity': r'decreaseLiquidity',
  r'collect': r'collect',
};
const _PositionEventtypeValueEnumMap = {
  r'mint': PositionEventType.mint,
  r'increaseLiquidity': PositionEventType.increaseLiquidity,
  r'decreaseLiquidity': PositionEventType.decreaseLiquidity,
  r'collect': PositionEventType.collect,
};

Id _positionEventGetId(PositionEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _positionEventGetLinks(PositionEvent object) {
  return [];
}

void _positionEventAttach(
  IsarCollection<dynamic> col,
  Id id,
  PositionEvent object,
) {
  object.id = id;
}

extension PositionEventQueryWhereSort
    on QueryBuilder<PositionEvent, PositionEvent, QWhere> {
  QueryBuilder<PositionEvent, PositionEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension PositionEventQueryWhere
    on QueryBuilder<PositionEvent, PositionEvent, QWhereClause> {
  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause> idBetween(
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause>
  positionKeyEqualTo(String positionKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'positionKey',
          value: [positionKey],
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause>
  positionKeyNotEqualTo(String positionKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey',
                lower: [],
                upper: [positionKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey',
                lower: [positionKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey',
                lower: [positionKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'positionKey',
                lower: [],
                upper: [positionKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause>
  timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause>
  timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause>
  timestampGreaterThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [timestamp],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause>
  timestampLessThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [],
          upper: [timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterWhereClause>
  timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [lowerTimestamp],
          includeLower: includeLower,
          upper: [upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PositionEventQueryFilter
    on QueryBuilder<PositionEvent, PositionEvent, QFilterCondition> {
  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  amountUsdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amountUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  amountUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amountUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  amountUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amountUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  amountUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amountUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  positionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  positionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
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

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'txHash'),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'txHash'),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'txHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'txHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'txHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'txHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'txHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'txHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'txHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'txHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'txHash', value: ''),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  txHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'txHash', value: ''),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition> typeEqualTo(
    PositionEventType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  typeGreaterThan(
    PositionEventType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  typeLessThan(
    PositionEventType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition> typeBetween(
    PositionEventType lower,
    PositionEventType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension PositionEventQueryObject
    on QueryBuilder<PositionEvent, PositionEvent, QFilterCondition> {}

extension PositionEventQueryLinks
    on QueryBuilder<PositionEvent, PositionEvent, QFilterCondition> {}

extension PositionEventQuerySortBy
    on QueryBuilder<PositionEvent, PositionEvent, QSortBy> {
  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> sortByAmountUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountUsd', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy>
  sortByAmountUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountUsd', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> sortByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy>
  sortByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> sortByTxHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txHash', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> sortByTxHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txHash', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PositionEventQuerySortThenBy
    on QueryBuilder<PositionEvent, PositionEvent, QSortThenBy> {
  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByAmountUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountUsd', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy>
  thenByAmountUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountUsd', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy>
  thenByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByTxHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txHash', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByTxHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txHash', Sort.desc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PositionEventQueryWhereDistinct
    on QueryBuilder<PositionEvent, PositionEvent, QDistinct> {
  QueryBuilder<PositionEvent, PositionEvent, QDistinct> distinctByAmountUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountUsd');
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QDistinct> distinctByPositionKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QDistinct> distinctByTxHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'txHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PositionEvent, PositionEvent, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension PositionEventQueryProperty
    on QueryBuilder<PositionEvent, PositionEvent, QQueryProperty> {
  QueryBuilder<PositionEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PositionEvent, double, QQueryOperations> amountUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountUsd');
    });
  }

  QueryBuilder<PositionEvent, String, QQueryOperations> positionKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionKey');
    });
  }

  QueryBuilder<PositionEvent, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<PositionEvent, String?, QQueryOperations> txHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'txHash');
    });
  }

  QueryBuilder<PositionEvent, PositionEventType, QQueryOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
