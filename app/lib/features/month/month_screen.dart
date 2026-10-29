import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../edit/edit_sheet.dart';
import 'month_controller.dart';
import 'widgets/phone_month_view.dart';
import 'widgets/wide_month_view.dart';

/// The month, laid out for the window: phone below 720px, wide above.
class MonthScreen extends ConsumerWidget {
  const MonthScreen({super.key});

  static const settingsPath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(monthViewProvider);
    final controller = ref.read(monthControllerProvider.notifier);
    ref.watch(monthControllerProvider);

    return view.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Center(child: Text('Could not open your data.\n$e', textAlign: TextAlign.center)),
      data: (v) {
        void toggle(String rowId) {
          final item = v.itemFor(rowId);
          if (item != null) controller.toggle(item);
        }

        void edit(String rowId) {
          final item = v.itemFor(rowId);
          if (item != null) showEditSheet(context, editing: item.commitment);
        }

        return LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth >= DueSize.wideBreakpoint) {
              return WideMonthView(
                view: v,
                onPrevious: controller.previousMonth,
                onNext: controller.nextMonth,
                onSettings: () => context.push(settingsPath),
                onAdd: () => showEditSheet(context),
                onSelectDay: controller.select,
                onToggle: toggle,
                onEdit: edit,
              );
            }
            return Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: PhoneMonthView(
                    view: v,
                    canGoBack: controller.canGoBack,
                    canGoForward: controller.canGoForward,
                    onPrevious: controller.previousMonth,
                    onNext: controller.nextMonth,
                    onSettings: () => context.push(settingsPath),
                    onSelectDay: controller.select,
                    onToggle: toggle,
                    onEdit: edit,
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 36,
                  child: DueButton(
                    label: 'Add',
                    semanticLabel: 'Add commitment',
                    leading: '+',
                    kind: DueButtonKind.accent,
                    height: 56,
                    onPressed: () => showEditSheet(context),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
