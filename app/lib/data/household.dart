import '../domain/commitment.dart';
import '../domain/month_brief.dart';

/// Everything the household has stored: its commitments in display order and
/// the occurrences marked paid.
final class Household {
  const Household({required this.commitments, required this.paid});

  static const empty = Household(commitments: [], paid: {});

  final List<Commitment> commitments;
  final Set<PaymentKey> paid;

  List<Commitment> get active => commitments.where((c) => !c.archived).toList();
}
