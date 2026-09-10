import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expenny/screens/PreferencesScreen.dart';
import 'package:expenny/service/ConfigService.dart';
import 'package:expenny/service/DateService.dart';

import 'support/dashboard_harness.dart';

/// Widget-test suite for the grouped Preferences experience.
///
/// The screen resolves its collaborators through GetX: the dark-mode toggle
/// and the budget row read/write [ConfigService]; the SMS row reads
/// [ConfigService.lastSyncedAt]. A real [ConfigService] is registered via the
/// shared harness (mocked GetStorage) so assertions exercise the genuine
/// persistence path rather than a hand-rolled stub. The suite never taps the
/// SMS import row or confirms deletion, so `SmsSyncService`, `DataService`, and
/// `TransactionController` are never resolved and need not be registered.

/// A tall, phone-width surface so every one of the five groups is built and
/// laid out (a `ListView` only realises visible children otherwise).
const Size _kTallSurface = Size(400, 2400);

Widget _screen({double textScale = 1.0, bool dark = false}) {
  return MaterialApp(
    theme: dark ? testDarkTheme() : testLightTheme(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: const Scaffold(body: PreferencesScreen()),
      ),
    ),
  );
}

/// Finds the `Semantics` node that fronts a preference row by its combined
/// `label` ("title. subtitle"), so we can assert on button/enabled/toggled
/// flags and the merged accessible label rather than the excluded descendants.
Finder _rowByLabelPrefix(String titlePrefix) {
  return find.byWidgetPredicate((widget) {
    if (widget is! Semantics) return false;
    final label = widget.properties.label;
    return label != null && label.startsWith(titlePrefix);
  });
}

void main() {
  late ConfigService config;

  setUp(() async {
    config = await registerConfigService();
  });

  group('PreferencesScreen — group scaffolding', () {
    testWidgets('renders all five section labels in order', (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      for (final label in const [
        'Appearance',
        'Planning',
        'Automation',
        'Data',
        'Danger zone',
      ]) {
        expect(find.text(label), findsOneWidget,
            reason: 'missing section: $label');
      }

      // The screen heading is present.
      expect(find.text('Preferences'), findsOneWidget);
    });

    testWidgets('each group exposes its expected rows', (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      // Appearance
      expect(find.text('Dark mode'), findsOneWidget);
      // Planning
      expect(find.text('Monthly budget'), findsOneWidget);
      // Automation
      expect(find.text('Import from Messages'), findsOneWidget);
      // Data
      expect(find.text('Import data'), findsOneWidget);
      expect(find.text('Export to Excel'), findsOneWidget);
      // Danger zone
      expect(find.text('Delete all data'), findsOneWidget);
    });
  });

  group('Appearance — dark mode', () {
    testWidgets('switch reflects the persisted ConfigService value',
        (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      expect(config.isDarkMode.value, isFalse);
      final initialSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(initialSwitch.value, isFalse);
    });

    testWidgets('toggling the switch drives ConfigService.toggleDarkMode',
        (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // The genuine ConfigService state flipped and persisted, and the Switch
      // re-rendered from that reactive value.
      expect(config.isDarkMode.value, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('tapping the row (not just the switch) toggles once',
        (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark mode'));
      await tester.pumpAndSettle();

      expect(config.isDarkMode.value, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });
  });

  group('Planning — monthly budget', () {
    testWidgets('row opens the shared showMonthlyBudgetDialog', (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly budget'));
      await tester.pumpAndSettle();

      // The shared dialog's distinctive title and hint prove it is the same
      // editor used from the Dashboard, not a bespoke copy.
      expect(find.text('Monthly Budget'), findsOneWidget);
      expect(
        find.text('Enter budget amount (leave empty to clear)'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);

      // Dismiss without changing anything.
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('trailing value shows "Set budget" when unset', (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      expect(find.text('Set budget'), findsOneWidget);
    });
  });

  group('Automation — SMS last-synced status', () {
    testWidgets('real lastSyncedAt renders "Last synced <time>"',
        (tester) async {
      final synced = DateTime(2026, 8, 23, 13, 24);
      config.lastSyncedAt.value = synced.toIso8601String();

      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      final expected =
          'Last synced ${DateService.formatTime(synced.toLocal())}';
      expect(find.text(expected), findsOneWidget);
      expect(find.text('Not synced yet'), findsNothing);
    });

    testWidgets('null lastSyncedAt renders "Not synced yet"', (tester) async {
      config.lastSyncedAt.value = null;

      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      expect(find.text('Not synced yet'), findsOneWidget);
    });

    testWidgets('malformed lastSyncedAt renders "Not synced yet"',
        (tester) async {
      config.lastSyncedAt.value = 'not-a-timestamp';

      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      expect(find.text('Not synced yet'), findsOneWidget);
    });
  });

  group('Data — Import data (disabled)', () {
    testWidgets(
        'is disabled, shows "Coming soon", and exposes disabled semantics',
        (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      // The "Coming soon" badge is present.
      expect(find.text('Coming soon'), findsWidgets);

      // The row's semantics node reports disabled and is not a button.
      final rowFinder = _rowByLabelPrefix('Import data.');
      expect(rowFinder, findsOneWidget);
      final semantics = tester.widget<Semantics>(rowFinder);
      expect(semantics.properties.enabled, isFalse,
          reason: 'Import data row must expose disabled semantics');
      expect(semantics.properties.button, isFalse,
          reason: 'a disabled row must not advertise itself as a button');
    });

    testWidgets('tapping Import data does nothing and shows no snackbar',
        (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import data'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // No feedback surface appears; the row has no onTap wired.
      expect(find.byType(SnackBar), findsNothing);
      // The disabled row does not host an InkWell (no ripple affordance).
      expect(
        find.descendant(
          of: _rowByLabelPrefix('Import data.'),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });
  });

  group('Danger zone — delete confirmation', () {
    testWidgets('tapping Delete all data opens a destructive confirmation',
        (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete all data'));
      await tester.pumpAndSettle();

      // A confirmation dialog appears with an explicit destructive action.
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete all data?'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'delete'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'cancel'), findsOneWidget);

      // Cancel to leave state untouched — deletion is never executed, so no
      // DataService / TransactionController resolution is triggered.
      await tester.tap(find.widgetWithText(TextButton, 'cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('delete row carries button semantics and no toggle',
        (tester) async {
      await setSurface(tester, _kTallSurface);
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      final rowFinder = _rowByLabelPrefix('Delete all data.');
      expect(rowFinder, findsOneWidget);
      final semantics = tester.widget<Semantics>(rowFinder);
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isTrue);
      expect(semantics.properties.toggled, isNull);
    });
  });

  group('Layout — scrolls without overflow', () {
    void expectNoOverflow(WidgetTester tester) {
      // Any RenderFlex overflow raises a FlutterError captured here.
      expect(tester.takeException(), isNull);
    }

    testWidgets('renders at 320dp width without overflow', (tester) async {
      await setSurface(tester, const Size(320, 640));
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();
      expectNoOverflow(tester);

      // The content is scrollable.
      expect(find.byType(Scrollable), findsWidgets);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('scrolls to reveal the Danger zone on a short viewport',
        (tester) async {
      await setSurface(tester, const Size(360, 480));
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();
      expectNoOverflow(tester);

      // The last group may be below the fold on a short viewport; scrolling
      // must bring it into view without any overflow.
      await tester.scrollUntilVisible(
        find.text('Delete all data'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Delete all data'), findsOneWidget);
      expectNoOverflow(tester);
    });

    testWidgets('renders at 2.0x text scale without overflow', (tester) async {
      await setSurface(tester, const Size(320, 900));
      await tester.pumpWidget(_screen(textScale: 2.0));
      await tester.pumpAndSettle();
      expectNoOverflow(tester);

      expect(find.text('Dark mode'), findsOneWidget);
    });
  });
}
