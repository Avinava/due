import 'package:due_catalog/frames/frame_scene.dart';
import 'package:due_catalog/frames/frame_spec.dart';
import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // In the catalog a frame is a small part of a large window, and the browser
  // may be in dark mode. The frame must still behave like its own device.
  testWidgets('1e opens its sheet as a phone sheet, in light, inside a large dark window', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1600, 1200);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final spec = frames.firstWhere((f) => f.id == '1e');
    // Widgetbook hosts frames inside its own app.
    await tester.pumpWidget(MaterialApp(home: Center(child: FrameScene(spec))));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    final sheet = find.byType(BottomSheet);
    expect(sheet, findsOneWidget);
    expect(tester.getSize(sheet).width, spec.kind.size.width);
    final paper = Theme.of(tester.element(find.text('Credit card bill'))).bottomSheetTheme.modalBackgroundColor;
    expect(paper, DuePalette.light.paper);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
