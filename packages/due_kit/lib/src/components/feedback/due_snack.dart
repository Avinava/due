import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';
import '../buttons/due_button.dart';

/// The dark bar along the bottom with an optional Undo.
class DueSnack extends StatelessWidget {
  const DueSnack({super.key, required this.text, this.onUndo});

  final String text;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        height: 56,
        padding: const EdgeInsets.only(left: 16, right: 8),
        decoration: BoxDecoration(
          color: p.snackBg,
          borderRadius: BorderRadius.circular(DueRadius.card),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, 10), spreadRadius: -10),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DueType.body(15, weight: FontWeight.w500, color: p.snackInk),
              ),
            ),
            if (onUndo != null)
              DueButton(
                label: 'Undo',
                kind: DueButtonKind.text,
                color: p.snackAct,
                bold: true,
                height: 40,
                fontSize: 15,
                onPressed: onUndo!,
              ),
          ],
        ),
      ),
    );
  }
}
