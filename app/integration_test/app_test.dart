import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:due/app/due_app.dart';
import 'package:due/app/platform_providers.dart';
import 'package:due/app/providers.dart';
import 'package:due/data/backup.dart';
import 'package:due/data/database.dart';
import 'package:due/features/edit/edit_sheet.dart';
import 'package:due/platform/backup_files.dart';
import 'package:due/platform/home_widget_sync.dart';
import 'package:due/platform/reminders.dart';
import 'package:due_kit/due_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final today = DateTime.utc(2026, 10, 12);

final class _CapturedBackup implements BackupFiles {
  String? exported;

  @override
  Future<bool> export(String json, String fileName) async {
    exported = json;
    return true;
  }

  @override
  Future<String?> pick() async => exported;
}

String _hero(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(HeroTotal.figureKey)).textSpan!.toPlainText().replaceAll(RegExp(r'[^0-9,]'), '');

/// The whole app on a real (in-memory) SQLite database: mark paid, add a
/// commitment, export, reset.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a month in the life', (tester) async {
    final db = DueDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    final backup = _CapturedBackup();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => today),
          databaseProvider.overrideWithValue(db),
          remindersProvider.overrideWithValue(const NoReminders()),
          homeWidgetsProvider.overrideWithValue(const NoHomeWidgets()),
          backupFilesProvider.overrideWithValue(backup),
        ],
        child: const DueApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(_hero(tester), '73,680');

    // Pay school fees from the list.
    await tester.ensureVisible(find.text('School fees'));
    await tester.tap(find.text('School fees'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(_hero(tester), '31,680');

    // Add a credit card bill on the 31st.
    await tester.tap(find.bySemanticsLabel(RegExp('Add')).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'Credit card bill');
    await tester.enterText(find.byType(EditableText).last, '12000');
    await tester.pump();
    final dayUp = find.descendant(of: find.byType(EditSheet), matching: find.text('+')).first;
    for (var i = 0; i < 19; i++) {
      await tester.tap(dayUp);
      await tester.pump();
    }
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));

    // Export, then reset to the sample household.
    await tester.tap(find.bySemanticsLabel('Settings').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Export as JSON'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export as JSON'));
    await tester.pumpAndSettle();
    final saved = Backup.decode(backup.exported!);
    expect(saved.commitments.map((c) => c.name), contains('Credit card bill'));
    expect(saved.paid.any((p) => p.commitmentId == 'school'), isTrue);

    await tester.ensureVisible(find.text('Reset to sample household'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset to sample household'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.ensureVisible(find.bySemanticsLabel('Back to October'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back to October'));
    await tester.pumpAndSettle();
    expect(_hero(tester), '73,680');

    await db.close();
  });
}
