import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/platform_providers.dart';
import '../../app/providers.dart';
import '../../data/backup.dart';
import '../../data/cadence_codec.dart';
import '../month/month_controller.dart';
import 'settings_controller.dart';

/// Frames 1f and 1k: reminders, appearance and the household's data.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.backLabel, required this.onBack, this.version = 'v1.0 (1)'});

  /// "October": the month the back button returns to.
  final String backLabel;
  final VoidCallback onBack;
  final String version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = DueTheme.of(context);
    final settings = ref.watch(settingsProvider).value ?? const Settings();
    final controller = ref.read(settingsProvider.notifier);
    final planned = ref.watch(reminderPlanProvider).length;
    final count = ref.watch(householdProvider).value?.commitments.length ?? 0;

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DueButton(
                        label: '‹ $backLabel',
                        semanticLabel: 'Back to $backLabel',
                        kind: DueButtonKind.text,
                        color: p.accentText,
                        bold: true,
                        onPressed: onBack,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
                    child: Semantics(
                      header: true,
                      child: Text('Settings', style: DueType.display(36, em: -.03, color: p.ink)),
                    ),
                  ),
                  const SectionLabel('REMINDERS', padding: EdgeInsets.fromLTRB(24, 20, 24, 8)),
                  GroupedCard(
                    children: [
                      _Row(
                        title: 'Remind me',
                        subtitle: 'The morning before each manual payment',
                        trailing: DueSwitch(
                          value: settings.remind,
                          label: 'Reminders',
                          onChanged: controller.setRemind,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: DueStepper(
                          label: 'Time',
                          value: settings.hourLabel,
                          valueWidth: 84,
                          mono: true,
                          decreaseLabel: 'Earlier',
                          increaseLabel: 'Later',
                          onDecrease: () => controller.stepHour(-1),
                          onIncrease: () => controller.stepHour(1),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Text(
                      settings.remind ? '$planned reminders scheduled for the next 60 days.' : 'Reminders are off.',
                      style: DueType.body(13, color: p.muted),
                    ),
                  ),
                  const SectionLabel('APPEARANCE'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedChoice<ThemeMode>(
                      style: SegmentedStyle.tabs,
                      columns: 3,
                      choices: const [
                        Choice(ThemeMode.light, 'Light'),
                        Choice(ThemeMode.dark, 'Dark'),
                        Choice(ThemeMode.system, 'System'),
                      ],
                      selected: settings.themeMode,
                      onSelect: controller.setThemeMode,
                    ),
                  ),
                  const SectionLabel('YOUR DATA'),
                  GroupedCard(
                    children: [
                      _ActionRow(
                        label: 'Export as JSON',
                        detail: Text('$count items', style: DueType.mono(12, color: p.muted)),
                        onTap: () => _export(ref),
                      ),
                      _ActionRow(
                        label: 'Import from JSON',
                        detail: Text('Checked before replacing', style: DueType.body(13, color: p.muted)),
                        onTap: () => _import(ref),
                      ),
                      _ActionRow(label: 'Reset to sample household', color: p.critical, onTap: () => _reset(ref)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Wordmark(size: 22),
                        const SizedBox(height: 6),
                        Text(
                          'Everything stays on this device. No account, no sync, no bank access.',
                          style: DueType.body(13, color: p.muted),
                        ),
                        const SizedBox(height: 6),
                        Text(version, style: DueType.mono(11, color: p.soft)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _export(WidgetRef ref) async {
    final today = ref.read(todayProvider);
    final household = await ref.read(repositoryProvider).load();
    final name = 'due-backup-${CadenceCodec.encodeDate(today)}.json';
    final saved = await ref
        .read(backupFilesProvider)
        .export(Backup.encode(household, exportedAt: DateTime.now()), name);
    if (saved) ref.read(monthControllerProvider.notifier).show(Snack('Saved $name'));
  }

  Future<void> _import(WidgetRef ref) async {
    final snack = ref.read(monthControllerProvider.notifier);
    final text = await ref.read(backupFilesProvider).pick();
    if (text == null) return;
    try {
      final household = Backup.decode(text);
      await ref.read(repositoryProvider).replaceAll(household);
      snack.show(Snack('Backup checked: version ${Backup.version}, ${household.commitments.length} items'));
    } on FormatException catch (e) {
      snack.show(Snack(e.message));
    }
  }

  Future<void> _reset(WidgetRef ref) async {
    await ref.read(repositoryProvider).resetToSample(ref.read(todayProvider));
    ref.read(monthControllerProvider.notifier)
      ..reset()
      ..show(const Snack('Sample household restored'));
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.subtitle, required this.trailing});

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DueSize.tapTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DueType.body(16, weight: FontWeight.w600, color: p.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: DueType.body(13, color: p.muted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.label, required this.onTap, this.detail, this.color});

  final String label;
  final VoidCallback onTap;
  final Widget? detail;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return DueTapTarget(
      label: label,
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: DueType.body(16, weight: FontWeight.w600, color: color ?? p.ink),
                ),
              ),
              ?detail,
            ],
          ),
        ),
      ),
    );
  }
}
