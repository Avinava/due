import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/commitment_repository.dart';
import '../data/database.dart';
import '../data/drift_commitment_repository.dart';
import '../data/household.dart';
import '../domain/calendar.dart';

/// The wall clock. Tests, goldens and the catalog pin it to 12 Oct 2026.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today as a UTC calendar date. Recomputed at local midnight; the app shell
/// also invalidates it on resume, since timers do not run while suspended.
final todayProvider = Provider<DateTime>((ref) {
  final now = ref.watch(clockProvider)();
  final midnight = Timer(DateTime(now.year, now.month, now.day + 1).difference(now), ref.invalidateSelf);
  ref.onDispose(midnight.cancel);
  return dateOnly(now);
});

final databaseProvider = Provider<DueDatabase>((ref) {
  final db = DueDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Override with a MemoryCommitmentRepository in tests and the catalog.
final repositoryProvider = Provider<CommitmentRepository>(
  (ref) => DriftCommitmentRepository(ref.watch(databaseProvider)),
);

/// The stored household, seeded with the sample on first run.
final householdProvider = StreamProvider<Household>((ref) async* {
  final repo = ref.watch(repositoryProvider);
  await repo.seedIfFirstRun(ref.read(todayProvider));
  yield* repo.watch();
});
