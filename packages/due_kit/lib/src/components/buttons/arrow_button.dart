import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import 'tap_target.dart';

/// The month arrows: a drawn chevron, bare on the phone or boxed on wide.
class ArrowButton extends StatelessWidget {
  const ArrowButton({super.key, required this.forward, required this.onPressed, this.boxed = false});

  final bool forward;
  final VoidCallback onPressed;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final size = boxed ? 40.0 : DueSize.tapTarget;
    return DueTapTarget(
      label: forward ? 'Next month' : 'Previous month',
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: boxed
            ? BoxDecoration(
                color: p.surface,
                border: Border.all(color: p.rule),
                borderRadius: BorderRadius.circular(DueRadius.card),
              )
            : null,
        child: CustomPaint(
          size: Size.square(boxed ? 12 : 14),
          painter: _Chevron(forward: forward, color: boxed ? p.ink : p.muted),
        ),
      ),
    );
  }
}

class _Chevron extends CustomPainter {
  const _Chevron({required this.forward, required this.color});

  final bool forward;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final x0 = forward ? w * .3 : w * .7, x1 = forward ? w * .7 : w * .3;
    canvas.drawPath(
      Path()
        ..moveTo(x0, 0)
        ..lineTo(x1, h / 2)
        ..lineTo(x0, h),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_Chevron oldDelegate) => oldDelegate.forward != forward || oldDelegate.color != color;
}
