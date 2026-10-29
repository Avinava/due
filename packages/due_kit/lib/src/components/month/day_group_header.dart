import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';

/// "SAT 10" or "TODAY · MON 12" with a hairline to the edge.
class DayGroupHeader extends StatelessWidget {
  const DayGroupHeader(this.label, {super.key, this.isToday = false, this.labelSize = DueSize.xs});

  final String label;
  final bool isToday;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
      child: Row(
        children: [
          Text(
            label,
            style: DueType.mono(labelSize, weight: FontWeight.w500, em: .1, color: isToday ? p.accentText : p.muted),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: isToday ? p.accent : p.rule)),
        ],
      ),
    );
  }
}
