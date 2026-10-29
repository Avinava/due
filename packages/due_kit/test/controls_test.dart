import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('inputs', () {
    testWidgets('DueSwitch toggles and reports its state', (tester) async {
      final handle = tester.ensureSemantics();
      var value = false;
      await pumpKit(tester, DueSwitch(value: value, label: 'Autopay', onChanged: (v) => value = v));
      expect(
        tester.getSemantics(find.byType(DueSwitch)),
        matchesSemantics(label: 'Autopay', hasToggledState: true, hasTapAction: true),
      );
      await tester.tap(find.byType(DueSwitch));
      expect(value, isTrue);
      handle.dispose();
    });

    testWidgets('DueStepper steps both ways', (tester) async {
      var n = 3;
      await pumpKit(
        tester,
        SizedBox(
          width: 360,
          child: DueStepper(label: 'Every', value: '$n months', onDecrease: () => n--, onIncrease: () => n++),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Increase'));
      await tester.tap(find.bySemanticsLabel('Increase'));
      await tester.tap(find.bySemanticsLabel('Decrease'));
      expect(n, 4);
    });

    testWidgets('SegmentedChoice selects and marks the selection', (tester) async {
      final handle = tester.ensureSemantics();
      var picked = 'monthly';
      await pumpKit(
        tester,
        SizedBox(
          width: 360,
          child: SegmentedChoice<String>(
            choices: const [
              Choice('monthly', 'Monthly'),
              Choice('months', 'Every N months'),
              Choice('weekly', 'Weekly'),
              Choice('days', 'Every N days'),
            ],
            selected: picked,
            onSelect: (v) => picked = v,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Monthly')),
        matchesSemantics(
          label: 'Monthly',
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.text('Every N days'));
      expect(picked, 'days');
      handle.dispose();
    });
  });

  group('buttons and feedback', () {
    testWidgets('DueSnack offers undo only when given', (tester) async {
      var undone = false;
      await pumpKit(tester, DueSnack(text: 'School fees marked paid', onUndo: () => undone = true));
      await tester.tap(find.text('Undo'));
      expect(undone, isTrue);
      await pumpKit(tester, const DueSnack(text: 'Sample household restored'));
      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('ArrowButton and MenuButton have labels', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpKit(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArrowButton(forward: false, onPressed: () {}),
            ArrowButton(forward: true, onPressed: () {}),
            MenuButton(onPressed: () {}),
          ],
        ),
      );
      for (final label in ['Previous month', 'Next month', 'Settings']) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      handle.dispose();
    });

    testWidgets('DueButton calls back', (tester) async {
      var pressed = 0;
      await pumpKit(
        tester,
        DueButton(label: 'Add', leading: '+', kind: DueButtonKind.accent, height: 56, onPressed: () => pressed++),
      );
      await tester.tap(find.text('Add'));
      expect(pressed, 1);
    });
  });

  group('display', () {
    testWidgets('each mark state renders in both themes', (tester) async {
      for (final b in Brightness.values) {
        await pumpKit(
          tester,
          Row(mainAxisSize: MainAxisSize.min, children: [for (final s in MarkState.values) StatusMark(s)]),
          brightness: b,
        );
        await tester.pumpAndSettle();
        expect(find.byType(StatusMark), findsNWidgets(MarkState.values.length));
      }
    });

    test('mark styles follow the design', () {
      const p = DuePalette.light;
      expect(MarkStyle.of(MarkState.late, p).statusColor, p.critical);
      expect(MarkStyle.of(MarkState.paid, p).statusColor, p.positive);
      expect(MarkStyle.of(MarkState.auto, p).dashed, isTrue);
      expect(MarkStyle.of(MarkState.settled, p).glyph, MarkGlyph.check);
      expect(MarkState.values.where((s) => s.needsYou), [MarkState.due, MarkState.late]);
    });

    testWidgets('large text switches on above 1.4x', (tester) async {
      late bool large;
      await pumpKit(
        tester,
        Builder(
          builder: (c) {
            large = isLargeText(c);
            return const SizedBox();
          },
        ),
        textScale: 2,
      );
      expect(large, isTrue);
      await pumpKit(
        tester,
        Builder(
          builder: (c) {
            large = isLargeText(c);
            return const SizedBox();
          },
        ),
      );
      expect(large, isFalse);
    });

    testWidgets('Wordmark, chips and legend render', (tester) async {
      await pumpKit(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wordmark(),
            DeltaChip('−₹42,000'),
            NoteChip('Clamped from 31st', background: Color(0xFFF7E6B8), foreground: Color(0xFF7A5400)),
            LegendDot(label: 'Autopay', color: Color(0xFF6B5D52), hollow: true),
            SectionLabel('REMINDERS'),
          ],
        ),
      );
      for (final t in ['due', '−₹42,000', 'Clamped from 31st', 'Autopay', 'REMINDERS']) {
        expect(find.text(t), findsOneWidget);
      }
    });
  });
}
