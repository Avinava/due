import '../domain/cadence.dart';
import '../domain/calendar.dart';

/// JSON form of a [Cadence], shared by the database column and the backup
/// file. Dates are `yyyy-mm-dd`, months are `yyyy-mm`.
abstract final class CadenceCodec {
  static Map<String, Object?> encode(Cadence c) => switch (c) {
    Monthly(:final day, :final from, :final count) => {
      'kind': 'monthly',
      'day': day,
      'from': ?from?.toString(),
      'count': ?count,
    },
    EveryNMonths(:final n, :final from, :final day, :final terms) => {
      'kind': 'months',
      'n': n,
      'from': from.toString(),
      'day': day,
      'terms': ?terms,
    },
    Weekly(:final weekday, :final from) => {'kind': 'weekly', 'weekday': weekday, 'from': encodeDate(from)},
    EveryNDays(:final n, :final anchor) => {'kind': 'days', 'n': n, 'anchor': encodeDate(anchor)},
  };

  /// Throws [FormatException] on anything that is not a valid cadence.
  static Cadence decode(Map<String, Object?> j) {
    int i(String k, int min, int max) {
      final v = j[k];
      if (v is! int || v < min || v > max) throw FormatException('cadence.$k must be an integer $min to $max');
      return v;
    }

    int? oi(String k, int min, int max) => j.containsKey(k) ? i(k, min, max) : null;

    String s(String k) {
      final v = j[k];
      if (v is! String) throw FormatException('cadence.$k must be a string');
      return v;
    }

    return switch (j['kind']) {
      'monthly' => Monthly(
        day: i('day', 1, 31),
        from: j.containsKey('from') ? decodeMonth(s('from')) : null,
        count: j.containsKey('from') ? oi('count', 1, 600) : null,
      ),
      'months' => EveryNMonths(
        n: i('n', 2, 24),
        from: decodeMonth(s('from')),
        day: i('day', 1, 31),
        terms: oi('terms', 1, 12),
      ),
      'weekly' => Weekly(weekday: i('weekday', 1, 7), from: decodeDate(s('from'))),
      'days' => EveryNDays(n: i('n', 2, 365), anchor: decodeDate(s('anchor'))),
      final k => throw FormatException('Unknown cadence kind $k'),
    };
  }

  static String encodeDate(DateTime d) => d.toIso8601String().substring(0, 10);

  static DateTime decodeDate(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
    if (m == null) throw FormatException('Bad date $s');
    final d = DateTime.utc(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    if (encodeDate(d) != s) throw FormatException('Bad date $s');
    return d;
  }

  static YearMonth decodeMonth(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(s);
    final month = m == null ? 0 : int.parse(m[2]!);
    if (m == null || month < 1 || month > 12) throw FormatException('Bad month $s');
    return YearMonth(int.parse(m[1]!), month);
  }
}
