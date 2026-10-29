import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/month/month_controller.dart';
import '../features/settings/settings_screen.dart';

/// Settings with a back button named after the month being viewed.
class SettingsRoute extends ConsumerWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthViewProvider).value?.monthName ?? 'Back';
    return SettingsScreen(backLabel: month, onBack: () => context.canPop() ? context.pop() : context.go('/'));
  }
}
