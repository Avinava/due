import 'package:due/domain/cadence.dart';
import 'package:due/domain/calendar.dart';
import 'package:due/domain/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);
List<DateTime> dates(List<Occurrence> os) => [for (final o in os) o.date];

void main() {
  group('Monthly', () {
    test('the 31st falls on each month end and comes back', () {
      final os = upcoming(const Monthly(day: 31), d(2026, 12, 1), 4);
      expect(dates(os), [d(2026, 12, 31), d(2027, 1, 31), d(2027, 2, 28), d(2027, 3, 31)]);
      expect([for (final o in os) o.clampedFrom], [null, null, 31, null]);
    });

    test('the 30th in a leap February clamps to the 29th', () {
      final o = occurrencesIn(const Monthly(day: 30), const YearMonth(2028, 2)).single;
      expect(o.date, d(2028, 2, 29));
      expect(o.clampedFrom, 30);
    });

    test('the 29th in a leap February is not clamped', () {
      final o = occurrencesIn(const Monthly(day: 29), const YearMonth(2028, 2)).single;
      expect(o.clamped, isFalse);
    });

    test('an EMI is numbered from its first month and stops after count', () {
      const emi = Monthly(day: 7, from: YearMonth(2025, 9), count: 36);
      expect(occurrencesIn(emi, const YearMonth(2025, 8)), isEmpty);
      expect(occurrencesIn(emi, const YearMonth(2025, 9)).single.seq, 1);
      expect(occurrencesIn(emi, const YearMonth(2026, 10)).single.seq, 14);
      expect(occurrencesIn(emi, const YearMonth(2028, 8)).single.seq, 36);
      expect(occurrencesIn(emi, const YearMonth(2028, 9)), isEmpty);
      expect(upcoming(emi, d(2028, 8, 1), 3), hasLength(1));
    });
  });

  group('EveryNMonths', () {
    test('a quarterly 31st keeps its day after a short month', () {
      final q = EveryNMonths(n: 3, from: const YearMonth(2027, 2), day: 31);
      expect(dates(upcoming(q, d(2027, 2, 1), 3)), [d(2027, 2, 28), d(2027, 5, 31), d(2027, 8, 31)]);
    });

    test('quarterly falls only on months in step with the anchor', () {
      final q = EveryNMonths(n: 3, from: const YearMonth(2026, 1), day: 10);
      expect(occurrencesIn(q, const YearMonth(2025, 10)), isEmpty);
      expect(occurrencesIn(q, const YearMonth(2026, 9)), isEmpty);
      expect(occurrencesIn(q, const YearMonth(2026, 10)).single.date, d(2026, 10, 10));
      expect(dates(upcoming(q, d(2026, 1, 1), 3)), [d(2026, 1, 10), d(2026, 4, 10), d(2026, 7, 10)]);
    });

    test('school terms are numbered and wrap each year', () {
      final school = EveryNMonths(n: 4, from: const YearMonth(2026, 6), day: 15, terms: 3);
      final os = upcoming(school, d(2026, 6, 1), 4);
      expect(dates(os), [d(2026, 6, 15), d(2026, 10, 15), d(2027, 2, 15), d(2027, 6, 15)]);
      expect([for (final o in os) o.seq], [1, 2, 3, 4]);
    });

    test('a yearly Feb 29 falls on Feb 28 in other years', () {
      final y = EveryNMonths(n: 12, from: const YearMonth(2028, 2), day: 29);
      final os = upcoming(y, d(2028, 1, 1), 5);
      expect(dates(os), [d(2028, 2, 29), d(2029, 2, 28), d(2030, 2, 28), d(2031, 2, 28), d(2032, 2, 29)]);
      expect([for (final o in os) o.clamped], [false, true, true, true, false]);
    });
  });

  group('EveryNDays', () {
    final jio = EveryNDays(n: 28, anchor: d(2026, 10, 3));

    test('a 28-day plan can fall twice in one month', () {
      expect(dates(occurrencesIn(jio, const YearMonth(2026, 10))), [d(2026, 10, 3), d(2026, 10, 31)]);
    });

    test('it drifts across month and year boundaries', () {
      expect(dates(upcoming(jio, d(2026, 11, 1), 4)), [
        d(2026, 11, 28),
        d(2026, 12, 26),
        d(2027, 1, 23),
        d(2027, 2, 20),
      ]);
    });

    test('nothing before the anchor', () {
      expect(occurrencesIn(jio, const YearMonth(2026, 9)), isEmpty);
    });

    test('day steps ignore daylight saving', () {
      final weekly = EveryNDays(n: 7, anchor: d(2026, 3, 1));
      expect(dates(occurrencesIn(weekly, const YearMonth(2026, 3))), [
        d(2026, 3, 1),
        d(2026, 3, 8),
        d(2026, 3, 15),
        d(2026, 3, 22),
        d(2026, 3, 29),
      ]);
    });
  });

  group('Weekly', () {
    test('every Monday on or after from', () {
      final w = Weekly(weekday: DateTime.monday, from: d(2026, 10, 12));
      expect(dates(occurrencesIn(w, const YearMonth(2026, 10))), [d(2026, 10, 12), d(2026, 10, 19), d(2026, 10, 26)]);
    });

    test('crosses into the next month', () {
      final w = Weekly(weekday: DateTime.friday, from: d(2026, 10, 1));
      expect(dates(upcoming(w, d(2026, 10, 28), 2)), [d(2026, 10, 30), d(2026, 11, 6)]);
    });
  });
}
