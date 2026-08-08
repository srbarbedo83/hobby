// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hobby.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHobbyCollection on Isar {
  IsarCollection<Hobby> get hobbys => this.collection();
}

const HobbySchema = CollectionSchema(
  name: r'Hobby',
  id: 7515871990174053315,
  properties: {
    r'ativo': PropertySchema(id: 0, name: r'ativo', type: IsarType.bool),
    r'cor': PropertySchema(id: 1, name: r'cor', type: IsarType.long),
    r'criadoEm': PropertySchema(
      id: 2,
      name: r'criadoEm',
      type: IsarType.dateTime,
    ),
    r'icone': PropertySchema(id: 3, name: r'icone', type: IsarType.long),
    r'meta': PropertySchema(
      id: 4,
      name: r'meta',
      type: IsarType.object,

      target: r'Meta',
    ),
    r'nome': PropertySchema(id: 5, name: r'nome', type: IsarType.string),
  },

  estimateSize: _hobbyEstimateSize,
  serialize: _hobbySerialize,
  deserialize: _hobbyDeserialize,
  deserializeProp: _hobbyDeserializeProp,
  idName: r'id',
  indexes: {
    r'nome': IndexSchema(
      id: -3554607249464315131,
      name: r'nome',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nome',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'ativo': IndexSchema(
      id: -4826929944764508603,
      name: r'ativo',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ativo',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'Meta': MetaSchema},

  getId: _hobbyGetId,
  getLinks: _hobbyGetLinks,
  attach: _hobbyAttach,
  version: '3.3.2',
);

int _hobbyEstimateSize(
  Hobby object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.meta;
    if (value != null) {
      bytesCount +=
          3 + MetaSchema.estimateSize(value, allOffsets[Meta]!, allOffsets);
    }
  }
  bytesCount += 3 + object.nome.length * 3;
  return bytesCount;
}

void _hobbySerialize(
  Hobby object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.ativo);
  writer.writeLong(offsets[1], object.cor);
  writer.writeDateTime(offsets[2], object.criadoEm);
  writer.writeLong(offsets[3], object.icone);
  writer.writeObject<Meta>(
    offsets[4],
    allOffsets,
    MetaSchema.serialize,
    object.meta,
  );
  writer.writeString(offsets[5], object.nome);
}

Hobby _hobbyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Hobby();
  object.ativo = reader.readBool(offsets[0]);
  object.cor = reader.readLong(offsets[1]);
  object.criadoEm = reader.readDateTime(offsets[2]);
  object.icone = reader.readLong(offsets[3]);
  object.id = id;
  object.meta = reader.readObjectOrNull<Meta>(
    offsets[4],
    MetaSchema.deserialize,
    allOffsets,
  );
  object.nome = reader.readString(offsets[5]);
  return object;
}

P _hobbyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readObjectOrNull<Meta>(
            offset,
            MetaSchema.deserialize,
            allOffsets,
          ))
          as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hobbyGetId(Hobby object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hobbyGetLinks(Hobby object) {
  return [];
}

void _hobbyAttach(IsarCollection<dynamic> col, Id id, Hobby object) {
  object.id = id;
}

extension HobbyQueryWhereSort on QueryBuilder<Hobby, Hobby, QWhere> {
  QueryBuilder<Hobby, Hobby, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterWhere> anyAtivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ativo'),
      );
    });
  }
}

extension HobbyQueryWhere on QueryBuilder<Hobby, Hobby, QWhereClause> {
  QueryBuilder<Hobby, Hobby, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> idBetween(
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

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> nomeEqualTo(String nome) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'nome', value: [nome]),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> nomeNotEqualTo(String nome) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nome',
                lower: [],
                upper: [nome],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nome',
                lower: [nome],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nome',
                lower: [nome],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'nome',
                lower: [],
                upper: [nome],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> ativoEqualTo(bool ativo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ativo', value: [ativo]),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterWhereClause> ativoNotEqualTo(bool ativo) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ativo',
                lower: [],
                upper: [ativo],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ativo',
                lower: [ativo],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ativo',
                lower: [ativo],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ativo',
                lower: [],
                upper: [ativo],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension HobbyQueryFilter on QueryBuilder<Hobby, Hobby, QFilterCondition> {
  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> ativoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ativo', value: value),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> corEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cor', value: value),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> corGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> corLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> corBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> criadoEmEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'criadoEm', value: value),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> criadoEmGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'criadoEm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> criadoEmLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'criadoEm',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> criadoEmBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'criadoEm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> iconeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'icone', value: value),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> iconeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'icone',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> iconeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'icone',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> iconeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'icone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> metaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'meta'),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> metaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'meta'),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nome', value: ''),
      );
    });
  }
}

extension HobbyQueryObject on QueryBuilder<Hobby, Hobby, QFilterCondition> {
  QueryBuilder<Hobby, Hobby, QAfterFilterCondition> meta(FilterQuery<Meta> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'meta');
    });
  }
}

extension HobbyQueryLinks on QueryBuilder<Hobby, Hobby, QFilterCondition> {}

extension HobbyQuerySortBy on QueryBuilder<Hobby, Hobby, QSortBy> {
  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByAtivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativo', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByAtivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativo', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByCor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cor', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByCorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cor', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByCriadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByIcone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icone', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByIconeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icone', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }
}

extension HobbyQuerySortThenBy on QueryBuilder<Hobby, Hobby, QSortThenBy> {
  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByAtivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativo', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByAtivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativo', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByCor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cor', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByCorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cor', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByCriadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByIcone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icone', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByIconeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icone', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<Hobby, Hobby, QAfterSortBy> thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }
}

extension HobbyQueryWhereDistinct on QueryBuilder<Hobby, Hobby, QDistinct> {
  QueryBuilder<Hobby, Hobby, QDistinct> distinctByAtivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ativo');
    });
  }

  QueryBuilder<Hobby, Hobby, QDistinct> distinctByCor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cor');
    });
  }

  QueryBuilder<Hobby, Hobby, QDistinct> distinctByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criadoEm');
    });
  }

  QueryBuilder<Hobby, Hobby, QDistinct> distinctByIcone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icone');
    });
  }

  QueryBuilder<Hobby, Hobby, QDistinct> distinctByNome({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }
}

extension HobbyQueryProperty on QueryBuilder<Hobby, Hobby, QQueryProperty> {
  QueryBuilder<Hobby, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Hobby, bool, QQueryOperations> ativoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ativo');
    });
  }

  QueryBuilder<Hobby, int, QQueryOperations> corProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cor');
    });
  }

  QueryBuilder<Hobby, DateTime, QQueryOperations> criadoEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criadoEm');
    });
  }

  QueryBuilder<Hobby, int, QQueryOperations> iconeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icone');
    });
  }

  QueryBuilder<Hobby, Meta?, QQueryOperations> metaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meta');
    });
  }

  QueryBuilder<Hobby, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MetaSchema = Schema(
  name: r'Meta',
  id: 3011675413520335034,
  properties: {
    r'numeroSessoes': PropertySchema(
      id: 0,
      name: r'numeroSessoes',
      type: IsarType.long,
    ),
    r'periodicidade': PropertySchema(
      id: 1,
      name: r'periodicidade',
      type: IsarType.string,
      enumMap: _MetaperiodicidadeEnumValueMap,
    ),
    r'tipo': PropertySchema(
      id: 2,
      name: r'tipo',
      type: IsarType.string,
      enumMap: _MetatipoEnumValueMap,
    ),
    r'valorMinutos': PropertySchema(
      id: 3,
      name: r'valorMinutos',
      type: IsarType.long,
    ),
  },

  estimateSize: _metaEstimateSize,
  serialize: _metaSerialize,
  deserialize: _metaDeserialize,
  deserializeProp: _metaDeserializeProp,
);

int _metaEstimateSize(
  Meta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.periodicidade.name.length * 3;
  bytesCount += 3 + object.tipo.name.length * 3;
  return bytesCount;
}

void _metaSerialize(
  Meta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.numeroSessoes);
  writer.writeString(offsets[1], object.periodicidade.name);
  writer.writeString(offsets[2], object.tipo.name);
  writer.writeLong(offsets[3], object.valorMinutos);
}

Meta _metaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Meta();
  object.numeroSessoes = reader.readLongOrNull(offsets[0]);
  object.periodicidade =
      _MetaperiodicidadeValueEnumMap[reader.readStringOrNull(offsets[1])] ??
      Periodicidade.diario;
  object.tipo =
      _MetatipoValueEnumMap[reader.readStringOrNull(offsets[2])] ??
      TipoMeta.diaria;
  object.valorMinutos = reader.readLongOrNull(offsets[3]);
  return object;
}

P _metaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (_MetaperiodicidadeValueEnumMap[reader.readStringOrNull(offset)] ??
              Periodicidade.diario)
          as P;
    case 2:
      return (_MetatipoValueEnumMap[reader.readStringOrNull(offset)] ??
              TipoMeta.diaria)
          as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MetaperiodicidadeEnumValueMap = {
  r'diario': r'diario',
  r'semanal': r'semanal',
};
const _MetaperiodicidadeValueEnumMap = {
  r'diario': Periodicidade.diario,
  r'semanal': Periodicidade.semanal,
};
const _MetatipoEnumValueMap = {
  r'diaria': r'diaria',
  r'semanal': r'semanal',
  r'porNumeroSessoes': r'porNumeroSessoes',
};
const _MetatipoValueEnumMap = {
  r'diaria': TipoMeta.diaria,
  r'semanal': TipoMeta.semanal,
  r'porNumeroSessoes': TipoMeta.porNumeroSessoes,
};

extension MetaQueryFilter on QueryBuilder<Meta, Meta, QFilterCondition> {
  QueryBuilder<Meta, Meta, QAfterFilterCondition> numeroSessoesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'numeroSessoes'),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> numeroSessoesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'numeroSessoes'),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> numeroSessoesEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroSessoes', value: value),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> numeroSessoesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numeroSessoes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> numeroSessoesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numeroSessoes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> numeroSessoesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numeroSessoes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeEqualTo(
    Periodicidade value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'periodicidade',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeGreaterThan(
    Periodicidade value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodicidade',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeLessThan(
    Periodicidade value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodicidade',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeBetween(
    Periodicidade lower,
    Periodicidade upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodicidade',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'periodicidade',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'periodicidade',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'periodicidade',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'periodicidade',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodicidade', value: ''),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> periodicidadeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'periodicidade', value: ''),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoEqualTo(
    TipoMeta value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoGreaterThan(
    TipoMeta value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoLessThan(
    TipoMeta value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoBetween(
    TipoMeta lower,
    TipoMeta upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tipo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipo', value: ''),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> tipoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tipo', value: ''),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> valorMinutosIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'valorMinutos'),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> valorMinutosIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'valorMinutos'),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> valorMinutosEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'valorMinutos', value: value),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> valorMinutosGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'valorMinutos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> valorMinutosLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'valorMinutos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Meta, Meta, QAfterFilterCondition> valorMinutosBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'valorMinutos',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MetaQueryObject on QueryBuilder<Meta, Meta, QFilterCondition> {}
