import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../foundation/theme.dart';
import '../../../foundation/tokens.g.dart';
import '../../../foundation/type.dart';
import '../../display/mark_style.dart';
import 'dial_model.dart';
import 'dial_painter.dart';

/// The month as a ring. Drag along it to pick a day; the middle clears the
/// pick. Mark colours ease when an item changes state.
class DueDial extends StatefulWidget {
  const DueDial({
    super.key,
    required this.model,
    required this.onSelect,
    this.size = DueSize.dial,
    this.showLine3 = true,
    this.labelSize = DueSize.xs,
    this.line2Size = DueSize.xl,
    this.line3Size = DueSize.sm,
    this.line3Width = 150,
  });

  final DialModel model;

  /// Called with the day under the pointer, or null when it moves to the
  /// middle.
  final ValueChanged<int?> onSelect;
  final double size;
  final bool showLine3;
  final double labelSize;
  final double line2Size;
  final double line3Size;
  final double line3Width;

  @override
  State<DueDial> createState() => _DueDialState();
}

class _DueDialState extends State<DueDial> with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(vsync: this, duration: DueMotion.markFill);
  Map<int, MarkState> _from = {};
  Map<int, MarkState> _to = {};

  @override
  void initState() {
    super.initState();
    _to = _states(widget.model);
    _from = _to;
    _fade.value = 1;
  }

  @override
  void didUpdateWidget(DueDial old) {
    super.didUpdateWidget(old);
    final next = _states(widget.model);
    if (!_sameStates(next, _to)) {
      _from = _to;
      _to = next;
      _fade.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  static Map<int, MarkState> _states(DialModel m) => {for (final k in m.marks) k.day: k.state};

  static bool _sameStates(Map<int, MarkState> a, Map<int, MarkState> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

  int? _dayAt(Offset local) {
    final r = widget.size / 2;
    final v = local - Offset(r, r);
    if (v.distance / r * 170 < 70) return null;
    var a = math.atan2(v.dy, v.dx) * 180 / math.pi + 90;
    if (a < 0) a += 360;
    final n = widget.model.days;
    final d = (a / (360 / n)).round() + 1;
    return d > n ? 1 : d;
  }

  void _scrub(Offset local, {required bool first}) {
    final d = _dayAt(local);
    if (d == widget.model.selected && !first) return;
    if (d != null && d != widget.model.selected) HapticFeedback.selectionClick();
    widget.onSelect(d);
  }

  /// The day [delta] steps from the selection, or from today when nothing is
  /// selected, wrapping round the month.
  int _stepped(int delta) {
    final n = widget.model.days;
    final current = widget.model.selected ?? widget.model.today ?? 0;
    return ((current - 1 + delta) % n + n) % n + 1;
  }

  String _describe(int? day) {
    if (day == null) return 'Whole month';
    return widget.model.marks.where((k) => k.day == day).firstOrNull?.label ?? 'Day $day, nothing due';
  }

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final m = widget.model;
    return Semantics(
      container: true,
      slider: true,
      label: m.semanticLabel,
      value: _describe(m.selected),
      increasedValue: _describe(_stepped(1)),
      decreasedValue: _describe(_stepped(-1)),
      onIncrease: () => widget.onSelect(_stepped(1)),
      onDecrease: () => widget.onSelect(_stepped(-1)),
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
            _EagerPan.new,
            (r) => r
              ..onDown = ((d) => _scrub(d.localPosition, first: true))
              ..onUpdate = ((d) => _scrub(d.localPosition, first: false)),
          ),
        },
        child: SizedBox.square(
          dimension: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _fade,
                  builder: (context, _) => CustomPaint(
                    painter: DialPainter(
                      model: m,
                      palette: p,
                      from: _from,
                      to: _to,
                      t: Curves.easeOut.transform(_fade.value),
                      labelStyle: DueType.mono(widget.size >= DueSize.dialWide ? 10 : 11, color: p.soft),
                    ),
                  ),
                ),
              ),
              ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m.line1,
                      textScaler: TextScaler.noScaling,
                      style: DueType.mono(widget.labelSize, em: .1, color: p.muted),
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: widget.line3Width),
                      child: Text(
                        m.line2,
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.noScaling,
                        style: DueType.display(widget.line2Size, em: -.03, color: p.ink, height: 1.05),
                      ),
                    ),
                    if (widget.showLine3 && m.line3.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: widget.line3Width),
                        child: Text(
                          m.line3,
                          textAlign: TextAlign.center,
                          textScaler: TextScaler.noScaling,
                          style: DueType.body(widget.line3Size, color: p.muted),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pan that claims the pointer on touch, so dragging round the ring never
/// scrolls the list it sits in.
class _EagerPan extends PanGestureRecognizer {
  _EagerPan() : super(debugOwner: null);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
