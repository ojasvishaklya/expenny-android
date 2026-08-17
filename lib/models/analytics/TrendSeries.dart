/// Income and expense totals for one month of the trend chart.
class TrendPoint {
  final int year;

  /// 1...12
  final int month;

  /// Non-negative income magnitude for the month.
  final double income;

  /// Non-negative expense magnitude for the month.
  final double expense;

  /// True for the month currently selected on the analytics screen.
  final bool isSelected;

  const TrendPoint({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.isSelected,
  });

  bool get isEmpty => income == 0 && expense == 0;

  @override
  String toString() =>
      'TrendPoint($year-$month, income: $income, expense: $expense, '
      'selected: $isSelected)';
}

/// Exactly six consecutive months ending with the selected month, ordered
/// oldest to newest. Months without transactions are present with zeros so
/// the chart never has gaps.
class TrendSeries {
  final List<TrendPoint> points;

  const TrendSeries({required this.points});

  /// True when no month in the range has any income or expense.
  bool get isEmpty => points.every((point) => point.isEmpty);

  /// Largest single income or expense value across the range, used to scale
  /// the chart. Zero when the range is empty.
  double get maxValue => points.fold<double>(
        0,
        (max, point) =>
            [max, point.income, point.expense].reduce((a, b) => a > b ? a : b),
      );

  /// True when the six months span more than one calendar year.
  bool get spansTwoYears =>
      points.isNotEmpty && points.first.year != points.last.year;

  @override
  String toString() => 'TrendSeries($points)';
}
