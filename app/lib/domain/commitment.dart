import 'cadence.dart';
import 'recurrence.dart';

/// Money a household has promised to pay on a schedule.
final class Commitment {
  const Commitment({
    required this.id,
    required this.name,
    required this.amount,
    required this.cadence,
    required this.createdAt,
    this.autopay = false,
    this.archived = false,
  });

  final String id;
  final String name;

  /// Whole rupees.
  final int amount;
  final Cadence cadence;

  /// Paid by a mandate or card on file. Counted as committed, never as
  /// needing the household.
  final bool autopay;

  /// Manual occurrences before this date are history and count as paid.
  final DateTime createdAt;
  final bool archived;

  Commitment copyWith({String? name, int? amount, Cadence? cadence, bool? autopay, bool? archived}) => Commitment(
    id: id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    cadence: cadence ?? this.cadence,
    createdAt: createdAt,
    autopay: autopay ?? this.autopay,
    archived: archived ?? this.archived,
  );
}

/// The schedule line under a commitment's name: "Quarterly", "EMI 14 of 36",
/// "Every 28 days · autopay".
String scheduleLabel(Commitment c, [Occurrence? o]) {
  final base = switch (c.cadence) {
    Monthly(:final count?) when o?.seq != null => 'EMI ${o!.seq} of $count',
    Monthly() => 'Monthly',
    EveryNMonths(:final terms?) when o?.seq != null => 'Term ${(o!.seq! - 1) % terms + 1} of $terms',
    EveryNMonths(n: 3) => 'Quarterly',
    EveryNMonths(n: 6) => 'Half-yearly',
    EveryNMonths(n: 12) => 'Yearly',
    EveryNMonths(:final n) => 'Every $n months',
    Weekly() => 'Weekly',
    EveryNDays(:final n) => 'Every $n days',
  };
  return c.autopay ? '$base · autopay' : base;
}
