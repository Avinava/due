import 'package:due/app/due_app.dart';
import 'package:due/app/platform_providers.dart';
import 'package:due/app/providers.dart';
import 'package:due/app/router.dart';
import 'package:due/data/memory_commitment_repository.dart';
import 'package:due/domain/calendar.dart';
import 'package:due/domain/month_brief.dart';
import 'package:due/features/edit/edit_sheet.dart';
import 'package:due/features/home_widget/widget_snapshot.dart';
import 'package:due/features/month/month_controller.dart';
import 'package:due/platform/backup_files.dart';
import 'package:due/platform/home_widget_sync.dart';
import 'package:due/platform/reminders.dart';
import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_frames.dart';
import 'frame_spec.dart';
import 'home_widget_preview.dart';

/// A live, interactive rendering of one design frame: the real app on an
/// in-memory household, with the clock at 12 Oct 2026.
class FrameScene extends StatefulWidget {
  const FrameScene(this.spec, {super.key, this.chrome = true});

  final FrameSpec spec;

  /// Draw the phone bezel or window chrome around the screen.
  final bool chrome;

  @override
  State<FrameScene> createState() => _FrameSceneState();
}

class _FrameSceneState extends State<FrameScene> {
  late final _repo = MemoryCommitmentRepository.sample(frameToday, extraPaid: widget.spec.preset.extraPaid)
    ..setPref('theme', widget.spec.dark ? 'dark' : 'light');
  final _navigator = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.spec.preset.sheet case final form?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _navigator.currentContext;
        if (ctx != null && ctx.mounted) showEditSheet(ctx, initial: form);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final screen = switch (spec.kind) {
      FrameKind.widgetSmall || FrameKind.widgetMedium => _widgetPreview(spec),
      _ => ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => frameToday),
          repositoryProvider.overrideWithValue(_repo),
          remindersProvider.overrideWithValue(const NoReminders()),
          homeWidgetsProvider.overrideWithValue(const NoHomeWidgets()),
          backupFilesProvider.overrideWithValue(const _CatalogBackupFiles()),
          monthControllerProvider.overrideWith(() => _PresetMonthController(spec.preset.ui)),
        ],
        child: DueApp(
          router: buildRouter(initialLocation: spec.preset.location, navigatorKey: _navigator),
          wrap: (context, child) {
            // The app reads its screen size from MediaQuery, which starts as
            // the whole window; inside a frame the screen is the frame.
            final mq = MediaQuery.of(context).copyWith(size: spec.kind.size);
            final framed = spec.kind == FrameKind.phone && widget.chrome
                ? mq.copyWith(padding: PhoneFrame.safeArea, viewPadding: PhoneFrame.safeArea)
                : mq;
            return MediaQuery(
              data: framed.copyWith(textScaler: TextScaler.linear(spec.textScale)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    };
    final sized = SizedBox.fromSize(size: spec.kind.size, child: screen);
    if (!widget.chrome) return sized;
    return switch (spec.kind) {
      FrameKind.phone => PhoneFrame(dark: spec.dark, child: sized),
      FrameKind.wide => WindowFrame(dark: spec.dark, child: sized),
      _ => WidgetFrame(dark: spec.dark, child: sized),
    };
  }

  Widget _widgetPreview(FrameSpec spec) {
    return FutureBuilder(
      future: _repo.load(),
      builder: (context, snap) {
        final h = snap.data;
        if (h == null) return const SizedBox.shrink();
        final brief = MonthBrief.build(
          month: YearMonth.of(frameToday),
          today: frameToday,
          commitments: h.commitments,
          paid: h.paid,
        );
        return Theme(
          data: dueThemeData(spec.brightness),
          child: HomeWidgetPreview(snapshot: WidgetSnapshot.of(brief), medium: spec.kind == FrameKind.widgetMedium),
        );
      },
    );
  }
}

/// Starts the month screen in a frame's [MonthUi] without timers, so the
/// snackbar and highlight stay put for screenshots.
class _PresetMonthController extends MonthController {
  _PresetMonthController(this._initial);

  final MonthUi _initial;

  @override
  MonthUi build() {
    super.build();
    return _initial;
  }
}

/// The catalog has no files to share; export and import report what they
/// would do.
final class _CatalogBackupFiles implements BackupFiles {
  const _CatalogBackupFiles();

  @override
  Future<bool> export(String json, String fileName) async => true;

  @override
  Future<String?> pick() async => null;
}
