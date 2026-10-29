import 'package:flutter/widgets.dart';

/// A tappable area with a click cursor and a semantics label.
class DueTapTarget extends StatelessWidget {
  const DueTapTarget({super.key, required this.child, required this.onTap, this.label, this.button = true});

  final Widget child;
  final VoidCallback onTap;
  final String? label;
  final bool button;

  @override
  Widget build(BuildContext context) => Semantics(
    button: button,
    label: label,
    excludeSemantics: label != null,
    onTap: onTap,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(cursor: SystemMouseCursors.click, child: child),
    ),
  );
}
