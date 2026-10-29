import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';

/// "−₹42,000" in a green chip.
class DeltaChip extends StatelessWidget {
  const DeltaChip(this.text, {super.key, this.size = DueSize.xs});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: p.flashBg, borderRadius: BorderRadius.circular(DueRadius.chip)),
      child: Text(
        text,
        style: DueType.mono(size, weight: FontWeight.w600, color: p.positive),
      ),
    );
  }
}
