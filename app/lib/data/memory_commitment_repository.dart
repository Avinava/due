import 'dart:async';

import '../domain/commitment.dart';
import '../domain/month_brief.dart';
import 'commitment_repository.dart';
import 'household.dart';
import 'sample_household.dart';

/// [CommitmentRepository] held in memory: for the catalog, screenshots and
/// tests. Behaves like the drift one, including change notifications.
final class MemoryCommitmentRepository implements CommitmentRepository {
  MemoryCommitmentRepository([Household initial = Household.empty]) : _household = initial;

  /// Starts from the sample household for [today], plus [extraPaid].
  factory MemoryCommitmentRepository.sample(DateTime today, {Set<PaymentKey> extraPaid = const {}}) {
    final s = sampleHousehold(today);
    return MemoryCommitmentRepository(Household(commitments: s.commitments, paid: {...s.paid, ...extraPaid}))
      .._seeded = true;
  }

  Household _household;
  bool _seeded = false;
  final _prefs = <String, String>{};
  final _changes = StreamController<Household>.broadcast();

  void _emit(Household h) {
    _household = h;
    _changes.add(h);
  }

  @override
  Stream<Household> watch() async* {
    yield _household;
    yield* _changes.stream;
  }

  @override
  Future<Household> load() async => _household;

  @override
  Future<void> seedIfFirstRun(DateTime today) async {
    if (_seeded) return;
    await resetToSample(today);
  }

  @override
  Future<void> resetToSample(DateTime today) async {
    final s = sampleHousehold(today);
    await replaceAll(Household(commitments: s.commitments, paid: s.paid));
  }

  @override
  Future<void> replaceAll(Household household) async {
    _seeded = true;
    _emit(Household(commitments: List.unmodifiable(household.commitments), paid: Set.unmodifiable(household.paid)));
  }

  @override
  Future<void> save(Commitment commitment) async {
    final list = [..._household.commitments];
    final i = list.indexWhere((c) => c.id == commitment.id);
    i < 0 ? list.add(commitment) : list[i] = commitment;
    _emit(Household(commitments: list, paid: _household.paid));
  }

  @override
  Future<void> setPaid(PaymentKey key, {required bool paid}) async {
    final next = {..._household.paid};
    paid ? next.add(key) : next.remove(key);
    _emit(Household(commitments: _household.commitments, paid: next));
  }

  @override
  Future<String?> pref(String key) async => _prefs[key];

  @override
  Future<void> setPref(String key, String value) async => _prefs[key] = value;
}
