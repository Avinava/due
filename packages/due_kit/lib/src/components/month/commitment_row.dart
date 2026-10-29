import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';
import '../display/mark_style.dart';
import '../display/status_mark.dart';
import 'row_model.dart';

/// A commitment in the month list. Tapping toggles paid; autopay rows and
/// rows that are not [RowModel.toggleable] are not tappable.
class CommitmentRow extends StatelessWidget {
  const CommitmentRow(this.model, {super.key, this.layout = RowLayout.phone, this.onTap, this.onLongPress});

  final RowModel model;
  final RowLayout layout;
  final VoidCallback? onTap;

  /// Opens the commitment for editing; works on autopay rows too.
  final VoidCallback? onLongPress;

  static const _wideMinWidth = 560.0;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final style = MarkStyle.of(model.state, p);
    final tappable = onTap != null && model.toggleable && !model.state.isAutopay;
    final late = model.state == MarkState.late;
    final rest = layout == RowLayout.card ? p.surface : p.paper.withValues(alpha: 0);
    final bg = model.flashing ? p.flashBg : (late ? p.lateBg : rest);

    final child = switch (layout) {
      RowLayout.phone => _phone(p, style),
      RowLayout.wide => LayoutBuilder(
        // Below this the status and amount columns no longer fit beside the
        // name, so the row stacks like the phone one.
        builder: (context, box) => box.maxWidth < _wideMinWidth ? _phone(p, style) : _wide(p, style),
      ),
      RowLayout.card => _card(p, style),
    };

    return Semantics(
      button: tappable,
      label: model.semanticLabel,
      excludeSemantics: true,
      onTap: tappable ? onTap : null,
      onLongPress: onLongPress,
      onLongPressHint: onLongPress == null ? null : 'edit',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tappable ? onTap : null,
        onLongPress: onLongPress,
        onSecondaryTap: onLongPress,
        child: MouseRegion(
          cursor: tappable ? SystemMouseCursors.click : MouseCursor.defer,
          child: AnimatedContainer(
            duration: DueMotion.rowFade,
            curve: Curves.ease,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: layout == RowLayout.phone ? null : BorderRadius.circular(DueRadius.card),
              border: layout == RowLayout.card ? Border.all(color: p.rule) : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _names(DuePalette p, MarkStyle style, {double name = DueSize.md, double sub = DueSize.sm}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        model.name,
        style: DueType.body(name, weight: FontWeight.w600, color: style.nameColor),
      ),
      const SizedBox(height: 2),
      Text(model.schedule, style: DueType.body(sub, color: p.muted)),
    ],
  );

  Widget _phone(DuePalette p, MarkStyle style) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: DueSize.tapTarget),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
      child: Row(
        children: [
          StatusMark(model.state),
          const SizedBox(width: 14),
          Expanded(child: _names(p, style)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model.amount,
                style: DueType.display(DueSize.md, weight: FontWeight.w600, color: style.nameColor),
              ),
              const SizedBox(height: 2),
              Text(model.status, style: DueType.mono(DueSize.xs, color: style.statusColor)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _wide(DuePalette p, MarkStyle style) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Row(
      children: [
        StatusMark(model.state),
        const SizedBox(width: 14),
        Expanded(child: _names(p, style)),
        const SizedBox(width: 14),
        SizedBox(
          width: 150,
          child: Text(model.status, style: DueType.mono(12, color: style.statusColor)),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 110,
          child: Text(
            model.amount,
            textAlign: TextAlign.right,
            style: DueType.display(17, weight: FontWeight.w600, color: style.nameColor),
          ),
        ),
      ],
    ),
  );

  /// Card sizes are already large, so they ignore the system text scale.
  Widget _card(DuePalette p, MarkStyle style) => MediaQuery.withNoTextScaling(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(model.amount, style: DueType.display(34, em: -.03, color: style.nameColor, height: 1)),
              ),
              StatusMark(model.state, size: 40),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            model.name,
            style: DueType.body(28, weight: FontWeight.w600, color: style.nameColor, height: 1.15),
          ),
          const SizedBox(height: 10),
          Text(
            model.status,
            style: DueType.body(22, weight: FontWeight.w600, color: style.statusColor, height: 1.25),
          ),
        ],
      ),
    ),
  );
}
