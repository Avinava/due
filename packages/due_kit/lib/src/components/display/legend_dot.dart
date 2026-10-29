import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/type.dart';

/// A coloured dot and label, for the wide view's legend.
class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.label, required this.color, this.hollow = false});

  final String label;
  final Color color;
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hollow ? null : color,
            border: hollow ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 7),
        Text(label, style: DueType.body(13, color: p.muted)),
      ],
    );
  }
}
