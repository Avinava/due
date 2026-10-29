import 'package:due_catalog/frames/frame_canvas.dart';
import 'package:due_catalog/frames/frame_spec.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/frame_pump.dart';

/// One golden per design frame. Update with `mise run golden`.
void main() {
  setUpAll(loadDueFonts);

  for (final spec in frames) {
    testWidgets('${spec.id} ${spec.title} ${spec.dark ? 'dark' : 'light'}', (tester) async {
      await pumpFrame(tester, spec);
      await expectLater(find.byType(FrameCanvas), matchesGoldenFile('goldens/${spec.fileName}.png'));
      await settleFrame(tester);
    });
  }

  test('every design frame has a spec', () {
    expect(
      {for (final f in frames) f.id},
      {for (var c = 'a'.codeUnitAt(0); c <= 'o'.codeUnitAt(0); c++) '1${String.fromCharCode(c)}'},
    );
    expect({for (final f in frames) f.fileName}, hasLength(frames.length));
  });
}
