import 'package:due/data/sample_household.dart';
import 'package:due/domain/calendar.dart';
import 'package:due/domain/month_brief.dart';
import 'package:due/features/home_widget/widget_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime.utc(2026, 10, 12);
  final s = sampleHousehold(today);
  final w = WidgetSnapshot.of(
    MonthBrief.build(month: YearMonth.of(today), today: today, commitments: s.commitments, paid: s.paid),
  );

  test('1n small widget', () {
    expect(w.needsYou, '73,680');
    expect(
      (w.nextLabel, w.nextName, w.nextLine, w.nextLate),
      ('OVERDUE', 'Society maintenance', 'Sat 10 · ₹7,500', true),
    );
  });

  test('1n medium widget', () {
    expect(w.monthLine, 'October · 19 days left');
    expect(
      [for (final i in w.items) '${i.name} ${i.when} ${i.amount}'],
      ['Society maintenance 2 DAYS LATE ₹7,500', 'School fees THU 15 ₹42,000', 'LIC premium THU 22 ₹24,180'],
    );
    expect(w.bar, hasLength(31));
    expect(w.bar[9], DayCell.needsYou);
    expect(w.bar[0], DayCell.settled);
    expect(w.bar[1], DayCell.past);
    expect(w.bar[12], DayCell.future);
  });

  test('serialises for the App Group', () {
    final json = w.toJson();
    expect(json['needsYou'], '73,680');
    expect((json['bar']! as List).first, 'settled');
  });

  test('the timeline runs a week ahead and crosses into the next month', () {
    final days = widgetTimeline(today: DateTime.utc(2026, 10, 28), commitments: s.commitments, paid: s.paid);
    expect(days, hasLength(widgetTimelineDays));
    expect(days.first.toJson()['date'], '2026-10-28');
    expect(days.last.toJson()['date'], '2026-11-03');
    expect(days.first.snapshot.monthLine, 'October · 3 days left');
    expect(days.last.snapshot.monthLine, 'November · 27 days left');
    expect(days.last.snapshot.bar, hasLength(30));
  });

  test('one day late is singular', () {
    final day = DateTime.utc(2026, 10, 11);
    final w = WidgetSnapshot.of(
      MonthBrief.build(month: YearMonth.of(day), today: day, commitments: s.commitments, paid: s.paid),
    );
    expect(w.items.first.when, '1 DAY LATE');
  });
}
