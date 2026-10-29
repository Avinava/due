import 'package:due/data/sample_household.dart';
import 'package:due/domain/calendar.dart';
import 'package:due/domain/month_brief.dart';
import 'package:due/features/month/month_view_model.dart';
import 'package:due_kit/due_kit.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime.utc(2026, 10, 12);

MonthView view({YearMonth month = const YearMonth(2026, 10), int? scrub, Set<PaymentKey> paid = const {}, int? delta}) {
  final s = sampleHousehold(today);
  final brief = MonthBrief.build(month: month, today: today, commitments: s.commitments, paid: {...s.paid, ...paid});
  return MonthView.of(brief, scrub: scrub, delta: delta, flash: paid.firstOrNull);
}

final schoolKey = PaymentKey('school', DateTime.utc(2026, 10, 15));

void main() {
  group('1a month', () {
    final v = view();

    test('hero', () {
      expect(v.heroLabel, 'NEEDS YOU');
      expect(v.needsYou, 73680);
      expect(v.subLine, '₹1,23,227 committed · ₹15,547 on autopay');
      expect(v.done, isFalse);
      expect(v.delta, isNull);
    });

    test('dial centre', () {
      expect(
        (v.dial.line1, v.dial.line2, v.dial.line3),
        ('MON 12 OCT', '19 days left', 'Next: Society maintenance, Sat 10'),
      );
      expect(v.dial.elapsedDays, 11);
      expect(
        [for (final m in v.dial.marks) (m.day, m.state)],
        [
          (1, MarkState.paid),
          (3, MarkState.settled),
          (5, MarkState.paid),
          (7, MarkState.settled),
          (10, MarkState.late),
          (15, MarkState.due),
          (18, MarkState.auto),
          (22, MarkState.due),
          (31, MarkState.auto),
        ],
      );
    });

    test('groups include today even with nothing due', () {
      expect(
        [for (final g in v.groups) g.label],
        ['THU 1', 'SAT 3', 'MON 5', 'WED 7', 'SAT 10', 'TODAY · MON 12', 'THU 15', 'SUN 18', 'THU 22', 'SAT 31'],
      );
      expect(v.groups.firstWhere((g) => g.isToday).rows, isEmpty);
    });

    test('row copy', () {
      final rows = {
        for (final g in v.groups)
          for (final r in g.rows) r.name: r,
      };
      expect(rows['Society maintenance']!.status, '2 days late');
      expect(rows['School fees']!.status, 'Due Thu 15');
      expect(rows['Netflix']!.status, 'Autopay Sun 18');
      expect(rows['Car EMI']!.status, 'Autopay · settled');
      expect(rows['Car EMI']!.schedule, 'EMI 14 of 36 · autopay');
      expect(rows['Rent']!.status, 'Paid');
      expect(rows['School fees']!.semanticLabel, '15 October, School fees, ₹42,000, unpaid');
      expect(v.listTitle, '9 charges this month');
    });
  });

  test('1b scrubbed to the 15th', () {
    final v = view(scrub: 15);
    expect(v.scrubLabel, 'Thursday 15 October');
    expect([for (final g in v.groups) g.label], ['THU 15']);
    expect((v.dial.line1, v.dial.line2, v.dial.line3), ('THU 15 OCT', '₹42,000', 'School fees · needs you'));
    expect(v.listTitle, 'Thu 15 Oct');
  });

  test('scrubbing an empty day', () {
    final v = view(scrub: 13);
    expect(v.groups, isEmpty);
    expect(v.emptyDay, isTrue);
    expect(v.dial.line2, '—');
    expect(v.dial.line3, 'Nothing due');
  });

  test('1c just paid school fees', () {
    final v = view(paid: {schoolKey}, delta: 42000);
    expect(v.needsYou, 31680);
    expect(v.delta, '−₹42,000');
    final school = v.groups.expand((g) => g.rows).firstWhere((r) => r.name == 'School fees');
    expect(school.flashing, isTrue);
    expect(school.state, MarkState.paid);
  });

  test('1d nothing left', () {
    final v = view(
      paid: {
        schoolKey,
        PaymentKey('society', DateTime.utc(2026, 10, 10)),
        PaymentKey('lic', DateTime.utc(2026, 10, 22)),
      },
    );
    expect(v.done, isTrue);
    expect((v.dial.line2, v.dial.line3), ('All clear', '2 autopays still to run'));
  });

  test('a future month', () {
    final v = view(month: const YearMonth(2026, 11));
    expect(v.heroLabel, 'NEEDS YOU IN NOVEMBER');
    expect((v.dial.line1, v.dial.line2), ('NOVEMBER', '${v.brief.items.length} charges'));
    expect(v.dial.today, isNull);
    expect(v.dial.elapsedDays, 0);
  });

  test('a past month', () {
    final v = view(month: const YearMonth(2026, 9));
    expect(v.heroLabel, 'SETTLED IN SEPTEMBER');
    expect(v.dial.line3, 'All settled');
    expect(v.dial.elapsedDays, 30);
  });

  test('a past month with bills still unpaid does not say settled', () {
    final s = sampleHousehold(today);
    final brief = MonthBrief.build(
      month: const YearMonth(2026, 10),
      today: DateTime.utc(2026, 11, 3),
      commitments: s.commitments,
      paid: s.paid,
    );
    final v = MonthView.of(brief);
    expect(v.heroLabel, 'STILL UNPAID IN OCTOBER');
    expect(v.dial.line3, '${brief.items.where((i) => i.state.needsYou).length} unpaid');
  });
}
