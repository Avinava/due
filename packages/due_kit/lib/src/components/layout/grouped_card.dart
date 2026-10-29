import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';

/// A bordered surface card whose children are split by inset hairlines.
class GroupedCard extends StatelessWidget {
  const GroupedCard({super.key, required this.children, this.margin = const EdgeInsets.symmetric(horizontal: 16)});

  final List<Widget> children;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.rule),
        borderRadius: BorderRadius.circular(DueRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) Container(height: 1, margin: const EdgeInsets.only(left: 16), color: p.rule),
            c,
          ],
        ],
      ),
    );
  }
}
