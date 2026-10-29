import '../domain/commitment.dart';
import '../domain/month_brief.dart';
import 'household.dart';

/// Where the household lives. The app uses [DriftCommitmentRepository]; the
/// catalog and tests use [MemoryCommitmentRepository].
abstract interface class CommitmentRepository {
  /// Emits the household now and after every change.
  Stream<Household> watch();

  Future<Household> load();

  /// Loads the sample household the first time the app runs.
  Future<void> seedIfFirstRun(DateTime today);

  Future<void> resetToSample(DateTime today);

  /// Replaces every commitment and payment at once.
  Future<void> replaceAll(Household household);

  /// Inserts or updates [commitment], keeping its place in the list.
  Future<void> save(Commitment commitment);

  Future<void> setPaid(PaymentKey key, {required bool paid});

  Future<String?> pref(String key);

  Future<void> setPref(String key, String value);
}
