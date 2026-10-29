import 'dart:math' as math;

import 'package:due_kit/due_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _model = DialModel(
  days: 31,
  today: 12,
  elapsedDays: 11,
  line1: 'MON 12 OCT',
  line2: '19 days left',
  line3: 'Next: Society maintenance, Sat 10',
  marks: [
    DialMark(day: 10, state: MarkState.late, label: '10 October, Society maintenance, ₹7,500, unpaid'),
    DialMark(day: 15, state: MarkState.due, label: '15 October, School fees, ₹42,000, unpaid'),
  ],
);

/// The global position of [day] on the ring of a dial of [size].
Offset _dayOffset(WidgetTester tester, int day, {double size = DueSize.dial, int days = 31}) {
  final origin = tester.getTopLeft(find.byType(DueDial));
  final a = (-90 + (day - 1) * 360 / days) * math.pi / 180;
  final r = 120 * size / 340;
  return origin + Offset(size / 2, size / 2) + Offset(math.cos(a), math.sin(a)) * r;
}

void main() {
  testWidgets('pressing the ring selects the day under the pointer', (tester) async {
    int? picked = -1;
    await pumpKit(tester, DueDial(model: _model, onSelect: (d) => picked = d));
    await tester.tapAt(_dayOffset(tester, 15));
    expect(picked, 15);
    await tester.tapAt(_dayOffset(tester, 1));
    expect(picked, 1);
  });

  testWidgets('the middle clears the selection', (tester) async {
    int? picked = -1;
    await pumpKit(tester, DueDial(model: _model, onSelect: (d) => picked = d));
    await tester.tapAt(tester.getCenter(find.byType(DueDial)));
    expect(picked, isNull);
  });

  testWidgets('dragging reports each new day once', (tester) async {
    final picked = <int?>[];
    await pumpKit(tester, DueDial(model: _model, onSelect: picked.add));
    final g = await tester.startGesture(_dayOffset(tester, 14));
    await g.moveTo(_dayOffset(tester, 15));
    await g.moveTo(_dayOffset(tester, 16));
    await g.up();
    expect(picked, [14, 15, 16]);
  });

  testWidgets('every mark has a screen reader label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpKit(tester, DueDial(model: _model, onSelect: (_) {}));
    expect(find.semantics.byLabel('15 October, School fees, ₹42,000, unpaid'), findsOne);
    expect(find.semantics.byLabel('10 October, Society maintenance, ₹7,500, unpaid'), findsOne);
    handle.dispose();
  });

  testWidgets('is an adjustable control that steps from today', (tester) async {
    final handle = tester.ensureSemantics();
    int? picked;
    await pumpKit(tester, DueDial(model: _model, onSelect: (d) => picked = d));
    const label = 'Month dial. Drag to scrub through days.';
    expect(
      tester.getSemantics(find.bySemanticsLabel(label)),
      isSemantics(isSlider: true, hasIncreaseAction: true, hasDecreaseAction: true, value: 'Whole month'),
    );
    final dial = find.semantics.byLabel(label);
    tester.semantics.increase(dial);
    expect(picked, 13);
    tester.semantics.decrease(dial);
    expect(picked, 11);
    handle.dispose();
  });

  testWidgets('shows the three centre lines and hides the third when asked', (tester) async {
    await pumpKit(tester, DueDial(model: _model, onSelect: (_) {}));
    expect(find.text('19 days left'), findsOneWidget);
    expect(find.text('Next: Society maintenance, Sat 10'), findsOneWidget);
    await pumpKit(tester, DueDial(model: _model, onSelect: (_) {}, showLine3: false, size: DueSize.dialLarge));
    expect(find.text('Next: Society maintenance, Sat 10'), findsNothing);
  });
}
