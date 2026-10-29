import 'package:flutter/widgets.dart';

import '../../foundation/tokens.g.dart';

/// The five states an item can be in. Mirrors the app's domain state without
/// depending on it.
enum MarkState {
  due,
  late,
  paid,
  auto,
  settled;

  bool get needsYou => this == due || this == late;
  bool get isAutopay => this == auto || this == settled;
}

/// How a [MarkState] looks: ring, fill, glyph and text colours.
@immutable
class MarkStyle {
  const MarkStyle({
    required this.border,
    required this.fill,
    required this.glyphColor,
    required this.glyph,
    required this.nameColor,
    required this.statusColor,
    this.dashed = false,
  });

  factory MarkStyle.of(MarkState s, DuePalette p) => switch (s) {
    MarkState.due => MarkStyle(
      border: p.accent,
      fill: const Color(0x00000000),
      glyphColor: p.accent,
      glyph: MarkGlyph.none,
      nameColor: p.ink,
      statusColor: p.muted,
    ),
    MarkState.late => MarkStyle(
      border: p.accent,
      fill: p.accent,
      glyphColor: p.accentInk,
      glyph: MarkGlyph.alert,
      nameColor: p.ink,
      statusColor: p.critical,
    ),
    MarkState.paid => MarkStyle(
      border: p.ink,
      fill: p.ink,
      glyphColor: p.paper,
      glyph: MarkGlyph.check,
      nameColor: p.muted,
      statusColor: p.positive,
    ),
    MarkState.auto => MarkStyle(
      border: p.muted,
      fill: const Color(0x00000000),
      glyphColor: p.muted,
      glyph: MarkGlyph.none,
      nameColor: p.ink,
      statusColor: p.muted,
      dashed: true,
    ),
    MarkState.settled => MarkStyle(
      border: p.ruleStrong,
      fill: p.ruleStrong,
      glyphColor: p.paper,
      glyph: MarkGlyph.check,
      nameColor: p.muted,
      statusColor: p.muted,
    ),
  };

  final Color border;
  final Color fill;
  final Color glyphColor;
  final MarkGlyph glyph;
  final Color nameColor;
  final Color statusColor;
  final bool dashed;
}

enum MarkGlyph { none, check, alert }
