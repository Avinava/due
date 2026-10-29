import 'dart:io';

import 'package:due_kit/due_kit.dart';
import 'package:flutter/services.dart';

/// Loads the kit's bundled fonts so goldens render real type instead of the
/// test font.
Future<void> loadDueFonts() async {
  final dir = Directory('../packages/due_kit/assets/fonts');
  final families = {
    DueFonts.display: 'BricolageGrotesque',
    DueFonts.body: 'HankenGrotesk',
    DueFonts.mono: 'JetBrainsMono',
  };
  for (final MapEntry(key: family, value: prefix) in families.entries) {
    final loader = FontLoader('packages/${DueType.package}/$family');
    for (final f in dir.listSync().whereType<File>().where((f) => f.uri.pathSegments.last.startsWith('$prefix-'))) {
      loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    }
    await loader.load();
  }
}
