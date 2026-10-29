import 'cadence.dart';
import 'calendar.dart';

/// One date a commitment falls due.
final class Occurrence {
  const Occurrence(this.date, {this.seq, this.clampedFrom});

  final DateTime date;

  /// 1-based position for numbered cadences (an EMI or a school term).
  final int? seq;

  /// The requested day when the month was too short for it.
  final int? clampedFrom;

  bool get clamped => clampedFrom != null;

  @override
  bool operator ==(Object other) =>
      other is Occurrence && other.date == date && other.seq == seq && other.clampedFrom == clampedFrom;

  @override
  int get hashCode => Object.hash(date, seq, clampedFrom);

  @override
  String toString() => 'Occurrence(${date.toIso8601String().substring(0, 10)}, seq: $seq, clampedFrom: $clampedFrom)';
}

Occurrence _onDay(YearMonth m, int day, {int? seq}) =>
    Occurrence(m.clampedDay(day), seq: seq, clampedFrom: day > m.days ? day : null);

/// Every occurrence of [cadence] inside [month], in date order.
List<Occurrence> occurrencesIn(Cadence cadence, YearMonth month) {
  switch (cadence) {
    case Monthly(:final day, :final from, :final count):
      if (from == null) return [_onDay(month, day)];
      final seq = from.monthsUntil(month) + 1;
      if (seq < 1 || (count != null && seq > count)) return const [];
      return [_onDay(month, day, seq: seq)];

    case EveryNMonths(:final n, :final from, :final day):
      final diff = from.monthsUntil(month);
      if (diff < 0 || diff % n != 0) return const [];
      return [_onDay(month, day, seq: diff ~/ n + 1)];

    case Weekly(:final weekday, :final from):
      final start = dateOnly(from);
      return [
        for (var d = 1; d <= month.days; d++)
          if (DateTime.utc(month.year, month.month, d) case final t when t.weekday == weekday && !t.isBefore(start))
            Occurrence(t),
      ];

    case EveryNDays(:final n, :final anchor):
      final a = dateOnly(anchor);
      final first = month.first.difference(a).inDays;
      var i = first <= 0 ? 0 : (first + n - 1) ~/ n;
      final out = <Occurrence>[];
      for (var t = a.add(Duration(days: i * n)); !t.isAfter(month.last); t = a.add(Duration(days: ++i * n))) {
        if (!t.isBefore(month.first)) out.add(Occurrence(t));
      }
      return out;
  }
}

/// The next [count] occurrences on or after [from]. Searches up to 50 years
/// ahead and returns fewer when the cadence ends first.
List<Occurrence> upcoming(Cadence cadence, DateTime from, int count) {
  final start = dateOnly(from);
  final out = <Occurrence>[];
  var month = YearMonth.of(start);
  for (var i = 0; i < 600 && out.length < count; i++, month = month.plus(1)) {
    for (final o in occurrencesIn(cadence, month)) {
      if (!o.date.isBefore(start) && out.length < count) out.add(o);
    }
  }
  return out;
}
