import 'package:drift/drift.dart';

import '../domain/commitment.dart';
import '../domain/month_brief.dart';
import 'cadence_codec.dart';
import 'commitment_repository.dart';
import 'database.dart';
import 'household.dart';
import 'sample_household.dart';

/// [CommitmentRepository] on SQLite through drift. The only code that knows
/// about tables.
final class DriftCommitmentRepository implements CommitmentRepository {
  DriftCommitmentRepository(this._db);

  final DueDatabase _db;

  static const _seededKey = 'seeded';

  /// Emits the household now and after every change to commitments or
  /// payments.
  @override
  Stream<Household> watch() =>
      _db.customSelect('SELECT 1', readsFrom: {_db.commitments, _db.payments}).watch().asyncMap((_) => load());

  @override
  Future<Household> load() async {
    final rows = await (_db.select(_db.commitments)..orderBy([(t) => OrderingTerm(expression: t.position)])).get();
    final payments = await _db.select(_db.payments).get();
    return Household(
      commitments: [for (final r in rows) _toDomain(r)],
      paid: {for (final p in payments) PaymentKey(p.commitmentId, p.dueDate)},
    );
  }

  /// Loads the sample household the first time the app runs.
  @override
  Future<void> seedIfFirstRun(DateTime today) async {
    final seeded = await (_db.select(_db.prefs)..where((p) => p.key.equals(_seededKey))).getSingleOrNull();
    if (seeded != null) return;
    final s = sampleHousehold(today);
    await replaceAll(Household(commitments: s.commitments, paid: s.paid));
  }

  @override
  Future<void> resetToSample(DateTime today) {
    final s = sampleHousehold(today);
    return replaceAll(Household(commitments: s.commitments, paid: s.paid));
  }

  /// Replaces every commitment and payment in one transaction.
  @override
  Future<void> replaceAll(Household h) => _db.transaction(() async {
    await _db.delete(_db.payments).go();
    await _db.delete(_db.commitments).go();
    await _db.batch((b) {
      b.insertAll(_db.commitments, [for (final (i, c) in h.commitments.indexed) _toRow(c, i)]);
      b.insertAll(_db.payments, [
        for (final p in h.paid)
          PaymentsCompanion.insert(commitmentId: p.commitmentId, dueDate: p.dueDate, paidAt: DateTime.now()),
      ]);
    });
    await _db.into(_db.prefs).insertOnConflictUpdate(PrefsCompanion.insert(key: _seededKey, value: '1'));
  });

  @override
  Future<void> save(Commitment c) async {
    final existing = await (_db.select(_db.commitments)..where((t) => t.id.equals(c.id))).getSingleOrNull();
    final position = existing?.position ?? await _nextPosition();
    await _db.into(_db.commitments).insertOnConflictUpdate(_toRow(c, position));
  }

  @override
  Future<void> setPaid(PaymentKey key, {required bool paid}) async {
    if (paid) {
      await _db
          .into(_db.payments)
          .insertOnConflictUpdate(
            PaymentsCompanion.insert(commitmentId: key.commitmentId, dueDate: key.dueDate, paidAt: DateTime.now()),
          );
    } else {
      await (_db.delete(
        _db.payments,
      )..where((p) => p.commitmentId.equals(key.commitmentId) & p.dueDate.equalsValue(key.dueDate))).go();
    }
  }

  @override
  Future<String?> pref(String key) async =>
      (await (_db.select(_db.prefs)..where((p) => p.key.equals(key))).getSingleOrNull())?.value;

  @override
  Future<void> setPref(String key, String value) =>
      _db.into(_db.prefs).insertOnConflictUpdate(PrefsCompanion.insert(key: key, value: value));

  Future<int> _nextPosition() async {
    final max = _db.commitments.position.max();
    final row = await (_db.selectOnly(_db.commitments)..addColumns([max])).getSingle();
    return (row.read(max) ?? -1) + 1;
  }

  static Commitment _toDomain(CommitmentRow r) => Commitment(
    id: r.id,
    name: r.name,
    amount: r.amount,
    cadence: CadenceCodec.decode(r.cadence),
    autopay: r.autopay,
    createdAt: r.createdAt,
    archived: r.archived,
  );

  static CommitmentsCompanion _toRow(Commitment c, int position) => CommitmentsCompanion.insert(
    id: c.id,
    name: c.name,
    amount: c.amount,
    cadence: CadenceCodec.encode(c.cadence),
    autopay: Value(c.autopay),
    createdAt: c.createdAt,
    archived: Value(c.archived),
    position: position,
  );
}
