// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_task_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubTaskItemCollection on Isar {
  IsarCollection<SubTaskItem> get subTaskItems => this.collection();
}

const SubTaskItemSchema = CollectionSchema(
  name: r'SubTaskItem',
  id: -2563545012733200043,
  properties: {
    r'durationSeconds': PropertySchema(
      id: 0,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'isCompleted': PropertySchema(
      id: 1,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'order': PropertySchema(
      id: 2,
      name: r'order',
      type: IsarType.long,
    ),
    r'parentTaskId': PropertySchema(
      id: 3,
      name: r'parentTaskId',
      type: IsarType.long,
    ),
    r'targetReps': PropertySchema(
      id: 4,
      name: r'targetReps',
      type: IsarType.long,
    ),
    r'targetSets': PropertySchema(
      id: 5,
      name: r'targetSets',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 6,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 7,
      name: r'type',
      type: IsarType.byte,
      enumMap: _SubTaskItemtypeEnumValueMap,
    )
  },
  estimateSize: _subTaskItemEstimateSize,
  serialize: _subTaskItemSerialize,
  deserialize: _subTaskItemDeserialize,
  deserializeProp: _subTaskItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'parentTaskId': IndexSchema(
      id: 1235852618244535635,
      name: r'parentTaskId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'parentTaskId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _subTaskItemGetId,
  getLinks: _subTaskItemGetLinks,
  attach: _subTaskItemAttach,
  version: '3.3.2',
);

int _subTaskItemEstimateSize(
  SubTaskItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _subTaskItemSerialize(
  SubTaskItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.durationSeconds);
  writer.writeBool(offsets[1], object.isCompleted);
  writer.writeLong(offsets[2], object.order);
  writer.writeLong(offsets[3], object.parentTaskId);
  writer.writeLong(offsets[4], object.targetReps);
  writer.writeLong(offsets[5], object.targetSets);
  writer.writeString(offsets[6], object.title);
  writer.writeByte(offsets[7], object.type.index);
}

SubTaskItem _subTaskItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubTaskItem();
  object.durationSeconds = reader.readLongOrNull(offsets[0]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[1]);
  object.order = reader.readLong(offsets[2]);
  object.parentTaskId = reader.readLong(offsets[3]);
  object.targetReps = reader.readLongOrNull(offsets[4]);
  object.targetSets = reader.readLongOrNull(offsets[5]);
  object.title = reader.readString(offsets[6]);
  object.type =
      _SubTaskItemtypeValueEnumMap[reader.readByteOrNull(offsets[7])] ??
          TaskType.generic;
  return object;
}

P _subTaskItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_SubTaskItemtypeValueEnumMap[reader.readByteOrNull(offset)] ??
          TaskType.generic) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SubTaskItemtypeEnumValueMap = {
  'generic': 0,
  'pomodoroStudy': 1,
  'timedExercise': 2,
  'repsExercise': 3,
};
const _SubTaskItemtypeValueEnumMap = {
  0: TaskType.generic,
  1: TaskType.pomodoroStudy,
  2: TaskType.timedExercise,
  3: TaskType.repsExercise,
};

Id _subTaskItemGetId(SubTaskItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subTaskItemGetLinks(SubTaskItem object) {
  return [];
}

void _subTaskItemAttach(
    IsarCollection<dynamic> col, Id id, SubTaskItem object) {
  object.id = id;
}

extension SubTaskItemQueryWhereSort
    on QueryBuilder<SubTaskItem, SubTaskItem, QWhere> {
  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhere> anyParentTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'parentTaskId'),
      );
    });
  }
}

extension SubTaskItemQueryWhere
    on QueryBuilder<SubTaskItem, SubTaskItem, QWhereClause> {
  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause> parentTaskIdEqualTo(
      int parentTaskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'parentTaskId',
        value: [parentTaskId],
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause>
      parentTaskIdNotEqualTo(int parentTaskId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentTaskId',
              lower: [],
              upper: [parentTaskId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentTaskId',
              lower: [parentTaskId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentTaskId',
              lower: [parentTaskId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentTaskId',
              lower: [],
              upper: [parentTaskId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause>
      parentTaskIdGreaterThan(
    int parentTaskId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentTaskId',
        lower: [parentTaskId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause>
      parentTaskIdLessThan(
    int parentTaskId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentTaskId',
        lower: [],
        upper: [parentTaskId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterWhereClause> parentTaskIdBetween(
    int lowerParentTaskId,
    int upperParentTaskId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentTaskId',
        lower: [lowerParentTaskId],
        includeLower: includeLower,
        upper: [upperParentTaskId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubTaskItemQueryFilter
    on QueryBuilder<SubTaskItem, SubTaskItem, QFilterCondition> {
  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      durationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      durationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      durationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      durationSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      durationSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      durationSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> orderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      parentTaskIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentTaskId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      parentTaskIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentTaskId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      parentTaskIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentTaskId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      parentTaskIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentTaskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetRepsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetReps',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetRepsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetReps',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetRepsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetReps',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetRepsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetReps',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetRepsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetReps',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetRepsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetReps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetSetsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetSets',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetSetsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetSets',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetSetsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetSets',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetSetsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetSets',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetSetsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetSets',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      targetSetsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetSets',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> typeEqualTo(
      TaskType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> typeGreaterThan(
    TaskType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> typeLessThan(
    TaskType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterFilterCondition> typeBetween(
    TaskType lower,
    TaskType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SubTaskItemQueryObject
    on QueryBuilder<SubTaskItem, SubTaskItem, QFilterCondition> {}

extension SubTaskItemQueryLinks
    on QueryBuilder<SubTaskItem, SubTaskItem, QFilterCondition> {}

extension SubTaskItemQuerySortBy
    on QueryBuilder<SubTaskItem, SubTaskItem, QSortBy> {
  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByParentTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentTaskId', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy>
      sortByParentTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentTaskId', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByTargetReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByTargetRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByTargetSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByTargetSetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SubTaskItemQuerySortThenBy
    on QueryBuilder<SubTaskItem, SubTaskItem, QSortThenBy> {
  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByParentTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentTaskId', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy>
      thenByParentTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentTaskId', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByTargetReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByTargetRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByTargetSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByTargetSetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SubTaskItemQueryWhereDistinct
    on QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> {
  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> distinctByParentTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentTaskId');
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> distinctByTargetReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetReps');
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> distinctByTargetSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetSets');
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubTaskItem, SubTaskItem, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension SubTaskItemQueryProperty
    on QueryBuilder<SubTaskItem, SubTaskItem, QQueryProperty> {
  QueryBuilder<SubTaskItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubTaskItem, int?, QQueryOperations> durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<SubTaskItem, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<SubTaskItem, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<SubTaskItem, int, QQueryOperations> parentTaskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentTaskId');
    });
  }

  QueryBuilder<SubTaskItem, int?, QQueryOperations> targetRepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetReps');
    });
  }

  QueryBuilder<SubTaskItem, int?, QQueryOperations> targetSetsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetSets');
    });
  }

  QueryBuilder<SubTaskItem, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SubTaskItem, TaskType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
