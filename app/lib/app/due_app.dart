import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/calendar.dart';
import '../features/settings/settings_controller.dart';
import 'platform_providers.dart';
import 'providers.dart';
import 'router.dart';
import 'snack_host.dart';

/// The app root: theme, router and the app-wide snackbar.
class DueApp extends ConsumerStatefulWidget {
  const DueApp({super.key, this.router, this.wrap});

  /// Injected by tests; built once otherwise.
  final GoRouter? router;

  /// Wraps every screen; the catalog uses it to force a text scale.
  final TransitionBuilder? wrap;

  @override
  ConsumerState<DueApp> createState() => _DueAppState();
}

class _DueAppState extends ConsumerState<DueApp> {
  late final GoRouter _router = widget.router ?? buildRouter();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _rollDay);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Moves to the new day if the date changed while the app was away.
  void _rollDay() {
    if (dateOnly(ref.read(clockProvider)()) != ref.read(todayProvider)) ref.invalidate(todayProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(platformSyncProvider);
    final mode = ref.watch(settingsProvider.select((s) => s.value?.themeMode ?? ThemeMode.system));
    return MaterialApp.router(
      title: 'Due',
      debugShowCheckedModeBanner: false,
      theme: dueThemeData(Brightness.light),
      darkTheme: dueThemeData(Brightness.dark),
      themeMode: mode,
      locale: const Locale('en', 'IN'),
      supportedLocales: const [Locale('en', 'IN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _router,
      builder: (context, child) {
        final app = SnackHost(child: child ?? const SizedBox.shrink());
        return widget.wrap?.call(context, app) ?? app;
      },
    );
  }
}
