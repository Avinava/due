// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CommitmentsTable extends Commitments with TableInfo<$CommitmentsTable, CommitmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitmentsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String> cadence = GeneratedColumn<String>(
    'cadence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, Object?>>($CommitmentsTable.$convertercadence);
  static const VerificationMeta _autopayMeta = const VerificationMeta('autopay');
  @override
  late final GeneratedColumn<bool> autopay = GeneratedColumn<bool>(
    'autopay',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("autopay" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DateTime>($CommitmentsTable.$convertercreatedAt);
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, amount, cadence, autopay, createdAt, archived, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commitments';
  @override
  VerificationContext validateIntegrity(Insertable<CommitmentRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('autopay')) {
      context.handle(_autopayMeta, autopay.isAcceptableOrUnknown(data['autopay']!, _autopayMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommitmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommitmentRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      cadence: $CommitmentsTable.$convertercadence.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cadence'])!,
      ),
      autopay: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}autopay'])!,
      createdAt: $CommitmentsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      ),
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $CommitmentsTable createAlias(String alias) {
    return $CommitmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, Object?>, String> $convertercadence = const JsonMapConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt = const DateConverter();
}

class CommitmentRow extends DataClass implements Insertable<CommitmentRow> {
  final String id;
  final String name;
  final int amount;
  final Map<String, Object?> cadence;
  final bool autopay;
  final DateTime createdAt;
  final bool archived;
  final int position;
  const CommitmentRow({
    required this.id,
    required this.name,
    required this.amount,
    required this.cadence,
    required this.autopay,
    required this.createdAt,
    required this.archived,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<int>(amount);
    {
      map['cadence'] = Variable<String>($CommitmentsTable.$convertercadence.toSql(cadence));
    }
    map['autopay'] = Variable<bool>(autopay);
    {
      map['created_at'] = Variable<String>($CommitmentsTable.$convertercreatedAt.toSql(createdAt));
    }
    map['archived'] = Variable<bool>(archived);
    map['position'] = Variable<int>(position);
    return map;
  }

  CommitmentsCompanion toCompanion(bool nullToAbsent) {
    return CommitmentsCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      cadence: Value(cadence),
      autopay: Value(autopay),
      createdAt: Value(createdAt),
      archived: Value(archived),
      position: Value(position),
    );
  }

  factory CommitmentRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommitmentRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<int>(json['amount']),
      cadence: serializer.fromJson<Map<String, Object?>>(json['cadence']),
      autopay: serializer.fromJson<bool>(json['autopay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archived: serializer.fromJson<bool>(json['archived']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<int>(amount),
      'cadence': serializer.toJson<Map<String, Object?>>(cadence),
      'autopay': serializer.toJson<bool>(autopay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archived': serializer.toJson<bool>(archived),
      'position': serializer.toJson<int>(position),
    };
  }

  CommitmentRow copyWith({
    String? id,
    String? name,
    int? amount,
    Map<String, Object?>? cadence,
    bool? autopay,
    DateTime? createdAt,
    bool? archived,
    int? position,
  }) => CommitmentRow(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    cadence: cadence ?? this.cadence,
    autopay: autopay ?? this.autopay,
    createdAt: createdAt ?? this.createdAt,
    archived: archived ?? this.archived,
    position: position ?? this.position,
  );
  CommitmentRow copyWithCompanion(CommitmentsCompanion data) {
    return CommitmentRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      autopay: data.autopay.present ? data.autopay.value : this.autopay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archived: data.archived.present ? data.archived.value : this.archived,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommitmentRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('cadence: $cadence, ')
          ..write('autopay: $autopay, ')
          ..write('createdAt: $createdAt, ')
          ..write('archived: $archived, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, amount, cadence, autopay, createdAt, archived, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommitmentRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.cadence == this.cadence &&
          other.autopay == this.autopay &&
          other.createdAt == this.createdAt &&
          other.archived == this.archived &&
          other.position == this.position);
}

class CommitmentsCompanion extends UpdateCompanion<CommitmentRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> amount;
  final Value<Map<String, Object?>> cadence;
  final Value<bool> autopay;
  final Value<DateTime> createdAt;
  final Value<bool> archived;
  final Value<int> position;
  final Value<int> rowid;
  const CommitmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.cadence = const Value.absent(),
    this.autopay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommitmentsCompanion.insert({
    required String id,
    required String name,
    required int amount,
    required Map<String, Object?> cadence,
    this.autopay = const Value.absent(),
    required DateTime createdAt,
    this.archived = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       amount = Value(amount),
       cadence = Value(cadence),
       createdAt = Value(createdAt),
       position = Value(position);
  static Insertable<CommitmentRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? amount,
    Expression<String>? cadence,
    Expression<bool>? autopay,
    Expression<String>? createdAt,
    Expression<bool>? archived,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (cadence != null) 'cadence': cadence,
      if (autopay != null) 'autopay': autopay,
      if (createdAt != null) 'created_at': createdAt,
      if (archived != null) 'archived': archived,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommitmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? amount,
    Value<Map<String, Object?>>? cadence,
    Value<bool>? autopay,
    Value<DateTime>? createdAt,
    Value<bool>? archived,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return CommitmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      cadence: cadence ?? this.cadence,
      autopay: autopay ?? this.autopay,
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
      position: position ?? this.position,
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
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<String>($CommitmentsTable.$convertercadence.toSql(cadence.value));
    }
    if (autopay.present) {
      map['autopay'] = Variable<bool>(autopay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>($CommitmentsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('cadence: $cadence, ')
          ..write('autopay: $autopay, ')
          ..write('createdAt: $createdAt, ')
          ..write('archived: $archived, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _commitmentIdMeta = const VerificationMeta('commitmentId');
  @override
  late final GeneratedColumn<String> commitmentId = GeneratedColumn<String>(
    'commitment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES commitments (id) ON DELETE CASCADE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DateTime>($PaymentsTable.$converterdueDate);
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [commitmentId, dueDate, paidAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('commitment_id')) {
      context.handle(_commitmentIdMeta, commitmentId.isAcceptableOrUnknown(data['commitment_id']!, _commitmentIdMeta));
    } else if (isInserting) {
      context.missing(_commitmentIdMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(_paidAtMeta, paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta));
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {commitmentId, dueDate};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      commitmentId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}commitment_id'])!,
      dueDate: $PaymentsTable.$converterdueDate.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}due_date'])!,
      ),
      paidAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}paid_at'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdueDate = const DateConverter();
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String commitmentId;
  final DateTime dueDate;
  final DateTime paidAt;
  const PaymentRow({required this.commitmentId, required this.dueDate, required this.paidAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['commitment_id'] = Variable<String>(commitmentId);
    {
      map['due_date'] = Variable<String>($PaymentsTable.$converterdueDate.toSql(dueDate));
    }
    map['paid_at'] = Variable<DateTime>(paidAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(commitmentId: Value(commitmentId), dueDate: Value(dueDate), paidAt: Value(paidAt));
  }

  factory PaymentRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      commitmentId: serializer.fromJson<String>(json['commitmentId']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'commitmentId': serializer.toJson<String>(commitmentId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'paidAt': serializer.toJson<DateTime>(paidAt),
    };
  }

  PaymentRow copyWith({String? commitmentId, DateTime? dueDate, DateTime? paidAt}) => PaymentRow(
    commitmentId: commitmentId ?? this.commitmentId,
    dueDate: dueDate ?? this.dueDate,
    paidAt: paidAt ?? this.paidAt,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      commitmentId: data.commitmentId.present ? data.commitmentId.value : this.commitmentId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('commitmentId: $commitmentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(commitmentId, dueDate, paidAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.commitmentId == this.commitmentId &&
          other.dueDate == this.dueDate &&
          other.paidAt == this.paidAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> commitmentId;
  final Value<DateTime> dueDate;
  final Value<DateTime> paidAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.commitmentId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String commitmentId,
    required DateTime dueDate,
    required DateTime paidAt,
    this.rowid = const Value.absent(),
  }) : commitmentId = Value(commitmentId),
       dueDate = Value(dueDate),
       paidAt = Value(paidAt);
  static Insertable<PaymentRow> custom({
    Expression<String>? commitmentId,
    Expression<String>? dueDate,
    Expression<DateTime>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (commitmentId != null) 'commitment_id': commitmentId,
      if (dueDate != null) 'due_date': dueDate,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? commitmentId,
    Value<DateTime>? dueDate,
    Value<DateTime>? paidAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      commitmentId: commitmentId ?? this.commitmentId,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (commitmentId.present) {
      map['commitment_id'] = Variable<String>(commitmentId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>($PaymentsTable.$converterdueDate.toSql(dueDate.value));
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('commitmentId: $commitmentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrefsTable extends Prefs with TableInfo<$PrefsTable, PrefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrefsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'prefs';
  @override
  VerificationContext validateIntegrity(Insertable<PrefRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  PrefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrefRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $PrefsTable createAlias(String alias) {
    return $PrefsTable(attachedDatabase, alias);
  }
}

class PrefRow extends DataClass implements Insertable<PrefRow> {
  final String key;
  final String value;
  const PrefRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PrefsCompanion toCompanion(bool nullToAbsent) {
    return PrefsCompanion(key: Value(key), value: Value(value));
  }

  factory PrefRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrefRow(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  PrefRow copyWith({String? key, String? value}) => PrefRow(key: key ?? this.key, value: value ?? this.value);
  PrefRow copyWithCompanion(PrefsCompanion data) {
    return PrefRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrefRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PrefRow && other.key == this.key && other.value == this.value);
}

class PrefsCompanion extends UpdateCompanion<PrefRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PrefsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrefsCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<PrefRow> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrefsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return PrefsCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
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
    return (StringBuffer('PrefsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DueDatabase extends GeneratedDatabase {
  _$DueDatabase(QueryExecutor e) : super(e);
  $DueDatabaseManager get managers => $DueDatabaseManager(this);
  late final $CommitmentsTable commitments = $CommitmentsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PrefsTable prefs = $PrefsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [commitments, payments, prefs];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('commitments', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('payments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CommitmentsTableCreateCompanionBuilder = CommitmentsCompanion Function({
  required String id,
  required String name,
  required int amount,
  required Map<String, Object?> cadence,
  Value<bool> autopay,
  required DateTime createdAt,
  Value<bool> archived,
  required int position,
  Value<int> rowid,
});
typedef $$CommitmentsTableUpdateCompanionBuilder = CommitmentsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> amount,
  Value<Map<String, Object?>> cadence,
  Value<bool> autopay,
  Value<DateTime> createdAt,
  Value<bool> archived,
  Value<int> position,
  Value<int> rowid,
});

final class $$CommitmentsTableReferences extends BaseReferences<_$DueDatabase, $CommitmentsTable, CommitmentRow> {
  $$CommitmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>> _paymentsRefsTable(_$DueDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments, aliasName: 'commitments__id__payments__commitment_id');

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.commitmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CommitmentsTableFilterComposer extends Composer<_$DueDatabase, $CommitmentsTable> {
  $$CommitmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, Object?>, Map<String, Object>, String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get autopay =>
      $composableBuilder(column: $table.autopay, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnFilters(column));

  Expression<bool> paymentsRefs(Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.commitmentId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitmentsTableOrderingComposer extends Composer<_$DueDatabase, $CommitmentsTable> {
  $$CommitmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autopay =>
      $composableBuilder(column: $table.autopay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $$CommitmentsTableAnnotationComposer extends Composer<_$DueDatabase, $CommitmentsTable> {
  $$CommitmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get amount => $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, Object?>, String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<bool> get autopay => $composableBuilder(column: $table.autopay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get position => $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> paymentsRefs<T extends Object>(Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.commitmentId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitmentsTableTableManager
    extends
        RootTableManager<
          _$DueDatabase,
          $CommitmentsTable,
          CommitmentRow,
          $$CommitmentsTableFilterComposer,
          $$CommitmentsTableOrderingComposer,
          $$CommitmentsTableAnnotationComposer,
          $$CommitmentsTableCreateCompanionBuilder,
          $$CommitmentsTableUpdateCompanionBuilder,
          (CommitmentRow, $$CommitmentsTableReferences),
          CommitmentRow,
          PrefetchHooks Function({bool paymentsRefs})
        > {
  $$CommitmentsTableTableManager(_$DueDatabase db, $CommitmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CommitmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CommitmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CommitmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<Map<String, Object?>> cadence = const Value.absent(),
                Value<bool> autopay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommitmentsCompanion(
                id: id,
                name: name,
                amount: amount,
                cadence: cadence,
                autopay: autopay,
                createdAt: createdAt,
                archived: archived,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int amount,
                required Map<String, Object?> cadence,
                Value<bool> autopay = const Value.absent(),
                required DateTime createdAt,
                Value<bool> archived = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => CommitmentsCompanion.insert(
                id: id,
                name: name,
                amount: amount,
                cadence: cadence,
                autopay: autopay,
                createdAt: createdAt,
                archived: archived,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable<$CommitmentsTable, CommitmentRow>(table), $$CommitmentsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedDataByColumns<CommitmentRow, $CommitmentsTable, PaymentRow, $PaymentsTable>(
                      currentTable: table,
                      referencedTable: $$CommitmentsTableReferences._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$CommitmentsTableReferences(db, table, p0).paymentsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'commitment_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CommitmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$DueDatabase,
      $CommitmentsTable,
      CommitmentRow,
      $$CommitmentsTableFilterComposer,
      $$CommitmentsTableOrderingComposer,
      $$CommitmentsTableAnnotationComposer,
      $$CommitmentsTableCreateCompanionBuilder,
      $$CommitmentsTableUpdateCompanionBuilder,
      (CommitmentRow, $$CommitmentsTableReferences),
      CommitmentRow,
      PrefetchHooks Function({bool paymentsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String commitmentId,
  required DateTime dueDate,
  required DateTime paidAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> commitmentId,
  Value<DateTime> dueDate,
  Value<DateTime> paidAt,
  Value<int> rowid,
});

final class $$PaymentsTableReferences extends BaseReferences<_$DueDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CommitmentsTable _commitmentIdTable(_$DueDatabase db) =>
      db.commitments.createAlias('payments__commitment_id__commitments__id');

  $$CommitmentsTableProcessedTableManager get commitmentId {
    final $_column = $_itemColumn<String>('commitment_id')!;

    final manager = $$CommitmentsTableTableManager($_db, $_db.commitments).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_commitmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableFilterComposer extends Composer<_$DueDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => ColumnFilters(column));

  $$CommitmentsTableFilterComposer get commitmentId {
    final $$CommitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CommitmentsTableFilterComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer extends Composer<_$DueDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => ColumnOrderings(column));

  $$CommitmentsTableOrderingComposer get commitmentId {
    final $$CommitmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CommitmentsTableOrderingComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer extends Composer<_$DueDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateTime, String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt => $composableBuilder(column: $table.paidAt, builder: (column) => column);

  $$CommitmentsTableAnnotationComposer get commitmentId {
    final $$CommitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CommitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$DueDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool commitmentId})
        > {
  $$PaymentsTableTableManager(_$DueDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> commitmentId = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<DateTime> paidAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PaymentsCompanion(commitmentId: commitmentId, dueDate: dueDate, paidAt: paidAt, rowid: rowid),
          createCompanionCallback: ({
            required String commitmentId,
            required DateTime dueDate,
            required DateTime paidAt,
            Value<int> rowid = const Value.absent(),
          }) => PaymentsCompanion.insert(commitmentId: commitmentId, dueDate: dueDate, paidAt: paidAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$PaymentsTable, PaymentRow>(table), $$PaymentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({commitmentId = false}) {
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
                    if (commitmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.commitmentId,
                        referencedTable: $$PaymentsTableReferences._commitmentIdTable(db),
                        referencedColumn: $$PaymentsTableReferences._commitmentIdTable(db).id,
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$DueDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool commitmentId})
    >;
typedef $$PrefsTableCreateCompanionBuilder = PrefsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$PrefsTableUpdateCompanionBuilder = PrefsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$PrefsTableFilterComposer extends Composer<_$DueDatabase, $PrefsTable> {
  $$PrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$PrefsTableOrderingComposer extends Composer<_$DueDatabase, $PrefsTable> {
  $$PrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$PrefsTableAnnotationComposer extends Composer<_$DueDatabase, $PrefsTable> {
  $$PrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PrefsTableTableManager
    extends
        RootTableManager<
          _$DueDatabase,
          $PrefsTable,
          PrefRow,
          $$PrefsTableFilterComposer,
          $$PrefsTableOrderingComposer,
          $$PrefsTableAnnotationComposer,
          $$PrefsTableCreateCompanionBuilder,
          $$PrefsTableUpdateCompanionBuilder,
          (PrefRow, BaseReferences<_$DueDatabase, $PrefsTable, PrefRow>),
          PrefRow,
          PrefetchHooks Function()
        > {
  $$PrefsTableTableManager(_$DueDatabase db, $PrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PrefsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => PrefsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrefsTable, PrefRow>(table),
                  BaseReferences<_$DueDatabase, $PrefsTable, PrefRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$DueDatabase,
      $PrefsTable,
      PrefRow,
      $$PrefsTableFilterComposer,
      $$PrefsTableOrderingComposer,
      $$PrefsTableAnnotationComposer,
      $$PrefsTableCreateCompanionBuilder,
      $$PrefsTableUpdateCompanionBuilder,
      (PrefRow, BaseReferences<_$DueDatabase, $PrefsTable, PrefRow>),
      PrefRow,
      PrefetchHooks Function()
    >;

class $DueDatabaseManager {
  final _$DueDatabase _db;
  $DueDatabaseManager(this._db);
  $$CommitmentsTableTableManager get commitments => $$CommitmentsTableTableManager(_db, _db.commitments);
  $$PaymentsTableTableManager get payments => $$PaymentsTableTableManager(_db, _db.payments);
  $$PrefsTableTableManager get prefs => $$PrefsTableTableManager(_db, _db.prefs);
}
