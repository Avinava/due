/// Calendar helpers. Every date in the domain is a UTC midnight, so day
/// arithmetic never crosses a daylight-saving boundary.
library;

/// The date part of [t] as a UTC midnight.
DateTime dateOnly(DateTime t) => DateTime.utc(t.year, t.month, t.day);

/// Number of days in [month] of [year].
int daysIn(int year, int month) => DateTime.utc(year, month + 1, 0).day;

const monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];
const monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// "1 day", "19 days".
String dayCount(int n) => '$n day${n == 1 ? '' : 's'}';

/// "1st", "2nd", "3rd", "11th", "31st".
String ordinal(int n) {
  final teen = n % 100 >= 11 && n % 100 <= 13;
  final suffix = teen
      ? 'th'
      : switch (n % 10) {
          1 => 'st',
          2 => 'nd',
          3 => 'rd',
          _ => 'th',
        };
  return '$n$suffix';
}

/// A calendar month, independent of any day.
final class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month) : assert(month >= 1 && month <= 12);

  factory YearMonth.of(DateTime t) => YearMonth(t.year, t.month);

  final int year;
  final int month;

  int get days => daysIn(year, month);
  DateTime get first => DateTime.utc(year, month, 1);
  DateTime get last => DateTime.utc(year, month, days);
  String get name => monthNames[month - 1];
  String get label => '$name $year';

  /// The month [n] months after this one; [n] may be negative.
  YearMonth plus(int n) {
    final index = year * 12 + (month - 1) + n;
    return YearMonth(index ~/ 12, index % 12 + 1);
  }

  /// Whole months from this month to [other].
  int monthsUntil(YearMonth other) => (other.year - year) * 12 + (other.month - month);

  /// The date for [day] in this month, clamped to the last day.
  DateTime clampedDay(int day) => DateTime.utc(year, month, day > days ? days : day);

  bool contains(DateTime t) => t.year == year && t.month == month;

  @override
  int compareTo(YearMonth other) => (year * 12 + month).compareTo(other.year * 12 + other.month);

  @override
  bool operator ==(Object other) => other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}
