/// One row of the "spending by category" breakdown.
///
/// A group is either a single tag or the synthetic "Other" bucket that folds
/// together every category outside the top five.
class CategoryGroup {
  /// Tag ids contained in this group. A named group holds exactly one id;
  /// the "Other" group holds every remaining id.
  final Set<String> tagIds;

  /// Display label — the tag name, or "Other" for the folded group.
  final String label;

  /// Total expense magnitude for this group (non-negative).
  final double amount;

  /// Share of the month's total expense, 0...100. Computed from unrounded
  /// amounts; the UI rounds for display.
  final double percent;

  final bool isOther;

  const CategoryGroup({
    required this.tagIds,
    required this.label,
    required this.amount,
    required this.percent,
    this.isOther = false,
  });

  /// The single tag id for a named group, or null for the "Other" group.
  String? get singleTagId =>
      !isOther && tagIds.length == 1 ? tagIds.first : null;

  @override
  String toString() =>
      'CategoryGroup($label, amount: $amount, percent: $percent, '
      'isOther: $isOther)';
}

/// Expense grouped by category for one month, ordered highest spend first.
///
/// At most five named groups plus one optional "Other" group. Group amounts
/// always sum exactly to [totalExpense].
class CategoryBreakdown {
  final List<CategoryGroup> groups;
  final double totalExpense;

  const CategoryBreakdown({
    required this.groups,
    required this.totalExpense,
  });

  const CategoryBreakdown.empty()
      : groups = const [],
        totalExpense = 0;

  bool get isEmpty => groups.isEmpty;

  @override
  String toString() =>
      'CategoryBreakdown(total: $totalExpense, groups: $groups)';
}
