import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// Where the month's money went: the biggest spending categories first, each
/// with its amount and share of total expense.
///
/// Each row shows the amount and percentage as text, so the proportional bar
/// is a visual aid rather than the only way to read the data.
class CategoryBreakdownSection extends StatelessWidget {
  final CategoryBreakdown breakdown;

  const CategoryBreakdownSection({Key? key, required this.breakdown})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (breakdown.isEmpty) {
      return const AnalyticsSection(
        title: 'Spending by category',
        child: AnalyticsEmptyHint(
          message: 'No spending recorded this month.',
        ),
      );
    }

    // Bars are scaled against the largest group so the leading category fills
    // the row; scaling against 100% would leave every bar short and hard to
    // compare when spending is spread across many categories.
    final largest = breakdown.groups.first.amount;

    return AnalyticsSection(
      title: 'Spending by category',
      trailing: Text(
        formatRupees(breakdown.totalExpense),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      child: Column(
        children: breakdown.groups
            .map((group) => _CategoryRow(group: group, largestAmount: largest))
            .toList(),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryGroup group;
  final double largestAmount;

  const _CategoryRow({required this.group, required this.largestAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The folded "Other" bucket has no single tag, so it uses a neutral colour
    // and a generic icon instead of a category identity.
    final tag =
        group.isOther ? null : TransactionTag.getTagById(group.tagIds.first);
    final color = tag?.color ?? theme.colorScheme.onSurfaceVariant;
    final icon = tag?.icon ?? Icons.more_horiz;

    final fill = largestAmount <= 0
        ? 0.0
        : (group.amount / largestAmount).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatRupees(group.amount),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                child: Text(
                  formatPercent(group.percent),
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fill,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
