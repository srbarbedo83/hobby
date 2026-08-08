// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessao_registada.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessaoRegistadaCollection on Isar {
  IsarCollection<SessaoRegistada> get sessaoRegistadas => this.collection();
}

const SessaoRegistadaSchema = CollectionSchema(
  name: r'SessaoRegistada',
  id: 2631008216015143697,
  properties: {
    r'duracaoSegundos': PropertySchema(
      id: 0,
      name: r'duracaoSegundos',
      type: IsarType.long,
    ),
    r'hobbyId': PropertySchema(id: 1, name: r'hobbyId', type: IsarType.long),
    r'inicio': PropertySchema(id: 2, name: r'inicio', type: IsarType.dateTime),
    r'nota': PropertySchema(id: 3, name: r'nota', type: IsarType.string),
    r'origem': PropertySchema(
      id: 4,
      name: r'origem',
      type: IsarType.string,
      enumMap: _SessaoRegistadaorigemEnumValueMap,
    ),
  },

  estimateSize: _sessaoRegistadaEstimateSize,
  serialize: _sessaoRegistadaSerialize,
  deserialize: _sessaoRegistadaDeserialize,
  deserializeProp: _sessaoRegistadaDeserializeProp,
  idName: r'id',
  indexes: {
    r'hobbyId_inicio': IndexSchema(
      id: 2646182899195864815,
      name: r'hobbyId_inicio',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hobbyId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'inicio',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'inicio': IndexSchema(
      id: -3250443433104705250,
      name: r'inicio',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'inicio',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _sessaoRegistadaGetId,
  getLinks: _sessaoRegistadaGetLinks,
  attach: _sessaoRegistadaAttach,
  version: '3.3.2',
);

int _sessaoRegistadaEstimateSize(
  SessaoRegistada object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.nota;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.origem.name.length * 3;
  return bytesCount;
}

void _sessaoRegistadaSerialize(
  SessaoRegistada object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.duracaoSegundos);
  writer.writeLong(offsets[1], object.hobbyId);
  writer.writeDateTime(offsets[2], object.inicio);
  writer.writeString(offsets[3], object.nota);
  writer.writeString(offsets[4], object.origem.name);
}

SessaoRegistada _sessaoRegistadaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessaoRegistada();
  object.duracaoSegundos = reader.readLong(offsets[0]);
  object.hobbyId = reader.readLong(offsets[1]);
  object.id = id;
  object.inicio = reader.readDateTime(offsets[2]);
  object.nota = reader.readStringOrNull(offsets[3]);
  object.origem =
      _SessaoRegistadaorigemValueEnumMap[reader.readStringOrNull(offsets[4])] ??
      OrigemSessao.cronometro;
  return object;
}

P _sessaoRegistadaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (_SessaoRegistadaorigemValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              OrigemSessao.cronometro)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SessaoRegistadaorigemEnumValueMap = {
  r'cronometro': r'cronometro',
  r'manual': r'manual',
};
const _SessaoRegistadaorigemValueEnumMap = {
  r'cronometro': OrigemSessao.cronometro,
  r'manual': OrigemSessao.manual,
};

Id _sessaoRegistadaGetId(SessaoRegistada object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessaoRegistadaGetLinks(SessaoRegistada object) {
  return [];
}

void _sessaoRegistadaAttach(
  IsarCollection<dynamic> col,
  Id id,
  SessaoRegistada object,
) {
  object.id = id;
}

extension SessaoRegistadaQueryWhereSort
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QWhere> {
  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhere>
  anyHobbyIdInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hobbyId_inicio'),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhere> anyInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'inicio'),
      );
    });
  }
}

extension SessaoRegistadaQueryWhere
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QWhereClause> {
  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause> idBetween(
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdEqualToAnyInicio(int hobbyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'hobbyId_inicio',
          value: [hobbyId],
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdNotEqualToAnyInicio(int hobbyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [],
                upper: [hobbyId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [hobbyId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [hobbyId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [],
                upper: [hobbyId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdGreaterThanAnyInicio(int hobbyId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId_inicio',
          lower: [hobbyId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdLessThanAnyInicio(int hobbyId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId_inicio',
          lower: [],
          upper: [hobbyId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdBetweenAnyInicio(
    int lowerHobbyId,
    int upperHobbyId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId_inicio',
          lower: [lowerHobbyId],
          includeLower: includeLower,
          upper: [upperHobbyId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdInicioEqualTo(int hobbyId, DateTime inicio) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'hobbyId_inicio',
          value: [hobbyId, inicio],
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdEqualToInicioNotEqualTo(int hobbyId, DateTime inicio) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [hobbyId],
                upper: [hobbyId, inicio],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [hobbyId, inicio],
                includeLower: false,
                upper: [hobbyId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [hobbyId, inicio],
                includeLower: false,
                upper: [hobbyId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hobbyId_inicio',
                lower: [hobbyId],
                upper: [hobbyId, inicio],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdEqualToInicioGreaterThan(
    int hobbyId,
    DateTime inicio, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId_inicio',
          lower: [hobbyId, inicio],
          includeLower: include,
          upper: [hobbyId],
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdEqualToInicioLessThan(
    int hobbyId,
    DateTime inicio, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId_inicio',
          lower: [hobbyId],
          upper: [hobbyId, inicio],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  hobbyIdEqualToInicioBetween(
    int hobbyId,
    DateTime lowerInicio,
    DateTime upperInicio, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'hobbyId_inicio',
          lower: [hobbyId, lowerInicio],
          includeLower: includeLower,
          upper: [hobbyId, upperInicio],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  inicioEqualTo(DateTime inicio) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'inicio', value: [inicio]),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  inicioNotEqualTo(DateTime inicio) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'inicio',
                lower: [],
                upper: [inicio],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'inicio',
                lower: [inicio],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'inicio',
                lower: [inicio],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'inicio',
                lower: [],
                upper: [inicio],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  inicioGreaterThan(DateTime inicio, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'inicio',
          lower: [inicio],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  inicioLessThan(DateTime inicio, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'inicio',
          lower: [],
          upper: [inicio],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterWhereClause>
  inicioBetween(
    DateTime lowerInicio,
    DateTime upperInicio, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'inicio',
          lower: [lowerInicio],
          includeLower: includeLower,
          upper: [upperInicio],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SessaoRegistadaQueryFilter
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QFilterCondition> {
  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  duracaoSegundosEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duracaoSegundos', value: value),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  duracaoSegundosGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duracaoSegundos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  duracaoSegundosLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duracaoSegundos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  duracaoSegundosBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duracaoSegundos',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  hobbyIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hobbyId', value: value),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
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

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  inicioEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'inicio', value: value),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  inicioGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'inicio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  inicioLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'inicio',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  inicioBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'inicio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nota'),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nota'),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nota',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nota',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nota',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nota',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nota',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nota',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nota',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nota',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nota', value: ''),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  notaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nota', value: ''),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemEqualTo(OrigemSessao value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'origem',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemGreaterThan(
    OrigemSessao value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'origem',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemLessThan(
    OrigemSessao value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'origem',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemBetween(
    OrigemSessao lower,
    OrigemSessao upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'origem',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'origem',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'origem',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'origem',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'origem',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'origem', value: ''),
      );
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterFilterCondition>
  origemIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'origem', value: ''),
      );
    });
  }
}

extension SessaoRegistadaQueryObject
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QFilterCondition> {}

extension SessaoRegistadaQueryLinks
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QFilterCondition> {}

extension SessaoRegistadaQuerySortBy
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QSortBy> {
  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  sortByDuracaoSegundos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoSegundos', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  sortByDuracaoSegundosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoSegundos', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> sortByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  sortByHobbyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> sortByInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicio', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  sortByInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicio', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> sortByNota() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nota', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  sortByNotaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nota', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> sortByOrigem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origem', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  sortByOrigemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origem', Sort.desc);
    });
  }
}

extension SessaoRegistadaQuerySortThenBy
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QSortThenBy> {
  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  thenByDuracaoSegundos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoSegundos', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  thenByDuracaoSegundosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duracaoSegundos', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> thenByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  thenByHobbyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> thenByInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicio', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  thenByInicioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inicio', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> thenByNota() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nota', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  thenByNotaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nota', Sort.desc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy> thenByOrigem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origem', Sort.asc);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QAfterSortBy>
  thenByOrigemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origem', Sort.desc);
    });
  }
}

extension SessaoRegistadaQueryWhereDistinct
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QDistinct> {
  QueryBuilder<SessaoRegistada, SessaoRegistada, QDistinct>
  distinctByDuracaoSegundos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duracaoSegundos');
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QDistinct>
  distinctByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hobbyId');
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QDistinct> distinctByInicio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inicio');
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QDistinct> distinctByNota({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nota', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessaoRegistada, SessaoRegistada, QDistinct> distinctByOrigem({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origem', caseSensitive: caseSensitive);
    });
  }
}

extension SessaoRegistadaQueryProperty
    on QueryBuilder<SessaoRegistada, SessaoRegistada, QQueryProperty> {
  QueryBuilder<SessaoRegistada, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessaoRegistada, int, QQueryOperations>
  duracaoSegundosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duracaoSegundos');
    });
  }

  QueryBuilder<SessaoRegistada, int, QQueryOperations> hobbyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hobbyId');
    });
  }

  QueryBuilder<SessaoRegistada, DateTime, QQueryOperations> inicioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inicio');
    });
  }

  QueryBuilder<SessaoRegistada, String?, QQueryOperations> notaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nota');
    });
  }

  QueryBuilder<SessaoRegistada, OrigemSessao, QQueryOperations>
  origemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origem');
    });
  }
}
