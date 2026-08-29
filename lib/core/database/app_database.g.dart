// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceTypeMeta = const VerificationMeta(
    'recurrenceType',
  );
  @override
  late final GeneratedColumn<String> recurrenceType = GeneratedColumn<String>(
    'recurrence_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oneOffAtUtcMeta = const VerificationMeta(
    'oneOffAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> oneOffAtUtc = GeneratedColumn<DateTime>(
    'one_off_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekdaysMaskMeta = const VerificationMeta(
    'weekdaysMask',
  );
  @override
  late final GeneratedColumn<int> weekdaysMask = GeneratedColumn<int>(
    'weekdays_mask',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localHourMeta = const VerificationMeta(
    'localHour',
  );
  @override
  late final GeneratedColumn<int> localHour = GeneratedColumn<int>(
    'local_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localMinuteMeta = const VerificationMeta(
    'localMinute',
  );
  @override
  late final GeneratedColumn<int> localMinute = GeneratedColumn<int>(
    'local_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preparationLeadMinutesMeta =
      const VerificationMeta('preparationLeadMinutes');
  @override
  late final GeneratedColumn<int> preparationLeadMinutes = GeneratedColumn<int>(
    'preparation_lead_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    durationMinutes,
    priority,
    recurrenceType,
    oneOffAtUtc,
    weekdaysMask,
    localHour,
    localMinute,
    preparationLeadMinutes,
    isActive,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('recurrence_type')) {
      context.handle(
        _recurrenceTypeMeta,
        recurrenceType.isAcceptableOrUnknown(
          data['recurrence_type']!,
          _recurrenceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurrenceTypeMeta);
    }
    if (data.containsKey('one_off_at_utc')) {
      context.handle(
        _oneOffAtUtcMeta,
        oneOffAtUtc.isAcceptableOrUnknown(
          data['one_off_at_utc']!,
          _oneOffAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('weekdays_mask')) {
      context.handle(
        _weekdaysMaskMeta,
        weekdaysMask.isAcceptableOrUnknown(
          data['weekdays_mask']!,
          _weekdaysMaskMeta,
        ),
      );
    }
    if (data.containsKey('local_hour')) {
      context.handle(
        _localHourMeta,
        localHour.isAcceptableOrUnknown(data['local_hour']!, _localHourMeta),
      );
    }
    if (data.containsKey('local_minute')) {
      context.handle(
        _localMinuteMeta,
        localMinute.isAcceptableOrUnknown(
          data['local_minute']!,
          _localMinuteMeta,
        ),
      );
    }
    if (data.containsKey('preparation_lead_minutes')) {
      context.handle(
        _preparationLeadMinutesMeta,
        preparationLeadMinutes.isAcceptableOrUnknown(
          data['preparation_lead_minutes']!,
          _preparationLeadMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      recurrenceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_type'],
      )!,
      oneOffAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}one_off_at_utc'],
      ),
      weekdaysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_mask'],
      ),
      localHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_hour'],
      ),
      localMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_minute'],
      ),
      preparationLeadMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preparation_lead_minutes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final String id;
  final String title;
  final String notes;
  final int durationMinutes;
  final String priority;
  final String recurrenceType;
  final DateTime? oneOffAtUtc;
  final int? weekdaysMask;
  final int? localHour;
  final int? localMinute;
  final int? preparationLeadMinutes;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  const ActivityRow({
    required this.id,
    required this.title,
    required this.notes,
    required this.durationMinutes,
    required this.priority,
    required this.recurrenceType,
    this.oneOffAtUtc,
    this.weekdaysMask,
    this.localHour,
    this.localMinute,
    this.preparationLeadMinutes,
    required this.isActive,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['priority'] = Variable<String>(priority);
    map['recurrence_type'] = Variable<String>(recurrenceType);
    if (!nullToAbsent || oneOffAtUtc != null) {
      map['one_off_at_utc'] = Variable<DateTime>(oneOffAtUtc);
    }
    if (!nullToAbsent || weekdaysMask != null) {
      map['weekdays_mask'] = Variable<int>(weekdaysMask);
    }
    if (!nullToAbsent || localHour != null) {
      map['local_hour'] = Variable<int>(localHour);
    }
    if (!nullToAbsent || localMinute != null) {
      map['local_minute'] = Variable<int>(localMinute);
    }
    if (!nullToAbsent || preparationLeadMinutes != null) {
      map['preparation_lead_minutes'] = Variable<int>(preparationLeadMinutes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      title: Value(title),
      notes: Value(notes),
      durationMinutes: Value(durationMinutes),
      priority: Value(priority),
      recurrenceType: Value(recurrenceType),
      oneOffAtUtc: oneOffAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(oneOffAtUtc),
      weekdaysMask: weekdaysMask == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdaysMask),
      localHour: localHour == null && nullToAbsent
          ? const Value.absent()
          : Value(localHour),
      localMinute: localMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(localMinute),
      preparationLeadMinutes: preparationLeadMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(preparationLeadMinutes),
      isActive: Value(isActive),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      priority: serializer.fromJson<String>(json['priority']),
      recurrenceType: serializer.fromJson<String>(json['recurrenceType']),
      oneOffAtUtc: serializer.fromJson<DateTime?>(json['oneOffAtUtc']),
      weekdaysMask: serializer.fromJson<int?>(json['weekdaysMask']),
      localHour: serializer.fromJson<int?>(json['localHour']),
      localMinute: serializer.fromJson<int?>(json['localMinute']),
      preparationLeadMinutes: serializer.fromJson<int?>(
        json['preparationLeadMinutes'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'priority': serializer.toJson<String>(priority),
      'recurrenceType': serializer.toJson<String>(recurrenceType),
      'oneOffAtUtc': serializer.toJson<DateTime?>(oneOffAtUtc),
      'weekdaysMask': serializer.toJson<int?>(weekdaysMask),
      'localHour': serializer.toJson<int?>(localHour),
      'localMinute': serializer.toJson<int?>(localMinute),
      'preparationLeadMinutes': serializer.toJson<int?>(preparationLeadMinutes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  ActivityRow copyWith({
    String? id,
    String? title,
    String? notes,
    int? durationMinutes,
    String? priority,
    String? recurrenceType,
    Value<DateTime?> oneOffAtUtc = const Value.absent(),
    Value<int?> weekdaysMask = const Value.absent(),
    Value<int?> localHour = const Value.absent(),
    Value<int?> localMinute = const Value.absent(),
    Value<int?> preparationLeadMinutes = const Value.absent(),
    bool? isActive,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
  }) => ActivityRow(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    priority: priority ?? this.priority,
    recurrenceType: recurrenceType ?? this.recurrenceType,
    oneOffAtUtc: oneOffAtUtc.present ? oneOffAtUtc.value : this.oneOffAtUtc,
    weekdaysMask: weekdaysMask.present ? weekdaysMask.value : this.weekdaysMask,
    localHour: localHour.present ? localHour.value : this.localHour,
    localMinute: localMinute.present ? localMinute.value : this.localMinute,
    preparationLeadMinutes: preparationLeadMinutes.present
        ? preparationLeadMinutes.value
        : this.preparationLeadMinutes,
    isActive: isActive ?? this.isActive,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ActivityRow copyWithCompanion(ActivitiesCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      priority: data.priority.present ? data.priority.value : this.priority,
      recurrenceType: data.recurrenceType.present
          ? data.recurrenceType.value
          : this.recurrenceType,
      oneOffAtUtc: data.oneOffAtUtc.present
          ? data.oneOffAtUtc.value
          : this.oneOffAtUtc,
      weekdaysMask: data.weekdaysMask.present
          ? data.weekdaysMask.value
          : this.weekdaysMask,
      localHour: data.localHour.present ? data.localHour.value : this.localHour,
      localMinute: data.localMinute.present
          ? data.localMinute.value
          : this.localMinute,
      preparationLeadMinutes: data.preparationLeadMinutes.present
          ? data.preparationLeadMinutes.value
          : this.preparationLeadMinutes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('priority: $priority, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('oneOffAtUtc: $oneOffAtUtc, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('localHour: $localHour, ')
          ..write('localMinute: $localMinute, ')
          ..write('preparationLeadMinutes: $preparationLeadMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    durationMinutes,
    priority,
    recurrenceType,
    oneOffAtUtc,
    weekdaysMask,
    localHour,
    localMinute,
    preparationLeadMinutes,
    isActive,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.durationMinutes == this.durationMinutes &&
          other.priority == this.priority &&
          other.recurrenceType == this.recurrenceType &&
          other.oneOffAtUtc == this.oneOffAtUtc &&
          other.weekdaysMask == this.weekdaysMask &&
          other.localHour == this.localHour &&
          other.localMinute == this.localMinute &&
          other.preparationLeadMinutes == this.preparationLeadMinutes &&
          other.isActive == this.isActive &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ActivitiesCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> notes;
  final Value<int> durationMinutes;
  final Value<String> priority;
  final Value<String> recurrenceType;
  final Value<DateTime?> oneOffAtUtc;
  final Value<int?> weekdaysMask;
  final Value<int?> localHour;
  final Value<int?> localMinute;
  final Value<int?> preparationLeadMinutes;
  final Value<bool> isActive;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    this.recurrenceType = const Value.absent(),
    this.oneOffAtUtc = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.localHour = const Value.absent(),
    this.localMinute = const Value.absent(),
    this.preparationLeadMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    required int durationMinutes,
    required String priority,
    required String recurrenceType,
    this.oneOffAtUtc = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.localHour = const Value.absent(),
    this.localMinute = const Value.absent(),
    this.preparationLeadMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       durationMinutes = Value(durationMinutes),
       priority = Value(priority),
       recurrenceType = Value(recurrenceType),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ActivityRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? durationMinutes,
    Expression<String>? priority,
    Expression<String>? recurrenceType,
    Expression<DateTime>? oneOffAtUtc,
    Expression<int>? weekdaysMask,
    Expression<int>? localHour,
    Expression<int>? localMinute,
    Expression<int>? preparationLeadMinutes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (priority != null) 'priority': priority,
      if (recurrenceType != null) 'recurrence_type': recurrenceType,
      if (oneOffAtUtc != null) 'one_off_at_utc': oneOffAtUtc,
      if (weekdaysMask != null) 'weekdays_mask': weekdaysMask,
      if (localHour != null) 'local_hour': localHour,
      if (localMinute != null) 'local_minute': localMinute,
      if (preparationLeadMinutes != null)
        'preparation_lead_minutes': preparationLeadMinutes,
      if (isActive != null) 'is_active': isActive,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? notes,
    Value<int>? durationMinutes,
    Value<String>? priority,
    Value<String>? recurrenceType,
    Value<DateTime?>? oneOffAtUtc,
    Value<int?>? weekdaysMask,
    Value<int?>? localHour,
    Value<int?>? localMinute,
    Value<int?>? preparationLeadMinutes,
    Value<bool>? isActive,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priority: priority ?? this.priority,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      oneOffAtUtc: oneOffAtUtc ?? this.oneOffAtUtc,
      weekdaysMask: weekdaysMask ?? this.weekdaysMask,
      localHour: localHour ?? this.localHour,
      localMinute: localMinute ?? this.localMinute,
      preparationLeadMinutes:
          preparationLeadMinutes ?? this.preparationLeadMinutes,
      isActive: isActive ?? this.isActive,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (recurrenceType.present) {
      map['recurrence_type'] = Variable<String>(recurrenceType.value);
    }
    if (oneOffAtUtc.present) {
      map['one_off_at_utc'] = Variable<DateTime>(oneOffAtUtc.value);
    }
    if (weekdaysMask.present) {
      map['weekdays_mask'] = Variable<int>(weekdaysMask.value);
    }
    if (localHour.present) {
      map['local_hour'] = Variable<int>(localHour.value);
    }
    if (localMinute.present) {
      map['local_minute'] = Variable<int>(localMinute.value);
    }
    if (preparationLeadMinutes.present) {
      map['preparation_lead_minutes'] = Variable<int>(
        preparationLeadMinutes.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('priority: $priority, ')
          ..write('recurrenceType: $recurrenceType, ')
          ..write('oneOffAtUtc: $oneOffAtUtc, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('localHour: $localHour, ')
          ..write('localMinute: $localMinute, ')
          ..write('preparationLeadMinutes: $preparationLeadMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OccurrencesTable extends Occurrences
    with TableInfo<$OccurrencesTable, OccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nativeAlarmIdMeta = const VerificationMeta(
    'nativeAlarmId',
  );
  @override
  late final GeneratedColumn<int> nativeAlarmId = GeneratedColumn<int>(
    'native_alarm_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id)',
    ),
  );
  static const VerificationMeta _originalStartUtcMeta = const VerificationMeta(
    'originalStartUtc',
  );
  @override
  late final GeneratedColumn<DateTime> originalStartUtc =
      GeneratedColumn<DateTime>(
        'original_start_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _scheduledStartUtcMeta = const VerificationMeta(
    'scheduledStartUtc',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledStartUtc =
      GeneratedColumn<DateTime>(
        'scheduled_start_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nativeAlarmId,
    activityId,
    originalStartUtc,
    scheduledStartUtc,
    durationMinutes,
    priority,
    status,
    attempt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<OccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('native_alarm_id')) {
      context.handle(
        _nativeAlarmIdMeta,
        nativeAlarmId.isAcceptableOrUnknown(
          data['native_alarm_id']!,
          _nativeAlarmIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nativeAlarmIdMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('original_start_utc')) {
      context.handle(
        _originalStartUtcMeta,
        originalStartUtc.isAcceptableOrUnknown(
          data['original_start_utc']!,
          _originalStartUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalStartUtcMeta);
    }
    if (data.containsKey('scheduled_start_utc')) {
      context.handle(
        _scheduledStartUtcMeta,
        scheduledStartUtc.isAcceptableOrUnknown(
          data['scheduled_start_utc']!,
          _scheduledStartUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledStartUtcMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OccurrenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nativeAlarmId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}native_alarm_id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      originalStartUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}original_start_utc'],
      )!,
      scheduledStartUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_start_utc'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
    );
  }

  @override
  $OccurrencesTable createAlias(String alias) {
    return $OccurrencesTable(attachedDatabase, alias);
  }
}

class OccurrenceRow extends DataClass implements Insertable<OccurrenceRow> {
  final String id;
  final int nativeAlarmId;
  final String activityId;
  final DateTime originalStartUtc;
  final DateTime scheduledStartUtc;
  final int durationMinutes;
  final String priority;
  final String status;
  final int attempt;
  const OccurrenceRow({
    required this.id,
    required this.nativeAlarmId,
    required this.activityId,
    required this.originalStartUtc,
    required this.scheduledStartUtc,
    required this.durationMinutes,
    required this.priority,
    required this.status,
    required this.attempt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['native_alarm_id'] = Variable<int>(nativeAlarmId);
    map['activity_id'] = Variable<String>(activityId);
    map['original_start_utc'] = Variable<DateTime>(originalStartUtc);
    map['scheduled_start_utc'] = Variable<DateTime>(scheduledStartUtc);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    map['attempt'] = Variable<int>(attempt);
    return map;
  }

  OccurrencesCompanion toCompanion(bool nullToAbsent) {
    return OccurrencesCompanion(
      id: Value(id),
      nativeAlarmId: Value(nativeAlarmId),
      activityId: Value(activityId),
      originalStartUtc: Value(originalStartUtc),
      scheduledStartUtc: Value(scheduledStartUtc),
      durationMinutes: Value(durationMinutes),
      priority: Value(priority),
      status: Value(status),
      attempt: Value(attempt),
    );
  }

  factory OccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OccurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      nativeAlarmId: serializer.fromJson<int>(json['nativeAlarmId']),
      activityId: serializer.fromJson<String>(json['activityId']),
      originalStartUtc: serializer.fromJson<DateTime>(json['originalStartUtc']),
      scheduledStartUtc: serializer.fromJson<DateTime>(
        json['scheduledStartUtc'],
      ),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      attempt: serializer.fromJson<int>(json['attempt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nativeAlarmId': serializer.toJson<int>(nativeAlarmId),
      'activityId': serializer.toJson<String>(activityId),
      'originalStartUtc': serializer.toJson<DateTime>(originalStartUtc),
      'scheduledStartUtc': serializer.toJson<DateTime>(scheduledStartUtc),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'attempt': serializer.toJson<int>(attempt),
    };
  }

  OccurrenceRow copyWith({
    String? id,
    int? nativeAlarmId,
    String? activityId,
    DateTime? originalStartUtc,
    DateTime? scheduledStartUtc,
    int? durationMinutes,
    String? priority,
    String? status,
    int? attempt,
  }) => OccurrenceRow(
    id: id ?? this.id,
    nativeAlarmId: nativeAlarmId ?? this.nativeAlarmId,
    activityId: activityId ?? this.activityId,
    originalStartUtc: originalStartUtc ?? this.originalStartUtc,
    scheduledStartUtc: scheduledStartUtc ?? this.scheduledStartUtc,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    attempt: attempt ?? this.attempt,
  );
  OccurrenceRow copyWithCompanion(OccurrencesCompanion data) {
    return OccurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      nativeAlarmId: data.nativeAlarmId.present
          ? data.nativeAlarmId.value
          : this.nativeAlarmId,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      originalStartUtc: data.originalStartUtc.present
          ? data.originalStartUtc.value
          : this.originalStartUtc,
      scheduledStartUtc: data.scheduledStartUtc.present
          ? data.scheduledStartUtc.value
          : this.scheduledStartUtc,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OccurrenceRow(')
          ..write('id: $id, ')
          ..write('nativeAlarmId: $nativeAlarmId, ')
          ..write('activityId: $activityId, ')
          ..write('originalStartUtc: $originalStartUtc, ')
          ..write('scheduledStartUtc: $scheduledStartUtc, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nativeAlarmId,
    activityId,
    originalStartUtc,
    scheduledStartUtc,
    durationMinutes,
    priority,
    status,
    attempt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OccurrenceRow &&
          other.id == this.id &&
          other.nativeAlarmId == this.nativeAlarmId &&
          other.activityId == this.activityId &&
          other.originalStartUtc == this.originalStartUtc &&
          other.scheduledStartUtc == this.scheduledStartUtc &&
          other.durationMinutes == this.durationMinutes &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.attempt == this.attempt);
}

class OccurrencesCompanion extends UpdateCompanion<OccurrenceRow> {
  final Value<String> id;
  final Value<int> nativeAlarmId;
  final Value<String> activityId;
  final Value<DateTime> originalStartUtc;
  final Value<DateTime> scheduledStartUtc;
  final Value<int> durationMinutes;
  final Value<String> priority;
  final Value<String> status;
  final Value<int> attempt;
  final Value<int> rowid;
  const OccurrencesCompanion({
    this.id = const Value.absent(),
    this.nativeAlarmId = const Value.absent(),
    this.activityId = const Value.absent(),
    this.originalStartUtc = const Value.absent(),
    this.scheduledStartUtc = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OccurrencesCompanion.insert({
    required String id,
    required int nativeAlarmId,
    required String activityId,
    required DateTime originalStartUtc,
    required DateTime scheduledStartUtc,
    required int durationMinutes,
    required String priority,
    required String status,
    this.attempt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nativeAlarmId = Value(nativeAlarmId),
       activityId = Value(activityId),
       originalStartUtc = Value(originalStartUtc),
       scheduledStartUtc = Value(scheduledStartUtc),
       durationMinutes = Value(durationMinutes),
       priority = Value(priority),
       status = Value(status);
  static Insertable<OccurrenceRow> custom({
    Expression<String>? id,
    Expression<int>? nativeAlarmId,
    Expression<String>? activityId,
    Expression<DateTime>? originalStartUtc,
    Expression<DateTime>? scheduledStartUtc,
    Expression<int>? durationMinutes,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<int>? attempt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nativeAlarmId != null) 'native_alarm_id': nativeAlarmId,
      if (activityId != null) 'activity_id': activityId,
      if (originalStartUtc != null) 'original_start_utc': originalStartUtc,
      if (scheduledStartUtc != null) 'scheduled_start_utc': scheduledStartUtc,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (attempt != null) 'attempt': attempt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OccurrencesCompanion copyWith({
    Value<String>? id,
    Value<int>? nativeAlarmId,
    Value<String>? activityId,
    Value<DateTime>? originalStartUtc,
    Value<DateTime>? scheduledStartUtc,
    Value<int>? durationMinutes,
    Value<String>? priority,
    Value<String>? status,
    Value<int>? attempt,
    Value<int>? rowid,
  }) {
    return OccurrencesCompanion(
      id: id ?? this.id,
      nativeAlarmId: nativeAlarmId ?? this.nativeAlarmId,
      activityId: activityId ?? this.activityId,
      originalStartUtc: originalStartUtc ?? this.originalStartUtc,
      scheduledStartUtc: scheduledStartUtc ?? this.scheduledStartUtc,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nativeAlarmId.present) {
      map['native_alarm_id'] = Variable<int>(nativeAlarmId.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (originalStartUtc.present) {
      map['original_start_utc'] = Variable<DateTime>(originalStartUtc.value);
    }
    if (scheduledStartUtc.present) {
      map['scheduled_start_utc'] = Variable<DateTime>(scheduledStartUtc.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('nativeAlarmId: $nativeAlarmId, ')
          ..write('activityId: $activityId, ')
          ..write('originalStartUtc: $originalStartUtc, ')
          ..write('scheduledStartUtc: $scheduledStartUtc, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTable extends ActivityEvents
    with TableInfo<$ActivityEventsTable, ActivityEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES occurrences (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _previousStartUtcMeta = const VerificationMeta(
    'previousStartUtc',
  );
  @override
  late final GeneratedColumn<DateTime> previousStartUtc =
      GeneratedColumn<DateTime>(
        'previous_start_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextStartUtcMeta = const VerificationMeta(
    'nextStartUtc',
  );
  @override
  late final GeneratedColumn<DateTime> nextStartUtc = GeneratedColumn<DateTime>(
    'next_start_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    occurrenceId,
    type,
    occurredAtUtc,
    previousStartUtc,
    nextStartUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('previous_start_utc')) {
      context.handle(
        _previousStartUtcMeta,
        previousStartUtc.isAcceptableOrUnknown(
          data['previous_start_utc']!,
          _previousStartUtcMeta,
        ),
      );
    }
    if (data.containsKey('next_start_utc')) {
      context.handle(
        _nextStartUtcMeta,
        nextStartUtc.isAcceptableOrUnknown(
          data['next_start_utc']!,
          _nextStartUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      previousStartUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}previous_start_utc'],
      ),
      nextStartUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_start_utc'],
      ),
    );
  }

  @override
  $ActivityEventsTable createAlias(String alias) {
    return $ActivityEventsTable(attachedDatabase, alias);
  }
}

class ActivityEventRow extends DataClass
    implements Insertable<ActivityEventRow> {
  final String id;
  final String occurrenceId;
  final String type;
  final DateTime occurredAtUtc;
  final DateTime? previousStartUtc;
  final DateTime? nextStartUtc;
  const ActivityEventRow({
    required this.id,
    required this.occurrenceId,
    required this.type,
    required this.occurredAtUtc,
    this.previousStartUtc,
    this.nextStartUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['occurrence_id'] = Variable<String>(occurrenceId);
    map['type'] = Variable<String>(type);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    if (!nullToAbsent || previousStartUtc != null) {
      map['previous_start_utc'] = Variable<DateTime>(previousStartUtc);
    }
    if (!nullToAbsent || nextStartUtc != null) {
      map['next_start_utc'] = Variable<DateTime>(nextStartUtc);
    }
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      occurrenceId: Value(occurrenceId),
      type: Value(type),
      occurredAtUtc: Value(occurredAtUtc),
      previousStartUtc: previousStartUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(previousStartUtc),
      nextStartUtc: nextStartUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(nextStartUtc),
    );
  }

  factory ActivityEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEventRow(
      id: serializer.fromJson<String>(json['id']),
      occurrenceId: serializer.fromJson<String>(json['occurrenceId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      previousStartUtc: serializer.fromJson<DateTime?>(
        json['previousStartUtc'],
      ),
      nextStartUtc: serializer.fromJson<DateTime?>(json['nextStartUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'occurrenceId': serializer.toJson<String>(occurrenceId),
      'type': serializer.toJson<String>(type),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'previousStartUtc': serializer.toJson<DateTime?>(previousStartUtc),
      'nextStartUtc': serializer.toJson<DateTime?>(nextStartUtc),
    };
  }

  ActivityEventRow copyWith({
    String? id,
    String? occurrenceId,
    String? type,
    DateTime? occurredAtUtc,
    Value<DateTime?> previousStartUtc = const Value.absent(),
    Value<DateTime?> nextStartUtc = const Value.absent(),
  }) => ActivityEventRow(
    id: id ?? this.id,
    occurrenceId: occurrenceId ?? this.occurrenceId,
    type: type ?? this.type,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    previousStartUtc: previousStartUtc.present
        ? previousStartUtc.value
        : this.previousStartUtc,
    nextStartUtc: nextStartUtc.present ? nextStartUtc.value : this.nextStartUtc,
  );
  ActivityEventRow copyWithCompanion(ActivityEventsCompanion data) {
    return ActivityEventRow(
      id: data.id.present ? data.id.value : this.id,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
      type: data.type.present ? data.type.value : this.type,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      previousStartUtc: data.previousStartUtc.present
          ? data.previousStartUtc.value
          : this.previousStartUtc,
      nextStartUtc: data.nextStartUtc.present
          ? data.nextStartUtc.value
          : this.nextStartUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventRow(')
          ..write('id: $id, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('type: $type, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('previousStartUtc: $previousStartUtc, ')
          ..write('nextStartUtc: $nextStartUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    occurrenceId,
    type,
    occurredAtUtc,
    previousStartUtc,
    nextStartUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEventRow &&
          other.id == this.id &&
          other.occurrenceId == this.occurrenceId &&
          other.type == this.type &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.previousStartUtc == this.previousStartUtc &&
          other.nextStartUtc == this.nextStartUtc);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEventRow> {
  final Value<String> id;
  final Value<String> occurrenceId;
  final Value<String> type;
  final Value<DateTime> occurredAtUtc;
  final Value<DateTime?> previousStartUtc;
  final Value<DateTime?> nextStartUtc;
  final Value<int> rowid;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.previousStartUtc = const Value.absent(),
    this.nextStartUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    required String id,
    required String occurrenceId,
    required String type,
    required DateTime occurredAtUtc,
    this.previousStartUtc = const Value.absent(),
    this.nextStartUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       occurrenceId = Value(occurrenceId),
       type = Value(type),
       occurredAtUtc = Value(occurredAtUtc);
  static Insertable<ActivityEventRow> custom({
    Expression<String>? id,
    Expression<String>? occurrenceId,
    Expression<String>? type,
    Expression<DateTime>? occurredAtUtc,
    Expression<DateTime>? previousStartUtc,
    Expression<DateTime>? nextStartUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (type != null) 'type': type,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (previousStartUtc != null) 'previous_start_utc': previousStartUtc,
      if (nextStartUtc != null) 'next_start_utc': nextStartUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? occurrenceId,
    Value<String>? type,
    Value<DateTime>? occurredAtUtc,
    Value<DateTime?>? previousStartUtc,
    Value<DateTime?>? nextStartUtc,
    Value<int>? rowid,
  }) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      type: type ?? this.type,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      previousStartUtc: previousStartUtc ?? this.previousStartUtc,
      nextStartUtc: nextStartUtc ?? this.nextStartUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (previousStartUtc.present) {
      map['previous_start_utc'] = Variable<DateTime>(previousStartUtc.value);
    }
    if (nextStartUtc.present) {
      map['next_start_utc'] = Variable<DateTime>(nextStartUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('type: $type, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('previousStartUtc: $previousStartUtc, ')
          ..write('nextStartUtc: $nextStartUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferenceRowsTable extends UserPreferenceRows
    with TableInfo<$UserPreferenceRowsTable, UserPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dayStartMinutesMeta = const VerificationMeta(
    'dayStartMinutes',
  );
  @override
  late final GeneratedColumn<int> dayStartMinutes = GeneratedColumn<int>(
    'day_start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(420),
  );
  static const VerificationMeta _dayEndMinutesMeta = const VerificationMeta(
    'dayEndMinutes',
  );
  @override
  late final GeneratedColumn<int> dayEndMinutes = GeneratedColumn<int>(
    'day_end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1320),
  );
  static const VerificationMeta _maxSameDayReplansMeta = const VerificationMeta(
    'maxSameDayReplans',
  );
  @override
  late final GeneratedColumn<int> maxSameDayReplans = GeneratedColumn<int>(
    'max_same_day_replans',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _scheduleHorizonDaysMeta =
      const VerificationMeta('scheduleHorizonDays');
  @override
  late final GeneratedColumn<int> scheduleHorizonDays = GeneratedColumn<int>(
    'schedule_horizon_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _maxPendingAlarmsMeta = const VerificationMeta(
    'maxPendingAlarms',
  );
  @override
  late final GeneratedColumn<int> maxPendingAlarms = GeneratedColumn<int>(
    'max_pending_alarms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(200),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayStartMinutes,
    dayEndMinutes,
    maxSameDayReplans,
    scheduleHorizonDays,
    maxPendingAlarms,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preference_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_start_minutes')) {
      context.handle(
        _dayStartMinutesMeta,
        dayStartMinutes.isAcceptableOrUnknown(
          data['day_start_minutes']!,
          _dayStartMinutesMeta,
        ),
      );
    }
    if (data.containsKey('day_end_minutes')) {
      context.handle(
        _dayEndMinutesMeta,
        dayEndMinutes.isAcceptableOrUnknown(
          data['day_end_minutes']!,
          _dayEndMinutesMeta,
        ),
      );
    }
    if (data.containsKey('max_same_day_replans')) {
      context.handle(
        _maxSameDayReplansMeta,
        maxSameDayReplans.isAcceptableOrUnknown(
          data['max_same_day_replans']!,
          _maxSameDayReplansMeta,
        ),
      );
    }
    if (data.containsKey('schedule_horizon_days')) {
      context.handle(
        _scheduleHorizonDaysMeta,
        scheduleHorizonDays.isAcceptableOrUnknown(
          data['schedule_horizon_days']!,
          _scheduleHorizonDaysMeta,
        ),
      );
    }
    if (data.containsKey('max_pending_alarms')) {
      context.handle(
        _maxPendingAlarmsMeta,
        maxPendingAlarms.isAcceptableOrUnknown(
          data['max_pending_alarms']!,
          _maxPendingAlarmsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreferenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dayStartMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_start_minutes'],
      )!,
      dayEndMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_end_minutes'],
      )!,
      maxSameDayReplans: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_same_day_replans'],
      )!,
      scheduleHorizonDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_horizon_days'],
      )!,
      maxPendingAlarms: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_pending_alarms'],
      )!,
    );
  }

  @override
  $UserPreferenceRowsTable createAlias(String alias) {
    return $UserPreferenceRowsTable(attachedDatabase, alias);
  }
}

class UserPreferenceRow extends DataClass
    implements Insertable<UserPreferenceRow> {
  final int id;
  final int dayStartMinutes;
  final int dayEndMinutes;
  final int maxSameDayReplans;
  final int scheduleHorizonDays;
  final int maxPendingAlarms;
  const UserPreferenceRow({
    required this.id,
    required this.dayStartMinutes,
    required this.dayEndMinutes,
    required this.maxSameDayReplans,
    required this.scheduleHorizonDays,
    required this.maxPendingAlarms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_start_minutes'] = Variable<int>(dayStartMinutes);
    map['day_end_minutes'] = Variable<int>(dayEndMinutes);
    map['max_same_day_replans'] = Variable<int>(maxSameDayReplans);
    map['schedule_horizon_days'] = Variable<int>(scheduleHorizonDays);
    map['max_pending_alarms'] = Variable<int>(maxPendingAlarms);
    return map;
  }

  UserPreferenceRowsCompanion toCompanion(bool nullToAbsent) {
    return UserPreferenceRowsCompanion(
      id: Value(id),
      dayStartMinutes: Value(dayStartMinutes),
      dayEndMinutes: Value(dayEndMinutes),
      maxSameDayReplans: Value(maxSameDayReplans),
      scheduleHorizonDays: Value(scheduleHorizonDays),
      maxPendingAlarms: Value(maxPendingAlarms),
    );
  }

  factory UserPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreferenceRow(
      id: serializer.fromJson<int>(json['id']),
      dayStartMinutes: serializer.fromJson<int>(json['dayStartMinutes']),
      dayEndMinutes: serializer.fromJson<int>(json['dayEndMinutes']),
      maxSameDayReplans: serializer.fromJson<int>(json['maxSameDayReplans']),
      scheduleHorizonDays: serializer.fromJson<int>(
        json['scheduleHorizonDays'],
      ),
      maxPendingAlarms: serializer.fromJson<int>(json['maxPendingAlarms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayStartMinutes': serializer.toJson<int>(dayStartMinutes),
      'dayEndMinutes': serializer.toJson<int>(dayEndMinutes),
      'maxSameDayReplans': serializer.toJson<int>(maxSameDayReplans),
      'scheduleHorizonDays': serializer.toJson<int>(scheduleHorizonDays),
      'maxPendingAlarms': serializer.toJson<int>(maxPendingAlarms),
    };
  }

  UserPreferenceRow copyWith({
    int? id,
    int? dayStartMinutes,
    int? dayEndMinutes,
    int? maxSameDayReplans,
    int? scheduleHorizonDays,
    int? maxPendingAlarms,
  }) => UserPreferenceRow(
    id: id ?? this.id,
    dayStartMinutes: dayStartMinutes ?? this.dayStartMinutes,
    dayEndMinutes: dayEndMinutes ?? this.dayEndMinutes,
    maxSameDayReplans: maxSameDayReplans ?? this.maxSameDayReplans,
    scheduleHorizonDays: scheduleHorizonDays ?? this.scheduleHorizonDays,
    maxPendingAlarms: maxPendingAlarms ?? this.maxPendingAlarms,
  );
  UserPreferenceRow copyWithCompanion(UserPreferenceRowsCompanion data) {
    return UserPreferenceRow(
      id: data.id.present ? data.id.value : this.id,
      dayStartMinutes: data.dayStartMinutes.present
          ? data.dayStartMinutes.value
          : this.dayStartMinutes,
      dayEndMinutes: data.dayEndMinutes.present
          ? data.dayEndMinutes.value
          : this.dayEndMinutes,
      maxSameDayReplans: data.maxSameDayReplans.present
          ? data.maxSameDayReplans.value
          : this.maxSameDayReplans,
      scheduleHorizonDays: data.scheduleHorizonDays.present
          ? data.scheduleHorizonDays.value
          : this.scheduleHorizonDays,
      maxPendingAlarms: data.maxPendingAlarms.present
          ? data.maxPendingAlarms.value
          : this.maxPendingAlarms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceRow(')
          ..write('id: $id, ')
          ..write('dayStartMinutes: $dayStartMinutes, ')
          ..write('dayEndMinutes: $dayEndMinutes, ')
          ..write('maxSameDayReplans: $maxSameDayReplans, ')
          ..write('scheduleHorizonDays: $scheduleHorizonDays, ')
          ..write('maxPendingAlarms: $maxPendingAlarms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayStartMinutes,
    dayEndMinutes,
    maxSameDayReplans,
    scheduleHorizonDays,
    maxPendingAlarms,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreferenceRow &&
          other.id == this.id &&
          other.dayStartMinutes == this.dayStartMinutes &&
          other.dayEndMinutes == this.dayEndMinutes &&
          other.maxSameDayReplans == this.maxSameDayReplans &&
          other.scheduleHorizonDays == this.scheduleHorizonDays &&
          other.maxPendingAlarms == this.maxPendingAlarms);
}

class UserPreferenceRowsCompanion extends UpdateCompanion<UserPreferenceRow> {
  final Value<int> id;
  final Value<int> dayStartMinutes;
  final Value<int> dayEndMinutes;
  final Value<int> maxSameDayReplans;
  final Value<int> scheduleHorizonDays;
  final Value<int> maxPendingAlarms;
  const UserPreferenceRowsCompanion({
    this.id = const Value.absent(),
    this.dayStartMinutes = const Value.absent(),
    this.dayEndMinutes = const Value.absent(),
    this.maxSameDayReplans = const Value.absent(),
    this.scheduleHorizonDays = const Value.absent(),
    this.maxPendingAlarms = const Value.absent(),
  });
  UserPreferenceRowsCompanion.insert({
    this.id = const Value.absent(),
    this.dayStartMinutes = const Value.absent(),
    this.dayEndMinutes = const Value.absent(),
    this.maxSameDayReplans = const Value.absent(),
    this.scheduleHorizonDays = const Value.absent(),
    this.maxPendingAlarms = const Value.absent(),
  });
  static Insertable<UserPreferenceRow> custom({
    Expression<int>? id,
    Expression<int>? dayStartMinutes,
    Expression<int>? dayEndMinutes,
    Expression<int>? maxSameDayReplans,
    Expression<int>? scheduleHorizonDays,
    Expression<int>? maxPendingAlarms,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayStartMinutes != null) 'day_start_minutes': dayStartMinutes,
      if (dayEndMinutes != null) 'day_end_minutes': dayEndMinutes,
      if (maxSameDayReplans != null) 'max_same_day_replans': maxSameDayReplans,
      if (scheduleHorizonDays != null)
        'schedule_horizon_days': scheduleHorizonDays,
      if (maxPendingAlarms != null) 'max_pending_alarms': maxPendingAlarms,
    });
  }

  UserPreferenceRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? dayStartMinutes,
    Value<int>? dayEndMinutes,
    Value<int>? maxSameDayReplans,
    Value<int>? scheduleHorizonDays,
    Value<int>? maxPendingAlarms,
  }) {
    return UserPreferenceRowsCompanion(
      id: id ?? this.id,
      dayStartMinutes: dayStartMinutes ?? this.dayStartMinutes,
      dayEndMinutes: dayEndMinutes ?? this.dayEndMinutes,
      maxSameDayReplans: maxSameDayReplans ?? this.maxSameDayReplans,
      scheduleHorizonDays: scheduleHorizonDays ?? this.scheduleHorizonDays,
      maxPendingAlarms: maxPendingAlarms ?? this.maxPendingAlarms,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayStartMinutes.present) {
      map['day_start_minutes'] = Variable<int>(dayStartMinutes.value);
    }
    if (dayEndMinutes.present) {
      map['day_end_minutes'] = Variable<int>(dayEndMinutes.value);
    }
    if (maxSameDayReplans.present) {
      map['max_same_day_replans'] = Variable<int>(maxSameDayReplans.value);
    }
    if (scheduleHorizonDays.present) {
      map['schedule_horizon_days'] = Variable<int>(scheduleHorizonDays.value);
    }
    if (maxPendingAlarms.present) {
      map['max_pending_alarms'] = Variable<int>(maxPendingAlarms.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('dayStartMinutes: $dayStartMinutes, ')
          ..write('dayEndMinutes: $dayEndMinutes, ')
          ..write('maxSameDayReplans: $maxSameDayReplans, ')
          ..write('scheduleHorizonDays: $scheduleHorizonDays, ')
          ..write('maxPendingAlarms: $maxPendingAlarms')
          ..write(')'))
        .toString();
  }
}

class $AppMetadataRowsTable extends AppMetadataRows
    with TableInfo<$AppMetadataRowsTable, AppMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetadataRowsTable createAlias(String alias) {
    return $AppMetadataRowsTable(attachedDatabase, alias);
  }
}

class AppMetadataRow extends DataClass implements Insertable<AppMetadataRow> {
  final String key;
  final String value;
  const AppMetadataRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetadataRowsCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataRowsCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetadataRow copyWith({String? key, String? value}) =>
      AppMetadataRow(key: key ?? this.key, value: value ?? this.value);
  AppMetadataRow copyWithCompanion(AppMetadataRowsCompanion data) {
    return AppMetadataRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetadataRowsCompanion extends UpdateCompanion<AppMetadataRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetadataRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetadataRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetadataRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $OccurrencesTable occurrences = $OccurrencesTable(this);
  late final $ActivityEventsTable activityEvents = $ActivityEventsTable(this);
  late final $UserPreferenceRowsTable userPreferenceRows =
      $UserPreferenceRowsTable(this);
  late final $AppMetadataRowsTable appMetadataRows = $AppMetadataRowsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activities,
    occurrences,
    activityEvents,
    userPreferenceRows,
    appMetadataRows,
  ];
}

typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      required String title,
      Value<String> notes,
      required int durationMinutes,
      required String priority,
      required String recurrenceType,
      Value<DateTime?> oneOffAtUtc,
      Value<int?> weekdaysMask,
      Value<int?> localHour,
      Value<int?> localMinute,
      Value<int?> preparationLeadMinutes,
      Value<bool> isActive,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> notes,
      Value<int> durationMinutes,
      Value<String> priority,
      Value<String> recurrenceType,
      Value<DateTime?> oneOffAtUtc,
      Value<int?> weekdaysMask,
      Value<int?> localHour,
      Value<int?> localMinute,
      Value<int?> preparationLeadMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, ActivityRow> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OccurrencesTable, List<OccurrenceRow>>
  _occurrencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.occurrences,
    aliasName: 'activities__id__occurrences__activity_id',
  );

  $$OccurrencesTableProcessedTableManager get occurrencesRefs {
    final manager = $$OccurrencesTableTableManager(
      $_db,
      $_db.occurrences,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_occurrencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get oneOffAtUtc => $composableBuilder(
    column: $table.oneOffAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localHour => $composableBuilder(
    column: $table.localHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localMinute => $composableBuilder(
    column: $table.localMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preparationLeadMinutes => $composableBuilder(
    column: $table.preparationLeadMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> occurrencesRefs(
    Expression<bool> Function($$OccurrencesTableFilterComposer f) f,
  ) {
    final $$OccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get oneOffAtUtc => $composableBuilder(
    column: $table.oneOffAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localHour => $composableBuilder(
    column: $table.localHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localMinute => $composableBuilder(
    column: $table.localMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preparationLeadMinutes => $composableBuilder(
    column: $table.preparationLeadMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get recurrenceType => $composableBuilder(
    column: $table.recurrenceType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get oneOffAtUtc => $composableBuilder(
    column: $table.oneOffAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localHour =>
      $composableBuilder(column: $table.localHour, builder: (column) => column);

  GeneratedColumn<int> get localMinute => $composableBuilder(
    column: $table.localMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preparationLeadMinutes => $composableBuilder(
    column: $table.preparationLeadMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  Expression<T> occurrencesRefs<T extends Object>(
    Expression<T> Function($$OccurrencesTableAnnotationComposer a) f,
  ) {
    final $$OccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          ActivityRow,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (ActivityRow, $$ActivitiesTableReferences),
          ActivityRow,
          PrefetchHooks Function({bool occurrencesRefs})
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> recurrenceType = const Value.absent(),
                Value<DateTime?> oneOffAtUtc = const Value.absent(),
                Value<int?> weekdaysMask = const Value.absent(),
                Value<int?> localHour = const Value.absent(),
                Value<int?> localMinute = const Value.absent(),
                Value<int?> preparationLeadMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                title: title,
                notes: notes,
                durationMinutes: durationMinutes,
                priority: priority,
                recurrenceType: recurrenceType,
                oneOffAtUtc: oneOffAtUtc,
                weekdaysMask: weekdaysMask,
                localHour: localHour,
                localMinute: localMinute,
                preparationLeadMinutes: preparationLeadMinutes,
                isActive: isActive,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> notes = const Value.absent(),
                required int durationMinutes,
                required String priority,
                required String recurrenceType,
                Value<DateTime?> oneOffAtUtc = const Value.absent(),
                Value<int?> weekdaysMask = const Value.absent(),
                Value<int?> localHour = const Value.absent(),
                Value<int?> localMinute = const Value.absent(),
                Value<int?> preparationLeadMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                durationMinutes: durationMinutes,
                priority: priority,
                recurrenceType: recurrenceType,
                oneOffAtUtc: oneOffAtUtc,
                weekdaysMask: weekdaysMask,
                localHour: localHour,
                localMinute: localMinute,
                preparationLeadMinutes: preparationLeadMinutes,
                isActive: isActive,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({occurrencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (occurrencesRefs) db.occurrences],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (occurrencesRefs)
                    await $_getPrefetchedData<
                      ActivityRow,
                      $ActivitiesTable,
                      OccurrenceRow
                    >(
                      currentTable: table,
                      referencedTable: $$ActivitiesTableReferences
                          ._occurrencesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ActivitiesTableReferences(
                            db,
                            table,
                            p0,
                          ).occurrencesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.activityId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      ActivityRow,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (ActivityRow, $$ActivitiesTableReferences),
      ActivityRow,
      PrefetchHooks Function({bool occurrencesRefs})
    >;
typedef $$OccurrencesTableCreateCompanionBuilder =
    OccurrencesCompanion Function({
      required String id,
      required int nativeAlarmId,
      required String activityId,
      required DateTime originalStartUtc,
      required DateTime scheduledStartUtc,
      required int durationMinutes,
      required String priority,
      required String status,
      Value<int> attempt,
      Value<int> rowid,
    });
typedef $$OccurrencesTableUpdateCompanionBuilder =
    OccurrencesCompanion Function({
      Value<String> id,
      Value<int> nativeAlarmId,
      Value<String> activityId,
      Value<DateTime> originalStartUtc,
      Value<DateTime> scheduledStartUtc,
      Value<int> durationMinutes,
      Value<String> priority,
      Value<String> status,
      Value<int> attempt,
      Value<int> rowid,
    });

final class $$OccurrencesTableReferences
    extends BaseReferences<_$AppDatabase, $OccurrencesTable, OccurrenceRow> {
  $$OccurrencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias('occurrences__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActivityEventsTable, List<ActivityEventRow>>
  _activityEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityEvents,
    aliasName: 'occurrences__id__activity_events__occurrence_id',
  );

  $$ActivityEventsTableProcessedTableManager get activityEventsRefs {
    final manager = $$ActivityEventsTableTableManager(
      $_db,
      $_db.activityEvents,
    ).filter((f) => f.occurrenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nativeAlarmId => $composableBuilder(
    column: $table.nativeAlarmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get originalStartUtc => $composableBuilder(
    column: $table.originalStartUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledStartUtc => $composableBuilder(
    column: $table.scheduledStartUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activityEventsRefs(
    Expression<bool> Function($$ActivityEventsTableFilterComposer f) f,
  ) {
    final $$ActivityEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.occurrenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableFilterComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nativeAlarmId => $composableBuilder(
    column: $table.nativeAlarmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get originalStartUtc => $composableBuilder(
    column: $table.originalStartUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledStartUtc => $composableBuilder(
    column: $table.scheduledStartUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nativeAlarmId => $composableBuilder(
    column: $table.nativeAlarmId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get originalStartUtc => $composableBuilder(
    column: $table.originalStartUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledStartUtc => $composableBuilder(
    column: $table.scheduledStartUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activityEventsRefs<T extends Object>(
    Expression<T> Function($$ActivityEventsTableAnnotationComposer a) f,
  ) {
    final $$ActivityEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.occurrenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OccurrencesTable,
          OccurrenceRow,
          $$OccurrencesTableFilterComposer,
          $$OccurrencesTableOrderingComposer,
          $$OccurrencesTableAnnotationComposer,
          $$OccurrencesTableCreateCompanionBuilder,
          $$OccurrencesTableUpdateCompanionBuilder,
          (OccurrenceRow, $$OccurrencesTableReferences),
          OccurrenceRow,
          PrefetchHooks Function({bool activityId, bool activityEventsRefs})
        > {
  $$OccurrencesTableTableManager(_$AppDatabase db, $OccurrencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> nativeAlarmId = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<DateTime> originalStartUtc = const Value.absent(),
                Value<DateTime> scheduledStartUtc = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion(
                id: id,
                nativeAlarmId: nativeAlarmId,
                activityId: activityId,
                originalStartUtc: originalStartUtc,
                scheduledStartUtc: scheduledStartUtc,
                durationMinutes: durationMinutes,
                priority: priority,
                status: status,
                attempt: attempt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int nativeAlarmId,
                required String activityId,
                required DateTime originalStartUtc,
                required DateTime scheduledStartUtc,
                required int durationMinutes,
                required String priority,
                required String status,
                Value<int> attempt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion.insert(
                id: id,
                nativeAlarmId: nativeAlarmId,
                activityId: activityId,
                originalStartUtc: originalStartUtc,
                scheduledStartUtc: scheduledStartUtc,
                durationMinutes: durationMinutes,
                priority: priority,
                status: status,
                attempt: attempt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({activityId = false, activityEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityEventsRefs) db.activityEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (activityId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.activityId,
                                    referencedTable:
                                        $$OccurrencesTableReferences
                                            ._activityIdTable(db),
                                    referencedColumn:
                                        $$OccurrencesTableReferences
                                            ._activityIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activityEventsRefs)
                        await $_getPrefetchedData<
                          OccurrenceRow,
                          $OccurrencesTable,
                          ActivityEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$OccurrencesTableReferences
                              ._activityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OccurrencesTableReferences(
                                db,
                                table,
                                p0,
                              ).activityEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.occurrenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OccurrencesTable,
      OccurrenceRow,
      $$OccurrencesTableFilterComposer,
      $$OccurrencesTableOrderingComposer,
      $$OccurrencesTableAnnotationComposer,
      $$OccurrencesTableCreateCompanionBuilder,
      $$OccurrencesTableUpdateCompanionBuilder,
      (OccurrenceRow, $$OccurrencesTableReferences),
      OccurrenceRow,
      PrefetchHooks Function({bool activityId, bool activityEventsRefs})
    >;
typedef $$ActivityEventsTableCreateCompanionBuilder =
    ActivityEventsCompanion Function({
      required String id,
      required String occurrenceId,
      required String type,
      required DateTime occurredAtUtc,
      Value<DateTime?> previousStartUtc,
      Value<DateTime?> nextStartUtc,
      Value<int> rowid,
    });
typedef $$ActivityEventsTableUpdateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<String> id,
      Value<String> occurrenceId,
      Value<String> type,
      Value<DateTime> occurredAtUtc,
      Value<DateTime?> previousStartUtc,
      Value<DateTime?> nextStartUtc,
      Value<int> rowid,
    });

final class $$ActivityEventsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEventRow> {
  $$ActivityEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OccurrencesTable _occurrenceIdTable(_$AppDatabase db) => db
      .occurrences
      .createAlias('activity_events__occurrence_id__occurrences__id');

  $$OccurrencesTableProcessedTableManager get occurrenceId {
    final $_column = $_itemColumn<String>('occurrence_id')!;

    final manager = $$OccurrencesTableTableManager(
      $_db,
      $_db.occurrences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_occurrenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get previousStartUtc => $composableBuilder(
    column: $table.previousStartUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextStartUtc => $composableBuilder(
    column: $table.nextStartUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$OccurrencesTableFilterComposer get occurrenceId {
    final $$OccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get previousStartUtc => $composableBuilder(
    column: $table.previousStartUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextStartUtc => $composableBuilder(
    column: $table.nextStartUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$OccurrencesTableOrderingComposer get occurrenceId {
    final $$OccurrencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableOrderingComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get previousStartUtc => $composableBuilder(
    column: $table.previousStartUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextStartUtc => $composableBuilder(
    column: $table.nextStartUtc,
    builder: (column) => column,
  );

  $$OccurrencesTableAnnotationComposer get occurrenceId {
    final $$OccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceId,
      referencedTable: $db.occurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.occurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityEventsTable,
          ActivityEventRow,
          $$ActivityEventsTableFilterComposer,
          $$ActivityEventsTableOrderingComposer,
          $$ActivityEventsTableAnnotationComposer,
          $$ActivityEventsTableCreateCompanionBuilder,
          $$ActivityEventsTableUpdateCompanionBuilder,
          (ActivityEventRow, $$ActivityEventsTableReferences),
          ActivityEventRow,
          PrefetchHooks Function({bool occurrenceId})
        > {
  $$ActivityEventsTableTableManager(
    _$AppDatabase db,
    $ActivityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> occurrenceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<DateTime?> previousStartUtc = const Value.absent(),
                Value<DateTime?> nextStartUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion(
                id: id,
                occurrenceId: occurrenceId,
                type: type,
                occurredAtUtc: occurredAtUtc,
                previousStartUtc: previousStartUtc,
                nextStartUtc: nextStartUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String occurrenceId,
                required String type,
                required DateTime occurredAtUtc,
                Value<DateTime?> previousStartUtc = const Value.absent(),
                Value<DateTime?> nextStartUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion.insert(
                id: id,
                occurrenceId: occurrenceId,
                type: type,
                occurredAtUtc: occurredAtUtc,
                previousStartUtc: previousStartUtc,
                nextStartUtc: nextStartUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivityEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({occurrenceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (occurrenceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.occurrenceId,
                                referencedTable: $$ActivityEventsTableReferences
                                    ._occurrenceIdTable(db),
                                referencedColumn:
                                    $$ActivityEventsTableReferences
                                        ._occurrenceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActivityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityEventsTable,
      ActivityEventRow,
      $$ActivityEventsTableFilterComposer,
      $$ActivityEventsTableOrderingComposer,
      $$ActivityEventsTableAnnotationComposer,
      $$ActivityEventsTableCreateCompanionBuilder,
      $$ActivityEventsTableUpdateCompanionBuilder,
      (ActivityEventRow, $$ActivityEventsTableReferences),
      ActivityEventRow,
      PrefetchHooks Function({bool occurrenceId})
    >;
typedef $$UserPreferenceRowsTableCreateCompanionBuilder =
    UserPreferenceRowsCompanion Function({
      Value<int> id,
      Value<int> dayStartMinutes,
      Value<int> dayEndMinutes,
      Value<int> maxSameDayReplans,
      Value<int> scheduleHorizonDays,
      Value<int> maxPendingAlarms,
    });
typedef $$UserPreferenceRowsTableUpdateCompanionBuilder =
    UserPreferenceRowsCompanion Function({
      Value<int> id,
      Value<int> dayStartMinutes,
      Value<int> dayEndMinutes,
      Value<int> maxSameDayReplans,
      Value<int> scheduleHorizonDays,
      Value<int> maxPendingAlarms,
    });

class $$UserPreferenceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferenceRowsTable> {
  $$UserPreferenceRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayStartMinutes => $composableBuilder(
    column: $table.dayStartMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayEndMinutes => $composableBuilder(
    column: $table.dayEndMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSameDayReplans => $composableBuilder(
    column: $table.maxSameDayReplans,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduleHorizonDays => $composableBuilder(
    column: $table.scheduleHorizonDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPendingAlarms => $composableBuilder(
    column: $table.maxPendingAlarms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferenceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferenceRowsTable> {
  $$UserPreferenceRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayStartMinutes => $composableBuilder(
    column: $table.dayStartMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayEndMinutes => $composableBuilder(
    column: $table.dayEndMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSameDayReplans => $composableBuilder(
    column: $table.maxSameDayReplans,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduleHorizonDays => $composableBuilder(
    column: $table.scheduleHorizonDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPendingAlarms => $composableBuilder(
    column: $table.maxPendingAlarms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferenceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferenceRowsTable> {
  $$UserPreferenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayStartMinutes => $composableBuilder(
    column: $table.dayStartMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayEndMinutes => $composableBuilder(
    column: $table.dayEndMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxSameDayReplans => $composableBuilder(
    column: $table.maxSameDayReplans,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduleHorizonDays => $composableBuilder(
    column: $table.scheduleHorizonDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPendingAlarms => $composableBuilder(
    column: $table.maxPendingAlarms,
    builder: (column) => column,
  );
}

class $$UserPreferenceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferenceRowsTable,
          UserPreferenceRow,
          $$UserPreferenceRowsTableFilterComposer,
          $$UserPreferenceRowsTableOrderingComposer,
          $$UserPreferenceRowsTableAnnotationComposer,
          $$UserPreferenceRowsTableCreateCompanionBuilder,
          $$UserPreferenceRowsTableUpdateCompanionBuilder,
          (
            UserPreferenceRow,
            BaseReferences<
              _$AppDatabase,
              $UserPreferenceRowsTable,
              UserPreferenceRow
            >,
          ),
          UserPreferenceRow,
          PrefetchHooks Function()
        > {
  $$UserPreferenceRowsTableTableManager(
    _$AppDatabase db,
    $UserPreferenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferenceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferenceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayStartMinutes = const Value.absent(),
                Value<int> dayEndMinutes = const Value.absent(),
                Value<int> maxSameDayReplans = const Value.absent(),
                Value<int> scheduleHorizonDays = const Value.absent(),
                Value<int> maxPendingAlarms = const Value.absent(),
              }) => UserPreferenceRowsCompanion(
                id: id,
                dayStartMinutes: dayStartMinutes,
                dayEndMinutes: dayEndMinutes,
                maxSameDayReplans: maxSameDayReplans,
                scheduleHorizonDays: scheduleHorizonDays,
                maxPendingAlarms: maxPendingAlarms,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dayStartMinutes = const Value.absent(),
                Value<int> dayEndMinutes = const Value.absent(),
                Value<int> maxSameDayReplans = const Value.absent(),
                Value<int> scheduleHorizonDays = const Value.absent(),
                Value<int> maxPendingAlarms = const Value.absent(),
              }) => UserPreferenceRowsCompanion.insert(
                id: id,
                dayStartMinutes: dayStartMinutes,
                dayEndMinutes: dayEndMinutes,
                maxSameDayReplans: maxSameDayReplans,
                scheduleHorizonDays: scheduleHorizonDays,
                maxPendingAlarms: maxPendingAlarms,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferenceRowsTable,
      UserPreferenceRow,
      $$UserPreferenceRowsTableFilterComposer,
      $$UserPreferenceRowsTableOrderingComposer,
      $$UserPreferenceRowsTableAnnotationComposer,
      $$UserPreferenceRowsTableCreateCompanionBuilder,
      $$UserPreferenceRowsTableUpdateCompanionBuilder,
      (
        UserPreferenceRow,
        BaseReferences<
          _$AppDatabase,
          $UserPreferenceRowsTable,
          UserPreferenceRow
        >,
      ),
      UserPreferenceRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetadataRowsTableCreateCompanionBuilder =
    AppMetadataRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetadataRowsTableUpdateCompanionBuilder =
    AppMetadataRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetadataRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetadataRowsTable> {
  $$AppMetadataRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetadataRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetadataRowsTable> {
  $$AppMetadataRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetadataRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetadataRowsTable> {
  $$AppMetadataRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetadataRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetadataRowsTable,
          AppMetadataRow,
          $$AppMetadataRowsTableFilterComposer,
          $$AppMetadataRowsTableOrderingComposer,
          $$AppMetadataRowsTableAnnotationComposer,
          $$AppMetadataRowsTableCreateCompanionBuilder,
          $$AppMetadataRowsTableUpdateCompanionBuilder,
          (
            AppMetadataRow,
            BaseReferences<
              _$AppDatabase,
              $AppMetadataRowsTable,
              AppMetadataRow
            >,
          ),
          AppMetadataRow,
          PrefetchHooks Function()
        > {
  $$AppMetadataRowsTableTableManager(
    _$AppDatabase db,
    $AppMetadataRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetadataRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetadataRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetadataRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataRowsCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetadataRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetadataRowsTable,
      AppMetadataRow,
      $$AppMetadataRowsTableFilterComposer,
      $$AppMetadataRowsTableOrderingComposer,
      $$AppMetadataRowsTableAnnotationComposer,
      $$AppMetadataRowsTableCreateCompanionBuilder,
      $$AppMetadataRowsTableUpdateCompanionBuilder,
      (
        AppMetadataRow,
        BaseReferences<_$AppDatabase, $AppMetadataRowsTable, AppMetadataRow>,
      ),
      AppMetadataRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$OccurrencesTableTableManager get occurrences =>
      $$OccurrencesTableTableManager(_db, _db.occurrences);
  $$ActivityEventsTableTableManager get activityEvents =>
      $$ActivityEventsTableTableManager(_db, _db.activityEvents);
  $$UserPreferenceRowsTableTableManager get userPreferenceRows =>
      $$UserPreferenceRowsTableTableManager(_db, _db.userPreferenceRows);
  $$AppMetadataRowsTableTableManager get appMetadataRows =>
      $$AppMetadataRowsTableTableManager(_db, _db.appMetadataRows);
}
