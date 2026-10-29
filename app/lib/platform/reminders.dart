import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_plan.dart';

/// Schedules the reminder plan on the device.
abstract interface class ReminderScheduler {
  /// Replaces every pending reminder with [plan].
  Future<void> replaceAll(List<Reminder> plan);
}

/// For web and tests: reminders are not supported.
final class NoReminders implements ReminderScheduler {
  const NoReminders();

  @override
  Future<void> replaceAll(List<Reminder> plan) async {}
}

/// Local notifications on iOS and macOS.
final class LocalReminders implements ReminderScheduler {
  LocalReminders();

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _ready;

  static const _details = NotificationDetails(
    iOS: DarwinNotificationDetails(threadIdentifier: 'due'),
    macOS: DarwinNotificationDetails(threadIdentifier: 'due'),
  );

  Future<bool> _init() async {
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(iOS: darwin, macOS: darwin),
    );
    return true;
  }

  /// The system asks the user once; after that this returns their answer.
  Future<bool> _permitted() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final mac = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    return await (ios?.requestPermissions(alert: true, sound: true) ??
            mac?.requestPermissions(alert: true, sound: true)) ??
        false;
  }

  /// Replacements run one at a time, and a newer plan stops an older one, so
  /// a stale plan can never be scheduled after its replacement.
  Future<void> _queue = Future.value();
  int _latest = 0;

  @override
  Future<void> replaceAll(List<Reminder> plan) {
    final generation = ++_latest;
    return _queue = _queue.catchError((Object _) {}).then((_) => _replace(plan, generation));
  }

  Future<void> _replace(List<Reminder> plan, int generation) async {
    if (generation != _latest) return;
    await (_ready ??= _init());
    // Pending only: a reminder already shown stays in Notification Centre.
    await _plugin.cancelAllPendingNotifications();
    if (plan.isEmpty || !await _permitted()) return;
    final now = tz.TZDateTime.now(tz.local);
    for (final r in plan) {
      if (generation != _latest) return;
      final at = tz.TZDateTime(tz.local, r.fireAt.year, r.fireAt.month, r.fireAt.day, r.fireAt.hour);
      if (!at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        scheduledDate: at,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}

ReminderScheduler platformReminders() =>
    kIsWeb || !(defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS)
    ? const NoReminders()
    : LocalReminders();
