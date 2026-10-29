import 'calendar.dart';

/// How a commitment repeats. The rules each variant follows are written up in
/// docs/recurrence.md.
sealed class Cadence {
  const Cadence();
}

/// Every month on [day]. A day past the end of a month falls on its last day
/// and comes back the month after.
///
/// With [from], occurrences start that month and are numbered from 1; with
/// [count] as well, they stop after that many (an EMI).
final class Monthly extends Cadence {
  const Monthly({required this.day, this.from, this.count})
    : assert(day >= 1 && day <= 31),
      assert(count == null || from != null);

  final int day;
  final YearMonth? from;
  final int? count;

  @override
  bool operator ==(Object other) => other is Monthly && other.day == day && other.from == from && other.count == count;

  @override
  int get hashCode => Object.hash(day, from, count);
}

/// Every [n] months starting [from], on [day]. Covers
/// quarterly (3), half-yearly (6), yearly (12) and school terms.
///
/// With [terms], occurrences are labelled "Term i of [terms]".
final class EveryNMonths extends Cadence {
  const EveryNMonths({required this.n, required this.from, required this.day, this.terms})
    : assert(n >= 2 && n <= 24),
      assert(day >= 1 && day <= 31);

  final int n;
  final YearMonth from;

  /// Day of month; clamped in short months like [Monthly.day].
  final int day;
  final int? terms;

  @override
  bool operator ==(Object other) =>
      other is EveryNMonths && other.n == n && other.from == from && other.day == day && other.terms == terms;

  @override
  int get hashCode => Object.hash(n, from, day, terms);
}

/// Every week on [weekday] (DateTime.monday to DateTime.sunday), on or after
/// [from].
final class Weekly extends Cadence {
  const Weekly({required this.weekday, required this.from})
    : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday);

  final int weekday;
  final DateTime from;

  @override
  bool operator ==(Object other) => other is Weekly && other.weekday == weekday && other.from == from;

  @override
  int get hashCode => Object.hash(weekday, from);
}

/// Every [n] days from [anchor], ignoring month boundaries. A 28-day prepaid
/// plan drifts through the calendar this way.
final class EveryNDays extends Cadence {
  const EveryNDays({required this.n, required this.anchor}) : assert(n >= 2 && n <= 365);

  final int n;
  final DateTime anchor;

  @override
  bool operator ==(Object other) => other is EveryNDays && other.n == n && other.anchor == anchor;

  @override
  int get hashCode => Object.hash(n, anchor);
}
