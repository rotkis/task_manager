// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskItemCollection on Isar {
  IsarCollection<TaskItem> get taskItems => this.collection();
}

const TaskItemSchema = CollectionSchema(
  name: r'TaskItem',
  id: 2171180427076855156,
  properties: {
    r'alarmId': PropertySchema(
      id: 0,
      name: r'alarmId',
      type: IsarType.long,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'durationMinutes': PropertySchema(
      id: 4,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'durationSeconds': PropertySchema(
      id: 5,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'indexedScheduledDate': PropertySchema(
      id: 6,
      name: r'indexedScheduledDate',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 7,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isImportant': PropertySchema(
      id: 8,
      name: r'isImportant',
      type: IsarType.bool,
    ),
    r'isNotificationEnabled': PropertySchema(
      id: 9,
      name: r'isNotificationEnabled',
      type: IsarType.bool,
    ),
    r'notificationId': PropertySchema(
      id: 10,
      name: r'notificationId',
      type: IsarType.long,
    ),
    r'parentRecurringId': PropertySchema(
      id: 11,
      name: r'parentRecurringId',
      type: IsarType.long,
    ),
    r'postponeCount': PropertySchema(
      id: 12,
      name: r'postponeCount',
      type: IsarType.long,
    ),
    r'recurrenceRule': PropertySchema(
      id: 13,
      name: r'recurrenceRule',
      type: IsarType.string,
    ),
    r'rewardPoints': PropertySchema(
      id: 14,
      name: r'rewardPoints',
      type: IsarType.long,
    ),
    r'scheduledDate': PropertySchema(
      id: 15,
      name: r'scheduledDate',
      type: IsarType.dateTime,
    ),
    r'scheduledTime': PropertySchema(
      id: 16,
      name: r'scheduledTime',
      type: IsarType.dateTime,
    ),
    r'syncGroupCode': PropertySchema(
      id: 17,
      name: r'syncGroupCode',
      type: IsarType.string,
    ),
    r'targetReps': PropertySchema(
      id: 18,
      name: r'targetReps',
      type: IsarType.long,
    ),
    r'targetSets': PropertySchema(
      id: 19,
      name: r'targetSets',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 20,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 21,
      name: r'type',
      type: IsarType.byte,
      enumMap: _TaskItemtypeEnumValueMap,
    )
  },
  estimateSize: _taskItemEstimateSize,
  serialize: _taskItemSerialize,
  deserialize: _taskItemDeserialize,
  deserializeProp: _taskItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'indexedScheduledDate': IndexSchema(
      id: -3454288124845483015,
      name: r'indexedScheduledDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'indexedScheduledDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _taskItemGetId,
  getLinks: _taskItemGetLinks,
  attach: _taskItemAttach,
  version: '3.3.2',
);

int _taskItemEstimateSize(
  TaskItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.recurrenceRule;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.syncGroupCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _taskItemSerialize(
  TaskItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.alarmId);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.description);
  writer.writeLong(offsets[4], object.durationMinutes);
  writer.writeLong(offsets[5], object.durationSeconds);
  writer.writeDateTime(offsets[6], object.indexedScheduledDate);
  writer.writeBool(offsets[7], object.isCompleted);
  writer.writeBool(offsets[8], object.isImportant);
  writer.writeBool(offsets[9], object.isNotificationEnabled);
  writer.writeLong(offsets[10], object.notificationId);
  writer.writeLong(offsets[11], object.parentRecurringId);
  writer.writeLong(offsets[12], object.postponeCount);
  writer.writeString(offsets[13], object.recurrenceRule);
  writer.writeLong(offsets[14], object.rewardPoints);
  writer.writeDateTime(offsets[15], object.scheduledDate);
  writer.writeDateTime(offsets[16], object.scheduledTime);
  writer.writeString(offsets[17], object.syncGroupCode);
  writer.writeLong(offsets[18], object.targetReps);
  writer.writeLong(offsets[19], object.targetSets);
  writer.writeString(offsets[20], object.title);
  writer.writeByte(offsets[21], object.type.index);
}

TaskItem _taskItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskItem();
  object.alarmId = reader.readLongOrNull(offsets[0]);
  object.completedAt = reader.readDateTimeOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.durationMinutes = reader.readLongOrNull(offsets[4]);
  object.durationSeconds = reader.readLongOrNull(offsets[5]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[7]);
  object.isImportant = reader.readBool(offsets[8]);
  object.isNotificationEnabled = reader.readBool(offsets[9]);
  object.notificationId = reader.readLongOrNull(offsets[10]);
  object.parentRecurringId = reader.readLongOrNull(offsets[11]);
  object.postponeCount = reader.readLong(offsets[12]);
  object.recurrenceRule = reader.readStringOrNull(offsets[13]);
  object.rewardPoints = reader.readLong(offsets[14]);
  object.scheduledDate = reader.readDateTimeOrNull(offsets[15]);
  object.scheduledTime = reader.readDateTimeOrNull(offsets[16]);
  object.syncGroupCode = reader.readStringOrNull(offsets[17]);
  object.targetReps = reader.readLongOrNull(offsets[18]);
  object.targetSets = reader.readLongOrNull(offsets[19]);
  object.title = reader.readString(offsets[20]);
  object.type = _TaskItemtypeValueEnumMap[reader.readByteOrNull(offsets[21])] ??
      TaskType.generic;
  return object;
}

P _taskItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (_TaskItemtypeValueEnumMap[reader.readByteOrNull(offset)] ??
          TaskType.generic) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TaskItemtypeEnumValueMap = {
  'generic': 0,
  'pomodoroStudy': 1,
  'timedExercise': 2,
  'repsExercise': 3,
};
const _TaskItemtypeValueEnumMap = {
  0: TaskType.generic,
  1: TaskType.pomodoroStudy,
  2: TaskType.timedExercise,
  3: TaskType.repsExercise,
};

Id _taskItemGetId(TaskItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskItemGetLinks(TaskItem object) {
  return [];
}

void _taskItemAttach(IsarCollection<dynamic> col, Id id, TaskItem object) {
  object.id = id;
}

extension TaskItemQueryWhereSort on QueryBuilder<TaskItem, TaskItem, QWhere> {
  QueryBuilder<TaskItem, TaskItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhere> anyIndexedScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'indexedScheduledDate'),
      );
    });
  }
}

extension TaskItemQueryWhere on QueryBuilder<TaskItem, TaskItem, QWhereClause> {
  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause> idBetween(
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

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause>
      indexedScheduledDateEqualTo(DateTime indexedScheduledDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'indexedScheduledDate',
        value: [indexedScheduledDate],
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause>
      indexedScheduledDateNotEqualTo(DateTime indexedScheduledDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexedScheduledDate',
              lower: [],
              upper: [indexedScheduledDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexedScheduledDate',
              lower: [indexedScheduledDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexedScheduledDate',
              lower: [indexedScheduledDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'indexedScheduledDate',
              lower: [],
              upper: [indexedScheduledDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause>
      indexedScheduledDateGreaterThan(
    DateTime indexedScheduledDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'indexedScheduledDate',
        lower: [indexedScheduledDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause>
      indexedScheduledDateLessThan(
    DateTime indexedScheduledDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'indexedScheduledDate',
        lower: [],
        upper: [indexedScheduledDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterWhereClause>
      indexedScheduledDateBetween(
    DateTime lowerIndexedScheduledDate,
    DateTime upperIndexedScheduledDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'indexedScheduledDate',
        lower: [lowerIndexedScheduledDate],
        includeLower: includeLower,
        upper: [upperIndexedScheduledDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TaskItemQueryFilter
    on QueryBuilder<TaskItem, TaskItem, QFilterCondition> {
  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> alarmIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'alarmId',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> alarmIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'alarmId',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> alarmIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alarmId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> alarmIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alarmId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> alarmIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alarmId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> alarmIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alarmId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> completedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationMinutes',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationMinutes',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationMinutesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationMinutesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      durationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      indexedScheduledDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'indexedScheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      indexedScheduledDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'indexedScheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      indexedScheduledDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'indexedScheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      indexedScheduledDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'indexedScheduledDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> isCompletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> isImportantEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isImportant',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      isNotificationEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNotificationEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      notificationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notificationId',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      notificationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notificationId',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> notificationIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      notificationIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      notificationIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> notificationIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      parentRecurringIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentRecurringId',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      parentRecurringIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentRecurringId',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      parentRecurringIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentRecurringId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      parentRecurringIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentRecurringId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      parentRecurringIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentRecurringId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      parentRecurringIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentRecurringId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> postponeCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'postponeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      postponeCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'postponeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> postponeCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'postponeCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> postponeCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'postponeCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recurrenceRule',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recurrenceRule',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> recurrenceRuleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> recurrenceRuleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrenceRule',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recurrenceRule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> recurrenceRuleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recurrenceRule',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceRule',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      recurrenceRuleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recurrenceRule',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> rewardPointsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rewardPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      rewardPointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rewardPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> rewardPointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rewardPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> rewardPointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rewardPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      scheduledDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledDate',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      scheduledDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledDate',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> scheduledDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      scheduledDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> scheduledDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> scheduledDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      scheduledTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledTime',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      scheduledTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledTime',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> scheduledTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      scheduledTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> scheduledTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> scheduledTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      syncGroupCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncGroupCode',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      syncGroupCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncGroupCode',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> syncGroupCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGroupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      syncGroupCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncGroupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> syncGroupCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncGroupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> syncGroupCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncGroupCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      syncGroupCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncGroupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> syncGroupCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncGroupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> syncGroupCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncGroupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> syncGroupCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncGroupCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      syncGroupCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncGroupCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      syncGroupCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncGroupCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetRepsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetReps',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      targetRepsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetReps',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetRepsEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetReps',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetRepsGreaterThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetRepsLessThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetRepsBetween(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetSetsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetSets',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition>
      targetSetsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetSets',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetSetsEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetSets',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetSetsGreaterThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetSetsLessThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> targetSetsBetween(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleContains(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> typeEqualTo(
      TaskType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<TaskItem, TaskItem, QAfterFilterCondition> typeBetween(
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

extension TaskItemQueryObject
    on QueryBuilder<TaskItem, TaskItem, QFilterCondition> {}

extension TaskItemQueryLinks
    on QueryBuilder<TaskItem, TaskItem, QFilterCondition> {}

extension TaskItemQuerySortBy on QueryBuilder<TaskItem, TaskItem, QSortBy> {
  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByIndexedScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedScheduledDate', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy>
      sortByIndexedScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedScheduledDate', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByIsImportantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByIsNotificationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy>
      sortByIsNotificationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByParentRecurringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurringId', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByParentRecurringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurringId', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByPostponeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postponeCount', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByPostponeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postponeCount', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByRecurrenceRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByRecurrenceRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByRewardPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByRewardPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortBySyncGroupCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGroupCode', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortBySyncGroupCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGroupCode', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByTargetReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByTargetRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByTargetSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByTargetSetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TaskItemQuerySortThenBy
    on QueryBuilder<TaskItem, TaskItem, QSortThenBy> {
  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByAlarmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alarmId', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByIndexedScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedScheduledDate', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy>
      thenByIndexedScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedScheduledDate', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByIsImportantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImportant', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByIsNotificationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy>
      thenByIsNotificationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationEnabled', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByParentRecurringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurringId', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByParentRecurringIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentRecurringId', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByPostponeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postponeCount', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByPostponeCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'postponeCount', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByRecurrenceRule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByRecurrenceRuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceRule', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByRewardPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByRewardPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardPoints', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenBySyncGroupCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGroupCode', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenBySyncGroupCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncGroupCode', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByTargetReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByTargetRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetReps', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByTargetSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByTargetSetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetSets', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TaskItemQueryWhereDistinct
    on QueryBuilder<TaskItem, TaskItem, QDistinct> {
  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByAlarmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alarmId');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByIndexedScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indexedScheduledDate');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByIsImportant() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isImportant');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct>
      distinctByIsNotificationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNotificationEnabled');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationId');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByParentRecurringId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentRecurringId');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByPostponeCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'postponeCount');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByRecurrenceRule(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceRule',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByRewardPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rewardPoints');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDate');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledTime');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctBySyncGroupCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncGroupCode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByTargetReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetReps');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByTargetSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetSets');
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItem, TaskItem, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension TaskItemQueryProperty
    on QueryBuilder<TaskItem, TaskItem, QQueryProperty> {
  QueryBuilder<TaskItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskItem, int?, QQueryOperations> alarmIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alarmId');
    });
  }

  QueryBuilder<TaskItem, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<TaskItem, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TaskItem, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<TaskItem, int?, QQueryOperations> durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<TaskItem, int?, QQueryOperations> durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<TaskItem, DateTime, QQueryOperations>
      indexedScheduledDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indexedScheduledDate');
    });
  }

  QueryBuilder<TaskItem, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<TaskItem, bool, QQueryOperations> isImportantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isImportant');
    });
  }

  QueryBuilder<TaskItem, bool, QQueryOperations>
      isNotificationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNotificationEnabled');
    });
  }

  QueryBuilder<TaskItem, int?, QQueryOperations> notificationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationId');
    });
  }

  QueryBuilder<TaskItem, int?, QQueryOperations> parentRecurringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentRecurringId');
    });
  }

  QueryBuilder<TaskItem, int, QQueryOperations> postponeCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'postponeCount');
    });
  }

  QueryBuilder<TaskItem, String?, QQueryOperations> recurrenceRuleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceRule');
    });
  }

  QueryBuilder<TaskItem, int, QQueryOperations> rewardPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rewardPoints');
    });
  }

  QueryBuilder<TaskItem, DateTime?, QQueryOperations> scheduledDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDate');
    });
  }

  QueryBuilder<TaskItem, DateTime?, QQueryOperations> scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledTime');
    });
  }

  QueryBuilder<TaskItem, String?, QQueryOperations> syncGroupCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncGroupCode');
    });
  }

  QueryBuilder<TaskItem, int?, QQueryOperations> targetRepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetReps');
    });
  }

  QueryBuilder<TaskItem, int?, QQueryOperations> targetSetsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetSets');
    });
  }

  QueryBuilder<TaskItem, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<TaskItem, TaskType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
