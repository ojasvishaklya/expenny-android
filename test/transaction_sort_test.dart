import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/service/TransactionSortService.dart';

Transaction txn({
  int? id,
  required DateTime date,
  required double amount,
}) {
  return Transaction(
    id: id,
    date: date,
    amount: amount,
    description: 'txn',
    isExpense: amount < 0,
    isStarred: false,
    tag: 'miscellaneous',
    paymentMethod: 'Cash',
  );
}

void main() {
  group('sortTransactions', () {
    test('empty list returns empty for every mode', () {
      for (final sort in TransactionSort.values) {
        expect(sortTransactions(const [], sort), isEmpty);
      }
    });

    test('does not mutate the input list', () {
      final a = txn(id: 1, date: DateTime(2026, 8, 1), amount: -100);
      final b = txn(id: 2, date: DateTime(2026, 8, 2), amount: -200);
      final input = [a, b];

      sortTransactions(input, TransactionSort.oldestFirst);

      expect(input, [a, b]); // original order preserved
    });

    test('newestFirst orders by descending date', () {
      final older = txn(id: 1, date: DateTime(2026, 8, 1), amount: -10);
      final newer = txn(id: 2, date: DateTime(2026, 8, 20), amount: -10);

      final result = sortTransactions([older, newer], TransactionSort.newestFirst);

      expect(result.map((t) => t.id), [2, 1]);
    });

    test('oldestFirst orders by ascending date', () {
      final older = txn(id: 1, date: DateTime(2026, 8, 1), amount: -10);
      final newer = txn(id: 2, date: DateTime(2026, 8, 20), amount: -10);

      final result = sortTransactions([newer, older], TransactionSort.oldestFirst);

      expect(result.map((t) => t.id), [1, 2]);
    });

    test('highestAmount ranks the largest-magnitude transactions first', () {
      final income = txn(id: 1, date: DateTime(2026, 8, 5), amount: 25500);
      final smallExpense = txn(id: 2, date: DateTime(2026, 8, 5), amount: -500);
      final bigExpense = txn(id: 3, date: DateTime(2026, 8, 5), amount: -1640);

      final result = sortTransactions(
        [smallExpense, income, bigExpense],
        TransactionSort.highestAmount,
      );

      // |25500| > |1640| > |500| — sign is ignored.
      expect(result.map((t) => t.id), [1, 3, 2]);
    });

    test('lowestAmount ranks the smallest-magnitude transactions first', () {
      final income = txn(id: 1, date: DateTime(2026, 8, 5), amount: 25500);
      final smallExpense = txn(id: 2, date: DateTime(2026, 8, 5), amount: -500);
      final bigExpense = txn(id: 3, date: DateTime(2026, 8, 5), amount: -1640);

      final result = sortTransactions(
        [income, bigExpense, smallExpense],
        TransactionSort.lowestAmount,
      );

      // |500| < |1640| < |25500| — sign is ignored.
      expect(result.map((t) => t.id), [2, 3, 1]);
    });

    test('a large expense outranks a small one under highestAmount', () {
      final small = txn(id: 1, date: DateTime(2026, 8, 5), amount: -100);
      final large = txn(id: 2, date: DateTime(2026, 8, 5), amount: -5000);

      final result = sortTransactions([small, large], TransactionSort.highestAmount);

      expect(result.map((t) => t.id), [2, 1]);
    });

    test('amount ties fall back to newest date first', () {
      final older = txn(id: 1, date: DateTime(2026, 8, 1), amount: -100);
      final newer = txn(id: 2, date: DateTime(2026, 8, 10), amount: -100);

      final highest = sortTransactions([older, newer], TransactionSort.highestAmount);
      expect(highest.map((t) => t.id), [2, 1]);

      final lowest = sortTransactions([older, newer], TransactionSort.lowestAmount);
      expect(lowest.map((t) => t.id), [2, 1]);
    });

    test('date ties fall back to highest signed amount first', () {
      final low = txn(id: 1, date: DateTime(2026, 8, 5), amount: -900);
      final high = txn(id: 2, date: DateTime(2026, 8, 5), amount: 300);

      final newest = sortTransactions([low, high], TransactionSort.newestFirst);
      expect(newest.map((t) => t.id), [2, 1]);
    });

    test('labels match the mockup sheet chips', () {
      expect(TransactionSort.newestFirst.label, 'Newest first');
      expect(TransactionSort.oldestFirst.label, 'Oldest first');
      expect(TransactionSort.highestAmount.label, 'Highest amount');
      expect(TransactionSort.lowestAmount.label, 'Lowest amount');
    });
  });
}
