import 'package:flutter/widgets.dart';

import '../../display/mark_style.dart';

/// One day on the dial that has something due.
@immutable
class DialMark {
  const DialMark({required this.day, required this.state, required this.label});

  final int day;

  /// The most urgent state among the day's items.
  final MarkState state;

  /// Screen reader text, e.g. "15 October, School fees, ₹42,000, unpaid".
  final String label;
}

/// Everything the dial draws. Built by the app from its month view model.
@immutable
class DialModel {
  const DialModel({
    required this.days,
    required this.marks,
    required this.line1,
    required this.line2,
    required this.line3,
    this.today,
    this.selected,
    this.elapsedDays = 0,
    this.semanticLabel = 'Month dial. Drag to scrub through days.',
  });

  /// Days in the month.
  final int days;
  final List<DialMark> marks;

  /// Today's day when the dial shows the current month.
  final int? today;

  /// The scrubbed day, or null for the whole month.
  final int? selected;

  /// How much of the ring is filled: today - 1 for the current month, all of
  /// it for a past month.
  final double elapsedDays;

  /// The three lines in the middle: "MON 12 OCT", "19 days left",
  /// "Next: Society maintenance, Sat 10".
  final String line1;
  final String line2;
  final String line3;
  final String semanticLabel;
}
