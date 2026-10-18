// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pool_position.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetPoolPositionCollection on Isar {
  IsarCollection<PoolPosition> get poolPositions => this.collection();
}

const PoolPositionSchema = CollectionSchema(
  name: r'PoolPosition',
  id: 7974501339427522556,
  properties: {
    r'chain': PropertySchema(
      id: 0,
      name: r'chain',
      type: IsarType.string,
      enumMap: _PoolPositionchainEnumValueMap,
    ),
    r'closedAt': PropertySchema(
      id: 1,
      name: r'closedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentTick': PropertySchema(
      id: 3,
      name: r'currentTick',
      type: IsarType.long,
    ),
    r'entryTick': PropertySchema(
      id: 4,
      name: r'entryTick',
      type: IsarType.long,
    ),
    r'feeTierBps': PropertySchema(
      id: 5,
      name: r'feeTierBps',
      type: IsarType.long,
    ),
    r'feeTierPct': PropertySchema(
      id: 6,
      name: r'feeTierPct',
      type: IsarType.double,
    ),
    r'feesClaimedUsd': PropertySchema(
      id: 7,
      name: r'feesClaimedUsd',
      type: IsarType.double,
    ),
    r'feesTotalUsd': PropertySchema(
      id: 8,
      name: r'feesTotalUsd',
      type: IsarType.double,
    ),
    r'feesUnclaimedUsd': PropertySchema(
      id: 9,
      name: r'feesUnclaimedUsd',
      type: IsarType.double,
    ),
    r'gasCostUsd': PropertySchema(
      id: 10,
      name: r'gasCostUsd',
      type: IsarType.double,
    ),
    r'initialLiquidityUsd': PropertySchema(
      id: 11,
      name: r'initialLiquidityUsd',
      type: IsarType.double,
    ),
    r'isClosed': PropertySchema(id: 12, name: r'isClosed', type: IsarType.bool),
    r'liquidityUsd': PropertySchema(
      id: 13,
      name: r'liquidityUsd',
      type: IsarType.double,
    ),
    r'positionKey': PropertySchema(
      id: 14,
      name: r'positionKey',
      type: IsarType.string,
    ),
    r'tickLower': PropertySchema(
      id: 15,
      name: r'tickLower',
      type: IsarType.long,
    ),
    r'tickUpper': PropertySchema(
      id: 16,
      name: r'tickUpper',
      type: IsarType.long,
    ),
    r'token0Symbol': PropertySchema(
      id: 17,
      name: r'token0Symbol',
      type: IsarType.string,
    ),
    r'token1Symbol': PropertySchema(
      id: 18,
      name: r'token1Symbol',
      type: IsarType.string,
    ),
    r'tokenIdOnChain': PropertySchema(
      id: 19,
      name: r'tokenIdOnChain',
      type: IsarType.string,
    ),
    r'walletAddress': PropertySchema(
      id: 20,
      name: r'walletAddress',
      type: IsarType.string,
    ),
  },

  estimateSize: _poolPositionEstimateSize,
  serialize: _poolPositionSerialize,
  deserialize: _poolPositionDeserialize,
  deserializeProp: _poolPositionDeserializeProp,
  idName: r'id',
  indexes: {
    r'positionKey': IndexSchema(
      id: -5085134367502655195,
      name: r'positionKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'positionKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'walletAddress': IndexSchema(
      id: -6656497977715402550,
      name: r'walletAddress',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'walletAddress',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _poolPositionGetId,
  getLinks: _poolPositionGetLinks,
  attach: _poolPositionAttach,
  version: '3.4.1',
);

int _poolPositionEstimateSize(
  PoolPosition object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chain.name.length * 3;
  bytesCount += 3 + object.positionKey.length * 3;
  bytesCount += 3 + object.token0Symbol.length * 3;
  bytesCount += 3 + object.token1Symbol.length * 3;
  bytesCount += 3 + object.tokenIdOnChain.length * 3;
  bytesCount += 3 + object.walletAddress.length * 3;
  return bytesCount;
}

void _poolPositionSerialize(
  PoolPosition object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chain.name);
  writer.writeDateTime(offsets[1], object.closedAt);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.currentTick);
  writer.writeLong(offsets[4], object.entryTick);
  writer.writeLong(offsets[5], object.feeTierBps);
  writer.writeDouble(offsets[6], object.feeTierPct);
  writer.writeDouble(offsets[7], object.feesClaimedUsd);
  writer.writeDouble(offsets[8], object.feesTotalUsd);
  writer.writeDouble(offsets[9], object.feesUnclaimedUsd);
  writer.writeDouble(offsets[10], object.gasCostUsd);
  writer.writeDouble(offsets[11], object.initialLiquidityUsd);
  writer.writeBool(offsets[12], object.isClosed);
  writer.writeDouble(offsets[13], object.liquidityUsd);
  writer.writeString(offsets[14], object.positionKey);
  writer.writeLong(offsets[15], object.tickLower);
  writer.writeLong(offsets[16], object.tickUpper);
  writer.writeString(offsets[17], object.token0Symbol);
  writer.writeString(offsets[18], object.token1Symbol);
  writer.writeString(offsets[19], object.tokenIdOnChain);
  writer.writeString(offsets[20], object.walletAddress);
}

PoolPosition _poolPositionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PoolPosition();
  object.chain =
      _PoolPositionchainValueEnumMap[reader.readStringOrNull(offsets[0])] ??
      Chain.ethereum;
  object.closedAt = reader.readDateTimeOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.currentTick = reader.readLong(offsets[3]);
  object.entryTick = reader.readLong(offsets[4]);
  object.feeTierBps = reader.readLong(offsets[5]);
  object.feesClaimedUsd = reader.readDouble(offsets[7]);
  object.feesUnclaimedUsd = reader.readDouble(offsets[9]);
  object.gasCostUsd = reader.readDouble(offsets[10]);
  object.id = id;
  object.initialLiquidityUsd = reader.readDouble(offsets[11]);
  object.isClosed = reader.readBool(offsets[12]);
  object.liquidityUsd = reader.readDouble(offsets[13]);
  object.positionKey = reader.readString(offsets[14]);
  object.tickLower = reader.readLong(offsets[15]);
  object.tickUpper = reader.readLong(offsets[16]);
  object.token0Symbol = reader.readString(offsets[17]);
  object.token1Symbol = reader.readString(offsets[18]);
  object.tokenIdOnChain = reader.readString(offsets[19]);
  object.walletAddress = reader.readString(offsets[20]);
  return object;
}

P _poolPositionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_PoolPositionchainValueEnumMap[reader.readStringOrNull(offset)] ??
              Chain.ethereum)
          as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PoolPositionchainEnumValueMap = {
  r'ethereum': r'ethereum',
  r'arbitrum': r'arbitrum',
  r'base': r'base',
  r'optimism': r'optimism',
  r'polygon': r'polygon',
};
const _PoolPositionchainValueEnumMap = {
  r'ethereum': Chain.ethereum,
  r'arbitrum': Chain.arbitrum,
  r'base': Chain.base,
  r'optimism': Chain.optimism,
  r'polygon': Chain.polygon,
};

Id _poolPositionGetId(PoolPosition object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _poolPositionGetLinks(PoolPosition object) {
  return [];
}

void _poolPositionAttach(
  IsarCollection<dynamic> col,
  Id id,
  PoolPosition object,
) {
  object.id = id;
}

extension PoolPositionByIndex on IsarCollection<PoolPosition> {
  Future<PoolPosition?> getByPositionKey(String positionKey) {
    return getByIndex(r'positionKey', [positionKey]);
  }

  PoolPosition? getByPositionKeySync(String positionKey) {
    return getByIndexSync(r'positionKey', [positionKey]);
  }

  Future<bool> deleteByPositionKey(String positionKey) {
    return deleteByIndex(r'positionKey', [positionKey]);
  }

  bool deleteByPositionKeySync(String positionKey) {
    return deleteByIndexSync(r'positionKey', [positionKey]);
  }

  Future<List<PoolPosition?>> getAllByPositionKey(
    List<String> positionKeyValues,
  ) {
    final values = positionKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'positionKey', values);
  }

  List<PoolPosition?> getAllByPositionKeySync(List<String> positionKeyValues) {
    final values = positionKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'positionKey', values);
  }

  Future<int> deleteAllByPositionKey(List<String> positionKeyValues) {
    final values = positionKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'positionKey', values);
  }

  int deleteAllByPositionKeySync(List<String> positionKeyValues) {
    final values = positionKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'positionKey', values);
  }

  Future<Id> putByPositionKey(PoolPosition object) {
    return putByIndex(r'positionKey', object);
  }

  Id putByPositionKeySync(PoolPosition object, {bool saveLinks = true}) {
    return putByIndexSync(r'positionKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPositionKey(List<PoolPosition> objects) {
    return putAllByIndex(r'positionKey', objects);
  }

  List<Id> putAllByPositionKeySync(
    List<PoolPosition> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'positionKey', objects, saveLinks: saveLinks);
  }
}

extension PoolPositionQueryWhereSort
    on QueryBuilder<PoolPosition, PoolPosition, QWhere> {
  QueryBuilder<PoolPosition, PoolPosition, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PoolPositionQueryWhere
    on QueryBuilder<PoolPosition, PoolPosition, QWhereClause> {
  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause> idBetween(
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause>
  walletAddressEqualTo(String walletAddress) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'walletAddress',
          value: [walletAddress],
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterWhereClause>
  walletAddressNotEqualTo(String walletAddress) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'walletAddress',
                lower: [],
                upper: [walletAddress],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'walletAddress',
                lower: [walletAddress],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'walletAddress',
                lower: [walletAddress],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'walletAddress',
                lower: [],
                upper: [walletAddress],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PoolPositionQueryFilter
    on QueryBuilder<PoolPosition, PoolPosition, QFilterCondition> {
  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> chainEqualTo(
    Chain value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'chain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  chainGreaterThan(
    Chain value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'chain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> chainLessThan(
    Chain value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'chain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> chainBetween(
    Chain lower,
    Chain upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'chain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  chainStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'chain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> chainEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'chain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> chainContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'chain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> chainMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'chain',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  chainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chain', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  chainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'chain', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  closedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'closedAt'),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  closedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'closedAt'),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  closedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'closedAt', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  closedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'closedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  closedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'closedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  closedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'closedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  currentTickEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentTick', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  currentTickGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentTick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  currentTickLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentTick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  currentTickBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentTick',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  entryTickEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entryTick', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  entryTickGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entryTick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  entryTickLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entryTick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  entryTickBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entryTick',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierBpsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'feeTierBps', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierBpsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feeTierBps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierBpsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feeTierBps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierBpsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feeTierBps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierPctEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feeTierPct',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierPctGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feeTierPct',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierPctLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feeTierPct',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feeTierPctBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feeTierPct',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesClaimedUsdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feesClaimedUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesClaimedUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feesClaimedUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesClaimedUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feesClaimedUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesClaimedUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feesClaimedUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesTotalUsdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feesTotalUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesTotalUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feesTotalUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesTotalUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feesTotalUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesTotalUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feesTotalUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesUnclaimedUsdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feesUnclaimedUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesUnclaimedUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feesUnclaimedUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesUnclaimedUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feesUnclaimedUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  feesUnclaimedUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feesUnclaimedUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  gasCostUsdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'gasCostUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  gasCostUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gasCostUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  gasCostUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gasCostUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  gasCostUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gasCostUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  initialLiquidityUsdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'initialLiquidityUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  initialLiquidityUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'initialLiquidityUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  initialLiquidityUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'initialLiquidityUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  initialLiquidityUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'initialLiquidityUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  isClosedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isClosed', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  liquidityUsdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'liquidityUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  liquidityUsdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'liquidityUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  liquidityUsdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'liquidityUsd',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  liquidityUsdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'liquidityUsd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
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

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  positionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  positionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickLowerEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tickLower', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickLowerGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tickLower',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickLowerLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tickLower',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickLowerBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tickLower',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickUpperEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tickUpper', value: value),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickUpperGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tickUpper',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickUpperLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tickUpper',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tickUpperBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tickUpper',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'token0Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'token0Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'token0Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'token0Symbol',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'token0Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'token0Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'token0Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'token0Symbol',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'token0Symbol', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token0SymbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'token0Symbol', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'token1Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'token1Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'token1Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'token1Symbol',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'token1Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'token1Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'token1Symbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'token1Symbol',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'token1Symbol', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  token1SymbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'token1Symbol', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tokenIdOnChain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tokenIdOnChain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tokenIdOnChain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tokenIdOnChain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tokenIdOnChain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tokenIdOnChain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tokenIdOnChain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tokenIdOnChain',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tokenIdOnChain', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  tokenIdOnChainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tokenIdOnChain', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'walletAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'walletAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'walletAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'walletAddress',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'walletAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'walletAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'walletAddress',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'walletAddress',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'walletAddress', value: ''),
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterFilterCondition>
  walletAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'walletAddress', value: ''),
      );
    });
  }
}

extension PoolPositionQueryObject
    on QueryBuilder<PoolPosition, PoolPosition, QFilterCondition> {}

extension PoolPositionQueryLinks
    on QueryBuilder<PoolPosition, PoolPosition, QFilterCondition> {}

extension PoolPositionQuerySortBy
    on QueryBuilder<PoolPosition, PoolPosition, QSortBy> {
  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByChain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chain', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByChainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chain', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByCurrentTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTick', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByCurrentTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTick', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByEntryTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryTick', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByEntryTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryTick', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByFeeTierBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierBps', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByFeeTierBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierBps', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByFeeTierPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierPct', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByFeeTierPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierPct', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByFeesClaimedUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesClaimedUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByFeesClaimedUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesClaimedUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByFeesTotalUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesTotalUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByFeesTotalUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesTotalUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByFeesUnclaimedUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUnclaimedUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByFeesUnclaimedUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUnclaimedUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByGasCostUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasCostUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByGasCostUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasCostUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByInitialLiquidityUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLiquidityUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByInitialLiquidityUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLiquidityUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByIsClosed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByIsClosedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByLiquidityUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liquidityUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByLiquidityUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liquidityUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByTickLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickLower', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByTickLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickLower', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByTickUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickUpper', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByTickUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickUpper', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByToken0Symbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token0Symbol', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByToken0SymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token0Symbol', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByToken1Symbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token1Symbol', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByToken1SymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token1Symbol', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByTokenIdOnChain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenIdOnChain', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByTokenIdOnChainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenIdOnChain', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> sortByWalletAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletAddress', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  sortByWalletAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletAddress', Sort.desc);
    });
  }
}

extension PoolPositionQuerySortThenBy
    on QueryBuilder<PoolPosition, PoolPosition, QSortThenBy> {
  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByChain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chain', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByChainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chain', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByCurrentTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTick', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByCurrentTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTick', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByEntryTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryTick', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByEntryTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryTick', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByFeeTierBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierBps', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByFeeTierBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierBps', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByFeeTierPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierPct', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByFeeTierPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feeTierPct', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByFeesClaimedUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesClaimedUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByFeesClaimedUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesClaimedUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByFeesTotalUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesTotalUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByFeesTotalUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesTotalUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByFeesUnclaimedUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUnclaimedUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByFeesUnclaimedUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feesUnclaimedUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByGasCostUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasCostUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByGasCostUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gasCostUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByInitialLiquidityUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLiquidityUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByInitialLiquidityUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialLiquidityUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByIsClosed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByIsClosedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClosed', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByLiquidityUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liquidityUsd', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByLiquidityUsdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'liquidityUsd', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByTickLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickLower', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByTickLowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickLower', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByTickUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickUpper', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByTickUpperDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tickUpper', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByToken0Symbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token0Symbol', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByToken0SymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token0Symbol', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByToken1Symbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token1Symbol', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByToken1SymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token1Symbol', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByTokenIdOnChain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenIdOnChain', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByTokenIdOnChainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenIdOnChain', Sort.desc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy> thenByWalletAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletAddress', Sort.asc);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QAfterSortBy>
  thenByWalletAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletAddress', Sort.desc);
    });
  }
}

extension PoolPositionQueryWhereDistinct
    on QueryBuilder<PoolPosition, PoolPosition, QDistinct> {
  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByChain({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chain', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedAt');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByCurrentTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentTick');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByEntryTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryTick');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByFeeTierBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feeTierBps');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByFeeTierPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feeTierPct');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct>
  distinctByFeesClaimedUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feesClaimedUsd');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByFeesTotalUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feesTotalUsd');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct>
  distinctByFeesUnclaimedUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feesUnclaimedUsd');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByGasCostUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gasCostUsd');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct>
  distinctByInitialLiquidityUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialLiquidityUsd');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByIsClosed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isClosed');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByLiquidityUsd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'liquidityUsd');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByPositionKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByTickLower() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tickLower');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByTickUpper() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tickUpper');
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByToken0Symbol({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token0Symbol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByToken1Symbol({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token1Symbol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByTokenIdOnChain({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'tokenIdOnChain',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PoolPosition, PoolPosition, QDistinct> distinctByWalletAddress({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'walletAddress',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension PoolPositionQueryProperty
    on QueryBuilder<PoolPosition, PoolPosition, QQueryProperty> {
  QueryBuilder<PoolPosition, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PoolPosition, Chain, QQueryOperations> chainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chain');
    });
  }

  QueryBuilder<PoolPosition, DateTime?, QQueryOperations> closedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedAt');
    });
  }

  QueryBuilder<PoolPosition, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PoolPosition, int, QQueryOperations> currentTickProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentTick');
    });
  }

  QueryBuilder<PoolPosition, int, QQueryOperations> entryTickProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryTick');
    });
  }

  QueryBuilder<PoolPosition, int, QQueryOperations> feeTierBpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feeTierBps');
    });
  }

  QueryBuilder<PoolPosition, double, QQueryOperations> feeTierPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feeTierPct');
    });
  }

  QueryBuilder<PoolPosition, double, QQueryOperations>
  feesClaimedUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feesClaimedUsd');
    });
  }

  QueryBuilder<PoolPosition, double, QQueryOperations> feesTotalUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feesTotalUsd');
    });
  }

  QueryBuilder<PoolPosition, double, QQueryOperations>
  feesUnclaimedUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feesUnclaimedUsd');
    });
  }

  QueryBuilder<PoolPosition, double, QQueryOperations> gasCostUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gasCostUsd');
    });
  }

  QueryBuilder<PoolPosition, double, QQueryOperations>
  initialLiquidityUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialLiquidityUsd');
    });
  }

  QueryBuilder<PoolPosition, bool, QQueryOperations> isClosedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isClosed');
    });
  }

  QueryBuilder<PoolPosition, double, QQueryOperations> liquidityUsdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'liquidityUsd');
    });
  }

  QueryBuilder<PoolPosition, String, QQueryOperations> positionKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionKey');
    });
  }

  QueryBuilder<PoolPosition, int, QQueryOperations> tickLowerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tickLower');
    });
  }

  QueryBuilder<PoolPosition, int, QQueryOperations> tickUpperProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tickUpper');
    });
  }

  QueryBuilder<PoolPosition, String, QQueryOperations> token0SymbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token0Symbol');
    });
  }

  QueryBuilder<PoolPosition, String, QQueryOperations> token1SymbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token1Symbol');
    });
  }

  QueryBuilder<PoolPosition, String, QQueryOperations>
  tokenIdOnChainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tokenIdOnChain');
    });
  }

  QueryBuilder<PoolPosition, String, QQueryOperations> walletAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'walletAddress');
    });
  }
}
