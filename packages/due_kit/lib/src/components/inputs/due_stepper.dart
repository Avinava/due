import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/type.dart';
import '../buttons/step_button.dart';

/// "Every  −  3 months  +" inside a grouped card.
class DueStepper extends StatelessWidget {
  const DueStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
    this.valueWidth = 130,
    this.mono = false,
    this.decreaseLabel = 'Decrease',
    this.increaseLabel = 'Increase',
  });

  final String label;
  final String value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final double valueWidth;
  final bool mono;
  final String decreaseLabel;
  final String increaseLabel;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Semantics(
      label: label,
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: DueType.body(15, color: p.muted)),
          ),
          StepButton(glyph: '−', label: decreaseLabel, onPressed: onDecrease),
          const SizedBox(width: 4),
          SizedBox(
            width: valueWidth,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: mono
                  ? DueType.mono(15, weight: FontWeight.w500, color: p.ink)
                  : DueType.body(15, weight: FontWeight.w600, color: p.ink),
            ),
          ),
          const SizedBox(width: 4),
          StepButton(glyph: '+', label: increaseLabel, onPressed: onIncrease),
        ],
      ),
    );
  }
}
