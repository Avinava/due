import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';

/// One choice in a [SegmentedChoice].
@immutable
class Choice<T> {
  const Choice(this.value, this.label);

  final T value;
  final String label;
}

enum SegmentedStyle {
  /// Bordered tiles in a grid (the repeat picker).
  tiles,

  /// Tabs inside one bordered track (the appearance picker).
  tabs,
}

/// Pick one of a few options. The selected one is ink on paper.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelect,
    this.columns = 2,
    this.style = SegmentedStyle.tiles,
  });

  final List<Choice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelect;
  final int columns;
  final SegmentedStyle style;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final tabs = style == SegmentedStyle.tabs;
    final gap = tabs ? 4.0 : 6.0;

    Widget cell(Choice<T> c) {
      final on = c.value == selected;
      return Semantics(
        selected: on,
        button: true,
        label: c.label,
        excludeSemantics: true,
        onTap: () => onSelect(c.value),
        child: GestureDetector(
          onTap: () => onSelect(c.value),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: tabs ? 40 : DueSize.tapTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? p.ink : (tabs ? p.ink.withValues(alpha: 0) : p.surface),
                border: tabs ? null : Border.all(color: on ? p.ink : p.rule, width: 1.5),
                borderRadius: BorderRadius.circular(tabs ? DueRadius.control : DueRadius.card),
              ),
              child: Text(
                c.label,
                style: DueType.body(tabs ? 15 : 14, weight: FontWeight.w600, color: on ? p.paper : p.ink),
              ),
            ),
          ),
        ),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < choices.length; i += columns) {
      final slice = choices.skip(i).take(columns).toList();
      rows.add(
        Row(
          children: [
            for (final (j, c) in slice.indexed) ...[if (j > 0) SizedBox(width: gap), Expanded(child: cell(c))],
            for (var k = slice.length; k < columns; k++) ...[SizedBox(width: gap), const Expanded(child: SizedBox())],
          ],
        ),
      );
    }
    final grid = Column(
      children: [
        for (final (i, r) in rows.indexed) ...[if (i > 0) SizedBox(height: gap), r],
      ],
    );
    if (!tabs) return grid;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.rule),
        borderRadius: BorderRadius.circular(DueRadius.card),
      ),
      child: grid,
    );
  }
}
