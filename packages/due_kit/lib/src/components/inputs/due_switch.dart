import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';

/// The square-cornered switch from the design: positive when on.
class DueSwitch extends StatelessWidget {
  const DueSwitch({super.key, required this.value, required this.onChanged, required this.label});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Semantics(
      toggled: value,
      label: label,
      onTap: () => onChanged(!value),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? p.positive : p.ruleStrong,
              borderRadius: BorderRadius.circular(DueRadius.toggle),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: p.accentInk, borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
