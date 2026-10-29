@Tags(['shots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:due_catalog/frames/frame_canvas.dart';
import 'package:due_catalog/frames/frame_spec.dart';
import 'package:due_catalog/frames/hero_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/frame_pump.dart';

/// Renders the README images from the real app: every frame, the hero and
/// the social preview. Run with `mise run shots`.
const _out = '../docs/screenshots';
const _ratio = 2.0;

/// Writes the image under [boundary], a [RepaintBoundary] finder.
Future<void> _capture(WidgetTester tester, Finder boundary, String name) async {
  final render = tester.renderObject<RenderRepaintBoundary>(boundary);
  await tester.runAsync(() async {
    final image = await render.toImage(pixelRatio: _ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(loadDueFonts);

  for (final spec in frames) {
    testWidgets('shot ${spec.fileName}', (tester) async {
      await pumpFrame(tester, spec, pixelRatio: _ratio);
      await _capture(
        tester,
        find.descendant(of: find.byType(FrameCanvas), matching: find.byType(RepaintBoundary)).first,
        spec.fileName,
      );
      await settleFrame(tester);
    });
  }

  for (final social in [false, true]) {
    testWidgets(social ? 'shot social preview' : 'shot hero', (tester) async {
      final size = social ? HeroScene.socialSize : HeroScene.heroSize;
      tester.view
        ..devicePixelRatio = _ratio
        ..physicalSize = size * _ratio;
      addTearDown(tester.view.reset);
      debugDisableShadows = false;
      await tester.pumpWidget(RepaintBoundary(child: HeroScene(social: social)));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      await _capture(tester, find.byType(RepaintBoundary).first, social ? 'social_preview' : 'hero');
      await settleFrame(tester);
    });
  }
}
