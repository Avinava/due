import 'calendar.dart';
import 'commitment.dart';
import 'money.dart';
import 'month_brief.dart';

/// One local notification to schedule.
final class Reminder {
  const Reminder({required this.id, required this.fireAt, required this.title, required this.body});

  /// Stable per occurrence, so rescheduling replaces rather than duplicates.
  final int id;

  /// Local wall-clock time; the platform layer applies the time zone.
  final DateTime fireAt;
  final String title;
  final String body;
}

/// iOS keeps at most 64 pending notifications.
const maxPendingReminders = 64;

/// How far ahead reminders are scheduled.
const reminderWindowDays = 60;

/// Reminders for unpaid manual items due after today and within the window,
/// firing at [hour] the morning before each. One whose time has already
/// passed on [now]'s wall clock is left out. Earliest first.
List<Reminder> planReminders({
  required List<Commitment> commitments,
  required Set<PaymentKey> paid,
  required DateTime now,
  required int hour,
}) {
  final t = dateOnly(now);
  final wall = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
  final end = t.add(const Duration(days: reminderWindowDays));
  final out = <Reminder>[];
  for (var month = YearMonth.of(t); !month.first.isAfter(end); month = month.plus(1)) {
    final brief = MonthBrief.build(month: month, today: t, commitments: commitments, paid: paid);
    for (final i in brief.items) {
      if (i.state != DueState.due || !i.date.isAfter(t) || i.date.isAfter(end)) continue;
      final eve = i.date.subtract(const Duration(days: 1));
      final fireAt = DateTime(eve.year, eve.month, eve.day, hour);
      if (!fireAt.isAfter(wall)) continue;
      out.add(
        Reminder(
          id: Object.hash(i.commitment.id, i.date) & 0x7fffffff,
          fireAt: fireAt,
          title: '${i.commitment.name} is due tomorrow',
          body:
              '${formatInr(i.amount)} · ${weekdayShort[i.date.weekday - 1]} ${i.date.day} ${monthShort[i.date.month - 1]}',
        ),
      );
    }
  }
  out.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return out.take(maxPendingReminders).toList();
}
