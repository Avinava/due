import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../features/home_widget/widget_snapshot.dart';

/// Pushes the widget timeline to the home screen.
abstract interface class HomeWidgets {
  Future<void> update(List<WidgetDay> timeline);
}

final class NoHomeWidgets implements HomeWidgets {
  const NoHomeWidgets();

  @override
  Future<void> update(List<WidgetDay> timeline) async {}
}

/// WidgetKit through an App Group shared with the DueWidget extension.
final class IosHomeWidgets implements HomeWidgets {
  IosHomeWidgets();

  static const appGroup = 'group.dev.avi.due';
  static const iOSName = 'DueWidget';
  static const key = 'timeline';

  bool _ready = false;

  @override
  Future<void> update(List<WidgetDay> timeline) async {
    if (!_ready) {
      await HomeWidget.setAppGroupId(appGroup);
      _ready = true;
    }
    await HomeWidget.saveWidgetData<String>(key, jsonEncode([for (final d in timeline) d.toJson()]));
    await HomeWidget.updateWidget(iOSName: iOSName);
  }
}

HomeWidgets platformHomeWidgets() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS ? IosHomeWidgets() : const NoHomeWidgets();
