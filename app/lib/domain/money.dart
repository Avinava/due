import 'package:intl/intl.dart';

final _indian = NumberFormat.decimalPattern('en_IN');

/// Whole rupees with Indian grouping and no symbol: 123227 -> "1,23,227".
String groupInr(int rupees) => _indian.format(rupees);

/// Whole rupees with the symbol: 42000 -> "₹42,000".
String formatInr(int rupees) => rupees < 0 ? '−₹${groupInr(-rupees)}' : '₹${groupInr(rupees)}';
