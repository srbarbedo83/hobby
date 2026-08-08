// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estado_cronometro.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEstadoCronometroCollection on Isar {
  IsarCollection<EstadoCronometro> get estadoCronometros => this.collection();
}

const EstadoCronometroSchema = CollectionSchema(
  name: r'EstadoCronometro',
  id: 5949562016149956784,
  properties: {
    r'duracaoAcumuladaSegundos': PropertySchema(
      id: 0,
      name: r'duracaoAcumuladaSegundos',
      type: IsarType.long,
    ),
    r'estado': PropertySchema(
      id: 1,
      name: r'estado',
      type: IsarType.string,
      enumMap: _EstadoCronometroestadoEnumValueMap,
    ),
    r'hobbyId': PropertySchema(id: 2, name: r'hobbyId', type: IsarType.long),
    r'inicioSessao': PropertySchema(
      id: 3,
      name: r'inicioSessao',
      type: IsarType.dateTime,
    ),
    r'timestampInicio': PropertySchema(
      id: 4,
      name: r'timestampInicio',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _estadoCronometroEstimateSize,
  serialize: _estadoCronometroSerialize,
  deserialize: _estadoCronometroDeserialize,
  deserializeProp: _estadoCronometroDeserializeProp,
  idName: r'id',
  indexes: {
    r'hobbyId': IndexSchema(
      id: -5158992410789902336,
      name: r'hobbyId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hobbyId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _estadoCronometroGetId,
  getLinks: _estadoCronometroGetLinks,
  attach: _estadoCronometroAttach,
  version: '3.3.2',
);

int _estadoCronometroEstimateSize(
  EstadoCronometro object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.estado.name.length * 3;
  return bytesCount;
}

void _estadoCronometroSerialize(
  EstadoCronometro object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.duracaoAcumuladaSegundos);
  writer.writeString(offsets[1], object.estado.name);
  writer.writeLong(offsets[2], object.hobbyId);
  writer.writeDateTime(offsets[3], object.inicioSessao);
  writer.writeDateTime(offsets[4], object.timestampInicio);
}

EstadoCronometro _estadoCronometroDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EstadoCronometro();
  object.duracaoAcumuladaSegundos = reader.readLong(offsets[0]);
  object.estado =
      _EstadoCronometroestadoValueEnumMap[reader.readStringOrNull(
        offsets[1],
      )] ??
      EstadoExecucao.emExecucao;
  object.hobbyId = reader.readLong(offsets[2]);
  object.id = id;
  object.inicioSessao = reader.readDateTime(offsets[3]);
  object.timestampInicio = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _estadoCronometroDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (_EstadoCronometroestadoValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              EstadoExecucao.emExecucao)
          as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EstadoCronometroestadoEnumValueMap = {
  r'emExecucao': r'emExecucao',
  r'pausado': r'pausado',
};
const _EstadoCronometroestadoValueEnumMap = {
  r'emExecucao': EstadoExecucao.emExecucao,
  r'pausado': EstadoExecucao.pausado,
};

Id _estadoCronometroGetId(EstadoCronometro object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _estadoCronometroGetLinks(EstadoCronometro object) {
  return [];
}

void _estadoCronometroAttach(
  IsarCollection<dynamic> col,
  Id id,
  EstadoCronometro object,
) {
  object.id = id;
}

extension EstadoCronometroByIndex on IsarCollection<EstadoCronometro> {
  Future<EstadoCronometro?> getByHobbyId(int hobbyId) {
    return getByIndex(r'hobbyId', [hobbyId]);
  }

  EstadoCronometro? getByHobbyIdSync(int hobbyId) {
    return getByIndexSync(r'hobbyId', [hobbyId]);
  }

  Future<bool> deleteByHobbyId(int hobbyId) {
    return deleteByIndex(r'hobbyId', [hobbyId]);
  }

  bool deleteByHobbyIdSync(int hobbyId) {
    return deleteByIndexSync(r'hobbyId', [hobbyId]);
  }

  Future<List<EstadoCronometro?>> getAllByHobbyId(List<int> hobbyIdValues) {
    final values = hobbyIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'hobbyId', values);
  }

  List<EstadoCronometro?> getAllByHobbyIdSync(List<int> hobbyIdValues) {
    final values = hobbyIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'hobbyId', values);
  }

  Future<int> deleteAllByHobbyId(List<int> hobbyIdValues) {
    final values = hobbyIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'hobbyId', values);
  }

  int deleteAllByHobbyIdSync(List<int> hobbyIdValues) {
    final values = hobbyIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'hobbyId', values);
  }

  Future<Id> putByHobbyId(EstadoCronometro object) {
    return putByIndex(r'hobbyId', object);
  }

  Id putByHobbyIdSync(EstadoCronometro object, {bool saveLinks = true}) {
    return putByIndexSync(r'hobbyId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByHobbyId(List<EstadoCronometro> objects) {
    return putAllByIndex(r'hobbyId', objects);
  }

  List<Id> putAllByHobbyIdSync(
    List<EstadoCronometro> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'hobbyId', objects, saveLinks: saveLinks);
  }
}

extension EstadoCronometroQueryWhereSort
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QWhere> {
  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhere> anyHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hobbyId'),
      );
    });
  }
}

extension EstadoCronometroQueryWhere
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QWhereClause> {
  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
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

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause> idBetween(
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

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
  hobbyIdEqualTo(int hobbyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'hobbyId', value: [hobbyId]),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
  hobbyIdNotEqualTo(int hobbyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId',
                lower: [],
                upper: [hobbyId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId',
                lower: [hobbyId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId',
                lower: [hobbyId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId',
                lower: [],
                upper: [hobbyId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
  hobbyIdGreaterThan(int hobbyId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId',
          lower: [hobbyId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
  hobbyIdLessThan(int hobbyId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId',
          lower: [],
          upper: [hobbyId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterWhereClause>
  hobbyIdBetween(
    int lowerHobbyId,
    int upperHobbyId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId',
          lower: [lowerHobbyId],
          includeLower: includeLower,
          upper: [upperHobbyId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EstadoCronometroQueryFilter
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QFilterCondition> {
  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  duracaoAcumuladaSegundosEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'duracaoAcumuladaSegundos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  duracaoAcumuladaSegundosGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duracaoAcumuladaSegundos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  duracaoAcumuladaSegundosLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duracaoAcumuladaSegundos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  duracaoAcumuladaSegundosBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duracaoAcumuladaSegundos',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoEqualTo(EstadoExecucao value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'estado',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoGreaterThan(
    EstadoExecucao value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'estado',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoLessThan(
    EstadoExecucao value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'estado',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoBetween(
    EstadoExecucao lower,
    EstadoExecucao upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'estado',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'estado',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'estado',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'estado',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'estado',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'estado', value: ''),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'estado', value: ''),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  hobbyIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hobbyId', value: value),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  hobbyIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hobbyId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  hobbyIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hobbyId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  hobbyIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hobbyId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
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

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
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

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  inicioSessaoEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'inicioSessao', value: value),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  inicioSessaoGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'inicioSessao',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  inicioSessaoLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'inicioSessao',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  inicioSessaoBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'inicioSessao',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  timestampInicioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'timestampInicio'),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  timestampInicioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'timestampInicio'),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  timestampInicioEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestampInicio', value: value),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  timestampInicioGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestampInicio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  timestampInicioLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestampInicio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterFilterCondition>
  timestampInicioBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestampInicio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EstadoCronometroQueryObject
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QFilterCondition> {}

extension EstadoCronometroQueryLinks
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QFilterCondition> {}

extension EstadoCronometroQuerySortBy
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QSortBy> {
  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByDuracaoAcumuladaSegundos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoAcumuladaSegundos', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByDuracaoAcumuladaSegundosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoAcumuladaSegundos', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByHobbyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByInicioSessao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicioSessao', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByInicioSessaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicioSessao', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByTimestampInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampInicio', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  sortByTimestampInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampInicio', Sort.desc);
    });
  }
}

extension EstadoCronometroQuerySortThenBy
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QSortThenBy> {
  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByDuracaoAcumuladaSegundos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoAcumuladaSegundos', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByDuracaoAcumuladaSegundosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoAcumuladaSegundos', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByHobbyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByInicioSessao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicioSessao', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByInicioSessaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicioSessao', Sort.desc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByTimestampInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampInicio', Sort.asc);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QAfterSortBy>
  thenByTimestampInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestampInicio', Sort.desc);
    });
  }
}

extension EstadoCronometroQueryWhereDistinct
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QDistinct> {
  QueryBuilder<EstadoCronometro, EstadoCronometro, QDistinct>
  distinctByDuracaoAcumuladaSegundos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duracaoAcumuladaSegundos');
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QDistinct> distinctByEstado({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QDistinct>
  distinctByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hobbyId');
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QDistinct>
  distinctByInicioSessao() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inicioSessao');
    });
  }

  QueryBuilder<EstadoCronometro, EstadoCronometro, QDistinct>
  distinctByTimestampInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestampInicio');
    });
  }
}

extension EstadoCronometroQueryProperty
    on QueryBuilder<EstadoCronometro, EstadoCronometro, QQueryProperty> {
  QueryBuilder<EstadoCronometro, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EstadoCronometro, int, QQueryOperations>
  duracaoAcumuladaSegundosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duracaoAcumuladaSegundos');
    });
  }

  QueryBuilder<EstadoCronometro, EstadoExecucao, QQueryOperations>
  estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<EstadoCronometro, int, QQueryOperations> hobbyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hobbyId');
    });
  }

  QueryBuilder<EstadoCronometro, DateTime, QQueryOperations>
  inicioSessaoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inicioSessao');
    });
  }

  QueryBuilder<EstadoCronometro, DateTime?, QQueryOperations>
  timestampInicioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestampInicio');
    });
  }
}
