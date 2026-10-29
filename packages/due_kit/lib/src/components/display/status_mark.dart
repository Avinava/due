import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import 'mark_style.dart';

/// The round state mark at the start of every row.
class StatusMark extends StatelessWidget {
  const StatusMark(this.state, {super.key, this.size = 26});

  final MarkState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = MarkStyle.of(state, DueTheme.of(context));
    return TweenAnimationBuilder<double>(
      key: ValueKey(state),
      tween: Tween(begin: .6, end: 1),
      duration: DueMotion.markFill,
      curve: Curves.easeOutBack,
      builder: (context, t, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _MarkPainter(style, t, stroke: size / 13)),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.style, this.t, {required this.stroke});

  final MarkStyle style;
  final double t;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - stroke / 2;
    canvas.drawCircle(c, r, Paint()..color = style.fill);
    final ring = Paint()
      ..color = style.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    if (style.dashed) {
      const dashes = 10;
      const sweep = math.pi * 2 / dashes;
      for (var i = 0; i < dashes; i++) {
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * sweep, sweep * .55, false, ring);
      }
    } else {
      canvas.drawCircle(c, r, ring);
    }

    final g = Paint()
      ..color = style.glyphColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 1.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final u = size.width / 26 * t;
    switch (style.glyph) {
      case MarkGlyph.none:
        break;
      case MarkGlyph.check:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 5 * u, c.dy + .2 * u)
            ..lineTo(c.dx - 1.6 * u, c.dy + 3.6 * u)
            ..lineTo(c.dx + 5.2 * u, c.dy - 3.6 * u),
          g,
        );
      case MarkGlyph.alert:
        canvas.drawLine(c.translate(0, -5 * u), c.translate(0, 1.4 * u), g);
        canvas.drawCircle(c.translate(0, 5 * u), stroke * .7, Paint()..color = style.glyphColor);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.t != t || oldDelegate.stroke != stroke;
}
