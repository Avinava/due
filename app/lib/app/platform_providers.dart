import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reminder_plan.dart';
import '../features/home_widget/widget_snapshot.dart';
import '../features/settings/settings_controller.dart';
import '../platform/backup_files.dart';
import '../platform/home_widget_sync.dart';
import '../platform/reminders.dart';
import 'providers.dart';

/// Platform seams. Tests override these with fakes.
final remindersProvider = Provider<ReminderScheduler>((ref) => platformReminders());
final homeWidgetsProvider = Provider<HomeWidgets>((ref) => platformHomeWidgets());
final backupFilesProvider = Provider<BackupFiles>((ref) => const SystemBackupFiles());

/// The reminders that would be scheduled now; the settings note counts them.
final reminderPlanProvider = Provider<List<Reminder>>((ref) {
  final household = ref.watch(householdProvider).value;
  final settings = ref.watch(settingsProvider).value;
  if (household == null || settings == null || !settings.remind) return const [];
  // Watched so the plan is rebuilt when the day rolls over.
  ref.watch(todayProvider);
  final now = ref.read(clockProvider)();
  final plan = planReminders(commitments: household.active, paid: household.paid, now: now, hour: settings.hour);
  // Rebuilt once the first reminder fires, so it stops being counted.
  if (plan.firstOrNull case final first?) {
    final fired = Timer(first.fireAt.difference(now) + const Duration(seconds: 1), ref.invalidateSelf);
    ref.onDispose(fired.cancel);
  }
  return plan;
});

/// Keeps reminders and the home-screen widget in step with the data. Watched
/// once by the app root.
final platformSyncProvider = Provider<void>((ref) {
  ref.listen(reminderPlanProvider, (_, plan) => ref.read(remindersProvider).replaceAll(plan), fireImmediately: true);
  ref.listen(widgetTimelineProvider, (_, timeline) {
    if (timeline != null) ref.read(homeWidgetsProvider).update(timeline);
  }, fireImmediately: true);
});

/// What the home-screen widget shows over the coming days.
final widgetTimelineProvider = Provider<List<WidgetDay>?>((ref) {
  final h = ref.watch(householdProvider).value;
  if (h == null) return null;
  return widgetTimeline(today: ref.watch(todayProvider), commitments: h.commitments, paid: h.paid);
});
