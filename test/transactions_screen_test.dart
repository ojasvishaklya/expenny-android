import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/screens/TransactionsScreen.dart';

import 'support/dashboard_harness.dart';

/// A tall, comfortably wide surface so the ledger list renders and the month /
/// control chips are fully visible and hittable.
const Size _kSurface = Size(500, 2200);


class _Request {
  _Request(this.startDate, this.endDate, this.searchString, this.tagSet);
  final DateTime startDate;
  final DateTime endDate;
  final String? searchString;
  final Set<TransactionTag>? tagSet;
}

/// Records every request and hands back test-controlled futures so completion
/// order can be inverted deliberately.
class _RecordingLoader {
  final List<_Request> requests = [];
  final List<Completer<List<Transaction>>> completers = [];

  Future<List<Transaction>> call({
    required DateTime startDate,
    required DateTime endDate,
    String? searchString,
    required Set<TransactionTag>? tagSet,
  }) {
    requests.add(_Request(startDate, endDate, searchString, tagSet));
    final completer = Completer<List<Transaction>>();
    completers.add(completer);
    return completer.future;
  }

  int get requestCount => requests.length;
}

Transaction txn({
  required int id,
  required double amount,
  required String description,
  required DateTime date,
  String tag = 'food',
}) {
  return Transaction(
    id: id,
    date: date,
    amount: amount,
    description: description,
    isExpense: amount < 0,
    isStarred: false,
    tag: tag,
    paymentMethod: 'Card/UPI',
  );
}

Widget screen(_RecordingLoader loader, {required DateTime now}) {
  return MaterialApp(
    home: Scaffold(
      body: TransactionsScreen(
        transactionLoader: loader.call,
        now: () => now,
      ),
    ),
  );
}

void main() {
  final now = DateTime(2026, 8, 23, 17, 0);

  group('TransactionsScreen', () {
    testWidgets('initial load requests the selected month range', (tester) async {
      final loader = _RecordingLoader();
      await tester.pumpWidget(screen(loader, now: now));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(loader.requestCount, 1);
      expect(loader.requests.first.startDate, DateTime(2026, 8, 1));
      expect(loader.requests.first.endDate, DateTime(2026, 9, 1));
      expect(loader.requests.first.searchString, isNull);
      expect(loader.requests.first.tagSet, isNull);

      loader.completers.first.complete([]);
      await tester.pumpAndSettle();
      expect(find.text('No transactions for this month.'), findsOneWidget);
    });

    testWidgets('renders date-grouped transactions', (tester) async {
      await setSurface(tester, _kSurface);
      final loader = _RecordingLoader();
      await tester.pumpWidget(screen(loader, now: now));

      loader.completers.first.complete([
        txn(id: 1, amount: -860, description: 'Lunch', date: DateTime(2026, 8, 23, 13, 24)),
        txn(id: 2, amount: 25500, description: 'Salary', date: DateTime(2026, 8, 12, 10, 2), tag: 'salary'),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('12 AUGUST'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('changing month reloads with the new range', (tester) async {
      await setSurface(tester, _kSurface);
      final loader = _RecordingLoader();
      await tester.pumpWidget(screen(loader, now: now));
      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      // July is before the current month, so its chip is enabled.
      await tester.tap(find.text('Jul 2026'));
      await tester.pump();

      expect(loader.requestCount, 2);
      expect(loader.requests[1].startDate, DateTime(2026, 7, 1));
      expect(loader.requests[1].endDate, DateTime(2026, 8, 1));

      loader.completers[1].complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('typing a search term reloads with the search string', (tester) async {
      await setSurface(tester, _kSurface);
      final loader = _RecordingLoader();
      await tester.pumpWidget(screen(loader, now: now));
      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'lunch');
      await tester.pump();

      expect(loader.requestCount, 2);
      expect(loader.requests[1].searchString, 'lunch');

      loader.completers[1].complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('toggling a sort chip re-sorts in memory without reloading', (tester) async {
      await setSurface(tester, _kSurface);
      final loader = _RecordingLoader();
      await tester.pumpWidget(screen(loader, now: now));
      loader.completers.first.complete([
        txn(id: 1, amount: -100, description: 'A', date: DateTime(2026, 8, 20)),
        txn(id: 2, amount: -900, description: 'B', date: DateTime(2026, 8, 21)),
      ]);
      await tester.pumpAndSettle();

      expect(loader.requestCount, 1);

      // Switch to amount sort — no new query, just an in-memory re-sort.
      await tester.tap(find.text('Amount'));
      await tester.pumpAndSettle();

      expect(loader.requestCount, 1);
      // The amount chip now reads "Highest".
      expect(find.text('Highest'), findsOneWidget);
    });

    testWidgets('a stale response cannot overwrite the current month', (tester) async {
      await setSurface(tester, _kSurface);
      final loader = _RecordingLoader();
      await tester.pumpWidget(screen(loader, now: now)); // token 1 (August)

      // Select July before August resolves → token 2.
      await tester.tap(find.text('Jul 2026'));
      await tester.pump();
      expect(loader.requestCount, 2);

      // July (latest) resolves first with its data.
      loader.completers[1].complete([
        txn(id: 10, amount: -50, description: 'July item', date: DateTime(2026, 7, 5)),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('July item'), findsOneWidget);

      // The stale August response resolves last and must be ignored.
      loader.completers[0].complete([
        txn(id: 20, amount: -50, description: 'August item', date: DateTime(2026, 8, 5)),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('July item'), findsOneWidget);
      expect(find.text('August item'), findsNothing);
    });

    testWidgets('applying a tag filter reloads with the tag set', (tester) async {
      await setSurface(tester, _kSurface);
      final loader = _RecordingLoader();
      await tester.pumpWidget(screen(loader, now: now));
      loader.completers.first.complete([]);
      await tester.pumpAndSettle();

      // Open the filter sheet from the Filter chip.
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      // Toggle a tag and apply.
      await tester.tap(find.widgetWithText(FilterChip, 'Food & Drink'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // dismiss the sheet

      expect(loader.requestCount, 2);
      expect(loader.requests[1].tagSet, isNotNull);
      expect(loader.requests[1].tagSet, contains(TransactionTag.getTagById('food')));

      loader.completers[1].complete([]);
      await tester.pumpAndSettle();
    });
  });
}
