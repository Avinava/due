import 'package:due_kit/due_kit.dart';
import 'package:flutter/widgets.dart';

import '../month_view_model.dart';

/// The day groups under the dial: headers and rows, or cards at large text.
class MonthList extends StatelessWidget {
  const MonthList({super.key, required this.view, required this.layout, required this.onToggle, required this.onEdit});

  final MonthView view;
  final RowLayout layout;

  /// Called with [RowModel.id] when a row is tapped.
  final ValueChanged<String> onToggle;

  /// Called with [RowModel.id] on long press or secondary click.
  final ValueChanged<String> onEdit;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final cards = layout == RowLayout.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final g in view.groups) ...[
          DayGroupHeader(g.label, isToday: g.isToday, labelSize: layout == RowLayout.wide ? 11 : DueSize.xs),
          if (cards)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, r) in g.rows.indexed) ...[
                    if (i > 0) const SizedBox(height: 10),
                    CommitmentRow(r, layout: layout, onTap: () => onToggle(r.id), onLongPress: () => onEdit(r.id)),
                  ],
                ],
              ),
            )
          else
            for (final r in g.rows)
              CommitmentRow(
                r,
                key: ValueKey(r.id),
                layout: layout,
                onTap: () => onToggle(r.id),
                onLongPress: () => onEdit(r.id),
              ),
        ],
        if (view.emptyDay)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Text(
              'Nothing due on this day.',
              textAlign: layout == RowLayout.wide ? TextAlign.left : TextAlign.center,
              style: DueType.body(layout == RowLayout.wide ? 14 : DueSize.sm, color: p.muted),
            ),
          ),
      ],
    );
  }
}

/// "Showing Thursday 15 October  [Whole month]" while a day is scrubbed.
class ScrubBar extends StatelessWidget {
  const ScrubBar({super.key, required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.rule),
        borderRadius: BorderRadius.circular(DueRadius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Showing ',
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              style: DueType.body(DueSize.sm, color: p.muted),
            ),
          ),
          DueButton(label: 'Whole month', kind: DueButtonKind.ink, onPressed: onClear),
        ],
      ),
    );
  }
}
