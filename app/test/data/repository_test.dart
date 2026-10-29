import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:due/data/backup.dart';
import 'package:due/data/database.dart';
import 'package:due/data/drift_commitment_repository.dart';
import 'package:due/domain/cadence.dart';
import 'package:due/domain/calendar.dart';
import 'package:due/domain/commitment.dart';
import 'package:due/domain/month_brief.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime.utc(2026, 10, 12);

void main() {
  late DueDatabase db;
  late DriftCommitmentRepository repo;

  setUp(() {
    db = DueDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = DriftCommitmentRepository(db);
  });
  tearDown(() => db.close());

  test('first run seeds the sample household once', () async {
    await repo.seedIfFirstRun(today);
    final h = await repo.load();
    expect(h.commitments, hasLength(8));
    expect(h.paid, hasLength(2));

    await repo.setPaid(PaymentKey('rent', DateTime.utc(2026, 10, 1)), paid: false);
    await repo.seedIfFirstRun(today);
    expect((await repo.load()).paid, hasLength(1));
  });

  test('round trips every cadence through the database', () async {
    final created = DateTime.utc(2026, 1, 1);
    final cadences = <Cadence>[
      const Monthly(day: 31),
      const Monthly(day: 7, from: YearMonth(2025, 9), count: 36),
      const EveryNMonths(n: 4, from: YearMonth(2026, 6), day: 15, terms: 3),
      Weekly(weekday: DateTime.saturday, from: DateTime.utc(2026, 10, 3)),
      EveryNDays(n: 28, anchor: DateTime.utc(2026, 10, 3)),
    ];
    for (final (i, c) in cadences.indexed) {
      await repo.save(Commitment(id: 'c$i', name: 'C$i', amount: i, cadence: c, createdAt: created));
    }
    final loaded = await repo.load();
    expect([for (final c in loaded.commitments) c.cadence], cadences);
    expect(loaded.commitments.first.createdAt, created);
  });

  test('marking paid and undoing it updates the stream', () async {
    await repo.seedIfFirstRun(today);
    final key = PaymentKey('school', DateTime.utc(2026, 10, 15));
    final seen = <bool>[];
    final sub = repo.watch().listen((h) => seen.add(h.paid.contains(key)));
    await pumpEventQueue();
    await repo.setPaid(key, paid: true);
    await pumpEventQueue();
    await repo.setPaid(key, paid: false);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [false, true, false]);
  });

  test('backup round trip keeps everything', () async {
    await repo.seedIfFirstRun(today);
    final before = await repo.load();
    final json = Backup.encode(before, exportedAt: today);
    final decoded = Backup.decode(json);
    await repo.replaceAll(decoded);
    final after = await repo.load();
    expect([for (final c in after.commitments) c.id], [for (final c in before.commitments) c.id]);
    expect(after.paid, before.paid);
  });

  group('backup validation', () {
    test('rejects other files', () {
      expect(() => Backup.decode('nope'), throwsA(isA<FormatException>()));
      expect(() => Backup.decode('{"app":"other"}'), throwsA(isA<FormatException>()));
      expect(() => Backup.decode('{"app":"due","version":2}'), throwsA(isA<FormatException>()));
    });

    test('rejects a payment for a missing commitment', () {
      const json =
          '{"app":"due","version":1,"commitments":[],'
          '"payments":[{"commitmentId":"x","dueDate":"2026-10-01"}]}';
      expect(() => Backup.decode(json), throwsA(isA<FormatException>()));
    });

    test('rejects an impossible date', () {
      const json =
          '{"app":"due","version":1,"payments":[],"commitments":[{"id":"a","name":"A","amount":1,'
          '"createdAt":"2026-02-30","cadence":{"kind":"monthly","day":1}}]}';
      expect(() => Backup.decode(json), throwsA(isA<FormatException>()));
    });

    test('rejects a date that is not a string, with a message', () {
      const json =
          '{"app":"due","version":1,"payments":[],"commitments":[{"id":"a","name":"A","amount":1,'
          '"createdAt":123,"cadence":{"kind":"monthly","day":1}}]}';
      expect(
        () => Backup.decode(json),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', 'A has a bad start date.')),
      );
    });
  });
}
