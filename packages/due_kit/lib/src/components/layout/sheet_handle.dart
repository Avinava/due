import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';

/// The grab bar at the top of a bottom sheet.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 8),
      width: 36,
      height: 5,
      decoration: BoxDecoration(color: DueTheme.of(context).ruleStrong, borderRadius: BorderRadius.circular(3)),
    ),
  );
}
