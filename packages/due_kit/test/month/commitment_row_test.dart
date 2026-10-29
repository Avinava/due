import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

RowModel _row(MarkState state, {bool toggleable = true}) => RowModel(
  id: 'school',
  name: 'School fees',
  schedule: 'Term 2 of 3',
  amount: '₹42,000',
  status: 'Due Thu 15',
  state: state,
  semanticLabel: '15 October, School fees, ₹42,000, ${state.needsYou ? 'unpaid' : 'paid'}',
  toggleable: toggleable,
);

void main() {
  for (final layout in RowLayout.values) {
    testWidgets('${layout.name}: shows name, schedule, amount and status', (tester) async {
      await pumpKit(tester, CommitmentRow(_row(MarkState.due), layout: layout, onTap: () {}));
      for (final text in ['School fees', '₹42,000', 'Due Thu 15']) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.text('Term 2 of 3'), layout == RowLayout.card ? findsNothing : findsOneWidget);
    });
  }

  testWidgets('a manual row toggles on tap', (tester) async {
    var taps = 0;
    await pumpKit(tester, SizedBox(width: 390, child: CommitmentRow(_row(MarkState.due), onTap: () => taps++)));
    await tester.tap(find.byType(CommitmentRow));
    expect(taps, 1);
  });

  for (final (name, row) in [
    ('an autopay row', _row(MarkState.auto)),
    ('a row that cannot be toggled', _row(MarkState.paid, toggleable: false)),
  ]) {
    testWidgets('$name ignores taps and is not a button', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpKit(tester, SizedBox(width: 390, child: CommitmentRow(row, onTap: () => taps++)));
      await tester.tap(find.byType(CommitmentRow));
      expect(taps, 0);
      expect(tester.getSemantics(find.byType(CommitmentRow)), isNot(matchesSemantics(isButton: true)));
      handle.dispose();
    });
  }

  testWidgets('reads as one labelled button', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpKit(tester, SizedBox(width: 390, child: CommitmentRow(_row(MarkState.late), onTap: () {})));
    expect(
      tester.getSemantics(find.byType(CommitmentRow)),
      matchesSemantics(label: '15 October, School fees, ₹42,000, unpaid', isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('the today header uses the accent', (tester) async {
    await pumpKit(tester, const SizedBox(width: 390, child: DayGroupHeader('TODAY · MON 12', isToday: true)));
    final text = tester.widget<Text>(find.text('TODAY · MON 12'));
    expect(text.style?.color, DuePalette.light.accentText);
  });
}
