import '../domain/cadence.dart';
import '../domain/calendar.dart';
import '../domain/commitment.dart';
import '../domain/month_brief.dart';

/// The household every fresh install, test and screenshot starts from.
///
/// Dates are relative to [today]'s month, so the app always looks lived in.
/// With today at 12 Oct 2026 it matches the design frames exactly: ₹73,680
/// needs you, ₹1,23,227 committed, ₹15,547 on autopay.
({List<Commitment> commitments, Set<PaymentKey> paid}) sampleHousehold(DateTime today) {
  final m = YearMonth.of(today);
  final created = m.first;
  DateTime on(YearMonth month, int day) => month.clampedDay(day);

  final commitments = [
    Commitment(id: 'rent', name: 'Rent', amount: 28000, cadence: const Monthly(day: 1), createdAt: created),
    Commitment(id: 'maid', name: 'Maid', amount: 6000, cadence: const Monthly(day: 5), createdAt: created),
    Commitment(
      id: 'jio',
      name: 'Jio prepaid',
      amount: 349,
      autopay: true,
      cadence: EveryNDays(n: 28, anchor: on(m, 3)),
      createdAt: created,
    ),
    Commitment(
      id: 'emi',
      name: 'Car EMI',
      amount: 14200,
      autopay: true,
      cadence: Monthly(day: 7, from: m.plus(-13), count: 36),
      createdAt: created,
    ),
    Commitment(
      id: 'society',
      name: 'Society maintenance',
      amount: 7500,
      cadence: EveryNMonths(n: 3, from: m.plus(-9), day: 10),
      createdAt: created,
    ),
    Commitment(
      id: 'school',
      name: 'School fees',
      amount: 42000,
      cadence: EveryNMonths(n: 4, from: m.plus(-4), day: 15, terms: 3),
      createdAt: created,
    ),
    Commitment(
      id: 'netflix',
      name: 'Netflix',
      amount: 649,
      autopay: true,
      cadence: const Monthly(day: 18),
      createdAt: created,
    ),
    Commitment(
      id: 'lic',
      name: 'LIC premium',
      amount: 24180,
      cadence: EveryNMonths(n: 12, from: m.plus(-12), day: 22),
      createdAt: created,
    ),
  ];
  return (commitments: commitments, paid: {PaymentKey('rent', on(m, 1)), PaymentKey('maid', on(m, 5))});
}
