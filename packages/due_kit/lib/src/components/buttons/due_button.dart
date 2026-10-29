import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';
import 'tap_target.dart';

enum DueButtonKind {
  /// Accent fill: Add.
  accent,

  /// Surface with a hairline: Settings, month arrows on wide.
  outline,

  /// Ink fill, small: "Whole month".
  ink,

  /// Text only: Cancel, Save, back.
  text,
}

/// The design's buttons. Heights default to the design's per kind.
class DueButton extends StatelessWidget {
  const DueButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = DueButtonKind.outline,
    this.height,
    this.leading,
    this.color,
    this.fontSize,
    this.bold = false,
    this.semanticLabel,
    this.width,
  });

  final String label;
  final VoidCallback onPressed;
  final DueButtonKind kind;
  final double? height;
  final double? width;
  final String? leading;
  final Color? color;
  final double? fontSize;
  final bool bold;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final (bg, fg, border) = switch (kind) {
      DueButtonKind.accent => (p.accent, p.accentInk, null),
      DueButtonKind.outline => (p.surface, p.ink, Border.all(color: p.rule)),
      DueButtonKind.ink => (p.ink, p.paper, null),
      DueButtonKind.text => (p.paper.withValues(alpha: 0), color ?? p.muted, null),
    };
    final h = height ?? (kind == DueButtonKind.ink ? 32.0 : DueSize.tapTarget);
    final size = fontSize ?? (kind == DueButtonKind.ink ? 13.0 : 16.0);
    final weight = bold || kind == DueButtonKind.accent
        ? FontWeight.w700
        : (kind == DueButtonKind.text ? FontWeight.w400 : FontWeight.w600);
    return DueTapTarget(
      label: semanticLabel ?? label,
      onTap: onPressed,
      child: Container(
        height: h,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: kind == DueButtonKind.accent ? 20 : 12),
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(kind == DueButtonKind.ink ? DueRadius.control : DueRadius.card),
          boxShadow: kind == DueButtonKind.accent && h > 50
              ? [BoxShadow(color: p.accentShadow, blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -8)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              Text(leading!, style: DueType.body(size * 1.5, color: fg, height: 1)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: DueType.body(size, weight: weight, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
