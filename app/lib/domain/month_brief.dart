import 'calendar.dart';
import 'commitment.dart';
import 'recurrence.dart';

/// Where one occurrence stands relative to today.
enum DueState {
  /// Manual, unpaid, today or later.
  due,

  /// Manual, unpaid, already past.
  late,

  /// Manual and marked paid, or history from before the commitment existed.
  paid,

  /// Autopay, still to run.
  auto,

  /// Autopay, already run.
  settled;

  bool get needsYou => this == due || this == late;
}

/// Identifies one occurrence of one commitment.
final class PaymentKey {
  const PaymentKey(this.commitmentId, this.dueDate);

  final String commitmentId;
  final DateTime dueDate;

  @override
  bool operator ==(Object other) =>
      other is PaymentKey && other.commitmentId == commitmentId && other.dueDate == dueDate;

  @override
  int get hashCode => Object.hash(commitmentId, dueDate);

  @override
  String toString() => '$commitmentId@${dueDate.toIso8601String().substring(0, 10)}';
}

DueState stateOf(Commitment c, DateTime date, {required DateTime today, required bool paid}) {
  if (c.autopay) return date.isBefore(today) ? DueState.settled : DueState.auto;
  if (paid || date.isBefore(c.createdAt)) return DueState.paid;
  return date.isBefore(today) ? DueState.late : DueState.due;
}

/// One commitment falling due on one day, with its state.
final class DueItem {
  const DueItem(this.commitment, this.occurrence, this.state);

  final Commitment commitment;
  final Occurrence occurrence;
  final DueState state;

  DateTime get date => occurrence.date;
  int get day => occurrence.date.day;
  int get amount => commitment.amount;
  PaymentKey get key => PaymentKey(commitment.id, occurrence.date);

  /// Whether the household can mark it paid or unpaid: not autopay, and not
  /// from before the commitment was added (that history counts as paid).
  bool get toggleable => !commitment.autopay && !date.isBefore(commitment.createdAt);
}

/// Everything the month screen needs to know about one month.
final class MonthBrief {
  MonthBrief._(this.month, this.today, this.items);

  /// Builds the brief for [month] from active [commitments] and the set of
  /// occurrences marked [paid]. Items are in date order, then input order.
  factory MonthBrief.build({
    required YearMonth month,
    required DateTime today,
    required List<Commitment> commitments,
    required Set<PaymentKey> paid,
  }) {
    final t = dateOnly(today);
    final items = <DueItem>[
      for (final c in commitments.where((c) => !c.archived))
        for (final o in occurrencesIn(c.cadence, month))
          DueItem(c, o, stateOf(c, o.date, today: t, paid: paid.contains(PaymentKey(c.id, o.date)))),
    ];
    // List.sort is not stable, so break ties on input order.
    final order = {for (final (i, item) in items.indexed) item: i};
    items.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : order[a]!.compareTo(order[b]!);
    });
    return MonthBrief._(month, t, List.unmodifiable(items));
  }

  final YearMonth month;
  final DateTime today;
  final List<DueItem> items;

  bool get isCurrent => month.contains(today);
  bool get isPast => month.compareTo(YearMonth.of(today)) < 0;
  bool get isFuture => month.compareTo(YearMonth.of(today)) > 0;

  /// Today's day of month when this is the current month, else null.
  int? get todayDay => isCurrent ? today.day : null;

  int get committed => _sum(items);
  int get autopayTotal => _sum(items.where((i) => i.commitment.autopay));
  int get needsYou => _sum(items.where((i) => i.state.needsYou));
  int get autopaysLeft => items.where((i) => i.state == DueState.auto).length;

  /// The current month has charges and none of them needs the household.
  bool get allSettled => isCurrent && items.isNotEmpty && needsYou == 0;

  /// The earliest item that still needs the household.
  DueItem? get nextManual => items.where((i) => i.state.needsYou).firstOrNull;

  /// Items grouped by day of month, in day order.
  Map<int, List<DueItem>> get byDay {
    final out = <int, List<DueItem>>{};
    for (final i in items) {
      (out[i.day] ??= []).add(i);
    }
    return out;
  }

  static int _sum(Iterable<DueItem> items) => items.fold(0, (a, i) => a + i.amount);
}
