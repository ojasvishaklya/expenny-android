import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/service/DateService.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// How the displayed month's spending compares with the month before it.
///
/// Every row states its direction in words, so the trend icon and status colour
/// are reinforcement rather than the only signal.
class MonthComparisonSection extends StatelessWidget {
  const MonthComparisonSection({
    super.key,
    required this.comparison,
    required this.displayedMonth,
  });

  final MonthComparison comparison;

  /// The month the comparison's current side belongs to. Its predecessor names
  /// the heading, so the heading always matches the visible data.
  final DateTime displayedMonth;

  /// Heading naming the month being compared against.
  static String headingFor(DateTime displayedMonth) {
    final previous = DateTime(displayedMonth.year, displayedMonth.month - 1, 1);
    return 'Compared with ${DateService.monthYear(previous)}';
  }

  /// Sentence describing the overall change in total spending.
  static String headline(MonthComparison comparison) {
    final amount = formatRupees(comparison.difference);

    switch (comparison.direction) {
      case ChangeDirection.higher:
        return 'You spent $amount more overall';
      case ChangeDirection.lower:
        return 'You spent $amount less overall';
      case ChangeDirection.noChange:
        return 'You spent the same as last month';
      case ChangeDirection.newSpending:
        return 'Spending began this month';
      case ChangeDirection.disappeared:
        return 'Spending stopped this month';
    }
  }

  /// Short direction word shown beside each change value.
  static String directionLabel(ChangeDirection direction) {
    switch (direction) {
      case ChangeDirection.higher:
        return 'Higher';
      case ChangeDirection.lower:
        return 'Lower';
      case ChangeDirection.noChange:
        return 'No change';
      case ChangeDirection.newSpending:
        return 'New';
      case ChangeDirection.disappeared:
        return 'Stopped';
    }
  }

  /// Sentence describing one category's movement.
  static String categorySentence(CategoryChange change) {
    switch (change.direction) {
      case ChangeDirection.higher:
        return '${change.label} spending increased';
      case ChangeDirection.lower:
        return '${change.label} spending decreased';
      case ChangeDirection.noChange:
        return '${change.label} spending was unchanged';
      case ChangeDirection.newSpending:
        return 'New ${change.label} spending';
      case ChangeDirection.disappeared:
        return '${change.label} spending stopped';
    }
  }

  /// Whether a direction represents more spending, which reads as adverse.
  static bool isIncrease(ChangeDirection direction) =>
      direction == ChangeDirection.higher ||
      direction == ChangeDirection.newSpending;

  static Color _statusColor(ChangeDirection direction, ColorScheme colors) {
    switch (direction) {
      case ChangeDirection.higher:
      case ChangeDirection.newSpending:
        return colors.error;
      case ChangeDirection.lower:
      case ChangeDirection.disappeared:
        return colors.tertiary;
      case ChangeDirection.noChange:
        return colors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final heading = headingFor(displayedMonth);

    if (!comparison.isAvailable) {
      return AnalyticsSection(
        title: heading,
        child: const AnalyticsEmptyHint(
          message: 'No transactions last month, so there is nothing to '
              'compare against.',
        ),
      );
    }

    final changes = comparison.categoryChanges;

    return AnalyticsSection(
      title: heading,
      trailing: changes.isEmpty
          ? null
          : Text(
              changes.length == 1
                  ? '1 notable change'
                  : '${changes.length} notable changes',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InsightRow(
            icon: isIncrease(comparison.direction)
                ? Icons.trending_up
                : Icons.trending_down,
            iconColor: _statusColor(
              comparison.direction,
              Theme.of(context).colorScheme,
            ),
            sentence: headline(comparison),
            detail: comparison.direction == ChangeDirection.noChange
                ? null
                : '${formatRupees(comparison.difference)} vs last month',
            changeValue: comparison.percentChange == null
                ? formatRupees(comparison.difference)
                : formatPercent(comparison.percentChange!.abs()),
            directionText: directionLabel(comparison.direction),
            statusColor: _statusColor(
              comparison.direction,
              Theme.of(context).colorScheme,
            ),
          ),
          for (final change in changes)
            _InsightRow(
              icon: TransactionTag.getTagById(change.tagId).icon,
              iconColor: TransactionTag.getTagById(change.tagId).color,
              sentence: categorySentence(change),
              detail: '${formatRupees(change.difference)} vs last month',
              changeValue: change.percentChange == null
                  ? formatRupees(change.difference)
                  : formatPercent(change.percentChange!.abs()),
              directionText: directionLabel(change.direction),
              statusColor: _statusColor(
                change.direction,
                Theme.of(context).colorScheme,
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.iconColor,
    required this.sentence,
    required this.detail,
    required this.changeValue,
    required this.directionText,
    required this.statusColor,
  });

  final IconData icon;
  final Color iconColor;
  final String sentence;
  final String? detail;
  final String changeValue;
  final String directionText;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final narrative = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sentence,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 2),
          Text(
            detail!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    // Direction is always written out, so the value block can be dropped below
    // the narrative on narrow screens without losing meaning.
    final valueBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          changeValue,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          directionText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack = constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(1) >
                  kAnalyticsStackTextScale;

          final leading = Padding(
            padding: const EdgeInsets.only(right: 10, top: 2),
            child: Icon(icon, size: 18, color: iconColor),
          );

          if (stack) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leading,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      narrative,
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              changeValue,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              directionText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              Expanded(child: narrative),
              const SizedBox(width: 10),
              valueBlock,
            ],
          );
        },
      ),
    );
  }
}
