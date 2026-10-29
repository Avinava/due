import 'package:due_kit/due_kit.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/money.dart';
import '../month_view_model.dart';
import 'month_list.dart';

/// Frames 1l and 1m: dial on the left, list on the right, from 720px up.
class WideMonthView extends StatelessWidget {
  const WideMonthView({
    super.key,
    required this.view,
    required this.onPrevious,
    required this.onNext,
    required this.onSettings,
    required this.onAdd,
    required this.onSelectDay,
    required this.onToggle,
    required this.onEdit,
  });

  final MonthView view;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSettings;
  final VoidCallback onAdd;
  final ValueChanged<int?> onSelectDay;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onEdit;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final compact = MediaQuery.sizeOf(context).width < _compactBar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.rule)),
          ),
          child: Row(
            children: [
              const Wordmark(),
              const Spacer(),
              ArrowButton(forward: false, boxed: true, onPressed: onPrevious),
              const SizedBox(width: 4),
              SizedBox(
                width: compact ? 150 : 180,
                child: Semantics(
                  header: true,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      view.monthLabel,
                      textAlign: TextAlign.center,
                      style: DueType.display(20, weight: FontWeight.w600, color: p.ink),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              ArrowButton(forward: true, boxed: true, onPressed: onNext),
              const Spacer(),
              DueButton(label: 'Settings', height: 40, fontSize: 14, onPressed: onSettings),
              const SizedBox(width: 10),
              DueButton(
                label: compact ? '+ Add' : '+ Add commitment',
                semanticLabel: 'Add commitment',
                kind: DueButtonKind.accent,
                height: 40,
                fontSize: 14,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final pane = paneWidth(box.maxWidth);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: pane,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeroTotal(
                            label: view.heroLabel,
                            amount: view.needsYou,
                            format: groupInr,
                            subLine: view.subLine,
                            delta: view.delta,
                            done: view.done,
                            size: HeroSize.wide,
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: DueDial(
                              model: view.dial,
                              onSelect: onSelectDay,
                              size: (pane - 96).clamp(260, DueSize.dialWide),
                              labelSize: 12,
                              line2Size: 34,
                              line3Size: 14,
                              line3Width: 190,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            children: [
                              LegendDot(label: 'Needs you', color: p.accent),
                              LegendDot(label: 'Autopay', color: p.muted, hollow: true),
                              LegendDot(label: 'Paid', color: p.ink),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.surface,
                        border: Border(left: BorderSide(color: p.rule)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      view.listTitle,
                                      style: DueType.display(22, weight: FontWeight.w600, color: p.ink),
                                    ),
                                  ),
                                  if (view.scrubLabel != null)
                                    DueButton(
                                      label: 'Whole month',
                                      kind: DueButtonKind.ink,
                                      onPressed: () => onSelectDay(null),
                                    ),
                                ],
                              ),
                            ),
                            MonthList(view: view, layout: RowLayout.wide, onToggle: onToggle, onEdit: onEdit),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Below this window width the top bar drops to its short labels.
  static const _compactBar = 960.0;

  /// The dial pane: the design's 560px at 1280 wide, narrower down to the
  /// 720px breakpoint so the list keeps room for its columns.
  static double paneWidth(double width) => (width * .44).clamp(380, DueSize.widePane);
}
