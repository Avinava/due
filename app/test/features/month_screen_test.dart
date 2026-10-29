import 'package:due/app/due_app.dart';
import 'package:due/app/platform_providers.dart';
import 'package:due/app/providers.dart';
import 'package:due/data/memory_commitment_repository.dart';
import 'package:due/domain/reminder_plan.dart';
import 'package:due/features/edit/edit_sheet.dart';
import 'package:due/platform/home_widget_sync.dart';
import 'package:due/platform/reminders.dart';
import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime.utc(2026, 10, 12);

final class _RecordingReminders implements ReminderScheduler {
  List<Reminder> last = const [];

  @override
  Future<void> replaceAll(List<Reminder> plan) async => last = plan;
}

Future<MemoryCommitmentRepository> pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  ReminderScheduler reminders = const NoReminders(),
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  final repo = MemoryCommitmentRepository.sample(today);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => today),
        repositoryProvider.overrideWithValue(repo),
        remindersProvider.overrideWithValue(reminders),
        homeWidgetsProvider.overrideWithValue(const NoHomeWidgets()),
      ],
      child: const DueApp(),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

String heroFigure(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(HeroTotal.figureKey)).textSpan!.toPlainText().replaceAll(RegExp(r'[^0-9,]'), '');

Future<void> drainTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('marking a row paid counts the total down, and undo restores it', (tester) async {
    await pumpApp(tester);
    expect(heroFigure(tester), '73,680');

    final list = find.byType(Scrollable).first;
    await tester.ensureVisible(find.text('School fees'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('School fees'));
    await tester.pumpAndSettle();
    await tester.drag(list, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(heroFigure(tester), '31,680');
    expect(find.text('School fees marked paid'), findsOneWidget);
    expect(find.text('−₹42,000'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(heroFigure(tester), '73,680');
    await drainTimers(tester);
  });

  testWidgets('tapping a row just marked paid again works like undo', (tester) async {
    await pumpApp(tester);
    await tester.ensureVisible(find.text('School fees'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('School fees'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('School fees'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(heroFigure(tester), '73,680');
    expect(find.text('School fees marked paid'), findsNothing);
    expect(find.text('−₹42,000'), findsNothing);
    await drainTimers(tester);
  });

  testWidgets('autopay rows ignore taps', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Jio prepaid').first);
    await tester.pumpAndSettle();
    expect(heroFigure(tester), '73,680');
    expect(find.text('Jio prepaid marked paid'), findsNothing);
  });

  testWidgets('scrubbing filters the list and Whole month resets it', (tester) async {
    await pumpApp(tester);
    final dial = find.byType(DueDial);
    final box = tester.getRect(dial);
    // Day 15 of 31 sits just past the bottom of the ring.
    await tester.tapAt(box.center + Offset(0, box.height / 2 * 120 / 170).translate(-6, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('Showing', findRichText: true), findsOneWidget);
    expect(find.text('Rent'), findsNothing);

    await tester.tap(find.text('Whole month'));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('month arrows move through months and stop at the limits', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('NEEDS YOU IN NOVEMBER'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pumpAndSettle();
    }
    expect(find.text('July 2026'), findsOneWidget);
  });

  testWidgets('adding a commitment on the 31st previews the clamp and saves', (tester) async {
    final repo = await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Add commitment'));
    await tester.pumpAndSettle();
    expect(find.text('New commitment'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Credit card bill');
    await tester.enterText(find.byType(TextField).last, '12000');
    final dayUp = find.descendant(of: find.byType(EditSheet), matching: find.text('+')).first;
    await tester.ensureVisible(dayUp);
    for (var i = 0; i < 19; i++) {
      await tester.tap(dayUp);
      await tester.pump();
    }
    expect(find.text('the 31st'), findsOneWidget);
    expect(find.text('Clamped from 31st'), findsWidgets);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await repo.load()).commitments.map((c) => c.name), contains('Credit card bill'));
    expect(find.textContaining('Credit card bill added'), findsOneWidget);
    await drainTimers(tester);
  });

  testWidgets('settings shows the reminder plan and switches theme', (tester) async {
    final reminders = _RecordingReminders();
    await pumpApp(tester, reminders: reminders);
    expect(reminders.last, hasLength(6));

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('6 reminders scheduled for the next 60 days.'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Settings').last)).brightness, Brightness.dark);

    await tester.tap(find.bySemanticsLabel('Reminders'));
    await tester.pumpAndSettle();
    expect(find.text('Reminders are off.'), findsOneWidget);
    expect(reminders.last, isEmpty);

    await tester.tap(find.bySemanticsLabel('Back to October'));
    await tester.pumpAndSettle();
    expect(find.byType(DueDial), findsOneWidget);
  });

  testWidgets('from 720px up the month is laid out wide', (tester) async {
    await pumpApp(tester, size: const Size(1280, 800));
    expect(find.text('9 charges this month'), findsOneWidget);
    expect(find.text('+ Add commitment'), findsOneWidget);
    expect(find.byType(LegendDot), findsNWidgets(3));
  });

  testWidgets('just above the breakpoint the wide layout still fits', (tester) async {
    // A default macOS window: overflow here fails the test.
    await pumpApp(tester, size: const Size(800, 600));
    expect(find.text('9 charges this month'), findsOneWidget);
    final pane = tester.getSize(find.byType(DueDial));
    expect(pane.width, lessThan(DueSize.dialWide));
  });

  testWidgets('at 200% text rows become cards', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester);
    final rent = tester.widget<CommitmentRow>(find.widgetWithText(CommitmentRow, 'Rent'));
    expect(rent.layout, RowLayout.card);
    expect(tester.getSize(find.byType(DueDial)).width, DueSize.dialLarge);
  });
}
