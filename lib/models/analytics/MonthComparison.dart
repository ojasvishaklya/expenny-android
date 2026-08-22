/// Direction of a month-over-month spending change.
enum ChangeDirection {
  /// Spent more than the previous month.
  higher,

  /// Spent less than the previous month.
  lower,

  /// Identical spend in both months.
  noChange,

  /// Spending appeared this month with no previous-month baseline, so a
  /// percentage change is undefined.
  newSpending,

  /// Spending existed last month and stopped entirely this month.
  disappeared,
}

/// A single category's movement between two months.
class CategoryChange {
  final String tagId;
  final String label;

  /// Expense magnitude in the selected month.
  final double currentAmount;

  /// Expense magnitude in the previous month.
  final double previousAmount;

  /// Absolute monetary difference between the two months (non-negative).
  final double difference;

  /// Signed percentage change, or null when the previous month was zero
  /// (a [ChangeDirection.newSpending] case where a percentage is undefined).
  final double? percentChange;

  final ChangeDirection direction;

  const CategoryChange({
    required this.tagId,
    required this.label,
    required this.currentAmount,
    required this.previousAmount,
    required this.difference,
    required this.percentChange,
    required this.direction,
  });

  @override
  String toString() =>
      'CategoryChange($label, diff: $difference, pct: $percentChange, '
      'direction: $direction)';
}

/// Comparison of the selected month's spending against the previous month.
///
/// When the previous month holds no transactions at all there is nothing to
/// compare against and [isAvailable] is false.
class MonthComparison {
  final bool isAvailable;

  /// Total expense magnitude for the selected month.
  final double currentExpense;

  /// Total expense magnitude for the previous month.
  final double previousExpense;

  /// Absolute monetary difference in total expense (non-negative).
  final double difference;

  /// Signed percentage change in total expense, or null when the previous
  /// month's expense was zero.
  final double? percentChange;

  final ChangeDirection direction;

  /// Notable category movements, most significant first.
  final List<CategoryChange> categoryChanges;

  const MonthComparison({
    required this.isAvailable,
    required this.currentExpense,
    required this.previousExpense,
    required this.difference,
    required this.percentChange,
    required this.direction,
    required this.categoryChanges,
  });

  const MonthComparison.unavailable()
      : isAvailable = false,
        currentExpense = 0,
        previousExpense = 0,
        difference = 0,
        percentChange = null,
        direction = ChangeDirection.noChange,
        categoryChanges = const [];

  @override
  String toString() =>
      'MonthComparison(available: $isAvailable, diff: $difference, '
      'pct: $percentChange, direction: $direction, '
      'categories: $categoryChanges)';
}
