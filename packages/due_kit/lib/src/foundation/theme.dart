import 'package:flutter/material.dart';

import 'tokens.g.dart';
import 'type.dart';

/// Due's theme: the colour roles for the current brightness. Read it with
/// `DueTheme.of(context)`.
@immutable
class DueTheme extends ThemeExtension<DueTheme> {
  const DueTheme(this.palette, this.brightness);

  static const light = DueTheme(DuePalette.light, Brightness.light);
  static const dark = DueTheme(DuePalette.dark, Brightness.dark);

  final DuePalette palette;
  final Brightness brightness;

  static DuePalette of(BuildContext context) => Theme.of(context).extension<DueTheme>()!.palette;

  @override
  DueTheme copyWith({DuePalette? palette, Brightness? brightness}) =>
      DueTheme(palette ?? this.palette, brightness ?? this.brightness);

  @override
  DueTheme lerp(DueTheme? other, double t) => other == null
      ? this
      : DueTheme(DuePalette.lerp(palette, other.palette, t), t < .5 ? brightness : other.brightness);
}

/// Material [ThemeData] carrying [DueTheme], so stock widgets (text fields,
/// scroll bars, focus rings) pick up the same roles.
ThemeData dueThemeData(Brightness brightness) {
  final due = brightness == Brightness.dark ? DueTheme.dark : DueTheme.light;
  final p = due.palette;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.accent,
    onPrimary: p.accentInk,
    secondary: p.ink,
    onSecondary: p.paper,
    error: p.critical,
    onError: p.paper,
    surface: p.paper,
    onSurface: p.ink,
    outline: p.rule,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.paper,
    fontFamily: 'packages/${DueType.package}/${DueFonts.body}',
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(cursorColor: p.accent, selectionColor: p.accentTint),
    // Sheets and dialogs read their colours here, from the route's own
    // context, so an open one follows a theme change.
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.paper,
      modalBackgroundColor: p.paper,
      modalBarrierColor: p.scrim,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DueRadius.card))),
    ),
    dialogTheme: DialogThemeData(barrierColor: p.scrim),
    extensions: [due],
  );
}
