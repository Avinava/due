import 'package:flutter/material.dart';

import 'frame_scene.dart';
import 'frame_spec.dart';

/// A frame on a plain backdrop, sized to fit its chrome. Used by
/// the goldens and the README screenshots.
class FrameCanvas extends StatelessWidget {
  const FrameCanvas(this.spec, {super.key});

  static const _lightCanvas = Color(0xFFE8DFD1);
  static const _darkCanvas = Color(0xFF0E0B09);
  static const margin = 40.0;

  final FrameSpec spec;

  /// Logical size of the whole image.
  static Size sizeOf(FrameSpec spec) {
    final s = spec.kind.size;
    final chrome = switch (spec.kind) {
      FrameKind.phone => const Size(22, 22),
      FrameKind.wide => const Size(2, 40),
      FrameKind.widgetSmall || FrameKind.widgetMedium => const Size(80, 80),
    };
    return Size(s.width + chrome.width + margin * 2, s.height + chrome.height + margin * 2);
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: spec.dark ? _darkCanvas : _lightCanvas,
        child: Center(child: FrameScene(spec)),
      ),
    ),
  );
}
