import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/type.dart';

/// "due" with the accent square.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final square = size * (size >= 60 ? .2 : (size >= 26 ? .29 : .27));
    return Semantics(
      label: 'due',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'due',
            textScaler: TextScaler.noScaling,
            style: DueType.display(size, weight: FontWeight.w800, em: -.04, color: p.ink, height: 1),
          ),
          SizedBox(width: size * .1),
          Container(
            width: square,
            height: square,
            decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(square / 3.5)),
          ),
        ],
      ),
    );
  }
}
