import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';

/// "REMINDERS", "NEXT 3 DATES": a mono eyebrow.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 8)});

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Text(text, style: DueType.mono(DueSize.xs, em: .12, color: DueTheme.of(context).muted)),
  );
}
