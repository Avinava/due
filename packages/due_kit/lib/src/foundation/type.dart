import 'package:flutter/painting.dart';

import 'tokens.g.dart';

/// Text styles for the three font roles. Sizes come from [DueSize]; letter
/// spacing is given in em, as in the design.
abstract final class DueType {
  static const _tabular = [FontFeature.tabularFigures()];

  /// The fonts ship inside this package, so styles must name it.
  static const package = 'due_kit';

  /// Only Bricolage Grotesque draws ₹, so the other roles fall back to it.
  static const _rupeeFallback = [DueFonts.display];

  /// Bricolage Grotesque, for totals, headings and amounts.
  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    double em = 0,
    Color? color,
    double? height,
  }) => TextStyle(
    package: package,
    fontFamily: DueFonts.display,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: em * size,
    color: color,
    height: height,
    fontFeatures: _tabular,
  );

  /// Hanken Grotesk, for names and body copy.
  static TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color? color, double? height}) => TextStyle(
    package: package,
    fontFamily: DueFonts.body,
    fontFamilyFallback: _rupeeFallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontFeatures: _tabular,
  );

  /// JetBrains Mono, for labels, dates and status.
  static TextStyle mono(double size, {FontWeight weight = FontWeight.w400, double em = 0, Color? color}) => TextStyle(
    package: package,
    fontFamily: DueFonts.mono,
    fontFamilyFallback: _rupeeFallback,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: em * size,
    color: color,
  );
}
