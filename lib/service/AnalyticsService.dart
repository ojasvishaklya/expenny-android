import 'package:expenny/models/Transaction.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/models/analytics/TrendSeries.dart';

/// Pure aggregation functions behind the analytics screen.
///
/// Every method is a pure function of its inputs — no storage access, no
/// reactive state, no widget or chart types — so each one is directly
/// unit-testable.
///
/// ### Sign convention
///
/// Transaction amounts are stored signed: expenses are negative, income is
/// positive (see `Transaction.setAmount`). These functions classify by sign,
/// matching `TransactionController.income` / `.expense`, and always return
/// expense as a non-negative magnitude.
class AnalyticsService {
  /// Number of named category groups shown before the rest are folded into
  /// a single "Other" bucket.
  static const int maxNamedCategories = 5;

  /// Number of months shown in the trend chart, including the selected month.
  static const int trendMonthCount = 6;

  /// A category must move by more than this percentage to be reported as a
  /// notable month-over-month change.
  static const double notableChangeThresholdPercent = 20.0;

  const AnalyticsService._();

  static bool _isExpense(Transaction transaction) => transaction.amount <= 0;

  /// Totals income, expense, net, and savings rate for [transactions].
  ///
  /// Returns zeros for an empty list.
  static MonthlySummary summarize(List<Transaction> transactions) {
    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (_isExpense(transaction)) {
        expense += transaction.amount.abs();
      } else {
        income += transaction.amount;
      }
    }

    final net = income - expense;
    final savingsRate =
        income == 0 ? 0.0 : ((net / income) * 100).clamp(0.0, 100.0).toDouble();

    return MonthlySummary(
      income: income,
      expense: expense,
      net: net,
      savingsRate: savingsRate,
    );
  }

  /// Groups expense by category, highest spend first, keeping at most
  /// [maxNamedCategories] named groups and folding the remainder into "Other".
  ///
  /// Income is ignored. Group amounts always sum exactly to the returned
  /// total expense.
  static CategoryBreakdown categoryBreakdown(List<Transaction> transactions) {
    final totals = _expenseByTag(transactions);
    if (totals.isEmpty) return const CategoryBreakdown.empty();

    final total = totals.values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return const CategoryBreakdown.empty();

    final ranked = totals.entries
        .map((entry) => _RankedTag(
              tagId: entry.key,
              label: TransactionTag.getTagById(entry.key).name,
              amount: entry.value,
            ))
        .toList()
      ..sort(_byAmountThenLabel);

    final groups = <CategoryGroup>[];

    if (ranked.length <= maxNamedCategories) {
      for (final tag in ranked) {
        groups.add(CategoryGroup(
          tagIds: {tag.tagId},
          label: tag.label,
          amount: tag.amount,
          percent: _percentOf(tag.amount, total),
        ));
      }
    } else {
      for (final tag in ranked.take(maxNamedCategories)) {
        groups.add(CategoryGroup(
          tagIds: {tag.tagId},
          label: tag.label,
          amount: tag.amount,
          percent: _percentOf(tag.amount, total),
        ));
      }

      final rest = ranked.skip(maxNamedCategories);
      final otherAmount = rest.fold<double>(0, (sum, tag) => sum + tag.amount);
      groups.add(CategoryGroup(
        tagIds: rest.map((tag) => tag.tagId).toSet(),
        label: 'Other',
        amount: otherAmount,
        percent: _percentOf(otherAmount, total),
        isOther: true,
      ));
    }

    return CategoryBreakdown(groups: groups, totalExpense: total);
  }

  /// Builds exactly [trendMonthCount] chronological monthly buckets ending at
  /// [year]-[month].
  ///
  /// [transactions] may span any range; only rows falling inside the six-month
  /// window contribute. Months with no data are still present with zeros, so
  /// the chart never has gaps.
  static TrendSeries trend({
    required int year,
    required int month,
    required List<Transaction> transactions,
  }) {
    // Oldest first: the selected month is the last bucket.
    final months = List.generate(trendMonthCount, (index) {
      final offset = trendMonthCount - 1 - index;
      final date = DateTime(year, month - offset, 1);
      return _YearMonth(date.year, date.month);
    });

    final incomeByMonth = <_YearMonth, double>{};
    final expenseByMonth = <_YearMonth, double>{};

    for (final transaction in transactions) {
      final key = _YearMonth(transaction.date.year, transaction.date.month);
      if (_isExpense(transaction)) {
        expenseByMonth[key] =
            (expenseByMonth[key] ?? 0) + transaction.amount.abs();
      } else {
        incomeByMonth[key] = (incomeByMonth[key] ?? 0) + transaction.amount;
      }
    }

    final selected = _YearMonth(year, month);
    final points = months
        .map((key) => TrendPoint(
              year: key.year,
              month: key.month,
              income: incomeByMonth[key] ?? 0,
              expense: expenseByMonth[key] ?? 0,
              isSelected: key == selected,
            ))
        .toList();

    return TrendSeries(points: points);
  }

  /// Compares expense in [current] against [previous].
  ///
  /// Returns an unavailable comparison when [previous] holds no transactions
  /// at all — there is no baseline to compare against. At most [categoryLimit]
  /// notable category movements are reported.
  static MonthComparison compare({
    required List<Transaction> current,
    required List<Transaction> previous,
    int categoryLimit = 3,
  }) {
    if (previous.isEmpty) return const MonthComparison.unavailable();

    final currentExpense = summarize(current).expense;
    final previousExpense = summarize(previous).expense;

    return MonthComparison(
      isAvailable: true,
      currentExpense: currentExpense,
      previousExpense: previousExpense,
      difference: (currentExpense - previousExpense).abs(),
      percentChange: _signedPercentChange(currentExpense, previousExpense),
      direction: _directionOf(currentExpense, previousExpense),
      categoryChanges: _categoryChanges(
        current: current,
        previous: previous,
        limit: categoryLimit,
      ),
    );
  }

  /// Notable per-category movements, most significant first.
  ///
  /// Percentage-based changes (including categories that stopped entirely)
  /// come first, ordered by descending absolute percentage change. Brand-new
  /// spending has no percentage baseline so it follows, ordered by descending
  /// monetary difference. Ties break on category name.
  static List<CategoryChange> _categoryChanges({
    required List<Transaction> current,
    required List<Transaction> previous,
    required int limit,
  }) {
    if (limit <= 0) return const [];

    final currentTotals = _expenseByTag(current);
    final previousTotals = _expenseByTag(previous);
    final tagIds = {...currentTotals.keys, ...previousTotals.keys};

    final percentBased = <CategoryChange>[];
    final newSpending = <CategoryChange>[];

    for (final tagId in tagIds) {
      final currentAmount = currentTotals[tagId] ?? 0;
      final previousAmount = previousTotals[tagId] ?? 0;
      if (currentAmount == 0 && previousAmount == 0) continue;

      final change = CategoryChange(
        tagId: tagId,
        label: TransactionTag.getTagById(tagId).name,
        currentAmount: currentAmount,
        previousAmount: previousAmount,
        difference: (currentAmount - previousAmount).abs(),
        percentChange: _signedPercentChange(currentAmount, previousAmount),
        direction: _directionOf(currentAmount, previousAmount),
      );

      if (previousAmount == 0) {
        newSpending.add(change);
      } else if (change.percentChange!.abs() > notableChangeThresholdPercent) {
        percentBased.add(change);
      }
    }

    percentBased.sort((a, b) {
      final byPercent =
          b.percentChange!.abs().compareTo(a.percentChange!.abs());
      if (byPercent != 0) return byPercent;
      return a.label.compareTo(b.label);
    });

    newSpending.sort((a, b) {
      final byDifference = b.difference.compareTo(a.difference);
      if (byDifference != 0) return byDifference;
      return a.label.compareTo(b.label);
    });

    return [...percentBased, ...newSpending].take(limit).toList();
  }

  /// Sums expense magnitude per tag id, skipping income and zero totals.
  static Map<String, double> _expenseByTag(List<Transaction> transactions) {
    final totals = <String, double>{};
    for (final transaction in transactions) {
      if (!_isExpense(transaction)) continue;
      final amount = transaction.amount.abs();
      if (amount == 0) continue;
      totals[transaction.tag] = (totals[transaction.tag] ?? 0) + amount;
    }
    return totals;
  }

  /// Signed percentage change from [previous] to [current], or null when
  /// [previous] is zero and a percentage is therefore undefined.
  static double? _signedPercentChange(double current, double previous) {
    if (previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  static ChangeDirection _directionOf(double current, double previous) {
    if (previous == 0 && current > 0) return ChangeDirection.newSpending;
    if (current == 0 && previous > 0) return ChangeDirection.disappeared;
    if (current > previous) return ChangeDirection.higher;
    if (current < previous) return ChangeDirection.lower;
    return ChangeDirection.noChange;
  }

  static double _percentOf(double amount, double total) =>
      total == 0 ? 0 : (amount / total) * 100;

  static int _byAmountThenLabel(_RankedTag a, _RankedTag b) {
    final byAmount = b.amount.compareTo(a.amount);
    if (byAmount != 0) return byAmount;
    return a.label.compareTo(b.label);
  }
}

/// A tag's total expense, used while ranking the category breakdown.
class _RankedTag {
  final String tagId;
  final String label;
  final double amount;

  const _RankedTag({
    required this.tagId,
    required this.label,
    required this.amount,
  });
}

/// Value-equal (year, month) pair used to bucket transactions by month
/// without relying on positional index arithmetic.
class _YearMonth {
  final int year;
  final int month;

  const _YearMonth(this.year, this.month);

  @override
  bool operator ==(Object other) =>
      other is _YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => year * 100 + month;
}
