import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/frame_use_cases.dart';
import 'use_cases/kit_use_cases.dart';

void main() => runApp(const DueCatalog());

/// Due's design kit and every design frame, browsable on the web.
class DueCatalog extends StatelessWidget {
  const DueCatalog({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook.material(
    directories: [
      WidgetbookCategory(name: 'Frames', children: frameNodes()),
      WidgetbookCategory(name: 'Kit', children: kitNodes()),
    ],
    addons: [
      MaterialThemeAddon(
        themes: [
          WidgetbookTheme(name: 'Light', data: dueThemeData(Brightness.light)),
          WidgetbookTheme(name: 'Dark', data: dueThemeData(Brightness.dark)),
        ],
      ),
      TextScaleAddon(min: 1, max: 2, divisions: 4),
    ],
  );
}
