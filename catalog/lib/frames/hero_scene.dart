import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';

import 'frame_scene.dart';
import 'frame_spec.dart';

/// The README hero and the GitHub social preview: the wide view behind a
/// light and a dark phone, with the wordmark and pitch.
class HeroScene extends StatelessWidget {
  const HeroScene({super.key, this.social = false});

  /// 1280×640 for GitHub's social preview; otherwise the 1600×900 hero.
  final bool social;

  static const heroSize = Size(1600, 900);
  static const socialSize = Size(1280, 640);

  static const _canvas = Color(0xFFE8DFD1);

  @override
  Widget build(BuildContext context) {
    final size = social ? socialSize : heroSize;
    FrameSpec spec(String id, {bool dark = false}) =>
        frames.firstWhere((f) => f.id == id && f.dark == dark && f.kind != FrameKind.widgetSmall);
    final p = DuePalette.light;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: dueThemeData(Brightness.light),
        child: SizedBox.fromSize(
          size: size,
          child: ColoredBox(
            color: _canvas,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: size.width * .34,
                  top: size.height * .12,
                  child: Transform.scale(
                    scale: social ? .62 : .78,
                    alignment: Alignment.topLeft,
                    child: FrameScene(spec('1l')),
                  ),
                ),
                Positioned(
                  left: size.width * (social ? .36 : .4),
                  bottom: -size.height * (social ? .32 : .2),
                  child: Transform.scale(
                    scale: social ? .74 : .82,
                    alignment: Alignment.bottomLeft,
                    child: FrameScene(spec('1a')),
                  ),
                ),
                Positioned(
                  left: size.width * (social ? .6 : .62),
                  bottom: -size.height * (social ? .4 : .28),
                  child: Transform.scale(
                    scale: social ? .74 : .82,
                    alignment: Alignment.bottomLeft,
                    child: FrameScene(spec('1h', dark: true)),
                  ),
                ),
                Positioned(
                  left: social ? 64 : 88,
                  top: social ? 72 : 110,
                  width: size.width * (social ? .27 : .28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wordmark(size: social ? 96 : 120),
                      SizedBox(height: social ? 20 : 28),
                      Text(
                        'What your household has committed to pay this month, and what still needs you.',
                        textScaler: TextScaler.noScaling,
                        style: DueType.body(social ? 22 : 26, color: p.muted, height: 1.3),
                      ),
                      SizedBox(height: social ? 20 : 28),
                      Text(
                        'Flutter · iOS · macOS · web',
                        textScaler: TextScaler.noScaling,
                        style: DueType.mono(social ? 14 : 16, em: .08, color: p.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
