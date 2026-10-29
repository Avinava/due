import 'package:due/domain/cadence.dart';
import 'package:due/domain/calendar.dart';
import 'package:due/domain/commitment.dart';
import 'package:due/features/edit/edit_form.dart';
import 'package:flutter_test/flutter_test.dart';

/// Frame 1e's form.
const creditCard = EditForm(name: 'Credit card bill', amount: 12000, day: 31, start: YearMonth(2026, 12));

void main() {
  test('1e preview shows the February clamp', () {
    final p = creditCard.preview;
    expect([for (final d in p) '${d.weekday} ${d.date}'], ['THU 31 Dec 2026', 'SUN 31 Jan 2027', 'SUN 28 Feb 2027']);
    expect([for (final d in p) d.note], [null, null, 'Clamped from 31st']);
    expect(
      creditCard.previewNote,
      'Months without a 31st fall on their last day. The 31st comes back the month after.',
    );
  });

  test('without a clamp the note is neutral', () {
    expect(creditCard.copyWith(day: 15).previewNote, 'Dates update as you change the rule.');
  });

  test('each repeat kind builds its cadence', () {
    expect(creditCard.cadence, const Monthly(day: 31, from: YearMonth(2026, 12)));
    expect(
      creditCard.copyWith(kind: RepeatKind.everyNMonths, months: 3).cadence,
      const EveryNMonths(n: 3, from: YearMonth(2026, 12), day: 31),
    );
    expect(creditCard.copyWith(kind: RepeatKind.weekly, weekday: DateTime.friday).preview.first.date, '4 Dec 2026');
    expect(creditCard.copyWith(kind: RepeatKind.everyNDays, days: 28, day: 3).preview.map((p) => p.date), [
      '3 Dec 2026',
      '31 Dec 2026',
      '28 Jan 2027',
    ]);
  });

  test('saving an unchanged commitment keeps its cadence', () {
    final created = DateTime.utc(2026, 10);
    for (final cadence in [
      const Monthly(day: 1),
      const Monthly(day: 7, from: YearMonth(2025, 9), count: 36),
      const EveryNMonths(n: 4, from: YearMonth(2026, 6), day: 15, terms: 3),
      Weekly(weekday: DateTime.monday, from: DateTime.utc(2026, 10, 12)),
      EveryNDays(n: 28, anchor: DateTime.utc(2026, 10, 3)),
    ]) {
      final c = Commitment(id: 'x', name: 'X', amount: 1, cadence: cadence, createdAt: created);
      expect(EditForm.from(c).toCommitment(newId: 'y', today: created).cadence, cadence);
    }
  });

  test('steppers wrap and clamp', () {
    expect(creditCard.stepDay(1).day, 1);
    expect(creditCard.copyWith(day: 1).stepDay(-1).day, 31);
    expect(creditCard.stepWeekday(-1).weekday, DateTime.sunday);
    expect(creditCard.copyWith(months: 2).stepMonths(-1).months, 2);
    expect(creditCard.copyWith(days: 365).stepDays(1).days, 365);
    expect(creditCard.stepStart(1).start, const YearMonth(2027, 1));
  });

  test('amount keeps digits only', () {
    expect(creditCard.withAmountText('₹12,500').amount, 12500);
    expect(creditCard.withAmountText('').amount, 0);
    expect(creditCard.withAmountText('1234567890123').amount, 123456789);
  });

  test('validity needs a name and an amount', () {
    expect(creditCard.isValid, isTrue);
    expect(creditCard.copyWith(name: '  ').isValid, isFalse);
    expect(creditCard.copyWith(amount: 0).isValid, isFalse);
  });

  test('editing round trips through the commitment', () {
    final c = creditCard.toCommitment(newId: 'cc', today: DateTime.utc(2026, 10, 12));
    final back = EditForm.from(c);
    expect(
      (back.name, back.amount, back.day, back.start, back.kind),
      ('Credit card bill', 12000, 31, const YearMonth(2026, 12), RepeatKind.monthly),
    );
  });
}
