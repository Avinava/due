import 'package:due_catalog/frames/frame_canvas.dart';
import 'package:due_catalog/frames/frame_spec.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [spec] on its canvas at [pixelRatio] and waits for it to settle:
/// data loaded, sheet open, animations done.
Future<void> pumpFrame(WidgetTester tester, FrameSpec spec, {double pixelRatio = 1}) async {
  final size = FrameCanvas.sizeOf(spec);
  tester.view
    ..devicePixelRatio = pixelRatio
    ..physicalSize = size * pixelRatio;
  addTearDown(tester.view.reset);
  // Draw real, blurred shadows like the device does.
  // settleFrame restores it; the binding checks before tear-downs run.
  debugDisableShadows = false;
  await tester.pumpWidget(FrameCanvas(spec));
  // Let the in-memory stream deliver, then the sheet animate in.
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// Lets any timers a frame started run out before the test ends, and puts
/// the shadow switch back.
Future<void> settleFrame(WidgetTester tester) async {
  debugDisableShadows = true;
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
