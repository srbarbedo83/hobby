// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetAlertStateCollection on Isar {
  IsarCollection<AlertState> get alertStates => this.collection();
}

const AlertStateSchema = CollectionSchema(
  name: r'AlertState',
  id: -7642080039112220721,
  properties: {
    r'lastConcentrationRiskActive': PropertySchema(
      id: 0,
      name: r'lastConcentrationRiskActive',
      type: IsarType.bool,
    ),
    r'lastFeeSlowdownNotified': PropertySchema(
      id: 1,
      name: r'lastFeeSlowdownNotified',
      type: IsarType.bool,
    ),
    r'lastFeeSpikeNotified': PropertySchema(
      id: 2,
      name: r'lastFeeSpikeNotified',
      type: IsarType.bool,
    ),
    r'lastNotifiedFeesTotal': PropertySchema(
      id: 3,
      name: r'lastNotifiedFeesTotal',
      type: IsarType.double,
    ),
    r'lastOutOfRangeDurationNotified': PropertySchema(
      id: 4,
      name: r'lastOutOfRangeDurationNotified',
      type: IsarType.bool,
    ),
    r'lastRangeStatus': PropertySchema(
      id: 5,
      name: r'lastRangeStatus',
      type: IsarType.string,
      enumMap: _AlertStatelastRangeStatusEnumValueMap,
    ),
    r'lastWeeklyDigestSentAt': PropertySchema(
      id: 6,
      name: r'lastWeeklyDigestSentAt',
      type: IsarType.dateTime,
    ),
    r'positionKey': PropertySchema(
      id: 7,
      name: r'positionKey',
      type: IsarType.string,
    ),
  },

  estimateSize: _alertStateEstimateSize,
  serialize: _alertStateSerialize,
  deserialize: _alertStateDeserialize,
  deserializeProp: _alertStateDeserializeProp,
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

  getId: _alertStateGetId,
  getLinks: _alertStateGetLinks,
  attach: _alertStateAttach,
  version: '3.4.1',
);

int _alertStateEstimateSize(
  AlertState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.lastRangeStatus.name.length * 3;
  bytesCount += 3 + object.positionKey.length * 3;
  return bytesCount;
}

void _alertStateSerialize(
  AlertState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.lastConcentrationRiskActive);
  writer.writeBool(offsets[1], object.lastFeeSlowdownNotified);
  writer.writeBool(offsets[2], object.lastFeeSpikeNotified);
  writer.writeDouble(offsets[3], object.lastNotifiedFeesTotal);
  writer.writeBool(offsets[4], object.lastOutOfRangeDurationNotified);
  writer.writeString(offsets[5], object.lastRangeStatus.name);
  writer.writeDateTime(offsets[6], object.lastWeeklyDigestSentAt);
  writer.writeString(offsets[7], object.positionKey);
}

AlertState _alertStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AlertState();
  object.id = id;
  object.lastConcentrationRiskActive = reader.readBool(offsets[0]);
  object.lastFeeSlowdownNotified = reader.readBool(offsets[1]);
  object.lastFeeSpikeNotified = reader.readBool(offsets[2]);
  object.lastNotifiedFeesTotal = reader.readDouble(offsets[3]);
  object.lastOutOfRangeDurationNotified = reader.readBool(offsets[4]);
  object.lastRangeStatus =
      _AlertStatelastRangeStatusValueEnumMap[reader.readStringOrNull(
        offsets[5],
      )] ??
      RangeStatus.inRange;
  object.lastWeeklyDigestSentAt = reader.readDateTimeOrNull(offsets[6]);
  object.positionKey = reader.readString(offsets[7]);
  return object;
}

P _alertStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (_AlertStatelastRangeStatusValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              RangeStatus.inRange)
          as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AlertStatelastRangeStatusEnumValueMap = {
  r'inRange': r'inRange',
  r'nearEdge': r'nearEdge',
  r'outOfRange': r'outOfRange',
};
const _AlertStatelastRangeStatusValueEnumMap = {
  r'inRange': RangeStatus.inRange,
  r'nearEdge': RangeStatus.nearEdge,
  r'outOfRange': RangeStatus.outOfRange,
};

Id _alertStateGetId(AlertState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _alertStateGetLinks(AlertState object) {
  return [];
}

void _alertStateAttach(IsarCollection<dynamic> col, Id id, AlertState object) {
  object.id = id;
}

extension AlertStateByIndex on IsarCollection<AlertState> {
  Future<AlertState?> getByPositionKey(String positionKey) {
    return getByIndex(r'positionKey', [positionKey]);
  }

  AlertState? getByPositionKeySync(String positionKey) {
    return getByIndexSync(r'positionKey', [positionKey]);
  }

  Future<bool> deleteByPositionKey(String positionKey) {
    return deleteByIndex(r'positionKey', [positionKey]);
  }

  bool deleteByPositionKeySync(String positionKey) {
    return deleteByIndexSync(r'positionKey', [positionKey]);
  }

  Future<List<AlertState?>> getAllByPositionKey(
    List<String> positionKeyValues,
  ) {
    final values = positionKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'positionKey', values);
  }

  List<AlertState?> getAllByPositionKeySync(List<String> positionKeyValues) {
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

  Future<Id> putByPositionKey(AlertState object) {
    return putByIndex(r'positionKey', object);
  }

  Id putByPositionKeySync(AlertState object, {bool saveLinks = true}) {
    return putByIndexSync(r'positionKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPositionKey(List<AlertState> objects) {
    return putAllByIndex(r'positionKey', objects);
  }

  List<Id> putAllByPositionKeySync(
    List<AlertState> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'positionKey', objects, saveLinks: saveLinks);
  }
}

extension AlertStateQueryWhereSort
    on QueryBuilder<AlertState, AlertState, QWhere> {
  QueryBuilder<AlertState, AlertState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AlertStateQueryWhere
    on QueryBuilder<AlertState, AlertState, QWhereClause> {
  QueryBuilder<AlertState, AlertState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AlertState, AlertState, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterWhereClause> idBetween(
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

  QueryBuilder<AlertState, AlertState, QAfterWhereClause> positionKeyEqualTo(
    String positionKey,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'positionKey',
          value: [positionKey],
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterWhereClause> positionKeyNotEqualTo(
    String positionKey,
  ) {
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

extension AlertStateQueryFilter
    on QueryBuilder<AlertState, AlertState, QFilterCondition> {
  QueryBuilder<AlertState, AlertState, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastConcentrationRiskActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastConcentrationRiskActive',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastFeeSlowdownNotifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastFeeSlowdownNotified',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastFeeSpikeNotifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastFeeSpikeNotified',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastNotifiedFeesTotalEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastNotifiedFeesTotal',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastNotifiedFeesTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastNotifiedFeesTotal',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastNotifiedFeesTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastNotifiedFeesTotal',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastNotifiedFeesTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastNotifiedFeesTotal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastOutOfRangeDurationNotifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastOutOfRangeDurationNotified',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusEqualTo(RangeStatus value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastRangeStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusGreaterThan(
    RangeStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastRangeStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusLessThan(
    RangeStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastRangeStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusBetween(
    RangeStatus lower,
    RangeStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastRangeStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastRangeStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastRangeStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastRangeStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastRangeStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastRangeStatus', value: ''),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastRangeStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastRangeStatus', value: ''),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastWeeklyDigestSentAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastWeeklyDigestSentAt'),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastWeeklyDigestSentAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastWeeklyDigestSentAt'),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastWeeklyDigestSentAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastWeeklyDigestSentAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastWeeklyDigestSentAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastWeeklyDigestSentAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastWeeklyDigestSentAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastWeeklyDigestSentAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  lastWeeklyDigestSentAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastWeeklyDigestSentAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
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

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  positionKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'positionKey', value: ''),
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterFilterCondition>
  positionKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'positionKey', value: ''),
      );
    });
  }
}

extension AlertStateQueryObject
    on QueryBuilder<AlertState, AlertState, QFilterCondition> {}

extension AlertStateQueryLinks
    on QueryBuilder<AlertState, AlertState, QFilterCondition> {}

extension AlertStateQuerySortBy
    on QueryBuilder<AlertState, AlertState, QSortBy> {
  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastConcentrationRiskActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConcentrationRiskActive', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastConcentrationRiskActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConcentrationRiskActive', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastFeeSlowdownNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSlowdownNotified', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastFeeSlowdownNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSlowdownNotified', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastFeeSpikeNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSpikeNotified', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastFeeSpikeNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSpikeNotified', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastNotifiedFeesTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedFeesTotal', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastNotifiedFeesTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedFeesTotal', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastOutOfRangeDurationNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOutOfRangeDurationNotified', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastOutOfRangeDurationNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOutOfRangeDurationNotified', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy> sortByLastRangeStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRangeStatus', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastRangeStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRangeStatus', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastWeeklyDigestSentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWeeklyDigestSentAt', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  sortByLastWeeklyDigestSentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWeeklyDigestSentAt', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy> sortByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy> sortByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }
}

extension AlertStateQuerySortThenBy
    on QueryBuilder<AlertState, AlertState, QSortThenBy> {
  QueryBuilder<AlertState, AlertState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastConcentrationRiskActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConcentrationRiskActive', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastConcentrationRiskActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastConcentrationRiskActive', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastFeeSlowdownNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSlowdownNotified', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastFeeSlowdownNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSlowdownNotified', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastFeeSpikeNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSpikeNotified', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastFeeSpikeNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFeeSpikeNotified', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastNotifiedFeesTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedFeesTotal', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastNotifiedFeesTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastNotifiedFeesTotal', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastOutOfRangeDurationNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOutOfRangeDurationNotified', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastOutOfRangeDurationNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOutOfRangeDurationNotified', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy> thenByLastRangeStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRangeStatus', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastRangeStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRangeStatus', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastWeeklyDigestSentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWeeklyDigestSentAt', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy>
  thenByLastWeeklyDigestSentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWeeklyDigestSentAt', Sort.desc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy> thenByPositionKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.asc);
    });
  }

  QueryBuilder<AlertState, AlertState, QAfterSortBy> thenByPositionKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionKey', Sort.desc);
    });
  }
}

extension AlertStateQueryWhereDistinct
    on QueryBuilder<AlertState, AlertState, QDistinct> {
  QueryBuilder<AlertState, AlertState, QDistinct>
  distinctByLastConcentrationRiskActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastConcentrationRiskActive');
    });
  }

  QueryBuilder<AlertState, AlertState, QDistinct>
  distinctByLastFeeSlowdownNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFeeSlowdownNotified');
    });
  }

  QueryBuilder<AlertState, AlertState, QDistinct>
  distinctByLastFeeSpikeNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFeeSpikeNotified');
    });
  }

  QueryBuilder<AlertState, AlertState, QDistinct>
  distinctByLastNotifiedFeesTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastNotifiedFeesTotal');
    });
  }

  QueryBuilder<AlertState, AlertState, QDistinct>
  distinctByLastOutOfRangeDurationNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOutOfRangeDurationNotified');
    });
  }

  QueryBuilder<AlertState, AlertState, QDistinct> distinctByLastRangeStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastRangeStatus',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AlertState, AlertState, QDistinct>
  distinctByLastWeeklyDigestSentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastWeeklyDigestSentAt');
    });
  }

  QueryBuilder<AlertState, AlertState, QDistinct> distinctByPositionKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionKey', caseSensitive: caseSensitive);
    });
  }
}

extension AlertStateQueryProperty
    on QueryBuilder<AlertState, AlertState, QQueryProperty> {
  QueryBuilder<AlertState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AlertState, bool, QQueryOperations>
  lastConcentrationRiskActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastConcentrationRiskActive');
    });
  }

  QueryBuilder<AlertState, bool, QQueryOperations>
  lastFeeSlowdownNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFeeSlowdownNotified');
    });
  }

  QueryBuilder<AlertState, bool, QQueryOperations>
  lastFeeSpikeNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFeeSpikeNotified');
    });
  }

  QueryBuilder<AlertState, double, QQueryOperations>
  lastNotifiedFeesTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastNotifiedFeesTotal');
    });
  }

  QueryBuilder<AlertState, bool, QQueryOperations>
  lastOutOfRangeDurationNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOutOfRangeDurationNotified');
    });
  }

  QueryBuilder<AlertState, RangeStatus, QQueryOperations>
  lastRangeStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRangeStatus');
    });
  }

  QueryBuilder<AlertState, DateTime?, QQueryOperations>
  lastWeeklyDigestSentAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastWeeklyDigestSentAt');
    });
  }

  QueryBuilder<AlertState, String, QQueryOperations> positionKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionKey');
    });
  }
}
