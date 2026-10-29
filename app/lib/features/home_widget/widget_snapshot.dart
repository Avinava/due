import '../../domain/calendar.dart';
import '../../domain/commitment.dart';
import '../../domain/money.dart';
import '../../domain/month_brief.dart';

/// One upcoming item on the medium widget.
final class WidgetItem {
  const WidgetItem({required this.name, required this.amount, required this.when, required this.late});

  final String name;

  /// "₹42,000".
  final String amount;

  /// "THU 15" or "2 DAYS LATE".
  final String when;
  final bool late;

  Map<String, Object> toJson() => {'name': name, 'amount': amount, 'when': when, 'late': late};
}

/// What a day cell on the medium widget's bar shows.
enum DayCell { needsYou, settled, past, future }

/// Everything the iOS widgets draw (frames 1n, 1o), computed in Dart so the
/// Swift side only lays it out.
final class WidgetSnapshot {
  const WidgetSnapshot({
    required this.needsYou,
    required this.nextLabel,
    required this.nextName,
    required this.nextLine,
    required this.nextLate,
    required this.monthLine,
    required this.items,
    required this.bar,
  });

  /// Builds the snapshot from the current month's brief.
  factory WidgetSnapshot.of(MonthBrief brief) {
    final today = brief.today.day;
    String wd(DateTime d) => weekdayShort[d.weekday - 1];
    final open = brief.items.where((i) => i.state.needsYou).toList();
    final next = open.firstOrNull;
    final byDay = brief.byDay;
    return WidgetSnapshot(
      needsYou: groupInr(brief.needsYou),
      nextLabel: next == null ? 'ALL CLEAR' : (next.state == DueState.late ? 'OVERDUE' : 'NEXT'),
      nextName: next?.commitment.name ?? 'Nothing left',
      nextLine: next == null ? 'this month' : '${wd(next.date)} ${next.day} · ${formatInr(next.amount)}',
      nextLate: next?.state == DueState.late,
      monthLine: '${brief.month.name} · ${dayCount(brief.month.days - today)} left',
      items: [
        for (final i in open.take(3))
          WidgetItem(
            name: i.commitment.name,
            amount: formatInr(i.amount),
            when: i.state == DueState.late
                ? '${dayCount(today - i.day).toUpperCase()} LATE'
                : '${wd(i.date).toUpperCase()} ${i.day}',
            late: i.state == DueState.late,
          ),
      ],
      bar: [
        for (var d = 1; d <= brief.month.days; d++)
          if (byDay[d]?.any((i) => i.state.needsYou) ?? false)
            DayCell.needsYou
          else if (byDay.containsKey(d))
            DayCell.settled
          else if (d < today)
            DayCell.past
          else
            DayCell.future,
      ],
    );
  }

  final String needsYou;
  final String nextLabel;
  final String nextName;
  final String nextLine;
  final bool nextLate;
  final String monthLine;
  final List<WidgetItem> items;
  final List<DayCell> bar;

  /// The App Group payload read by the SwiftUI widget.
  Map<String, Object> toJson() => {
    'needsYou': needsYou,
    'nextLabel': nextLabel,
    'nextName': nextName,
    'nextLine': nextLine,
    'nextLate': nextLate,
    'monthLine': monthLine,
    'items': [for (final i in items) i.toJson()],
    'bar': [for (final c in bar) c.name],
  };
}

/// One day of the widget's timeline: what the widget shows from [date].
final class WidgetDay {
  const WidgetDay({required this.date, required this.snapshot});

  final DateTime date;
  final WidgetSnapshot snapshot;

  Map<String, Object> toJson() => {
    'date': '${date.year}-${_two(date.month)}-${_two(date.day)}',
    'snapshot': snapshot.toJson(),
  };

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// Days of snapshots written ahead, so the widget moves on at midnight
/// without the app running.
const widgetTimelineDays = 7;

/// The widget's timeline from [today], assuming nothing more is paid. The app
/// rewrites it whenever the household changes.
List<WidgetDay> widgetTimeline({
  required DateTime today,
  required List<Commitment> commitments,
  required Set<PaymentKey> paid,
}) => List.generate(widgetTimelineDays, (i) {
  final day = today.add(Duration(days: i));
  final brief = MonthBrief.build(month: YearMonth.of(day), today: day, commitments: commitments, paid: paid);
  return WidgetDay(date: day, snapshot: WidgetSnapshot.of(brief));
});
