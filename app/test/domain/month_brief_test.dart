import 'package:due/data/sample_household.dart';
import 'package:due/domain/cadence.dart';
import 'package:due/domain/calendar.dart';
import 'package:due/domain/commitment.dart';
import 'package:due/domain/money.dart';
import 'package:due/domain/month_brief.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime.utc(2026, 10, 12);

MonthBrief brief(YearMonth month, {Set<PaymentKey> extraPaid = const {}}) {
  final s = sampleHousehold(today);
  return MonthBrief.build(month: month, today: today, commitments: s.commitments, paid: {...s.paid, ...extraPaid});
}

void main() {
  group('design acceptance numbers, 12 Oct 2026', () {
    final oct = brief(const YearMonth(2026, 10));

    test('totals', () {
      expect(oct.needsYou, 73680);
      expect(oct.committed, 123227);
      expect(oct.autopayTotal, 15547);
      expect(groupInr(oct.committed), '1,23,227');
    });

    test('states', () {
      final byId = {for (final i in oct.items) '${i.commitment.id}@${i.day}': i.state};
      expect(byId, {
        'rent@1': DueState.paid,
        'jio@3': DueState.settled,
        'maid@5': DueState.paid,
        'emi@7': DueState.settled,
        'society@10': DueState.late,
        'school@15': DueState.due,
        'netflix@18': DueState.auto,
        'lic@22': DueState.due,
        'jio@31': DueState.auto,
      });
    });

    test('labels', () {
      String label(String id) {
        final i = oct.items.firstWhere((i) => i.commitment.id == id);
        return scheduleLabel(i.commitment, i.occurrence);
      }

      expect(label('emi'), 'EMI 14 of 36 · autopay');
      expect(label('school'), 'Term 2 of 3');
      expect(label('society'), 'Quarterly');
      expect(label('lic'), 'Yearly');
      expect(label('jio'), 'Every 28 days · autopay');
      expect(label('rent'), 'Monthly');
    });

    test('next manual is the late society bill', () {
      expect(oct.nextManual?.commitment.id, 'society');
      expect(oct.autopaysLeft, 2);
      expect(oct.allSettled, isFalse);
    });

    test('paying everything manual settles the month', () {
      final done = brief(
        const YearMonth(2026, 10),
        extraPaid: {
          PaymentKey('society', DateTime.utc(2026, 10, 10)),
          PaymentKey('school', DateTime.utc(2026, 10, 15)),
          PaymentKey('lic', DateTime.utc(2026, 10, 22)),
        },
      );
      expect(done.needsYou, 0);
      expect(done.allSettled, isTrue);
    });
  });

  test('a past month is history before the commitments existed', () {
    final sep = brief(const YearMonth(2026, 9));
    expect(sep.isPast, isTrue);
    expect(sep.needsYou, 0);
    expect(sep.allSettled, isFalse);
  });

  test('a future month counts everything as needing you', () {
    final nov = brief(const YearMonth(2026, 11));
    expect(nov.isFuture, isTrue);
    expect(nov.todayDay, isNull);
    expect(nov.needsYou, 28000 + 6000);
  });

  test('archived commitments are left out', () {
    final c = Commitment(
      id: 'x',
      name: 'Gym',
      amount: 1500,
      cadence: const Monthly(day: 20),
      createdAt: DateTime.utc(2026, 1, 1),
      archived: true,
    );
    final b = MonthBrief.build(month: const YearMonth(2026, 10), today: today, commitments: [c], paid: {});
    expect(b.items, isEmpty);
  });

  test('same-day items keep input order', () {
    Commitment mk(String id) =>
        Commitment(id: id, name: id, amount: 1, cadence: const Monthly(day: 20), createdAt: DateTime.utc(2026, 1, 1));
    final b = MonthBrief.build(
      month: const YearMonth(2026, 10),
      today: today,
      commitments: [mk('a'), mk('b'), mk('c')],
      paid: {},
    );
    expect([for (final i in b.items) i.commitment.id], ['a', 'b', 'c']);
  });

  group('money', () {
    test('Indian grouping', () {
      expect(formatInr(0), '₹0');
      expect(formatInr(349), '₹349');
      expect(formatInr(42000), '₹42,000');
      expect(formatInr(124500), '₹1,24,500');
      expect(formatInr(12345678), '₹1,23,45,678');
      expect(formatInr(-42000), '−₹42,000');
    });
  });

  group('calendar', () {
    test('ordinals', () {
      expect([1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 31].map(ordinal), [
        '1st',
        '2nd',
        '3rd',
        '4th',
        '11th',
        '12th',
        '13th',
        '21st',
        '22nd',
        '23rd',
        '31st',
      ]);
    });

    test('month arithmetic', () {
      expect(const YearMonth(2026, 10).plus(3), const YearMonth(2027, 1));
      expect(const YearMonth(2026, 1).plus(-1), const YearMonth(2025, 12));
      expect(const YearMonth(2025, 9).monthsUntil(const YearMonth(2026, 10)), 13);
    });
  });
}
