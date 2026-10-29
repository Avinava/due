import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';

/// Presentation chrome around the screenshots. These colours belong to the
/// backdrop, not to the app, so they are not tokens.
abstract final class _Chrome {
  static const bezelLight = Color(0xFF1A1411);
  static const bezelDark = Color(0xFF2A221D);
  static const windowBarLight = Color(0xFFEDE4D6);
  static const windowBarDark = Color(0xFF211B17);
  static const windowEdgeLight = Color(0xFFCDBCA6);
  static const windowEdgeDark = Color(0xFF2E2620);
  static const close = Color(0xFFE0675B);
  static const minimise = Color(0xFFE3B341);
  static const zoom = Color(0xFF5FB35A);
  static const wallpaperLight = [Color(0xFFCBBFAE), Color(0xFFD6CBBB)];
  static const wallpaperDark = [Color(0xFF1E1813), Color(0xFF2A221C)];
}

/// An iPhone-like bezel with the 9:41 status bar and home indicator.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.dark = false});

  /// The insets the status bar and home indicator take.
  static const safeArea = EdgeInsets.only(top: 50, bottom: 34);

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = dark ? DuePalette.dark : DuePalette.light;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: dark ? _Chrome.bezelDark : _Chrome.bezelLight,
        borderRadius: BorderRadius.circular(58),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .8 : .45),
            blurRadius: 80,
            offset: const Offset(0, 40),
            spreadRadius: -30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(47),
        child: Stack(
          children: [
            child,
            Positioned(left: 0, right: 0, top: 0, child: _StatusBar(color: p.ink)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(color: p.ink, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget bar(double h) => Container(
      width: 3,
      height: h,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
    );
    return IgnorePointer(
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(left: 34, right: 30),
          child: Row(
            children: [
              Text(
                '9:41',
                textScaler: TextScaler.noScaling,
                style: DueType.body(16, weight: FontWeight.w600, color: color),
              ),
              const Spacer(),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [bar(4), bar(6), bar(8), bar(11)]),
              const SizedBox(width: 6),
              Container(
                width: 24,
                height: 12,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  border: Border.all(color: color.withValues(alpha: .9), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: .7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A macOS window with traffic lights, for the wide frames.
class WindowFrame extends StatelessWidget {
  const WindowFrame({super.key, required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final edge = dark ? _Chrome.windowEdgeDark : _Chrome.windowEdgeLight;
    Widget light(Color c) => Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: edge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .6 : .4),
            blurRadius: 80,
            offset: const Offset(0, 40),
            spreadRadius: -30,
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: dark ? _Chrome.windowBarDark : _Chrome.windowBarLight,
                border: Border(bottom: BorderSide(color: edge)),
              ),
              child: Row(children: [light(_Chrome.close), light(_Chrome.minimise), light(_Chrome.zoom)]),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// A home screen widget on a striped placeholder wallpaper.
class WidgetFrame extends StatelessWidget {
  const WidgetFrame({super.key, required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final stripes = dark ? _Chrome.wallpaperDark : _Chrome.wallpaperLight;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: const Alignment(-.86, -.86),
          colors: [stripes[0], stripes[0], stripes[1], stripes[1]],
          stops: const [0, .14, .14, 1],
          tileMode: TileMode.repeated,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DueRadius.widget),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? .6 : .35),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: -12,
            ),
          ],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(DueRadius.widget), child: child),
      ),
    );
  }
}
