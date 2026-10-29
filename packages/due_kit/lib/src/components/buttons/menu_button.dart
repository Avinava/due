import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import 'tap_target.dart';

/// The three-line menu button that opens settings on the phone.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    Widget bar(double w, {double left = 0}) => Container(
      width: w,
      height: 2,
      margin: EdgeInsets.only(left: left),
      decoration: BoxDecoration(color: p.ink, borderRadius: BorderRadius.circular(1)),
    );
    return DueTapTarget(
      label: 'Settings',
      onTap: onPressed,
      child: Container(
        width: DueSize.tapTarget,
        height: DueSize.tapTarget,
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(color: p.rule),
          borderRadius: BorderRadius.circular(DueRadius.card),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [bar(16), const SizedBox(height: 4), bar(10, left: 6), const SizedBox(height: 4), bar(16)],
        ),
      ),
    );
  }
}
