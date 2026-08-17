import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// How the selected month's spending compares with the month before it: the
/// overall movement, then the categories that drove it.
class MonthComparisonSection extends StatelessWidget {
  final MonthComparison comparison;

  const MonthComparisonSection({Key? key, required this.comparison})
      : super(key: key);

  /// Sentence describing the overall change in total spending.
  static String headline(MonthComparison comparison) {
    final amount = formatRupees(comparison.difference);

    switch (comparison.direction) {
      case ChangeDirection.higher:
        return 'You spent $amount more than last month';
      case ChangeDirection.lower:
        return 'You spent $amount less than last month';
      case ChangeDirection.noChange:
        return 'You spent the same as last month';
      case ChangeDirection.newSpending:
        return 'You spent $amount this month, with nothing to compare';
      case ChangeDirection.disappeared:
        return 'You spent nothing this month, down $amount';
    }
  }

  /// Short direction word used on each category row.
  static String directionLabel(ChangeDirection direction) {
    switch (direction) {
      case ChangeDirection.higher:
        return 'more';
      case ChangeDirection.lower:
        return 'less';
      case ChangeDirection.noChange:
        return 'no change';
      case ChangeDirection.newSpending:
        return 'new';
      case ChangeDirection.disappeared:
        return 'stopped';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!comparison.isAvailable) {
      return const AnalyticsSection(
        title: 'Vs last month',
        child: AnalyticsEmptyHint(
          message: 'No transactions last month, so there is nothing to '
              'compare against.',
        ),
      );
    }

    final isUp = comparison.direction == ChangeDirection.higher ||
        comparison.direction == ChangeDirection.newSpending;

    return AnalyticsSection(
      title: 'Vs last month',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: isUp ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headline(comparison),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (comparison.percentChange != null) ...[
                const SizedBox(width: 8),
                Text(
                  formatPercent(comparison.percentChange!.abs()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUp ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ],
          ),
          if (comparison.categoryChanges.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Biggest movers',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...comparison.categoryChanges.map(
              (change) => _CategoryChangeRow(change: change),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChangeRow extends StatelessWidget {
  final CategoryChange change;

  const _CategoryChangeRow({required this.change});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = TransactionTag.getTagById(change.tagId);

    final isUp = change.direction == ChangeDirection.higher ||
        change.direction == ChangeDirection.newSpending;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(tag.icon, size: 16, color: tag.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              change.label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupees(change.difference),
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text(
            MonthComparisonSection.directionLabel(change.direction),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isUp ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
