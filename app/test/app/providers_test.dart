import 'package:due/app/providers.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('today rolls over at local midnight', () {
    fakeAsync((async) {
      var now = DateTime(2026, 10, 31, 23, 59);
      final container = ProviderContainer(overrides: [clockProvider.overrideWithValue(() => now)]);
      addTearDown(container.dispose);
      container.listen(todayProvider, (_, _) {});
      expect(container.read(todayProvider), DateTime.utc(2026, 10, 31));

      now = DateTime(2026, 11, 1, 0, 0, 1);
      async.elapse(const Duration(minutes: 2));
      expect(container.read(todayProvider), DateTime.utc(2026, 11, 1));
    });
  });
}
