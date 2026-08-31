import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/service/AnalyticsService.dart';

/// Builds an expense transaction. Expenses are stored with a negative amount,
/// mirroring `Transaction.setAmount`.
Transaction expense(
  double amount, {
  String tag = 'food',
  DateTime? date,
}) {
  return Transaction(
    date: date ?? DateTime(2026, 8, 15),
    amount: -amount.abs(),
    description: 'expense',
    isExpense: true,
    isStarred: false,
    tag: tag,
    paymentMethod: 'CASH',
  );
}

/// Builds an income transaction with a positive amount.
Transaction income(
  double amount, {
  String tag = 'salary',
  DateTime? date,
}) {
  return Transaction(
    date: date ?? DateTime(2026, 8, 15),
    amount: amount.abs(),
    description: 'income',
    isExpense: false,
    isStarred: false,
    tag: tag,
    paymentMethod: 'CASH',
  );
}

void main() {
  group('summarize', () {
    test('returns zeros for an empty list', () {
      final summary = AnalyticsService.summarize([]);

      expect(summary.income, 0);
      expect(summary.expense, 0);
      expect(summary.net, 0);
      expect(summary.savingsRate, 0);
      expect(summary.isEmpty, isTrue);
      expect(summary.netState, NetState.zero);
    });

    test('totals income and expense as positive magnitudes', () {
      final summary = AnalyticsService.summarize([
        income(50000),
        expense(12000),
        expense(3000),
      ]);

      expect(summary.income, 50000);
      expect(summary.expense, 15000);
      expect(summary.net, 35000);
    });

    test('net equals income minus expense and can be negative', () {
      final summary = AnalyticsService.summarize([
        income(1000),
        expense(2500),
      ]);

      expect(summary.net, -1500);
      expect(summary.netState, NetState.negative);
    });

    test('savings rate is the retained share of income', () {
      final summary = AnalyticsService.summarize([
        income(1000),
        expense(250),
      ]);

      expect(summary.savingsRate, 75);
    });

    test('savings rate is zero when there is no income', () {
      final summary = AnalyticsService.summarize([expense(500)]);

      expect(summary.savingsRate, 0);
      expect(summary.net, -500);
    });

    test('savings rate clamps to zero when overspending', () {
      final summary = AnalyticsService.summarize([
        income(1000),
        expense(4000),
      ]);

      expect(summary.savingsRate, 0);
    });

    test('net state is positive only when money is left over', () {
      expect(
        AnalyticsService.summarize([income(100)]).netState,
        NetState.positive,
      );
      expect(
        AnalyticsService.summarize([income(100), expense(100)]).netState,
        NetState.zero,
      );
    });
  });

  group('categoryBreakdown', () {
    test('is empty when there are no expenses', () {
      final breakdown = AnalyticsService.categoryBreakdown([income(5000)]);

      expect(breakdown.isEmpty, isTrue);
      expect(breakdown.totalExpense, 0);
    });

    test('ignores income when totalling categories', () {
      final breakdown = AnalyticsService.categoryBreakdown([
        income(9000, tag: 'salary'),
        expense(1000, tag: 'food'),
      ]);

      expect(breakdown.groups.length, 1);
      expect(breakdown.totalExpense, 1000);
      expect(breakdown.groups.first.label, 'Food & Drink');
    });

    test('orders groups by spend, highest first', () {
      final breakdown = AnalyticsService.categoryBreakdown([
        expense(100, tag: 'food'),
        expense(900, tag: 'cab'),
        expense(500, tag: 'grocery'),
      ]);

      expect(
        breakdown.groups.map((group) => group.label).toList(),
        ['Transport', 'Groceries', 'Food & Drink'],
      );
    });

    test('a single category holds the full 100 percent', () {
      final breakdown =
          AnalyticsService.categoryBreakdown([expense(750, tag: 'food')]);

      expect(breakdown.groups.single.percent, 100);
    });

    test('percentages are shares of total expense', () {
      final breakdown = AnalyticsService.categoryBreakdown([
        expense(750, tag: 'food'),
        expense(250, tag: 'cab'),
      ]);

      expect(breakdown.totalExpense, 1000);
      expect(breakdown.groups[0].percent, 75);
      expect(breakdown.groups[1].percent, 25);
    });

    test('keeps every category separate when five or fewer', () {
      final breakdown = AnalyticsService.categoryBreakdown([
        expense(500, tag: 'food'),
        expense(400, tag: 'cab'),
        expense(300, tag: 'grocery'),
        expense(200, tag: 'gym'),
        expense(100, tag: 'apparel'),
      ]);

      expect(breakdown.groups.length, 5);
      expect(breakdown.groups.any((group) => group.isOther), isFalse);
    });

    test('folds everything past the top five into Other', () {
      final breakdown = AnalyticsService.categoryBreakdown([
        expense(600, tag: 'food'),
        expense(500, tag: 'cab'),
        expense(400, tag: 'grocery'),
        expense(300, tag: 'gym'),
        expense(200, tag: 'apparel'),
        expense(70, tag: 'loan'),
        expense(30, tag: 'healthcare'),
      ]);

      expect(breakdown.groups.length, 6);

      final other = breakdown.groups.last;
      expect(other.isOther, isTrue);
      expect(other.label, 'Other');
      expect(other.amount, 100);
      expect(other.tagIds, {'loan', 'healthcare'});
      expect(other.singleTagId, isNull);
    });

    test('group amounts sum exactly to the total expense', () {
      final breakdown = AnalyticsService.categoryBreakdown([
        expense(600, tag: 'food'),
        expense(500, tag: 'cab'),
        expense(400, tag: 'grocery'),
        expense(300, tag: 'gym'),
        expense(200, tag: 'apparel'),
        expense(70, tag: 'loan'),
        expense(30, tag: 'healthcare'),
      ]);

      final summed =
          breakdown.groups.fold<double>(0, (sum, group) => sum + group.amount);

      expect(summed, breakdown.totalExpense);
      expect(summed, 2100);
    });

    test('breaks equal spend ties on category name', () {
      final breakdown = AnalyticsService.categoryBreakdown([
        expense(100, tag: 'grocery'),
        expense(100, tag: 'cab'),
      ]);

      expect(
        breakdown.groups.map((group) => group.label).toList(),
        ['Groceries', 'Transport'],
      );
    });
  });

  group('trend', () {
    test('always returns six chronological months ending at the selection', () {
      final series = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [],
      );

      expect(series.points.length, 6);
      expect(
        series.points.map((point) => '${point.year}-${point.month}').toList(),
        ['2026-3', '2026-4', '2026-5', '2026-6', '2026-7', '2026-8'],
      );
      expect(series.points.last.isSelected, isTrue);
      expect(series.isEmpty, isTrue);
    });

    test('crosses a year boundary without gaps', () {
      final series = AnalyticsService.trend(
        year: 2026,
        month: 2,
        transactions: [],
      );

      expect(
        series.points.map((point) => '${point.year}-${point.month}').toList(),
        ['2025-9', '2025-10', '2025-11', '2025-12', '2026-1', '2026-2'],
      );
    });

    test('buckets transactions into their own calendar month', () {
      final series = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [
          expense(1000, date: DateTime(2026, 8, 3)),
          income(5000, date: DateTime(2026, 8, 20)),
          expense(400, date: DateTime(2026, 6, 11)),
        ],
      );

      final august = series.points.last;
      expect(august.expense, 1000);
      expect(august.income, 5000);

      final june = series.points[3];
      expect(june.year, 2026);
      expect(june.month, 6);
      expect(june.expense, 400);
      expect(june.income, 0);
    });

    test('leaves months without data at zero', () {
      final series = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [expense(100, date: DateTime(2026, 8, 1))],
      );

      final empties = series.points.where((point) => point.isEmpty).length;
      expect(empties, 5);
      expect(series.isEmpty, isFalse);
    });

    test('ignores transactions outside the six month window', () {
      final series = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [expense(9999, date: DateTime(2025, 1, 5))],
      );

      expect(series.isEmpty, isTrue);
    });

    test('marks only the selected month', () {
      final series = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [],
      );

      expect(series.points.where((point) => point.isSelected).length, 1);
    });

    test('reports the largest value across both series', () {
      final series = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [
          expense(1200, date: DateTime(2026, 7, 2)),
          income(3400, date: DateTime(2026, 8, 2)),
        ],
      );

      expect(series.maxValue, 3400);
    });
  });

  group('compare', () {
    test('is unavailable when the previous month has no transactions', () {
      final comparison = AnalyticsService.compare(
        current: [expense(500)],
        previous: [],
      );

      expect(comparison.isAvailable, isFalse);
      expect(comparison.categoryChanges, isEmpty);
    });

    test('reports higher spending with a signed percentage', () {
      final comparison = AnalyticsService.compare(
        current: [expense(1500)],
        previous: [expense(1000)],
      );

      expect(comparison.isAvailable, isTrue);
      expect(comparison.direction, ChangeDirection.higher);
      expect(comparison.difference, 500);
      expect(comparison.percentChange, 50);
    });

    test('reports lower spending with a negative percentage', () {
      final comparison = AnalyticsService.compare(
        current: [expense(750)],
        previous: [expense(1000)],
      );

      expect(comparison.direction, ChangeDirection.lower);
      expect(comparison.difference, 250);
      expect(comparison.percentChange, -25);
    });

    test('reports no change for identical spend', () {
      final comparison = AnalyticsService.compare(
        current: [expense(1000)],
        previous: [expense(1000)],
      );

      expect(comparison.direction, ChangeDirection.noChange);
      expect(comparison.difference, 0);
      expect(comparison.percentChange, 0);
    });

    test('omits the percentage when the previous month had no expense', () {
      final comparison = AnalyticsService.compare(
        current: [expense(800)],
        previous: [income(5000)],
      );

      expect(comparison.isAvailable, isTrue);
      expect(comparison.previousExpense, 0);
      expect(comparison.percentChange, isNull);
      expect(comparison.direction, ChangeDirection.newSpending);
    });

    test('reports spending that stopped entirely', () {
      final comparison = AnalyticsService.compare(
        current: [income(100)],
        previous: [expense(600)],
      );

      expect(comparison.direction, ChangeDirection.disappeared);
      expect(comparison.difference, 600);
      expect(comparison.percentChange, -100);
    });

    test('surfaces categories that moved more than twenty percent', () {
      final comparison = AnalyticsService.compare(
        current: [expense(2000, tag: 'food')],
        previous: [expense(1000, tag: 'food')],
      );

      final change = comparison.categoryChanges.single;
      expect(change.label, 'Food & Drink');
      expect(change.percentChange, 100);
      expect(change.direction, ChangeDirection.higher);
      expect(change.difference, 1000);
    });

    test('ignores categories that moved twenty percent or less', () {
      final comparison = AnalyticsService.compare(
        current: [expense(1200, tag: 'food')],
        previous: [expense(1000, tag: 'food')],
      );

      expect(comparison.categoryChanges, isEmpty);
    });

    test('orders notable changes by size and puts new spending last', () {
      final comparison = AnalyticsService.compare(
        current: [
          expense(1000, tag: 'food'), // +100%
          expense(900, tag: 'cab'), // brand new
          expense(400, tag: 'grocery'), // +300%
        ],
        previous: [
          expense(500, tag: 'food'),
          expense(100, tag: 'grocery'),
        ],
        categoryLimit: 5,
      );

      expect(
        comparison.categoryChanges.map((change) => change.label).toList(),
        ['Groceries', 'Food & Drink', 'Transport'],
      );
      expect(comparison.categoryChanges.last.percentChange, isNull);
      expect(
        comparison.categoryChanges.last.direction,
        ChangeDirection.newSpending,
      );
    });

    test('caps the number of reported category changes', () {
      final comparison = AnalyticsService.compare(
        current: [
          expense(1000, tag: 'food'),
          expense(1000, tag: 'cab'),
          expense(1000, tag: 'grocery'),
          expense(1000, tag: 'gym'),
        ],
        previous: [
          expense(100, tag: 'food'),
          expense(100, tag: 'cab'),
          expense(100, tag: 'grocery'),
          expense(100, tag: 'gym'),
        ],
        categoryLimit: 2,
      );

      expect(comparison.categoryChanges.length, 2);
    });

    test('reports no category changes when the limit is zero', () {
      final comparison = AnalyticsService.compare(
        current: [expense(1000, tag: 'food')],
        previous: [expense(100, tag: 'food')],
        categoryLimit: 0,
      );

      expect(comparison.categoryChanges, isEmpty);
      expect(comparison.isAvailable, isTrue);
    });
  });
}
