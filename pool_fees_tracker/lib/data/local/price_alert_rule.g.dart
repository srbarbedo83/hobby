// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_alert_rule.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetPriceAlertRuleCollection on Isar {
  IsarCollection<PriceAlertRule> get priceAlertRules => this.collection();
}

const PriceAlertRuleSchema = CollectionSchema(
  name: r'PriceAlertRule',
  id: -8790327504814388774,
  properties: {
    r'direction': PropertySchema(
      id: 0,
      name: r'direction',
      type: IsarType.string,
      enumMap: _PriceAlertRuledirectionEnumValueMap,
    ),
    r'enabled': PropertySchema(id: 1, name: r'enabled', type: IsarType.bool),
    r'lastTriggered': PropertySchema(
      id: 2,
      name: r'lastTriggered',
      type: IsarType.bool,
    ),
    r'positionKey': PropertySchema(
      id: 3,
      name: r'positionKey',
      type: IsarType.string,
    ),
    r'thresholdTick': PropertySchema(
      id: 4,
      name: r'thresholdTick',
      type: IsarType.long,
    ),
  },

  estimateSize: _priceAlertRuleEstimateSize,
  serialize: _priceAlertRuleSerialize,
  deserialize: _priceAlertRuleDeserialize,
  deserializeProp: _priceAlertRuleDeserializeProp,
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
  },
  links: {},
  embeddedSchemas: {},

  getId: _priceAlertRuleGetId,
  getLinks: _priceAlertRuleGetLinks,
  attach: _priceAlertRuleAttach,
  version: '3.4.1',
);

int _priceAlertRuleEstimateSize(
  PriceAlertRule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.direction.name.length * 3;
  bytesCount += 3 + object.positionKey.length * 3;
  return bytesCount;
}

void _priceAlertRuleSerialize(
  PriceAlertRule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.direction.name);
  writer.writeBool(offsets[1], object.enabled);
  writer.writeBool(offsets[2], object.lastTriggered);
  writer.writeString(offsets[3], object.positionKey);
  writer.writeLong(offsets[4], object.thresholdTick);
}

PriceAlertRule _priceAlertRuleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PriceAlertRule();
  object.direction =
      _PriceAlertRuledirectionValueEnumMap[reader.readStringOrNull(
        offsets[0],
      )] ??
      PriceAlertDirection.above;
  object.enabled = reader.readBool(offsets[1]);
  object.id = id;
  object.lastTriggered = reader.readBool(offsets[2]);
  object.positionKey = reader.readString(offsets[3]);
  object.thresholdTick = reader.readLong(offsets[4]);
  return object;
}

P _priceAlertRuleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_PriceAlertRuledirectionValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              PriceAlertDirection.above)
          as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PriceAlertRuledirectionEnumValueMap = {
  r'above': r'above',
  r'below': r'below',
};
const _PriceAlertRuledirectionValueEnumMap = {
  r'above': PriceAlertDirection.above,
  r'below': PriceAlertDirection.below,
};

Id _priceAlertRuleGetId(PriceAlertRule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _priceAlertRuleGetLinks(PriceAlertRule object) {
  return [];
}

void _priceAlertRuleAttach(
  IsarCollection<dynamic> col,
  Id id,
  PriceAlertRule object,
) {
  object.id = id;
}

extension PriceAlertRuleByIndex on IsarCollection<PriceAlertRule> {
  Future<PriceAlertRule?> getByPositionKey(String positionKey) {
    return getByIndex(r'positionKey', [positionKey]);
  }

  PriceAlertRule? getByPositionKeySync(String positionKey) {
    return getByIndexSync(r'positionKey', [positionKey]);
  }

  Future<bool> deleteByPositionKey(String positionKey) {
    return deleteByIndex(r'positionKey', [positionKey]);
  }

  bool deleteByPositionKeySync(String positionKey) {
    return deleteByIndexSync(r'positionKey', [positionKey]);
  }

  Future<List<PriceAlertRule?>> getAllByPositionKey(
    List<String> positionKeyValues,
  ) {
    final values = positionKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'positionKey', values);
  }

  List<PriceAlertRule?> getAllByPositionKeySync(
    List<String> positionKeyValues,
  ) {
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

  Future<Id> putByPositionKey(PriceAlertRule object) {
    return putByIndex(r'positionKey', object);
  }

  Id putByPositionKeySync(PriceAlertRule object, {bool saveLinks = true}) {
    return putByIndexSync(r'positionKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPositionKey(List<PriceAlertRule> objects) {
    return putAllByIndex(r'positionKey', objects);
  }

  List<Id> putAllByPositionKeySync(
    List<PriceAlertRule> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'positionKey', objects, saveLinks: saveLinks);
  }
}

extension PriceAlertRuleQueryWhereSort
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QWhere> {
  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PriceAlertRuleQueryWhere
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QWhereClause> {
  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhereClause> idBetween(
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhereClause>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterWhereClause>
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
}

extension PriceAlertRuleQueryFilter
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QFilterCondition> {
  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionEqualTo(PriceAlertDirection value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionGreaterThan(
    PriceAlertDirection value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionLessThan(
    PriceAlertDirection value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionBetween(
    PriceAlertDirection lower,
    PriceAlertDirection upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'direction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'direction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  directionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  lastTriggeredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastTriggered', value: value),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
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

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  positionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  positionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  thresholdTickEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thresholdTick', value: value),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  thresholdTickGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thresholdTick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  thresholdTickLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thresholdTick',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterFilterCondition>
  thresholdTickBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thresholdTick',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PriceAlertRuleQueryObject
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QFilterCondition> {}

extension PriceAlertRuleQueryLinks
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QFilterCondition> {}

extension PriceAlertRuleQuerySortBy
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QSortBy> {
  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy> sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy> sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByLastTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByLastTriggeredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByThresholdTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thresholdTick', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  sortByThresholdTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thresholdTick', Sort.desc);
    });
  }
}

extension PriceAlertRuleQuerySortThenBy
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QSortThenBy> {
  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy> thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy> thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByLastTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByLastTriggeredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastTriggered', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByThresholdTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thresholdTick', Sort.asc);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QAfterSortBy>
  thenByThresholdTickDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thresholdTick', Sort.desc);
    });
  }
}

extension PriceAlertRuleQueryWhereDistinct
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QDistinct> {
  QueryBuilder<PriceAlertRule, PriceAlertRule, QDistinct> distinctByDirection({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QDistinct> distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QDistinct>
  distinctByLastTriggered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastTriggered');
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QDistinct>
  distinctByPositionKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertRule, QDistinct>
  distinctByThresholdTick() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thresholdTick');
    });
  }
}

extension PriceAlertRuleQueryProperty
    on QueryBuilder<PriceAlertRule, PriceAlertRule, QQueryProperty> {
  QueryBuilder<PriceAlertRule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PriceAlertRule, PriceAlertDirection, QQueryOperations>
  directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<PriceAlertRule, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<PriceAlertRule, bool, QQueryOperations> lastTriggeredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastTriggered');
    });
  }

  QueryBuilder<PriceAlertRule, String, QQueryOperations> positionKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionKey');
    });
  }

  QueryBuilder<PriceAlertRule, int, QQueryOperations> thresholdTickProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thresholdTick');
    });
  }
}
