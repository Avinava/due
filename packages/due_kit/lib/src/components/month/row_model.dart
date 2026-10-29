import 'package:flutter/widgets.dart';

import '../display/mark_style.dart';

/// What one row shows. Built by the app; the kit only lays it out.
@immutable
class RowModel {
  const RowModel({
    required this.id,
    required this.name,
    required this.schedule,
    required this.amount,
    required this.status,
    required this.state,
    required this.semanticLabel,
    this.flashing = false,
    this.toggleable = true,
  });

  final String id;
  final String name;

  /// "Quarterly", "EMI 14 of 36 · autopay".
  final String schedule;

  /// Formatted, e.g. "₹42,000".
  final String amount;

  /// "Due Thu 15", "2 days late", "Paid", "Autopay Sun 18".
  final String status;
  final MarkState state;
  final String semanticLabel;

  /// Just marked paid: the row glows briefly.
  final bool flashing;

  /// Whether a tap can mark it paid or unpaid. Autopay rows never can.
  final bool toggleable;
}

enum RowLayout {
  /// Phone list row.
  phone,

  /// Wide list row with status and amount columns.
  wide,

  /// Large-text card (frame 1g).
  card,
}
