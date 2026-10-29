import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';
import 'tap_target.dart';

/// A small bordered square button: the stepper's minus and plus.
class StepButton extends StatelessWidget {
  const StepButton({super.key, required this.glyph, required this.label, required this.onPressed});

  final String glyph;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return DueTapTarget(
      label: label,
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.paper,
          border: Border.all(color: p.rule),
          borderRadius: BorderRadius.circular(DueRadius.control),
        ),
        child: Text(
          glyph,
          textScaler: TextScaler.noScaling,
          style: DueType.body(18, color: p.ink),
        ),
      ),
    );
  }
}
