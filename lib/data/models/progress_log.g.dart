// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProgressLogCollection on Isar {
  IsarCollection<ProgressLog> get progressLogs => this.collection();
}

const ProgressLogSchema = CollectionSchema(
  name: r'ProgressLog',
  id: -1222859646161031035,
  properties: {
    r'currentStreak': PropertySchema(
      id: 0,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'day': PropertySchema(
      id: 1,
      name: r'day',
      type: IsarType.dateTime,
    ),
    r'pointsEarned': PropertySchema(
      id: 2,
      name: r'pointsEarned',
      type: IsarType.long,
    ),
    r'tasksCompleted': PropertySchema(
      id: 3,
      name: r'tasksCompleted',
      type: IsarType.long,
    )
  },
  estimateSize: _progressLogEstimateSize,
  serialize: _progressLogSerialize,
  deserialize: _progressLogDeserialize,
  deserializeProp: _progressLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'day': IndexSchema(
      id: 3809350088207220763,
      name: r'day',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'day',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _progressLogGetId,
  getLinks: _progressLogGetLinks,
  attach: _progressLogAttach,
  version: '3.3.2',
);

int _progressLogEstimateSize(
  ProgressLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _progressLogSerialize(
  ProgressLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentStreak);
  writer.writeDateTime(offsets[1], object.day);
  writer.writeLong(offsets[2], object.pointsEarned);
  writer.writeLong(offsets[3], object.tasksCompleted);
}

ProgressLog _progressLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProgressLog();
  object.currentStreak = reader.readLong(offsets[0]);
  object.day = reader.readDateTime(offsets[1]);
  object.id = id;
  object.pointsEarned = reader.readLong(offsets[2]);
  object.tasksCompleted = reader.readLong(offsets[3]);
  return object;
}

P _progressLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _progressLogGetId(ProgressLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _progressLogGetLinks(ProgressLog object) {
  return [];
}

void _progressLogAttach(
    IsarCollection<dynamic> col, Id id, ProgressLog object) {
  object.id = id;
}

extension ProgressLogByIndex on IsarCollection<ProgressLog> {
  Future<ProgressLog?> getByDay(DateTime day) {
    return getByIndex(r'day', [day]);
  }

  ProgressLog? getByDaySync(DateTime day) {
    return getByIndexSync(r'day', [day]);
  }

  Future<bool> deleteByDay(DateTime day) {
    return deleteByIndex(r'day', [day]);
  }

  bool deleteByDaySync(DateTime day) {
    return deleteByIndexSync(r'day', [day]);
  }

  Future<List<ProgressLog?>> getAllByDay(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return getAllByIndex(r'day', values);
  }

  List<ProgressLog?> getAllByDaySync(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'day', values);
  }

  Future<int> deleteAllByDay(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'day', values);
  }

  int deleteAllByDaySync(List<DateTime> dayValues) {
    final values = dayValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'day', values);
  }

  Future<Id> putByDay(ProgressLog object) {
    return putByIndex(r'day', object);
  }

  Id putByDaySync(ProgressLog object, {bool saveLinks = true}) {
    return putByIndexSync(r'day', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDay(List<ProgressLog> objects) {
    return putAllByIndex(r'day', objects);
  }

  List<Id> putAllByDaySync(List<ProgressLog> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'day', objects, saveLinks: saveLinks);
  }
}

extension ProgressLogQueryWhereSort
    on QueryBuilder<ProgressLog, ProgressLog, QWhere> {
  QueryBuilder<ProgressLog, ProgressLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhere> anyDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'day'),
      );
    });
  }
}

extension ProgressLogQueryWhere
    on QueryBuilder<ProgressLog, ProgressLog, QWhereClause> {
  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> dayEqualTo(
      DateTime day) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'day',
        value: [day],
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> dayNotEqualTo(
      DateTime day) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [],
              upper: [day],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [day],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [day],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'day',
              lower: [],
              upper: [day],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> dayGreaterThan(
    DateTime day, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'day',
        lower: [day],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> dayLessThan(
    DateTime day, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'day',
        lower: [],
        upper: [day],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterWhereClause> dayBetween(
    DateTime lowerDay,
    DateTime upperDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'day',
        lower: [lowerDay],
        includeLower: includeLower,
        upper: [upperDay],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProgressLogQueryFilter
    on QueryBuilder<ProgressLog, ProgressLog, QFilterCondition> {
  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> dayEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'day',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> dayGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'day',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> dayLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'day',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> dayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'day',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      pointsEarnedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pointsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      pointsEarnedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pointsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      pointsEarnedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pointsEarned',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      pointsEarnedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pointsEarned',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      tasksCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      tasksCompletedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      tasksCompletedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tasksCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterFilterCondition>
      tasksCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tasksCompleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProgressLogQueryObject
    on QueryBuilder<ProgressLog, ProgressLog, QFilterCondition> {}

extension ProgressLogQueryLinks
    on QueryBuilder<ProgressLog, ProgressLog, QFilterCondition> {}

extension ProgressLogQuerySortBy
    on QueryBuilder<ProgressLog, ProgressLog, QSortBy> {
  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy>
      sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> sortByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> sortByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> sortByPointsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointsEarned', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy>
      sortByPointsEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointsEarned', Sort.desc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> sortByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy>
      sortByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }
}

extension ProgressLogQuerySortThenBy
    on QueryBuilder<ProgressLog, ProgressLog, QSortThenBy> {
  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy>
      thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> thenByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> thenByDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'day', Sort.desc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> thenByPointsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointsEarned', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy>
      thenByPointsEarnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointsEarned', Sort.desc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy> thenByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.asc);
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QAfterSortBy>
      thenByTasksCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasksCompleted', Sort.desc);
    });
  }
}

extension ProgressLogQueryWhereDistinct
    on QueryBuilder<ProgressLog, ProgressLog, QDistinct> {
  QueryBuilder<ProgressLog, ProgressLog, QDistinct> distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QDistinct> distinctByDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'day');
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QDistinct> distinctByPointsEarned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pointsEarned');
    });
  }

  QueryBuilder<ProgressLog, ProgressLog, QDistinct> distinctByTasksCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasksCompleted');
    });
  }
}

extension ProgressLogQueryProperty
    on QueryBuilder<ProgressLog, ProgressLog, QQueryProperty> {
  QueryBuilder<ProgressLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProgressLog, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<ProgressLog, DateTime, QQueryOperations> dayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'day');
    });
  }

  QueryBuilder<ProgressLog, int, QQueryOperations> pointsEarnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pointsEarned');
    });
  }

  QueryBuilder<ProgressLog, int, QQueryOperations> tasksCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasksCompleted');
    });
  }
}
