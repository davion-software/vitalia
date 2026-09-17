// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MetadataTable extends Metadata
    with TableInfo<$MetadataTable, MetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetadataRow> instance, {
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
  MetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataRow(
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
  $MetadataTable createAlias(String alias) {
    return $MetadataTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class MetadataRow extends DataClass implements Insertable<MetadataRow> {
  final String key;
  final String value;
  const MetadataRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetadataCompanion toCompanion(bool nullToAbsent) {
    return MetadataCompanion(key: Value(key), value: Value(value));
  }

  factory MetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataRow(
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

  MetadataRow copyWith({String? key, String? value}) =>
      MetadataRow(key: key ?? this.key, value: value ?? this.value);
  MetadataRow copyWithCompanion(MetadataCompanion data) {
    return MetadataRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataRow(')
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
      (other is MetadataRow &&
          other.key == this.key &&
          other.value == this.value);
}

class MetadataCompanion extends UpdateCompanion<MetadataRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetadataRow> custom({
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

  MetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetadataCompanion(
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
    return (StringBuffer('MetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, MedicationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
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
  static const VerificationMeta _shapeMeta = const VerificationMeta('shape');
  @override
  late final GeneratedColumn<String> shape = GeneratedColumn<String>(
    'shape',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refillThresholdMeta = const VerificationMeta(
    'refillThreshold',
  );
  @override
  late final GeneratedColumn<int> refillThreshold = GeneratedColumn<int>(
    'refill_threshold',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMsMeta = const VerificationMeta(
    'createdAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdAtUtcMs = GeneratedColumn<int>(
    'created_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMsMeta = const VerificationMeta(
    'updatedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtUtcMs = GeneratedColumn<int>(
    'updated_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMsMeta = const VerificationMeta(
    'deletedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtUtcMs = GeneratedColumn<int>(
    'deleted_at_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    dosage,
    notes,
    shape,
    color,
    quantity,
    refillThreshold,
    isDeleted,
    createdAtUtcMs,
    updatedAtUtcMs,
    deletedAtUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('shape')) {
      context.handle(
        _shapeMeta,
        shape.isAcceptableOrUnknown(data['shape']!, _shapeMeta),
      );
    } else if (isInserting) {
      context.missing(_shapeMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('refill_threshold')) {
      context.handle(
        _refillThresholdMeta,
        refillThreshold.isAcceptableOrUnknown(
          data['refill_threshold']!,
          _refillThresholdMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at_utc_ms')) {
      context.handle(
        _createdAtUtcMsMeta,
        createdAtUtcMs.isAcceptableOrUnknown(
          data['created_at_utc_ms']!,
          _createdAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMsMeta);
    }
    if (data.containsKey('updated_at_utc_ms')) {
      context.handle(
        _updatedAtUtcMsMeta,
        updatedAtUtcMs.isAcceptableOrUnknown(
          data['updated_at_utc_ms']!,
          _updatedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMsMeta);
    }
    if (data.containsKey('deleted_at_utc_ms')) {
      context.handle(
        _deletedAtUtcMsMeta,
        deletedAtUtcMs.isAcceptableOrUnknown(
          data['deleted_at_utc_ms']!,
          _deletedAtUtcMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      shape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shape'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      ),
      refillThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refill_threshold'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_ms'],
      )!,
      updatedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_utc_ms'],
      )!,
      deletedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_utc_ms'],
      ),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class MedicationRow extends DataClass implements Insertable<MedicationRow> {
  final String id;
  final String name;
  final String dosage;
  final String notes;
  final String shape;
  final String color;
  final int? quantity;
  final int? refillThreshold;
  final bool isDeleted;
  final int createdAtUtcMs;
  final int updatedAtUtcMs;
  final int? deletedAtUtcMs;
  const MedicationRow({
    required this.id,
    required this.name,
    required this.dosage,
    required this.notes,
    required this.shape,
    required this.color,
    this.quantity,
    this.refillThreshold,
    required this.isDeleted,
    required this.createdAtUtcMs,
    required this.updatedAtUtcMs,
    this.deletedAtUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    map['notes'] = Variable<String>(notes);
    map['shape'] = Variable<String>(shape);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<int>(quantity);
    }
    if (!nullToAbsent || refillThreshold != null) {
      map['refill_threshold'] = Variable<int>(refillThreshold);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs);
    map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs);
    if (!nullToAbsent || deletedAtUtcMs != null) {
      map['deleted_at_utc_ms'] = Variable<int>(deletedAtUtcMs);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      dosage: Value(dosage),
      notes: Value(notes),
      shape: Value(shape),
      color: Value(color),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      refillThreshold: refillThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(refillThreshold),
      isDeleted: Value(isDeleted),
      createdAtUtcMs: Value(createdAtUtcMs),
      updatedAtUtcMs: Value(updatedAtUtcMs),
      deletedAtUtcMs: deletedAtUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtcMs),
    );
  }

  factory MedicationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      notes: serializer.fromJson<String>(json['notes']),
      shape: serializer.fromJson<String>(json['shape']),
      color: serializer.fromJson<String>(json['color']),
      quantity: serializer.fromJson<int?>(json['quantity']),
      refillThreshold: serializer.fromJson<int?>(json['refillThreshold']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAtUtcMs: serializer.fromJson<int>(json['createdAtUtcMs']),
      updatedAtUtcMs: serializer.fromJson<int>(json['updatedAtUtcMs']),
      deletedAtUtcMs: serializer.fromJson<int?>(json['deletedAtUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'notes': serializer.toJson<String>(notes),
      'shape': serializer.toJson<String>(shape),
      'color': serializer.toJson<String>(color),
      'quantity': serializer.toJson<int?>(quantity),
      'refillThreshold': serializer.toJson<int?>(refillThreshold),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAtUtcMs': serializer.toJson<int>(createdAtUtcMs),
      'updatedAtUtcMs': serializer.toJson<int>(updatedAtUtcMs),
      'deletedAtUtcMs': serializer.toJson<int?>(deletedAtUtcMs),
    };
  }

  MedicationRow copyWith({
    String? id,
    String? name,
    String? dosage,
    String? notes,
    String? shape,
    String? color,
    Value<int?> quantity = const Value.absent(),
    Value<int?> refillThreshold = const Value.absent(),
    bool? isDeleted,
    int? createdAtUtcMs,
    int? updatedAtUtcMs,
    Value<int?> deletedAtUtcMs = const Value.absent(),
  }) => MedicationRow(
    id: id ?? this.id,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
    notes: notes ?? this.notes,
    shape: shape ?? this.shape,
    color: color ?? this.color,
    quantity: quantity.present ? quantity.value : this.quantity,
    refillThreshold: refillThreshold.present
        ? refillThreshold.value
        : this.refillThreshold,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
    updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
    deletedAtUtcMs: deletedAtUtcMs.present
        ? deletedAtUtcMs.value
        : this.deletedAtUtcMs,
  );
  MedicationRow copyWithCompanion(MedicationsCompanion data) {
    return MedicationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      notes: data.notes.present ? data.notes.value : this.notes,
      shape: data.shape.present ? data.shape.value : this.shape,
      color: data.color.present ? data.color.value : this.color,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      refillThreshold: data.refillThreshold.present
          ? data.refillThreshold.value
          : this.refillThreshold,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAtUtcMs: data.createdAtUtcMs.present
          ? data.createdAtUtcMs.value
          : this.createdAtUtcMs,
      updatedAtUtcMs: data.updatedAtUtcMs.present
          ? data.updatedAtUtcMs.value
          : this.updatedAtUtcMs,
      deletedAtUtcMs: data.deletedAtUtcMs.present
          ? data.deletedAtUtcMs.value
          : this.deletedAtUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('notes: $notes, ')
          ..write('shape: $shape, ')
          ..write('color: $color, ')
          ..write('quantity: $quantity, ')
          ..write('refillThreshold: $refillThreshold, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs, ')
          ..write('deletedAtUtcMs: $deletedAtUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    dosage,
    notes,
    shape,
    color,
    quantity,
    refillThreshold,
    isDeleted,
    createdAtUtcMs,
    updatedAtUtcMs,
    deletedAtUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.notes == this.notes &&
          other.shape == this.shape &&
          other.color == this.color &&
          other.quantity == this.quantity &&
          other.refillThreshold == this.refillThreshold &&
          other.isDeleted == this.isDeleted &&
          other.createdAtUtcMs == this.createdAtUtcMs &&
          other.updatedAtUtcMs == this.updatedAtUtcMs &&
          other.deletedAtUtcMs == this.deletedAtUtcMs);
}

class MedicationsCompanion extends UpdateCompanion<MedicationRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> dosage;
  final Value<String> notes;
  final Value<String> shape;
  final Value<String> color;
  final Value<int?> quantity;
  final Value<int?> refillThreshold;
  final Value<bool> isDeleted;
  final Value<int> createdAtUtcMs;
  final Value<int> updatedAtUtcMs;
  final Value<int?> deletedAtUtcMs;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.notes = const Value.absent(),
    this.shape = const Value.absent(),
    this.color = const Value.absent(),
    this.quantity = const Value.absent(),
    this.refillThreshold = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAtUtcMs = const Value.absent(),
    this.updatedAtUtcMs = const Value.absent(),
    this.deletedAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required String name,
    required String dosage,
    this.notes = const Value.absent(),
    required String shape,
    required String color,
    this.quantity = const Value.absent(),
    this.refillThreshold = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required int createdAtUtcMs,
    required int updatedAtUtcMs,
    this.deletedAtUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       dosage = Value(dosage),
       shape = Value(shape),
       color = Value(color),
       createdAtUtcMs = Value(createdAtUtcMs),
       updatedAtUtcMs = Value(updatedAtUtcMs);
  static Insertable<MedicationRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? notes,
    Expression<String>? shape,
    Expression<String>? color,
    Expression<int>? quantity,
    Expression<int>? refillThreshold,
    Expression<bool>? isDeleted,
    Expression<int>? createdAtUtcMs,
    Expression<int>? updatedAtUtcMs,
    Expression<int>? deletedAtUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (notes != null) 'notes': notes,
      if (shape != null) 'shape': shape,
      if (color != null) 'color': color,
      if (quantity != null) 'quantity': quantity,
      if (refillThreshold != null) 'refill_threshold': refillThreshold,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAtUtcMs != null) 'created_at_utc_ms': createdAtUtcMs,
      if (updatedAtUtcMs != null) 'updated_at_utc_ms': updatedAtUtcMs,
      if (deletedAtUtcMs != null) 'deleted_at_utc_ms': deletedAtUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? dosage,
    Value<String>? notes,
    Value<String>? shape,
    Value<String>? color,
    Value<int?>? quantity,
    Value<int?>? refillThreshold,
    Value<bool>? isDeleted,
    Value<int>? createdAtUtcMs,
    Value<int>? updatedAtUtcMs,
    Value<int?>? deletedAtUtcMs,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      shape: shape ?? this.shape,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAtUtcMs: createdAtUtcMs ?? this.createdAtUtcMs,
      updatedAtUtcMs: updatedAtUtcMs ?? this.updatedAtUtcMs,
      deletedAtUtcMs: deletedAtUtcMs ?? this.deletedAtUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (shape.present) {
      map['shape'] = Variable<String>(shape.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (refillThreshold.present) {
      map['refill_threshold'] = Variable<int>(refillThreshold.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAtUtcMs.present) {
      map['created_at_utc_ms'] = Variable<int>(createdAtUtcMs.value);
    }
    if (updatedAtUtcMs.present) {
      map['updated_at_utc_ms'] = Variable<int>(updatedAtUtcMs.value);
    }
    if (deletedAtUtcMs.present) {
      map['deleted_at_utc_ms'] = Variable<int>(deletedAtUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('notes: $notes, ')
          ..write('shape: $shape, ')
          ..write('color: $color, ')
          ..write('quantity: $quantity, ')
          ..write('refillThreshold: $refillThreshold, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAtUtcMs: $createdAtUtcMs, ')
          ..write('updatedAtUtcMs: $updatedAtUtcMs, ')
          ..write('deletedAtUtcMs: $deletedAtUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationTimesTable extends MedicationTimes
    with TableInfo<$MedicationTimesTable, MedicationTimeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationTimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [medicationId, minutes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_times';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationTimeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {medicationId, minutes};
  @override
  MedicationTimeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationTimeRow(
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
    );
  }

  @override
  $MedicationTimesTable createAlias(String alias) {
    return $MedicationTimesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class MedicationTimeRow extends DataClass
    implements Insertable<MedicationTimeRow> {
  final String medicationId;
  final int minutes;
  const MedicationTimeRow({required this.medicationId, required this.minutes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['medication_id'] = Variable<String>(medicationId);
    map['minutes'] = Variable<int>(minutes);
    return map;
  }

  MedicationTimesCompanion toCompanion(bool nullToAbsent) {
    return MedicationTimesCompanion(
      medicationId: Value(medicationId),
      minutes: Value(minutes),
    );
  }

  factory MedicationTimeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationTimeRow(
      medicationId: serializer.fromJson<String>(json['medicationId']),
      minutes: serializer.fromJson<int>(json['minutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'medicationId': serializer.toJson<String>(medicationId),
      'minutes': serializer.toJson<int>(minutes),
    };
  }

  MedicationTimeRow copyWith({String? medicationId, int? minutes}) =>
      MedicationTimeRow(
        medicationId: medicationId ?? this.medicationId,
        minutes: minutes ?? this.minutes,
      );
  MedicationTimeRow copyWithCompanion(MedicationTimesCompanion data) {
    return MedicationTimeRow(
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationTimeRow(')
          ..write('medicationId: $medicationId, ')
          ..write('minutes: $minutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(medicationId, minutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationTimeRow &&
          other.medicationId == this.medicationId &&
          other.minutes == this.minutes);
}

class MedicationTimesCompanion extends UpdateCompanion<MedicationTimeRow> {
  final Value<String> medicationId;
  final Value<int> minutes;
  final Value<int> rowid;
  const MedicationTimesCompanion({
    this.medicationId = const Value.absent(),
    this.minutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationTimesCompanion.insert({
    required String medicationId,
    required int minutes,
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId),
       minutes = Value(minutes);
  static Insertable<MedicationTimeRow> custom({
    Expression<String>? medicationId,
    Expression<int>? minutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (medicationId != null) 'medication_id': medicationId,
      if (minutes != null) 'minutes': minutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationTimesCompanion copyWith({
    Value<String>? medicationId,
    Value<int>? minutes,
    Value<int>? rowid,
  }) {
    return MedicationTimesCompanion(
      medicationId: medicationId ?? this.medicationId,
      minutes: minutes ?? this.minutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationTimesCompanion(')
          ..write('medicationId: $medicationId, ')
          ..write('minutes: $minutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationDaysTable extends MedicationDays
    with TableInfo<$MedicationDaysTable, MedicationDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [medicationId, weekday];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {medicationId, weekday};
  @override
  MedicationDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationDayRow(
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
    );
  }

  @override
  $MedicationDaysTable createAlias(String alias) {
    return $MedicationDaysTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class MedicationDayRow extends DataClass
    implements Insertable<MedicationDayRow> {
  final String medicationId;
  final int weekday;
  const MedicationDayRow({required this.medicationId, required this.weekday});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['medication_id'] = Variable<String>(medicationId);
    map['weekday'] = Variable<int>(weekday);
    return map;
  }

  MedicationDaysCompanion toCompanion(bool nullToAbsent) {
    return MedicationDaysCompanion(
      medicationId: Value(medicationId),
      weekday: Value(weekday),
    );
  }

  factory MedicationDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationDayRow(
      medicationId: serializer.fromJson<String>(json['medicationId']),
      weekday: serializer.fromJson<int>(json['weekday']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'medicationId': serializer.toJson<String>(medicationId),
      'weekday': serializer.toJson<int>(weekday),
    };
  }

  MedicationDayRow copyWith({String? medicationId, int? weekday}) =>
      MedicationDayRow(
        medicationId: medicationId ?? this.medicationId,
        weekday: weekday ?? this.weekday,
      );
  MedicationDayRow copyWithCompanion(MedicationDaysCompanion data) {
    return MedicationDayRow(
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationDayRow(')
          ..write('medicationId: $medicationId, ')
          ..write('weekday: $weekday')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(medicationId, weekday);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationDayRow &&
          other.medicationId == this.medicationId &&
          other.weekday == this.weekday);
}

class MedicationDaysCompanion extends UpdateCompanion<MedicationDayRow> {
  final Value<String> medicationId;
  final Value<int> weekday;
  final Value<int> rowid;
  const MedicationDaysCompanion({
    this.medicationId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationDaysCompanion.insert({
    required String medicationId,
    required int weekday,
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId),
       weekday = Value(weekday);
  static Insertable<MedicationDayRow> custom({
    Expression<String>? medicationId,
    Expression<int>? weekday,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (medicationId != null) 'medication_id': medicationId,
      if (weekday != null) 'weekday': weekday,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationDaysCompanion copyWith({
    Value<String>? medicationId,
    Value<int>? weekday,
    Value<int>? rowid,
  }) {
    return MedicationDaysCompanion(
      medicationId: medicationId ?? this.medicationId,
      weekday: weekday ?? this.weekday,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationDaysCompanion(')
          ..write('medicationId: $medicationId, ')
          ..write('weekday: $weekday, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoseEventsTable extends DoseEvents
    with TableInfo<$DoseEventsTable, DoseEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtUtcMsMeta = const VerificationMeta(
    'scheduledAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> scheduledAtUtcMs = GeneratedColumn<int>(
    'scheduled_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMsMeta = const VerificationMeta(
    'occurredAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> occurredAtUtcMs = GeneratedColumn<int>(
    'occurred_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    check: () => action.isIn(const ['taken', 'skipped', 'snoozed']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snoozeUntilUtcMsMeta = const VerificationMeta(
    'snoozeUntilUtcMs',
  );
  @override
  late final GeneratedColumn<int> snoozeUntilUtcMs = GeneratedColumn<int>(
    'snooze_until_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    medicationName,
    scheduledAtUtcMs,
    occurredAtUtcMs,
    action,
    snoozeUntilUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoseEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('scheduled_at_utc_ms')) {
      context.handle(
        _scheduledAtUtcMsMeta,
        scheduledAtUtcMs.isAcceptableOrUnknown(
          data['scheduled_at_utc_ms']!,
          _scheduledAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtUtcMsMeta);
    }
    if (data.containsKey('occurred_at_utc_ms')) {
      context.handle(
        _occurredAtUtcMsMeta,
        occurredAtUtcMs.isAcceptableOrUnknown(
          data['occurred_at_utc_ms']!,
          _occurredAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMsMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('snooze_until_utc_ms')) {
      context.handle(
        _snoozeUntilUtcMsMeta,
        snoozeUntilUtcMs.isAcceptableOrUnknown(
          data['snooze_until_utc_ms']!,
          _snoozeUntilUtcMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoseEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      scheduledAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at_utc_ms'],
      )!,
      occurredAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_utc_ms'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      snoozeUntilUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_until_utc_ms'],
      ),
    );
  }

  @override
  $DoseEventsTable createAlias(String alias) {
    return $DoseEventsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class DoseEventRow extends DataClass implements Insertable<DoseEventRow> {
  final String id;
  final String medicationId;
  final String medicationName;
  final int scheduledAtUtcMs;
  final int occurredAtUtcMs;
  final String action;
  final int? snoozeUntilUtcMs;
  const DoseEventRow({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledAtUtcMs,
    required this.occurredAtUtcMs,
    required this.action,
    this.snoozeUntilUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medication_id'] = Variable<String>(medicationId);
    map['medication_name'] = Variable<String>(medicationName);
    map['scheduled_at_utc_ms'] = Variable<int>(scheduledAtUtcMs);
    map['occurred_at_utc_ms'] = Variable<int>(occurredAtUtcMs);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || snoozeUntilUtcMs != null) {
      map['snooze_until_utc_ms'] = Variable<int>(snoozeUntilUtcMs);
    }
    return map;
  }

  DoseEventsCompanion toCompanion(bool nullToAbsent) {
    return DoseEventsCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      medicationName: Value(medicationName),
      scheduledAtUtcMs: Value(scheduledAtUtcMs),
      occurredAtUtcMs: Value(occurredAtUtcMs),
      action: Value(action),
      snoozeUntilUtcMs: snoozeUntilUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozeUntilUtcMs),
    );
  }

  factory DoseEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseEventRow(
      id: serializer.fromJson<String>(json['id']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      scheduledAtUtcMs: serializer.fromJson<int>(json['scheduledAtUtcMs']),
      occurredAtUtcMs: serializer.fromJson<int>(json['occurredAtUtcMs']),
      action: serializer.fromJson<String>(json['action']),
      snoozeUntilUtcMs: serializer.fromJson<int?>(json['snoozeUntilUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicationId': serializer.toJson<String>(medicationId),
      'medicationName': serializer.toJson<String>(medicationName),
      'scheduledAtUtcMs': serializer.toJson<int>(scheduledAtUtcMs),
      'occurredAtUtcMs': serializer.toJson<int>(occurredAtUtcMs),
      'action': serializer.toJson<String>(action),
      'snoozeUntilUtcMs': serializer.toJson<int?>(snoozeUntilUtcMs),
    };
  }

  DoseEventRow copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    int? scheduledAtUtcMs,
    int? occurredAtUtcMs,
    String? action,
    Value<int?> snoozeUntilUtcMs = const Value.absent(),
  }) => DoseEventRow(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    medicationName: medicationName ?? this.medicationName,
    scheduledAtUtcMs: scheduledAtUtcMs ?? this.scheduledAtUtcMs,
    occurredAtUtcMs: occurredAtUtcMs ?? this.occurredAtUtcMs,
    action: action ?? this.action,
    snoozeUntilUtcMs: snoozeUntilUtcMs.present
        ? snoozeUntilUtcMs.value
        : this.snoozeUntilUtcMs,
  );
  DoseEventRow copyWithCompanion(DoseEventsCompanion data) {
    return DoseEventRow(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      scheduledAtUtcMs: data.scheduledAtUtcMs.present
          ? data.scheduledAtUtcMs.value
          : this.scheduledAtUtcMs,
      occurredAtUtcMs: data.occurredAtUtcMs.present
          ? data.occurredAtUtcMs.value
          : this.occurredAtUtcMs,
      action: data.action.present ? data.action.value : this.action,
      snoozeUntilUtcMs: data.snoozeUntilUtcMs.present
          ? data.snoozeUntilUtcMs.value
          : this.snoozeUntilUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseEventRow(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('medicationName: $medicationName, ')
          ..write('scheduledAtUtcMs: $scheduledAtUtcMs, ')
          ..write('occurredAtUtcMs: $occurredAtUtcMs, ')
          ..write('action: $action, ')
          ..write('snoozeUntilUtcMs: $snoozeUntilUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    medicationName,
    scheduledAtUtcMs,
    occurredAtUtcMs,
    action,
    snoozeUntilUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseEventRow &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.medicationName == this.medicationName &&
          other.scheduledAtUtcMs == this.scheduledAtUtcMs &&
          other.occurredAtUtcMs == this.occurredAtUtcMs &&
          other.action == this.action &&
          other.snoozeUntilUtcMs == this.snoozeUntilUtcMs);
}

class DoseEventsCompanion extends UpdateCompanion<DoseEventRow> {
  final Value<String> id;
  final Value<String> medicationId;
  final Value<String> medicationName;
  final Value<int> scheduledAtUtcMs;
  final Value<int> occurredAtUtcMs;
  final Value<String> action;
  final Value<int?> snoozeUntilUtcMs;
  final Value<int> rowid;
  const DoseEventsCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.scheduledAtUtcMs = const Value.absent(),
    this.occurredAtUtcMs = const Value.absent(),
    this.action = const Value.absent(),
    this.snoozeUntilUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoseEventsCompanion.insert({
    required String id,
    required String medicationId,
    required String medicationName,
    required int scheduledAtUtcMs,
    required int occurredAtUtcMs,
    required String action,
    this.snoozeUntilUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicationId = Value(medicationId),
       medicationName = Value(medicationName),
       scheduledAtUtcMs = Value(scheduledAtUtcMs),
       occurredAtUtcMs = Value(occurredAtUtcMs),
       action = Value(action);
  static Insertable<DoseEventRow> custom({
    Expression<String>? id,
    Expression<String>? medicationId,
    Expression<String>? medicationName,
    Expression<int>? scheduledAtUtcMs,
    Expression<int>? occurredAtUtcMs,
    Expression<String>? action,
    Expression<int>? snoozeUntilUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (medicationName != null) 'medication_name': medicationName,
      if (scheduledAtUtcMs != null) 'scheduled_at_utc_ms': scheduledAtUtcMs,
      if (occurredAtUtcMs != null) 'occurred_at_utc_ms': occurredAtUtcMs,
      if (action != null) 'action': action,
      if (snoozeUntilUtcMs != null) 'snooze_until_utc_ms': snoozeUntilUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoseEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? medicationId,
    Value<String>? medicationName,
    Value<int>? scheduledAtUtcMs,
    Value<int>? occurredAtUtcMs,
    Value<String>? action,
    Value<int?>? snoozeUntilUtcMs,
    Value<int>? rowid,
  }) {
    return DoseEventsCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      scheduledAtUtcMs: scheduledAtUtcMs ?? this.scheduledAtUtcMs,
      occurredAtUtcMs: occurredAtUtcMs ?? this.occurredAtUtcMs,
      action: action ?? this.action,
      snoozeUntilUtcMs: snoozeUntilUtcMs ?? this.snoozeUntilUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (scheduledAtUtcMs.present) {
      map['scheduled_at_utc_ms'] = Variable<int>(scheduledAtUtcMs.value);
    }
    if (occurredAtUtcMs.present) {
      map['occurred_at_utc_ms'] = Variable<int>(occurredAtUtcMs.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (snoozeUntilUtcMs.present) {
      map['snooze_until_utc_ms'] = Variable<int>(snoozeUntilUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseEventsCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('medicationName: $medicationName, ')
          ..write('scheduledAtUtcMs: $scheduledAtUtcMs, ')
          ..write('occurredAtUtcMs: $occurredAtUtcMs, ')
          ..write('action: $action, ')
          ..write('snoozeUntilUtcMs: $snoozeUntilUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<bool> sound = GeneratedColumn<bool>(
    'sound',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound" IN (0, 1))',
    ),
  );
  static const VerificationMeta _vibrationMeta = const VerificationMeta(
    'vibration',
  );
  @override
  late final GeneratedColumn<bool> vibration = GeneratedColumn<bool>(
    'vibration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration" IN (0, 1))',
    ),
  );
  static const VerificationMeta _bannersMeta = const VerificationMeta(
    'banners',
  );
  @override
  late final GeneratedColumn<bool> banners = GeneratedColumn<bool>(
    'banners',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("banners" IN (0, 1))',
    ),
  );
  static const VerificationMeta _snoozeMinutesMeta = const VerificationMeta(
    'snoozeMinutes',
  );
  @override
  late final GeneratedColumn<int> snoozeMinutes = GeneratedColumn<int>(
    'snooze_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sound,
    vibration,
    banners,
    snoozeMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    } else if (isInserting) {
      context.missing(_soundMeta);
    }
    if (data.containsKey('vibration')) {
      context.handle(
        _vibrationMeta,
        vibration.isAcceptableOrUnknown(data['vibration']!, _vibrationMeta),
      );
    } else if (isInserting) {
      context.missing(_vibrationMeta);
    }
    if (data.containsKey('banners')) {
      context.handle(
        _bannersMeta,
        banners.isAcceptableOrUnknown(data['banners']!, _bannersMeta),
      );
    } else if (isInserting) {
      context.missing(_bannersMeta);
    }
    if (data.containsKey('snooze_minutes')) {
      context.handle(
        _snoozeMinutesMeta,
        snoozeMinutes.isAcceptableOrUnknown(
          data['snooze_minutes']!,
          _snoozeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snoozeMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound'],
      )!,
      vibration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration'],
      )!,
      banners: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}banners'],
      )!,
      snoozeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_minutes'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int id;
  final bool sound;
  final bool vibration;
  final bool banners;
  final int snoozeMinutes;
  const SettingsRow({
    required this.id,
    required this.sound,
    required this.vibration,
    required this.banners,
    required this.snoozeMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sound'] = Variable<bool>(sound);
    map['vibration'] = Variable<bool>(vibration);
    map['banners'] = Variable<bool>(banners);
    map['snooze_minutes'] = Variable<int>(snoozeMinutes);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      sound: Value(sound),
      vibration: Value(vibration),
      banners: Value(banners),
      snoozeMinutes: Value(snoozeMinutes),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      sound: serializer.fromJson<bool>(json['sound']),
      vibration: serializer.fromJson<bool>(json['vibration']),
      banners: serializer.fromJson<bool>(json['banners']),
      snoozeMinutes: serializer.fromJson<int>(json['snoozeMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sound': serializer.toJson<bool>(sound),
      'vibration': serializer.toJson<bool>(vibration),
      'banners': serializer.toJson<bool>(banners),
      'snoozeMinutes': serializer.toJson<int>(snoozeMinutes),
    };
  }

  SettingsRow copyWith({
    int? id,
    bool? sound,
    bool? vibration,
    bool? banners,
    int? snoozeMinutes,
  }) => SettingsRow(
    id: id ?? this.id,
    sound: sound ?? this.sound,
    vibration: vibration ?? this.vibration,
    banners: banners ?? this.banners,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
  );
  SettingsRow copyWithCompanion(SettingsCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      sound: data.sound.present ? data.sound.value : this.sound,
      vibration: data.vibration.present ? data.vibration.value : this.vibration,
      banners: data.banners.present ? data.banners.value : this.banners,
      snoozeMinutes: data.snoozeMinutes.present
          ? data.snoozeMinutes.value
          : this.snoozeMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('sound: $sound, ')
          ..write('vibration: $vibration, ')
          ..write('banners: $banners, ')
          ..write('snoozeMinutes: $snoozeMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sound, vibration, banners, snoozeMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.sound == this.sound &&
          other.vibration == this.vibration &&
          other.banners == this.banners &&
          other.snoozeMinutes == this.snoozeMinutes);
}

class SettingsCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<bool> sound;
  final Value<bool> vibration;
  final Value<bool> banners;
  final Value<int> snoozeMinutes;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.sound = const Value.absent(),
    this.vibration = const Value.absent(),
    this.banners = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required bool sound,
    required bool vibration,
    required bool banners,
    required int snoozeMinutes,
  }) : sound = Value(sound),
       vibration = Value(vibration),
       banners = Value(banners),
       snoozeMinutes = Value(snoozeMinutes);
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<bool>? sound,
    Expression<bool>? vibration,
    Expression<bool>? banners,
    Expression<int>? snoozeMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sound != null) 'sound': sound,
      if (vibration != null) 'vibration': vibration,
      if (banners != null) 'banners': banners,
      if (snoozeMinutes != null) 'snooze_minutes': snoozeMinutes,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? sound,
    Value<bool>? vibration,
    Value<bool>? banners,
    Value<int>? snoozeMinutes,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      banners: banners ?? this.banners,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sound.present) {
      map['sound'] = Variable<bool>(sound.value);
    }
    if (vibration.present) {
      map['vibration'] = Variable<bool>(vibration.value);
    }
    if (banners.present) {
      map['banners'] = Variable<bool>(banners.value);
    }
    if (snoozeMinutes.present) {
      map['snooze_minutes'] = Variable<int>(snoozeMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('sound: $sound, ')
          ..write('vibration: $vibration, ')
          ..write('banners: $banners, ')
          ..write('snoozeMinutes: $snoozeMinutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MetadataTable metadata = $MetadataTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $MedicationTimesTable medicationTimes = $MedicationTimesTable(
    this,
  );
  late final $MedicationDaysTable medicationDays = $MedicationDaysTable(this);
  late final $DoseEventsTable doseEvents = $DoseEventsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    metadata,
    medications,
    medicationTimes,
    medicationDays,
    doseEvents,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medication_times', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medication_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dose_events', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MetadataTableCreateCompanionBuilder = MetadataCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetadataTableUpdateCompanionBuilder = MetadataCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetadataTableFilterComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableFilterComposer({
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

class $$MetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableOrderingComposer({
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

class $$MetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetadataTable> {
  $$MetadataTableAnnotationComposer({
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

class $$MetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetadataTable,
          MetadataRow,
          $$MetadataTableFilterComposer,
          $$MetadataTableOrderingComposer,
          $$MetadataTableAnnotationComposer,
          $$MetadataTableCreateCompanionBuilder,
          $$MetadataTableUpdateCompanionBuilder,
          (
            MetadataRow,
            BaseReferences<_$AppDatabase, $MetadataTable, MetadataRow>,
          ),
          MetadataRow,
          PrefetchHooks Function()
        > {
  $$MetadataTableTableManager(_$AppDatabase db, $MetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => MetadataCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetadataTable, MetadataRow>(table),
                  BaseReferences<_$AppDatabase, $MetadataTable, MetadataRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetadataTable,
      MetadataRow,
      $$MetadataTableFilterComposer,
      $$MetadataTableOrderingComposer,
      $$MetadataTableAnnotationComposer,
      $$MetadataTableCreateCompanionBuilder,
      $$MetadataTableUpdateCompanionBuilder,
      (MetadataRow, BaseReferences<_$AppDatabase, $MetadataTable, MetadataRow>),
      MetadataRow,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      required String name,
      required String dosage,
      Value<String> notes,
      required String shape,
      required String color,
      Value<int?> quantity,
      Value<int?> refillThreshold,
      Value<bool> isDeleted,
      required int createdAtUtcMs,
      required int updatedAtUtcMs,
      Value<int?> deletedAtUtcMs,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> dosage,
      Value<String> notes,
      Value<String> shape,
      Value<String> color,
      Value<int?> quantity,
      Value<int?> refillThreshold,
      Value<bool> isDeleted,
      Value<int> createdAtUtcMs,
      Value<int> updatedAtUtcMs,
      Value<int?> deletedAtUtcMs,
      Value<int> rowid,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, MedicationRow> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicationTimesTable, List<MedicationTimeRow>>
  _medicationTimesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicationTimes,
    aliasName: 'medications__id__medication_times__medication_id',
  );

  $$MedicationTimesTableProcessedTableManager get medicationTimesRefs {
    final manager = $$MedicationTimesTableTableManager(
      $_db,
      $_db.medicationTimes,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationTimesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MedicationDaysTable, List<MedicationDayRow>>
  _medicationDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicationDays,
    aliasName: 'medications__id__medication_days__medication_id',
  );

  $$MedicationDaysTableProcessedTableManager get medicationDaysRefs {
    final manager = $$MedicationDaysTableTableManager(
      $_db,
      $_db.medicationDays,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DoseEventsTable, List<DoseEventRow>>
  _doseEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.doseEvents,
    aliasName: 'medications__id__dose_events__medication_id',
  );

  $$DoseEventsTableProcessedTableManager get doseEventsRefs {
    final manager = $$DoseEventsTableTableManager(
      $_db,
      $_db.doseEvents,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_doseEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refillThreshold => $composableBuilder(
    column: $table.refillThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtUtcMs => $composableBuilder(
    column: $table.deletedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicationTimesRefs(
    Expression<bool> Function($$MedicationTimesTableFilterComposer f) f,
  ) {
    final $$MedicationTimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationTimes,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationTimesTableFilterComposer(
            $db: $db,
            $table: $db.medicationTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicationDaysRefs(
    Expression<bool> Function($$MedicationDaysTableFilterComposer f) f,
  ) {
    final $$MedicationDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationDays,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationDaysTableFilterComposer(
            $db: $db,
            $table: $db.medicationDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> doseEventsRefs(
    Expression<bool> Function($$DoseEventsTableFilterComposer f) f,
  ) {
    final $$DoseEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseEvents,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseEventsTableFilterComposer(
            $db: $db,
            $table: $db.doseEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refillThreshold => $composableBuilder(
    column: $table.refillThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtUtcMs => $composableBuilder(
    column: $table.deletedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get shape =>
      $composableBuilder(column: $table.shape, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get refillThreshold => $composableBuilder(
    column: $table.refillThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get createdAtUtcMs => $composableBuilder(
    column: $table.createdAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtUtcMs => $composableBuilder(
    column: $table.updatedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtUtcMs => $composableBuilder(
    column: $table.deletedAtUtcMs,
    builder: (column) => column,
  );

  Expression<T> medicationTimesRefs<T extends Object>(
    Expression<T> Function($$MedicationTimesTableAnnotationComposer a) f,
  ) {
    final $$MedicationTimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationTimes,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationTimesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> medicationDaysRefs<T extends Object>(
    Expression<T> Function($$MedicationDaysTableAnnotationComposer a) f,
  ) {
    final $$MedicationDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationDays,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> doseEventsRefs<T extends Object>(
    Expression<T> Function($$DoseEventsTableAnnotationComposer a) f,
  ) {
    final $$DoseEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseEvents,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.doseEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          MedicationRow,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (MedicationRow, $$MedicationsTableReferences),
          MedicationRow,
          PrefetchHooks Function({
            bool medicationTimesRefs,
            bool medicationDaysRefs,
            bool doseEventsRefs,
          })
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> shape = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int?> quantity = const Value.absent(),
                Value<int?> refillThreshold = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> createdAtUtcMs = const Value.absent(),
                Value<int> updatedAtUtcMs = const Value.absent(),
                Value<int?> deletedAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                dosage: dosage,
                notes: notes,
                shape: shape,
                color: color,
                quantity: quantity,
                refillThreshold: refillThreshold,
                isDeleted: isDeleted,
                createdAtUtcMs: createdAtUtcMs,
                updatedAtUtcMs: updatedAtUtcMs,
                deletedAtUtcMs: deletedAtUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String dosage,
                Value<String> notes = const Value.absent(),
                required String shape,
                required String color,
                Value<int?> quantity = const Value.absent(),
                Value<int?> refillThreshold = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required int createdAtUtcMs,
                required int updatedAtUtcMs,
                Value<int?> deletedAtUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                dosage: dosage,
                notes: notes,
                shape: shape,
                color: color,
                quantity: quantity,
                refillThreshold: refillThreshold,
                isDeleted: isDeleted,
                createdAtUtcMs: createdAtUtcMs,
                updatedAtUtcMs: updatedAtUtcMs,
                deletedAtUtcMs: deletedAtUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicationsTable, MedicationRow>(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicationTimesRefs = false,
                medicationDaysRefs = false,
                doseEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicationTimesRefs) db.medicationTimes,
                    if (medicationDaysRefs) db.medicationDays,
                    if (doseEventsRefs) db.doseEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicationTimesRefs)
                        await $_getPrefetchedData<
                          MedicationRow,
                          $MedicationsTable,
                          MedicationTimeRow
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._medicationTimesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationTimesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicationDaysRefs)
                        await $_getPrefetchedData<
                          MedicationRow,
                          $MedicationsTable,
                          MedicationDayRow
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._medicationDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (doseEventsRefs)
                        await $_getPrefetchedData<
                          MedicationRow,
                          $MedicationsTable,
                          DoseEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._doseEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).doseEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
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

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      MedicationRow,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (MedicationRow, $$MedicationsTableReferences),
      MedicationRow,
      PrefetchHooks Function({
        bool medicationTimesRefs,
        bool medicationDaysRefs,
        bool doseEventsRefs,
      })
    >;
typedef $$MedicationTimesTableCreateCompanionBuilder =
    MedicationTimesCompanion Function({
      required String medicationId,
      required int minutes,
      Value<int> rowid,
    });
typedef $$MedicationTimesTableUpdateCompanionBuilder =
    MedicationTimesCompanion Function({
      Value<String> medicationId,
      Value<int> minutes,
      Value<int> rowid,
    });

final class $$MedicationTimesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicationTimesTable,
          MedicationTimeRow
        > {
  $$MedicationTimesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) => db
      .medications
      .createAlias('medication_times__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationTimesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationTimesTable> {
  $$MedicationTimesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationTimesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationTimesTable> {
  $$MedicationTimesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationTimesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationTimesTable> {
  $$MedicationTimesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationTimesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationTimesTable,
          MedicationTimeRow,
          $$MedicationTimesTableFilterComposer,
          $$MedicationTimesTableOrderingComposer,
          $$MedicationTimesTableAnnotationComposer,
          $$MedicationTimesTableCreateCompanionBuilder,
          $$MedicationTimesTableUpdateCompanionBuilder,
          (MedicationTimeRow, $$MedicationTimesTableReferences),
          MedicationTimeRow,
          PrefetchHooks Function({bool medicationId})
        > {
  $$MedicationTimesTableTableManager(
    _$AppDatabase db,
    $MedicationTimesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationTimesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationTimesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationTimesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> medicationId = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationTimesCompanion(
                medicationId: medicationId,
                minutes: minutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String medicationId,
                required int minutes,
                Value<int> rowid = const Value.absent(),
              }) => MedicationTimesCompanion.insert(
                medicationId: medicationId,
                minutes: minutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicationTimesTable, MedicationTimeRow>(table),
                  $$MedicationTimesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
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
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$MedicationTimesTableReferences
                            ._medicationIdTable(db),
                        referencedColumn: $$MedicationTimesTableReferences
                            ._medicationIdTable(db)
                            .id,
                      ) as T;
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

typedef $$MedicationTimesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationTimesTable,
      MedicationTimeRow,
      $$MedicationTimesTableFilterComposer,
      $$MedicationTimesTableOrderingComposer,
      $$MedicationTimesTableAnnotationComposer,
      $$MedicationTimesTableCreateCompanionBuilder,
      $$MedicationTimesTableUpdateCompanionBuilder,
      (MedicationTimeRow, $$MedicationTimesTableReferences),
      MedicationTimeRow,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$MedicationDaysTableCreateCompanionBuilder =
    MedicationDaysCompanion Function({
      required String medicationId,
      required int weekday,
      Value<int> rowid,
    });
typedef $$MedicationDaysTableUpdateCompanionBuilder =
    MedicationDaysCompanion Function({
      Value<String> medicationId,
      Value<int> weekday,
      Value<int> rowid,
    });

final class $$MedicationDaysTableReferences
    extends
        BaseReferences<_$AppDatabase, $MedicationDaysTable, MedicationDayRow> {
  $$MedicationDaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) => db
      .medications
      .createAlias('medication_days__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationDaysTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationDaysTable> {
  $$MedicationDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationDaysTable> {
  $$MedicationDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationDaysTable> {
  $$MedicationDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationDaysTable,
          MedicationDayRow,
          $$MedicationDaysTableFilterComposer,
          $$MedicationDaysTableOrderingComposer,
          $$MedicationDaysTableAnnotationComposer,
          $$MedicationDaysTableCreateCompanionBuilder,
          $$MedicationDaysTableUpdateCompanionBuilder,
          (MedicationDayRow, $$MedicationDaysTableReferences),
          MedicationDayRow,
          PrefetchHooks Function({bool medicationId})
        > {
  $$MedicationDaysTableTableManager(
    _$AppDatabase db,
    $MedicationDaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> medicationId = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationDaysCompanion(
                medicationId: medicationId,
                weekday: weekday,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String medicationId,
                required int weekday,
                Value<int> rowid = const Value.absent(),
              }) => MedicationDaysCompanion.insert(
                medicationId: medicationId,
                weekday: weekday,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicationDaysTable, MedicationDayRow>(table),
                  $$MedicationDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
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
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$MedicationDaysTableReferences
                            ._medicationIdTable(db),
                        referencedColumn: $$MedicationDaysTableReferences
                            ._medicationIdTable(db)
                            .id,
                      ) as T;
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

typedef $$MedicationDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationDaysTable,
      MedicationDayRow,
      $$MedicationDaysTableFilterComposer,
      $$MedicationDaysTableOrderingComposer,
      $$MedicationDaysTableAnnotationComposer,
      $$MedicationDaysTableCreateCompanionBuilder,
      $$MedicationDaysTableUpdateCompanionBuilder,
      (MedicationDayRow, $$MedicationDaysTableReferences),
      MedicationDayRow,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$DoseEventsTableCreateCompanionBuilder = DoseEventsCompanion Function({
  required String id,
  required String medicationId,
  required String medicationName,
  required int scheduledAtUtcMs,
  required int occurredAtUtcMs,
  required String action,
  Value<int?> snoozeUntilUtcMs,
  Value<int> rowid,
});
typedef $$DoseEventsTableUpdateCompanionBuilder = DoseEventsCompanion Function({
  Value<String> id,
  Value<String> medicationId,
  Value<String> medicationName,
  Value<int> scheduledAtUtcMs,
  Value<int> occurredAtUtcMs,
  Value<String> action,
  Value<int?> snoozeUntilUtcMs,
  Value<int> rowid,
});

final class $$DoseEventsTableReferences
    extends BaseReferences<_$AppDatabase, $DoseEventsTable, DoseEventRow> {
  $$DoseEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias('dose_events__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DoseEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DoseEventsTable> {
  $$DoseEventsTableFilterComposer({
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

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAtUtcMs => $composableBuilder(
    column: $table.scheduledAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAtUtcMs => $composableBuilder(
    column: $table.occurredAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeUntilUtcMs => $composableBuilder(
    column: $table.snoozeUntilUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseEventsTable> {
  $$DoseEventsTableOrderingComposer({
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

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAtUtcMs => $composableBuilder(
    column: $table.scheduledAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtUtcMs => $composableBuilder(
    column: $table.occurredAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeUntilUtcMs => $composableBuilder(
    column: $table.snoozeUntilUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseEventsTable> {
  $$DoseEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledAtUtcMs => $composableBuilder(
    column: $table.scheduledAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAtUtcMs => $composableBuilder(
    column: $table.occurredAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get snoozeUntilUtcMs => $composableBuilder(
    column: $table.snoozeUntilUtcMs,
    builder: (column) => column,
  );

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoseEventsTable,
          DoseEventRow,
          $$DoseEventsTableFilterComposer,
          $$DoseEventsTableOrderingComposer,
          $$DoseEventsTableAnnotationComposer,
          $$DoseEventsTableCreateCompanionBuilder,
          $$DoseEventsTableUpdateCompanionBuilder,
          (DoseEventRow, $$DoseEventsTableReferences),
          DoseEventRow,
          PrefetchHooks Function({bool medicationId})
        > {
  $$DoseEventsTableTableManager(_$AppDatabase db, $DoseEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoseEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoseEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoseEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<int> scheduledAtUtcMs = const Value.absent(),
                Value<int> occurredAtUtcMs = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int?> snoozeUntilUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoseEventsCompanion(
                id: id,
                medicationId: medicationId,
                medicationName: medicationName,
                scheduledAtUtcMs: scheduledAtUtcMs,
                occurredAtUtcMs: occurredAtUtcMs,
                action: action,
                snoozeUntilUtcMs: snoozeUntilUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicationId,
                required String medicationName,
                required int scheduledAtUtcMs,
                required int occurredAtUtcMs,
                required String action,
                Value<int?> snoozeUntilUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoseEventsCompanion.insert(
                id: id,
                medicationId: medicationId,
                medicationName: medicationName,
                scheduledAtUtcMs: scheduledAtUtcMs,
                occurredAtUtcMs: occurredAtUtcMs,
                action: action,
                snoozeUntilUtcMs: snoozeUntilUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DoseEventsTable, DoseEventRow>(table),
                  $$DoseEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
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
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$DoseEventsTableReferences
                            ._medicationIdTable(db),
                        referencedColumn: $$DoseEventsTableReferences
                            ._medicationIdTable(db)
                            .id,
                      ) as T;
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

typedef $$DoseEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoseEventsTable,
      DoseEventRow,
      $$DoseEventsTableFilterComposer,
      $$DoseEventsTableOrderingComposer,
      $$DoseEventsTableAnnotationComposer,
      $$DoseEventsTableCreateCompanionBuilder,
      $$DoseEventsTableUpdateCompanionBuilder,
      (DoseEventRow, $$DoseEventsTableReferences),
      DoseEventRow,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  required bool sound,
  required bool vibration,
  required bool banners,
  required int snoozeMinutes,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> sound,
  Value<bool> vibration,
  Value<bool> banners,
  Value<int> snoozeMinutes,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

  ColumnFilters<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get banners => $composableBuilder(
    column: $table.banners,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get banners => $composableBuilder(
    column: $table.banners,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<bool> get vibration =>
      $composableBuilder(column: $table.vibration, builder: (column) => column);

  GeneratedColumn<bool> get banners =>
      $composableBuilder(column: $table.banners, builder: (column) => column);

  GeneratedColumn<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingsRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> sound = const Value.absent(),
                Value<bool> vibration = const Value.absent(),
                Value<bool> banners = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                sound: sound,
                vibration: vibration,
                banners: banners,
                snoozeMinutes: snoozeMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool sound,
                required bool vibration,
                required bool banners,
                required int snoozeMinutes,
              }) => SettingsCompanion.insert(
                id: id,
                sound: sound,
                vibration: vibration,
                banners: banners,
                snoozeMinutes: snoozeMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingsRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingsRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingsRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingsRow>),
      SettingsRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MetadataTableTableManager get metadata =>
      $$MetadataTableTableManager(_db, _db.metadata);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$MedicationTimesTableTableManager get medicationTimes =>
      $$MedicationTimesTableTableManager(_db, _db.medicationTimes);
  $$MedicationDaysTableTableManager get medicationDays =>
      $$MedicationDaysTableTableManager(_db, _db.medicationDays);
  $$DoseEventsTableTableManager get doseEvents =>
      $$DoseEventsTableTableManager(_db, _db.doseEvents);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
