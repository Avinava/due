import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// Preferences kept on the device.
final class Settings {
  const Settings({this.remind = true, this.hour = 9, this.themeMode = ThemeMode.system});

  static const minHour = 5;
  static const maxHour = 22;

  /// Remind the morning before each manual payment.
  final bool remind;

  /// Local hour reminders fire at.
  final int hour;
  final ThemeMode themeMode;

  /// "9:00 AM".
  String get hourLabel => '${hour > 12 ? hour - 12 : hour}:00 ${hour >= 12 ? 'PM' : 'AM'}';

  Settings copyWith({bool? remind, int? hour, ThemeMode? themeMode}) =>
      Settings(remind: remind ?? this.remind, hour: hour ?? this.hour, themeMode: themeMode ?? this.themeMode);
}

final settingsProvider = AsyncNotifierProvider<SettingsController, Settings>(SettingsController.new);

class SettingsController extends AsyncNotifier<Settings> {
  static const _remind = 'remind';
  static const _hour = 'remindHour';
  static const _theme = 'theme';

  @override
  Future<Settings> build() async {
    final repo = ref.watch(repositoryProvider);
    final theme = await repo.pref(_theme);
    return Settings(
      remind: (await repo.pref(_remind)) != '0',
      hour: int.tryParse(await repo.pref(_hour) ?? '') ?? 9,
      themeMode: ThemeMode.values.where((m) => m.name == theme).firstOrNull ?? ThemeMode.system,
    );
  }

  Settings get _current => state.value ?? const Settings();

  Future<void> setRemind(bool on) => _save(_current.copyWith(remind: on), _remind, on ? '1' : '0');

  Future<void> stepHour(int delta) {
    final hour = (_current.hour + delta).clamp(Settings.minHour, Settings.maxHour);
    return _save(_current.copyWith(hour: hour), _hour, '$hour');
  }

  Future<void> setThemeMode(ThemeMode mode) => _save(_current.copyWith(themeMode: mode), _theme, mode.name);

  Future<void> _save(Settings next, String key, String value) async {
    state = AsyncData(next);
    await ref.read(repositoryProvider).setPref(key, value);
  }
}
