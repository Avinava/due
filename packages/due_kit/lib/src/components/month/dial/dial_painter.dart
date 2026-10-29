import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../foundation/tokens.g.dart';
import '../../display/mark_style.dart';
import 'dial_model.dart';

class DialPainter extends CustomPainter {
  DialPainter({
    required this.model,
    required this.palette,
    required this.from,
    required this.to,
    required this.t,
    required this.labelStyle,
  });

  final DialModel model;
  final DuePalette palette;
  final Map<int, MarkState> from;
  final Map<int, MarkState> to;
  final double t;
  final TextStyle labelStyle;

  /// Geometry is in the design's 340-unit box; `s` scales it to the widget.
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 340;
    final c = Offset(170 * s, 170 * s);
    final n = model.days;
    final p = palette;
    Offset at(num day, double r) {
      final a = (-90 + (day - 1) * 360 / n) * math.pi / 180;
      return c + Offset(math.cos(a), math.sin(a)) * r * s;
    }

    Paint stroke(Color color, double w, {StrokeCap cap = StrokeCap.butt}) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * s
      ..strokeCap = cap;

    canvas.drawCircle(c, 120 * s, stroke(p.rule, 14));
    final elapsed = model.elapsedDays * 360 / n;
    if (elapsed > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: 120 * s),
        -math.pi / 2,
        math.min(elapsed, 360) * math.pi / 180,
        false,
        stroke(p.ruleStrong, 14, cap: elapsed >= 359.5 ? StrokeCap.butt : StrokeCap.round),
      );
    }

    for (var d = 1; d <= n; d++) {
      final major = d % 7 == 1;
      canvas.drawLine(at(d, 134), at(d, major ? 144 : 139), stroke(major ? p.muted : p.soft, major ? 1.6 : 1));
      if (major) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$d',
            style: labelStyle.copyWith(fontSize: labelStyle.fontSize! * s),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, at(d, 157) - Offset(tp.width / 2, tp.height / 2));
      }
    }

    if (model.today case final today?) {
      canvas.drawLine(at(today, 106), at(today, 134), stroke(p.ink, 3, cap: StrokeCap.round));
    }

    for (final mark in model.marks) {
      final pos = at(mark.day, 120);
      final now = DialMarkLook.of(mark.state, p);
      final was = DialMarkLook.of(from[mark.day] ?? mark.state, p);
      final look = DialMarkLook.lerp(was, now, to[mark.day] == mark.state ? t : 1);
      if (mark.state == MarkState.late) canvas.drawCircle(pos, 16 * s, stroke(p.accent, 2));
      final r = (mark.day == model.selected ? 12 : 9.5) * s;
      canvas.drawCircle(pos, r, Paint()..color = look.fill);
      canvas.drawCircle(pos, r, stroke(look.ring, look.ringWidth));
    }

    if (model.selected case final sel?) {
      canvas.drawCircle(at(sel, 120), 21 * s, stroke(p.ink, 2.5));
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) {
    final s = size.width / 340;
    final c = Offset(170 * s, 170 * s);
    return [
      for (final mark in model.marks)
        CustomPainterSemantics(
          rect: Rect.fromCircle(
            center:
                c +
                Offset(
                      math.cos((-90 + (mark.day - 1) * 360 / model.days) * math.pi / 180),
                      math.sin((-90 + (mark.day - 1) * 360 / model.days) * math.pi / 180),
                    ) *
                    120 *
                    s,
            radius: 16 * s,
          ),
          properties: SemanticsProperties(label: mark.label, textDirection: TextDirection.ltr),
        ),
    ];
  };

  @override
  bool shouldRepaint(DialPainter oldDelegate) =>
      oldDelegate.model != model ||
      oldDelegate.palette != palette ||
      oldDelegate.t != t ||
      oldDelegate.from != from ||
      oldDelegate.to != to;

  @override
  bool shouldRebuildSemantics(DialPainter oldDelegate) => oldDelegate.model != model;
}

/// Fill and ring for a mark on the ring, which differ from the row marks.
class DialMarkLook {
  const DialMarkLook(this.fill, this.ring, this.ringWidth);

  factory DialMarkLook.of(MarkState s, DuePalette p) => switch (s) {
    MarkState.due || MarkState.late => DialMarkLook(p.accent, p.paper, 3),
    MarkState.auto => DialMarkLook(p.surface, p.muted, 2.5),
    MarkState.paid => DialMarkLook(p.ink, p.paper, 3),
    MarkState.settled => DialMarkLook(p.ruleStrong, p.paper, 3),
  };

  static DialMarkLook lerp(DialMarkLook a, DialMarkLook b, double t) => DialMarkLook(
    Color.lerp(a.fill, b.fill, t)!,
    Color.lerp(a.ring, b.ring, t)!,
    a.ringWidth + (b.ringWidth - a.ringWidth) * t,
  );

  final Color fill;
  final Color ring;
  final double ringWidth;
}
