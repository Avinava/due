import 'package:due_kit/due_kit.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/money.dart';
import '../month_view_model.dart';
import 'month_list.dart';

/// Frames 1a to 1d and 1g: the month on a phone.
class PhoneMonthView extends StatelessWidget {
  const PhoneMonthView({
    super.key,
    required this.view,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
    required this.onSettings,
    required this.onSelectDay,
    required this.onToggle,
    required this.onEdit,
  });

  final MonthView view;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSettings;
  final ValueChanged<int?> onSelectDay;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onEdit;

  /// Room under the list for the Add button.
  static const _addClearance = 110.0;

  @override
  Widget build(BuildContext context) {
    final large = isLargeText(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 14, 4),
          child: Row(
            children: [
              Expanded(child: _MonthNav(view.monthLabel, canGoBack, canGoForward, onPrevious, onNext)),
              const SizedBox(width: 8),
              MenuButton(onPressed: onSettings),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                  child: HeroTotal(
                    label: view.heroLabel,
                    amount: view.needsYou,
                    format: groupInr,
                    subLine: view.subLine,
                    delta: view.delta,
                    done: view.done,
                    size: large ? HeroSize.large : HeroSize.phone,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                  child: Center(
                    child: DueDial(
                      model: view.dial,
                      onSelect: onSelectDay,
                      size: large ? DueSize.dialLarge : DueSize.dial,
                      showLine3: !large,
                      labelSize: large ? 13 : DueSize.xs,
                      line2Size: DueSize.xl * (large ? 1.3 : 1),
                      line3Size: large ? 14 : DueSize.sm,
                    ),
                  ),
                ),
              ),
              if (view.scrubLabel case final label?)
                SliverToBoxAdapter(
                  child: ScrubBar(label: label, onClear: () => onSelectDay(null)),
                ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: _addClearance),
                sliver: SliverToBoxAdapter(
                  child: MonthList(
                    view: view,
                    layout: large ? RowLayout.card : RowLayout.phone,
                    onToggle: onToggle,
                    onEdit: onEdit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav(this.label, this.canGoBack, this.canGoForward, this.onPrevious, this.onNext);

  final String label;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: canGoBack ? 1 : .3,
          child: ArrowButton(forward: false, onPressed: onPrevious),
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Semantics(
            header: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: DueType.display(DueSize.lg, weight: FontWeight.w600, em: -.01, color: p.ink),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Opacity(
          opacity: canGoForward ? 1 : .3,
          child: ArrowButton(forward: true, onPressed: onNext),
        ),
      ],
    );
  }
}
