import 'package:due/data/sample_household.dart';
import 'package:due/domain/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime.utc(2026, 10, 12);
  final s = sampleHousehold(today);

  test('the sample household has reminders for unpaid manual items only', () {
    final plan = planReminders(commitments: s.commitments, paid: s.paid, now: today, hour: 9);
    expect(
      [for (final r in plan) r.title],
      [
        'School fees is due tomorrow',
        'LIC premium is due tomorrow',
        'Rent is due tomorrow',
        'Maid is due tomorrow',
        'Rent is due tomorrow',
        'Maid is due tomorrow',
      ],
    );
    expect(plan.first.fireAt, DateTime(2026, 10, 14, 9));
    expect(plan.first.body, '₹42,000 · Thu 15 Oct');
  });

  test('ids are stable and unique per occurrence', () {
    final a = planReminders(commitments: s.commitments, paid: s.paid, now: today, hour: 9);
    final b = planReminders(commitments: s.commitments, paid: s.paid, now: today, hour: 18);
    expect([for (final r in a) r.id], [for (final r in b) r.id]);
    expect({for (final r in a) r.id}, hasLength(a.length));
  });

  test('a reminder whose time has passed is left out', () {
    final afternoon = DateTime(2026, 10, 14, 15);
    final plan = planReminders(commitments: s.commitments, paid: s.paid, now: afternoon, hour: 9);
    expect(plan.first.title, 'LIC premium is due tomorrow');
  });

  test('late items are not reminded', () {
    final plan = planReminders(commitments: s.commitments, paid: s.paid, now: today, hour: 9);
    expect(plan.where((r) => r.title.startsWith('Society')), isEmpty);
  });
}
