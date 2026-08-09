// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livro.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLivroCollection on Isar {
  IsarCollection<Livro> get livros => this.collection();
}

const LivroSchema = CollectionSchema(
  name: r'Livro',
  id: -9113541738558547385,
  properties: {
    r'autor': PropertySchema(id: 0, name: r'autor', type: IsarType.string),
    r'criadoEm': PropertySchema(
      id: 1,
      name: r'criadoEm',
      type: IsarType.dateTime,
    ),
    r'dataConclusao': PropertySchema(
      id: 2,
      name: r'dataConclusao',
      type: IsarType.dateTime,
    ),
    r'hobbyId': PropertySchema(id: 3, name: r'hobbyId', type: IsarType.long),
    r'titulo': PropertySchema(id: 4, name: r'titulo', type: IsarType.string),
  },

  estimateSize: _livroEstimateSize,
  serialize: _livroSerialize,
  deserialize: _livroDeserialize,
  deserializeProp: _livroDeserializeProp,
  idName: r'id',
  indexes: {
    r'hobbyId': IndexSchema(
      id: -5158992410789902336,
      name: r'hobbyId',
      unique: false,
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

  getId: _livroGetId,
  getLinks: _livroGetLinks,
  attach: _livroAttach,
  version: '3.3.2',
);

int _livroEstimateSize(
  Livro object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.autor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.titulo.length * 3;
  return bytesCount;
}

void _livroSerialize(
  Livro object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.autor);
  writer.writeDateTime(offsets[1], object.criadoEm);
  writer.writeDateTime(offsets[2], object.dataConclusao);
  writer.writeLong(offsets[3], object.hobbyId);
  writer.writeString(offsets[4], object.titulo);
}

Livro _livroDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Livro();
  object.autor = reader.readStringOrNull(offsets[0]);
  object.criadoEm = reader.readDateTime(offsets[1]);
  object.dataConclusao = reader.readDateTimeOrNull(offsets[2]);
  object.hobbyId = reader.readLong(offsets[3]);
  object.id = id;
  object.titulo = reader.readString(offsets[4]);
  return object;
}

P _livroDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _livroGetId(Livro object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _livroGetLinks(Livro object) {
  return [];
}

void _livroAttach(IsarCollection<dynamic> col, Id id, Livro object) {
  object.id = id;
}

extension LivroQueryWhereSort on QueryBuilder<Livro, Livro, QWhere> {
  QueryBuilder<Livro, Livro, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Livro, Livro, QAfterWhere> anyHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hobbyId'),
      );
    });
  }
}

extension LivroQueryWhere on QueryBuilder<Livro, Livro, QWhereClause> {
  QueryBuilder<Livro, Livro, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Livro, Livro, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Livro, Livro, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterWhereClause> idBetween(
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

  QueryBuilder<Livro, Livro, QAfterWhereClause> hobbyIdEqualTo(int hobbyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'hobbyId', value: [hobbyId]),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterWhereClause> hobbyIdNotEqualTo(int hobbyId) {
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

  QueryBuilder<Livro, Livro, QAfterWhereClause> hobbyIdGreaterThan(
    int hobbyId, {
    bool include = false,
  }) {
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

  QueryBuilder<Livro, Livro, QAfterWhereClause> hobbyIdLessThan(
    int hobbyId, {
    bool include = false,
  }) {
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

  QueryBuilder<Livro, Livro, QAfterWhereClause> hobbyIdBetween(
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

extension LivroQueryFilter on QueryBuilder<Livro, Livro, QFilterCondition> {
  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'autor'),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'autor'),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'autor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'autor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'autor',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'autor',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autor', value: ''),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> autorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'autor', value: ''),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> criadoEmEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'criadoEm', value: value),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> criadoEmGreaterThan(
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> criadoEmLessThan(
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> criadoEmBetween(
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> dataConclusaoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dataConclusao'),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> dataConclusaoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dataConclusao'),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> dataConclusaoEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataConclusao', value: value),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> dataConclusaoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataConclusao',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> dataConclusaoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataConclusao',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> dataConclusaoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataConclusao',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> hobbyIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hobbyId', value: value),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> hobbyIdGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> hobbyIdLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> hobbyIdBetween(
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'titulo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'titulo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'titulo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'titulo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'titulo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'titulo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'titulo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'titulo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'titulo', value: ''),
      );
    });
  }

  QueryBuilder<Livro, Livro, QAfterFilterCondition> tituloIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'titulo', value: ''),
      );
    });
  }
}

extension LivroQueryObject on QueryBuilder<Livro, Livro, QFilterCondition> {}

extension LivroQueryLinks on QueryBuilder<Livro, Livro, QFilterCondition> {}

extension LivroQuerySortBy on QueryBuilder<Livro, Livro, QSortBy> {
  QueryBuilder<Livro, Livro, QAfterSortBy> sortByAutor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autor', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByAutorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autor', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByCriadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByDataConclusao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataConclusao', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByDataConclusaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataConclusao', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByHobbyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByTitulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> sortByTituloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.desc);
    });
  }
}

extension LivroQuerySortThenBy on QueryBuilder<Livro, Livro, QSortThenBy> {
  QueryBuilder<Livro, Livro, QAfterSortBy> thenByAutor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autor', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByAutorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autor', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByCriadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByDataConclusao() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataConclusao', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByDataConclusaoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataConclusao', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByHobbyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hobbyId', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByTitulo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.asc);
    });
  }

  QueryBuilder<Livro, Livro, QAfterSortBy> thenByTituloDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titulo', Sort.desc);
    });
  }
}

extension LivroQueryWhereDistinct on QueryBuilder<Livro, Livro, QDistinct> {
  QueryBuilder<Livro, Livro, QDistinct> distinctByAutor({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Livro, Livro, QDistinct> distinctByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criadoEm');
    });
  }

  QueryBuilder<Livro, Livro, QDistinct> distinctByDataConclusao() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataConclusao');
    });
  }

  QueryBuilder<Livro, Livro, QDistinct> distinctByHobbyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hobbyId');
    });
  }

  QueryBuilder<Livro, Livro, QDistinct> distinctByTitulo({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titulo', caseSensitive: caseSensitive);
    });
  }
}

extension LivroQueryProperty on QueryBuilder<Livro, Livro, QQueryProperty> {
  QueryBuilder<Livro, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Livro, String?, QQueryOperations> autorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autor');
    });
  }

  QueryBuilder<Livro, DateTime, QQueryOperations> criadoEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criadoEm');
    });
  }

  QueryBuilder<Livro, DateTime?, QQueryOperations> dataConclusaoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataConclusao');
    });
  }

  QueryBuilder<Livro, int, QQueryOperations> hobbyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hobbyId');
    });
  }

  QueryBuilder<Livro, String, QQueryOperations> tituloProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titulo');
    });
  }
}
