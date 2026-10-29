import 'package:due/features/home_widget/widget_snapshot.dart';
import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';

/// The iOS widgets (frames 1n, 1o) drawn in Flutter from the same
/// [WidgetSnapshot] the SwiftUI extension reads. Keep the two in step.
class HomeWidgetPreview extends StatelessWidget {
  const HomeWidgetPreview({super.key, required this.snapshot, this.medium = false});

  final WidgetSnapshot snapshot;
  final bool medium;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final s = snapshot;
    final amount = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '₹',
            style: DueType.display(32 * .6, weight: FontWeight.w500, color: p.muted),
          ),
          TextSpan(text: s.needsYou),
        ],
      ),
      textScaler: TextScaler.noScaling,
      style: DueType.display(32, em: -.04, color: p.ink, height: 1),
    );
    final label = Text(
      'NEEDS YOU',
      style: DueType.mono(10, weight: FontWeight.w600, em: .12, color: p.accent),
    );

    return MediaQuery.withNoTextScaling(
      child: ColoredBox(
        color: p.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: medium ? _medium(p, label, amount) : _small(p, label, amount),
        ),
      ),
    );
  }

  Widget _small(DuePalette p, Widget label, Widget amount) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          label,
          const Spacer(),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
      const SizedBox(height: 4),
      amount,
      const Spacer(),
      Text(snapshot.nextLabel, style: DueType.mono(10, em: .08, color: snapshot.nextLate ? p.critical : p.muted)),
      const SizedBox(height: 2),
      Text(
        snapshot.nextName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DueType.body(14, weight: FontWeight.w600, color: p.ink),
      ),
      Text(snapshot.nextLine, style: DueType.body(12, color: p.muted)),
    ],
  );

  Widget _medium(DuePalette p, Widget label, Widget amount) {
    Color cell(DayCell c) => switch (c) {
      DayCell.needsYou => p.accent,
      DayCell.settled => p.ink,
      DayCell.past => p.ruleStrong,
      DayCell.future => p.rule,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 132,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label,
              const SizedBox(height: 4),
              amount,
              const Spacer(),
              Text(snapshot.monthLine, style: DueType.body(12, color: p.muted)),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final (i, c) in snapshot.bar.indexed) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(color: cell(c), borderRadius: BorderRadius.circular(1)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: p.rule)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, item) in snapshot.items.indexed) ...[
                  if (i > 0) const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DueType.body(13, weight: FontWeight.w600, color: p.ink),
                            ),
                            Text(item.when, style: DueType.mono(10, color: item.late ? p.critical : p.muted)),
                          ],
                        ),
                      ),
                      Text(
                        item.amount,
                        style: DueType.display(13, weight: FontWeight.w600, color: p.ink),
                      ),
                    ],
                  ),
                ],
                if (snapshot.items.isEmpty) Text('Nothing left this month', style: DueType.body(13, color: p.muted)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
