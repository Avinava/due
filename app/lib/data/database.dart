import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'cadence_codec.dart';

part 'database.g.dart';

/// Stores a UTC calendar date as `yyyy-mm-dd`, so no time zone can move it.
class DateConverter extends TypeConverter<DateTime, String> {
  const DateConverter();

  @override
  DateTime fromSql(String fromDb) => CadenceCodec.decodeDate(fromDb);

  @override
  String toSql(DateTime value) => CadenceCodec.encodeDate(value);
}

class JsonMapConverter extends TypeConverter<Map<String, Object?>, String> {
  const JsonMapConverter();

  @override
  Map<String, Object?> fromSql(String fromDb) => (jsonDecode(fromDb) as Map).cast<String, Object?>();

  @override
  String toSql(Map<String, Object?> value) => jsonEncode(value);
}

@DataClassName('CommitmentRow')
class Commitments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amount => integer()();
  TextColumn get cadence => text().map(const JsonMapConverter())();
  BoolColumn get autopay => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text().map(const DateConverter())();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get commitmentId => text().references(Commitments, #id, onDelete: KeyAction.cascade)();
  TextColumn get dueDate => text().map(const DateConverter())();
  DateTimeColumn get paidAt => dateTime()();

  @override
  Set<Column> get primaryKey => {commitmentId, dueDate};
}

@DataClassName('PrefRow')
class Prefs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Commitments, Payments, Prefs])
class DueDatabase extends _$DueDatabase {
  DueDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'));

  static QueryExecutor _open() => driftDatabase(
    name: 'due',
    web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
  );
}
