import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/screens/DashboardScreen.dart';

import 'support/dashboard_harness.dart';

/// Records every range requested and hands back futures the test controls, so
/// completion order can be inverted deliberately.
class _RecordingLoader {
  final List<DateTimeRange> requests = [];
  final List<Completer<List<Transaction>>> completers = [];

  Future<List<Transaction>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    requests.add(DateTimeRange(start: startDate, end: endDate));
    final completer = Completer<List<Transaction>>();
    completers.add(completer);
    return completer.future;
  }

  int get requestCount => requests.length;
}

Widget dashboard(
  _RecordingLoader loader, {
  required DateTime now,
  bool dark = false,
}) {
  return MaterialApp(
    theme: dark ? testDarkTheme() : testLightTheme(),
    home: Scaffold(
      body: DashboardScreen(
        transactionLoader: loader.call,
        now: () => now,
      ),
    ),
  );
}

void main() {
  final now = DateTime(2026, 8, 17);

  setUp(() async {
    // The budget panel observes ConfigService, so it must be registered for the
    // dashboard to build.
    await registerConfigService();
  });

  group('DashboardScreen initial load', () {
    testWidgets('shows a blocking progress state with no monetary values',
        (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading August 2026'), findsOneWidget);
      // Nothing financial may appear before data exists.
      expect(find.textContaining('₹'), findsNothing);

      loader.completers.first.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('requests five months back through the exclusive next month',
        (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      expect(loader.requestCount, 1);
      expect(loader.requests.first.start, DateTime(2026, 3, 1));
      expect(loader.requests.first.end, DateTime(2026, 9, 1));

      loader.completers.first.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('renders every section from one response', (tester) async {
      // Tall surface so the lazily-built list constructs every section.
      await setSurface(tester, kTallSurface);

      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.complete([
        incomeTxn(25500, date: DateTime(2026, 8, 5)),
        expenseTxn(13040, date: DateTime(2026, 8, 6), tag: 'food'),
        expenseTxn(9000, date: DateTime(2026, 7, 6), tag: 'food'),
      ]);
      await tester.pumpAndSettle();

      // Still exactly one query for all the sections.
      expect(loader.requestCount, 1);
      // The loaded dashboard leads with the BALANCE card carrying August's
      // net (25500 income - 13040 expense) as a raw two-decimal value.
      expect(find.text('B A L A N C E'), findsOneWidget);
      expect(find.text('12460.0'), findsOneWidget);
      expect(find.text('Monthly budget'), findsOneWidget);
      expect(find.text('Spending by category'), findsOneWidget);
      expect(find.text('Six-month trend'), findsOneWidget);
      expect(find.text('Compared with July 2026'), findsOneWidget);
    });

    testWidgets('shows an error with Retry and no values when the load fails',
        (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.completeError(Exception('db down'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load August 2026"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('₹'), findsNothing);
      expect(find.textContaining('db down'), findsNothing);
    });

    testWidgets('Retry re-requests the same month', (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.completeError(Exception('nope'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(loader.requestCount, 2);
      expect(loader.requests.last.start, DateTime(2026, 3, 1));
      expect(loader.requests.last.end, DateTime(2026, 9, 1));

      loader.completers.last.complete([
        incomeTxn(100, date: DateTime(2026, 8, 2)),
      ]);
      await tester.pumpAndSettle();

      // A settled reload shows no status line; the loaded card is the anchor.
      expect(find.text('B A L A N C E'), findsOneWidget);
    });
  });

  group('DashboardScreen month selection', () {
    testWidgets('one chip activation starts exactly one request',
        (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));
      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jun 2026'));
      await tester.pump();

      expect(loader.requestCount, 2);
      expect(loader.requests.last.start, DateTime(2026, 1, 1));
      expect(loader.requests.last.end, DateTime(2026, 7, 1));
    });

    testWidgets('keeps values attributed to the displayed month while loading',
        (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.complete([
        incomeTxn(25500, date: DateTime(2026, 8, 5)),
        expenseTxn(13040, date: DateTime(2026, 8, 6)),
      ]);
      await tester.pumpAndSettle();
      // August's net snapshot (25500 - 13040) is on the BALANCE card.
      expect(find.text('B A L A N C E'), findsOneWidget);
      expect(find.text('12460.0'), findsOneWidget);

      // Ask for July but leave it pending.
      await tester.tap(find.text('Jul 2026'));
      await tester.pump();

      // The status names the loading month while August's figures stay put.
      expect(find.text('Loading July 2026'), findsOneWidget);
      expect(find.text('12460.0'), findsOneWidget);
      // The dashboard stays readable rather than blocking.
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      loader.completers.last.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('a future month cannot be selected', (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));
      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sep 2026'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(loader.requestCount, 1);
      expect(find.text('B A L A N C E'), findsOneWidget);
    });
  });

  group('DashboardScreen request ordering', () {
    testWidgets('a stale success cannot replace newer data', (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));
      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      // Request A: September is in the future, so use two past months instead.
      await tester.tap(find.text('Jun 2026'));
      await tester.pump();
      final requestA = loader.completers.last;

      // Request B supersedes A before A resolves.
      await tester.tap(find.text('Jul 2026'));
      await tester.pump();
      final requestB = loader.completers.last;

      // B resolves first with July data (9000 income - 4000 expense = 5000).
      requestB.complete([
        expenseTxn(4000, date: DateTime(2026, 7, 9)),
        incomeTxn(9000, date: DateTime(2026, 7, 9)),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('B A L A N C E'), findsOneWidget);
      expect(find.text('5000.0'), findsOneWidget);

      // Now the abandoned June request arrives with different figures
      // (777777 income - 1 expense = 777776).
      requestA.complete([
        expenseTxn(1, date: DateTime(2026, 6, 9)),
        incomeTxn(777777, date: DateTime(2026, 6, 9)),
      ]);
      await tester.pumpAndSettle();

      // July's snapshot must still own the screen; June never replaces it.
      expect(find.text('5000.0'), findsOneWidget);
      expect(find.text('777776.0'), findsNothing);
    });

    testWidgets('a stale failure cannot show an error or clear loading',
        (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));
      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jun 2026'));
      await tester.pump();
      final requestA = loader.completers.last;

      await tester.tap(find.text('Jul 2026'));
      await tester.pump();
      final requestB = loader.completers.last;

      // July with expense only (no income): net -4000, shown as -4000.0. The
      // net and the signed expense on the card share that value.
      requestB.complete([expenseTxn(4000, date: DateTime(2026, 7, 9))]);
      await tester.pumpAndSettle();
      expect(find.text('B A L A N C E'), findsOneWidget);
      expect(find.text('-4000.0'), findsWidgets);

      // The abandoned request fails afterwards.
      requestA.completeError(Exception('stale failure'));
      await tester.pumpAndSettle();

      // July's snapshot stays; no error surfaces from the stale failure.
      expect(find.text('B A L A N C E'), findsOneWidget);
      expect(find.text('-4000.0'), findsWidgets);
      expect(find.text('Retry'), findsNothing);
      expect(find.textContaining("Couldn't load"), findsNothing);
    });

    testWidgets('a refresh failure keeps the previous month visible',
        (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.complete([
        incomeTxn(25500, date: DateTime(2026, 8, 5)),
        expenseTxn(13040, date: DateTime(2026, 8, 6)),
      ]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jul 2026'));
      await tester.pump();
      loader.completers.last.completeError(Exception('offline'));
      await tester.pumpAndSettle();

      // Data is retained and August's net stays on the card, with a way back.
      expect(find.text("Couldn't load July 2026"), findsOneWidget);
      expect(find.text('B A L A N C E'), findsOneWidget);
      expect(find.text('12460.0'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('DashboardScreen presentation', () {
    testWidgets('renders at 320px without horizontal overflow', (tester) async {
      await setSurface(tester, kNarrowSurface);

      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.complete([
        incomeTxn(25500, date: DateTime(2026, 8, 5)),
        expenseTxn(6000, date: DateTime(2026, 8, 6), tag: 'food'),
        expenseTxn(4000, date: DateTime(2026, 8, 7), tag: 'cab'),
        expenseTxn(3040, date: DateTime(2026, 8, 8), tag: 'grocery'),
        expenseTxn(9000, date: DateTime(2026, 7, 6), tag: 'food'),
      ]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('B A L A N C E'), findsOneWidget);
    });

    testWidgets('renders an empty month with per-section empty states',
        (tester) async {
      await setSurface(tester, kTallSurface);

      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      // The BALANCE card is always mounted; the monthly summary hint is not,
      // so only the still-mounted sections show their own empty states.
      expect(find.text('B A L A N C E'), findsOneWidget);
      expect(find.text('No spending recorded this month.'), findsOneWidget);
      expect(
        find.textContaining('No transactions between Mar 2026 and Aug 2026'),
        findsOneWidget,
      );
      expect(
        find.textContaining('No transactions last month'),
        findsOneWidget,
      );
    });

    testWidgets('renders in the dark theme without error', (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now, dark: true));

      loader.completers.first.complete([
        incomeTxn(1000, date: DateTime(2026, 8, 5)),
        expenseTxn(400, date: DateTime(2026, 8, 6)),
      ]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('B A L A N C E'), findsOneWidget);
    });

    testWidgets('survives long values at 320px', (tester) async {
      await setSurface(tester, kNarrowSurface);

      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.complete([
        incomeTxn(98765432, date: DateTime(2026, 8, 5)),
        expenseTxn(87654321, date: DateTime(2026, 8, 6), tag: 'food'),
        expenseTxn(12345678, date: DateTime(2026, 7, 6), tag: 'food'),
      ]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The long income (98765432) shows as a raw two-decimal value on the card.
      expect(find.text('98765432.0'), findsOneWidget);
    });

    testWidgets('survives a doubled text scale at 320px', (tester) async {
      await setSurface(tester, kNarrowSurface);

      final loader = _RecordingLoader();
      await tester.pumpWidget(MaterialApp(
        theme: testLightTheme(),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2.0),
            ),
            child: Scaffold(
              body: DashboardScreen(
                transactionLoader: loader.call,
                now: () => now,
              ),
            ),
          ),
        ),
      ));

      loader.completers.first.complete([
        incomeTxn(25500, date: DateTime(2026, 8, 5)),
        expenseTxn(13040, date: DateTime(2026, 8, 6), tag: 'food'),
      ]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('B A L A N C E'), findsOneWidget);
    });

    testWidgets('lays out side by side at a wider width', (tester) async {
      await setSurface(tester, kWideSurface);

      final loader = _RecordingLoader();
      await tester.pumpWidget(dashboard(loader, now: now));

      loader.completers.first.complete([
        incomeTxn(25500, date: DateTime(2026, 8, 5)),
        expenseTxn(9000, date: DateTime(2026, 8, 6), tag: 'food'),
        expenseTxn(4040, date: DateTime(2026, 8, 7), tag: 'cab'),
      ]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('B A L A N C E'), findsOneWidget);
    });
  });
}
