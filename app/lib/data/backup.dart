import 'dart:convert';

import '../domain/commitment.dart';
import '../domain/month_brief.dart';
import 'cadence_codec.dart';
import 'household.dart';

/// The versioned JSON backup format. Import is validated in full before
/// anything is replaced.
abstract final class Backup {
  static const version = 1;

  static String encode(Household h, {required DateTime exportedAt}) => const JsonEncoder.withIndent('  ').convert({
    'app': 'due',
    'version': version,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'commitments': [
      for (final c in h.commitments)
        {
          'id': c.id,
          'name': c.name,
          'amount': c.amount,
          'autopay': c.autopay,
          'archived': c.archived,
          'createdAt': CadenceCodec.encodeDate(c.createdAt),
          'cadence': CadenceCodec.encode(c.cadence),
        },
    ],
    'payments': [
      for (final p in h.paid) {'commitmentId': p.commitmentId, 'dueDate': CadenceCodec.encodeDate(p.dueDate)},
    ],
  });

  /// Parses and checks a backup. Throws [FormatException] with a message fit
  /// to show the user.
  static Household decode(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const FormatException('This file is not JSON.');
    }
    if (root is! Map || root['app'] != 'due') throw const FormatException('This is not a Due backup.');
    if (root['version'] != version) throw FormatException('Backup version ${root['version']} is not supported.');

    final rawCommitments = root['commitments'];
    final rawPayments = root['payments'];
    if (rawCommitments is! List || rawPayments is! List) throw const FormatException('The backup is incomplete.');

    final commitments = <Commitment>[];
    final ids = <String>{};
    for (final (index, raw) in rawCommitments.indexed) {
      if (raw is! Map) throw FormatException('Commitment ${index + 1} is malformed.');
      final j = raw.cast<String, Object?>();
      final id = j['id'], name = j['name'], amount = j['amount'], cadence = j['cadence'];
      if (id is! String || id.isEmpty || !ids.add(id)) throw FormatException('Commitment ${index + 1} has a bad id.');
      if (name is! String || name.trim().isEmpty) throw FormatException('Commitment ${index + 1} has no name.');
      if (amount is! int || amount < 0) throw FormatException('$name has a bad amount.');
      if (cadence is! Map) throw FormatException('$name has no schedule.');
      commitments.add(
        Commitment(
          id: id,
          name: name,
          amount: amount,
          autopay: j['autopay'] == true,
          archived: j['archived'] == true,
          createdAt: _date(j['createdAt'], '$name has a bad start date.'),
          cadence: CadenceCodec.decode(cadence.cast<String, Object?>()),
        ),
      );
    }

    final paid = <PaymentKey>{};
    for (final raw in rawPayments) {
      if (raw is! Map || raw['commitmentId'] is! String || !ids.contains(raw['commitmentId'])) {
        throw const FormatException('A payment points at a missing commitment.');
      }
      paid.add(PaymentKey(raw['commitmentId'] as String, _date(raw['dueDate'], 'A payment has a bad date.')));
    }
    return Household(commitments: commitments, paid: paid);
  }

  static DateTime _date(Object? value, String error) {
    if (value is! String) throw FormatException(error);
    try {
      return CadenceCodec.decodeDate(value);
    } on FormatException {
      throw FormatException(error);
    }
  }
}
