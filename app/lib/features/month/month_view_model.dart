import 'package:due_kit/due_kit.dart';

import '../../domain/calendar.dart';
import '../../domain/commitment.dart';
import '../../domain/money.dart';
import '../../domain/month_brief.dart';

/// One day's heading and rows in the month list.
final class DayGroup {
  const DayGroup({required this.day, required this.label, required this.isToday, required this.rows});

  final int day;

  /// "SAT 10" or "TODAY · MON 12".
  final String label;
  final bool isToday;
  final List<RowModel> rows;
}

/// Everything the month screen shows, as plain strings and kit models. Pure,
/// so the design's copy is tested without pumping widgets.
final class MonthView {
  const MonthView({
    required this.brief,
    required this.monthLabel,
    required this.monthName,
    required this.heroLabel,
    required this.subLine,
    required this.done,
    required this.dial,
    required this.groups,
    required this.listTitle,
    this.delta,
    this.scrubLabel,
    this.emptyDay = false,
  });

  /// Builds the view for [brief]. [scrub] is the selected day, [flash] the
  /// occurrence just marked paid and [delta] the amount it took off.
  factory MonthView.of(MonthBrief brief, {int? scrub, PaymentKey? flash, int? delta}) {
    final m = brief.month;
    final today = brief.todayDay;
    final byDay = brief.byDay;
    String wd(int day) => weekdayShort[DateTime.utc(m.year, m.month, day).weekday - 1];

    RowModel row(DueItem i) => RowModel(
      id: i.key.toString(),
      name: i.commitment.name,
      schedule: scheduleLabel(i.commitment, i.occurrence),
      amount: formatInr(i.amount),
      status: switch (i.state) {
        DueState.due => i.day == today ? 'Due today' : 'Due ${wd(i.day)} ${i.day}',
        DueState.late => _late(brief.today.difference(i.date).inDays),
        DueState.paid => 'Paid',
        DueState.auto => 'Autopay ${wd(i.day)} ${i.day}',
        DueState.settled => 'Autopay · settled',
      },
      state: markState(i.state),
      semanticLabel: '${i.day} ${m.name}, ${i.commitment.name}, ${formatInr(i.amount)}, ${_spoken(i.state)}',
      flashing: flash != null && i.key == flash,
      toggleable: i.toggleable,
    );

    final days = {...byDay.keys, ?today}.toList()..sort();
    final shown = scrub == null ? days : days.where((d) => d == scrub && byDay.containsKey(d));
    final groups = [
      for (final d in shown)
        DayGroup(
          day: d,
          isToday: d == today,
          label: d == today ? 'TODAY · ${wd(d).toUpperCase()} $d' : '${wd(d).toUpperCase()} $d',
          rows: [for (final i in byDay[d] ?? const <DueItem>[]) row(i)],
        ),
    ];

    final marks = [
      for (final MapEntry(key: d, value: items) in byDay.entries)
        DialMark(
          day: d,
          state: markState(_mostUrgent(items)),
          label:
              '$d ${m.name}, ${items.map((i) => '${i.commitment.name}, ${formatInr(i.amount)}, ${_spoken(i.state)}').join('; ')}',
        ),
    ];

    final (line1, line2, line3) = _centre(brief, scrub, wd);
    return MonthView(
      brief: brief,
      monthLabel: m.label,
      monthName: m.name,
      heroLabel: brief.isCurrent
          ? 'NEEDS YOU'
          : brief.isPast
          ? '${brief.needsYou == 0 ? 'SETTLED' : 'STILL UNPAID'} IN ${m.name.toUpperCase()}'
          : 'NEEDS YOU IN ${m.name.toUpperCase()}',
      subLine: '${formatInr(brief.committed)} committed · ${formatInr(brief.autopayTotal)} on autopay',
      done: brief.allSettled,
      delta: delta != null && brief.isCurrent ? formatInr(-delta) : null,
      dial: DialModel(
        days: m.days,
        today: today,
        selected: scrub,
        elapsedDays: brief.isPast ? m.days.toDouble() : (today == null ? 0 : today - 1.0),
        marks: marks,
        line1: line1,
        line2: line2,
        line3: line3,
      ),
      groups: groups,
      scrubLabel: scrub == null
          ? null
          : '${weekdayNames[DateTime.utc(m.year, m.month, scrub).weekday - 1]} $scrub ${m.name}',
      emptyDay: scrub != null && !byDay.containsKey(scrub),
      listTitle: scrub == null
          ? '${brief.items.length} charges this month'
          : '${wd(scrub)} $scrub ${monthShort[m.month - 1]}',
    );
  }

  final MonthBrief brief;
  final String monthLabel;
  final String monthName;
  final String heroLabel;
  final String subLine;
  final bool done;
  final String? delta;
  final DialModel dial;
  final List<DayGroup> groups;

  /// "Thursday 15 October" while a day is scrubbed.
  final String? scrubLabel;

  /// A scrubbed day with nothing due.
  final bool emptyDay;

  /// Wide list heading: "9 charges this month" or "Thu 15 Oct".
  final String listTitle;

  int get needsYou => brief.needsYou;

  /// The item behind a row, by [RowModel.id].
  DueItem? itemFor(String rowId) => brief.items.where((i) => i.key.toString() == rowId).firstOrNull;
}

MarkState markState(DueState s) => switch (s) {
  DueState.due => MarkState.due,
  DueState.late => MarkState.late,
  DueState.paid => MarkState.paid,
  DueState.auto => MarkState.auto,
  DueState.settled => MarkState.settled,
};

String _late(int days) => '${dayCount(days)} late';

String _spoken(DueState s) => switch (s) {
  DueState.due || DueState.late => 'unpaid',
  DueState.auto => 'autopay',
  DueState.paid || DueState.settled => 'paid',
};

DueState _mostUrgent(List<DueItem> items) {
  for (final s in const [DueState.late, DueState.due, DueState.auto, DueState.paid]) {
    if (items.any((i) => i.state == s)) return s;
  }
  return DueState.settled;
}

(String, String, String) _centre(MonthBrief brief, int? scrub, String Function(int) wd) {
  final m = brief.month;
  final mon = monthShort[m.month - 1].toUpperCase();
  if (scrub != null) {
    final items = brief.byDay[scrub] ?? const <DueItem>[];
    final sum = items.fold(0, (a, i) => a + i.amount);
    final line3 = switch (items) {
      [] => 'Nothing due',
      [final one] =>
        '${one.commitment.name} · ${switch (one.state) {
          DueState.due || DueState.late => 'needs you',
          DueState.auto => 'autopay',
          _ => 'paid',
        }}',
      _ => '${items.length} items',
    };
    return ('${wd(scrub).toUpperCase()} $scrub $mon', items.isEmpty ? '—' : formatInr(sum), line3);
  }
  if (brief.todayDay case final today?) {
    final head = '${wd(today).toUpperCase()} $today $mon';
    if (brief.allSettled) {
      final left = brief.autopaysLeft;
      return (head, 'All clear', left > 0 ? '$left autopay${left > 1 ? 's' : ''} still to run' : 'Month settled');
    }
    final next = brief.nextManual;
    return (
      head,
      '${dayCount(m.days - today)} left',
      next == null ? '' : 'Next: ${next.commitment.name}, ${wd(next.day)} ${next.day}',
    );
  }
  final unpaid = brief.items.where((i) => i.state.needsYou).length;
  return (
    m.name.toUpperCase(),
    '${brief.items.length} charges',
    !brief.isPast
        ? '${formatInr(brief.committed)} committed'
        : unpaid == 0
        ? 'All settled'
        : '$unpaid unpaid',
  );
}
