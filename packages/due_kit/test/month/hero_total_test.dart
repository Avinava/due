import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

String _fmt(int v) => v.toString();

Widget _hero(int amount, {String? delta, bool done = false}) => HeroTotal(
  label: 'NEEDS YOU',
  amount: amount,
  format: _fmt,
  subLine: '₹1,23,227 committed · ₹15,547 on autopay',
  delta: delta,
  done: done,
);

String _shown(WidgetTester tester) => tester.widget<Text>(find.byKey(HeroTotal.figureKey)).textSpan!.toPlainText();

void main() {
  testWidgets('counts down to the new total', (tester) async {
    await pumpKit(tester, _hero(73680));
    expect(_shown(tester), contains('73680'));

    await pumpKit(tester, _hero(31680, delta: '−₹42,000'));
    await tester.pump(DueMotion.counter ~/ 4);
    final mid = int.parse(_shown(tester).replaceAll(RegExp(r'\D'), ''));
    expect(mid, inExclusiveRange(31680, 73680));

    await tester.pumpAndSettle();
    expect(_shown(tester), contains('31680'));
    expect(find.text('−₹42,000'), findsOneWidget);
  });

  testWidgets('a settled month says so instead of a total', (tester) async {
    await pumpKit(tester, _hero(0, done: true));
    expect(find.text('ALL SETTLED'), findsOneWidget);
    expect(find.textContaining('Nothing left', findRichText: true), findsOneWidget);
  });

  testWidgets('announces the total to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpKit(tester, _hero(73680));
    expect(find.bySemanticsLabel('NEEDS YOU, rupees 73680'), findsOneWidget);
    handle.dispose();
  });
}
