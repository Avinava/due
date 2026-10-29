import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/month/month_controller.dart';

/// Shows the current [Snack] above every screen, sliding in from the
/// bottom.
class SnackHost extends ConsumerWidget {
  const SnackHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snack = ref.watch(monthControllerProvider.select((s) => s.snack));
    final wide = MediaQuery.sizeOf(context).width >= DueSize.wideBreakpoint;
    return Stack(
      children: [
        child,
        Positioned(
          left: 16,
          right: wide ? null : 16,
          bottom: 36,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, .4), end: Offset.zero).animate(a),
                child: child,
              ),
            ),
            child: snack == null
                ? const SizedBox.shrink()
                : ConstrainedBox(
                    key: ValueKey(snack),
                    constraints: BoxConstraints(maxWidth: wide ? 520 : double.infinity),
                    // Sits above the navigator, so it brings its own Material.
                    child: Material(
                      type: MaterialType.transparency,
                      child: DueSnack(
                        text: snack.text,
                        onUndo: snack.undo == null ? null : ref.read(monthControllerProvider.notifier).undo,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
