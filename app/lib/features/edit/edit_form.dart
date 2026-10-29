import '../../domain/cadence.dart';
import '../../domain/calendar.dart';
import '../../domain/commitment.dart';
import '../../domain/recurrence.dart';

/// The four choices in the sheet's repeat picker.
enum RepeatKind {
  monthly('Monthly'),
  everyNMonths('Every N months'),
  weekly('Weekly'),
  everyNDays('Every N days');

  const RepeatKind(this.label);

  final String label;
}

/// One row of the "next 3 dates" preview.
final class PreviewDate {
  const PreviewDate({required this.weekday, required this.date, this.clampedFrom});

  /// "THU".
  final String weekday;

  /// "31 Dec 2026".
  final String date;
  final int? clampedFrom;

  String? get note => clampedFrom == null ? null : 'Clamped from ${ordinal(clampedFrom!)}';
}

/// The add/edit sheet's state. Immutable; every edit returns a new form.
final class EditForm {
  const EditForm({
    required this.start,
    this.id,
    this.name = '',
    this.amount = 0,
    this.kind = RepeatKind.monthly,
    this.day = 1,
    this.weekday = DateTime.monday,
    this.months = 3,
    this.days = 28,
    this.autopay = false,
    this.count,
    this.terms,
    this.weeklyFrom,
    this.openStart = false,
    this.createdAt,
  });

  /// A blank form for a new commitment, due on today's day from this month.
  factory EditForm.blank(DateTime today) => EditForm(start: YearMonth.of(today), day: today.day);

  /// The form for editing [c].
  factory EditForm.from(Commitment c) {
    final base = EditForm(
      id: c.id,
      name: c.name,
      amount: c.amount,
      autopay: c.autopay,
      createdAt: c.createdAt,
      start: YearMonth.of(c.createdAt),
      count: switch (c.cadence) {
        Monthly(:final count) => count,
        _ => null,
      },
      terms: switch (c.cadence) {
        EveryNMonths(:final terms) => terms,
        _ => null,
      },
      weeklyFrom: switch (c.cadence) {
        Weekly(:final from) => from,
        _ => null,
      },
      openStart: switch (c.cadence) {
        Monthly(from: null) => true,
        _ => false,
      },
    );
    return switch (c.cadence) {
      Monthly(:final day, :final from) => base.copyWith(day: day, start: from),
      EveryNMonths(:final n, :final from, :final day) => base.copyWith(
        kind: RepeatKind.everyNMonths,
        months: n,
        day: day,
        start: from,
      ),
      Weekly(:final weekday, :final from) => base.copyWith(
        kind: RepeatKind.weekly,
        weekday: weekday,
        start: YearMonth.of(from),
      ),
      EveryNDays(:final n, :final anchor) => base.copyWith(
        kind: RepeatKind.everyNDays,
        days: n,
        day: anchor.day,
        start: YearMonth.of(anchor),
      ),
    };
  }

  static const minMonths = 2, maxMonths = 24, minDays = 2, maxDays = 365;
  static const maxAmount = 999999999;

  final String? id;
  final String name;
  final int amount;
  final RepeatKind kind;

  /// Day of month for monthly and every-N-months; first day for every-N-days.
  final int day;
  final int weekday;
  final int months;
  final int days;
  final YearMonth start;
  final bool autopay;

  /// Payments in a fixed run (an EMI). The sheet has no control for it, so it
  /// is carried over from the commitment being edited.
  final int? count;

  /// Terms in a year (school fees), carried over like [count].
  final int? terms;

  /// A weekly commitment's first day. Kept while [start] stays in its month;
  /// otherwise a weekly rule starts on the first of [start].
  final DateTime? weeklyFrom;

  /// A monthly commitment with no start month (rent since forever). It stays
  /// open-ended until the start is stepped.
  final bool openStart;
  final DateTime? createdAt;

  bool get isNew => id == null;
  bool get isValid => name.trim().isNotEmpty && amount > 0;

  Cadence get cadence => switch (kind) {
    RepeatKind.monthly => openStart ? Monthly(day: day) : Monthly(day: day, from: start, count: count),
    RepeatKind.everyNMonths => EveryNMonths(n: months, from: start, day: day, terms: terms),
    RepeatKind.weekly => Weekly(
      weekday: weekday,
      from: weeklyFrom != null && YearMonth.of(weeklyFrom!) == start ? weeklyFrom! : start.first,
    ),
    RepeatKind.everyNDays => EveryNDays(n: days, anchor: start.clampedDay(day)),
  };

  /// The next three dates from the start month, flagging month-end clamps.
  List<PreviewDate> get preview => [
    for (final o in upcoming(cadence, start.first, 3))
      PreviewDate(
        weekday: weekdayShort[o.date.weekday - 1].toUpperCase(),
        date: '${o.date.day} ${monthShort[o.date.month - 1]} ${o.date.year}',
        clampedFrom: o.clampedFrom,
      ),
  ];

  /// The line under the preview.
  String get previewNote => preview.any((p) => p.clampedFrom != null)
      ? 'Months without a ${ordinal(day)} fall on their last day. The ${ordinal(day)} comes back the month after.'
      : 'Dates update as you change the rule.';

  Commitment toCommitment({required String newId, required DateTime today}) => Commitment(
    id: id ?? newId,
    name: name.trim(),
    amount: amount,
    cadence: cadence,
    autopay: autopay,
    createdAt: createdAt ?? today,
  );

  /// Steps [day] round 1 to 31.
  EditForm stepDay(int delta) => copyWith(day: (day - 1 + delta) % 31 + 1);
  EditForm stepWeekday(int delta) => copyWith(weekday: (weekday - 1 + delta) % 7 + 1);
  EditForm stepMonths(int delta) => copyWith(months: (months + delta).clamp(minMonths, maxMonths));
  EditForm stepDays(int delta) => copyWith(days: (days + delta).clamp(minDays, maxDays));
  EditForm stepStart(int delta) => copyWith(start: start.plus(delta), openStart: false);

  /// Keeps digits only, up to [maxAmount].
  EditForm withAmountText(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final v = digits.isEmpty ? 0 : int.parse(digits.length > 9 ? digits.substring(0, 9) : digits);
    return copyWith(amount: v);
  }

  EditForm copyWith({
    String? name,
    int? amount,
    RepeatKind? kind,
    int? day,
    int? weekday,
    int? months,
    int? days,
    YearMonth? start,
    bool? autopay,
    bool? openStart,
  }) => EditForm(
    id: id,
    createdAt: createdAt,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    kind: kind ?? this.kind,
    day: day ?? this.day,
    weekday: weekday ?? this.weekday,
    months: months ?? this.months,
    days: days ?? this.days,
    start: start ?? this.start,
    autopay: autopay ?? this.autopay,
    count: count,
    terms: terms,
    weeklyFrom: weeklyFrom,
    openStart: openStart ?? this.openStart,
  );
}
