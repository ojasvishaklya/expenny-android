/// Whether the month ended with money left over, in deficit, or exactly even.
///
/// Exposed separately from the numeric net so the UI can communicate the
/// outcome in words as well as colour.
enum NetState { positive, negative, zero }

/// Income, expense, and retained income for a single calendar month.
///
/// [income] and [expense] are both non-negative magnitudes. [net] may be
/// negative. Values are unrounded; rounding happens at display time.
class MonthlySummary {
  final double income;
  final double expense;
  final double net;

  /// `((income - expense) / income) * 100`, clamped to 0...100.
  /// Zero when [income] is zero.
  final double savingsRate;

  const MonthlySummary({
    required this.income,
    required this.expense,
    required this.net,
    required this.savingsRate,
  });

  const MonthlySummary.zero()
      : income = 0,
        expense = 0,
        net = 0,
        savingsRate = 0;

  NetState get netState {
    if (net > 0) return NetState.positive;
    if (net < 0) return NetState.negative;
    return NetState.zero;
  }

  /// True when the month has no income and no expense at all.
  bool get isEmpty => income == 0 && expense == 0;

  @override
  String toString() =>
      'MonthlySummary(income: $income, expense: $expense, net: $net, '
      'savingsRate: $savingsRate)';
}
