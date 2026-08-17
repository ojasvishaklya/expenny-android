import 'package:flutter/material.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/service/DateService.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// The month's headline figures, grouped into a single prominent container.
///
/// The net outcome is always stated in words as well as colour, and the whole
/// hero is labelled with the month it describes so values can never be read as
/// belonging to a month that is still loading.
class MonthlySummarySection extends StatelessWidget {
  const MonthlySummarySection({
    super.key,
    required this.summary,
    required this.displayedMonth,
  });

  final MonthlySummary summary;

  /// The month these values belong to — not necessarily the selected month.
  final DateTime displayedMonth;

  /// Width below which the income and expense tiles stack instead of sharing a
  /// row, so neither value is squeezed or clipped.
  static const double stackBelowWidth = 360;

  /// Plain-language description of the month's net result.
  static String netStateLabel(NetState state) {
    switch (state) {
      case NetState.positive:
        return 'Saved this month';
      case NetState.negative:
        return 'Overspent this month';
      case NetState.zero:
        return 'Broke even this month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final monthLabel = DateService.monthYear(displayedMonth);

    if (summary.isEmpty) {
      return AnalyticsSection(
        title: 'Summary',
        child: AnalyticsEmptyHint(
          message: 'No transactions in $monthLabel. Add one to see your '
              'summary for this month.',
        ),
      );
    }

    final stateLabel = netStateLabel(summary.netState);

    return AnalyticsSection(
      title: 'Summary',
      outlined: false,
      semanticLabel: '$monthLabel summary. '
          'Net ${formatRupees(summary.net)}, $stateLabel. '
          'Income ${formatRupees(summary.income)}. '
          'Expense ${formatRupees(summary.expense)}. '
          'Savings rate ${formatPercent(summary.savingsRate)}.',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(kAnalyticsPanelPadding),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(kAnalyticsPanelRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$monthLabel net',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              // Only the amount is allowed to shrink, and only as far as its
              // own slot; the page is never scaled down as a whole.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatRupees(summary.net),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onPrimaryContainer.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 18),
              _MoneyTiles(summary: summary),
              const SizedBox(height: 18),
              _SavingsRate(rate: summary.savingsRate),
            ],
          ),
        ),
      ),
    );
  }
}

/// Income and expense figures, side by side when there is room and stacked when
/// there is not.
class _MoneyTiles extends StatelessWidget {
  const _MoneyTiles({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final income = _MoneyTile(
      label: 'Income',
      value: formatRupees(summary.income),
    );
    final expense = _MoneyTile(
      label: 'Expense',
      value: formatRupees(summary.expense),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stack =
            constraints.maxWidth < MonthlySummarySection.stackBelowWidth ||
                MediaQuery.textScalerOf(context).scale(1) >
                    kAnalyticsStackTextScale;

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              income,
              const SizedBox(height: 12),
              expense,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: income),
            const SizedBox(width: 12),
            Expanded(child: expense),
          ],
        );
      },
    );
  }
}

class _MoneyTile extends StatelessWidget {
  const _MoneyTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: onContainer.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 2),
        // Grouped amounts have no break opportunities, so they are scaled down
        // within their own slot rather than allowed to overflow the tile.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: onContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// The retained share of income, with a decorative track visualising the
/// already-clamped 0–100 value.
class _SavingsRate extends StatelessWidget {
  const _SavingsRate({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Savings rate',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onContainer.withValues(alpha: 0.8),
                ),
              ),
            ),
            Text(
              formatPercent(rate),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (rate / 100).clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: onContainer.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(onContainer),
          ),
        ),
      ],
    );
  }
}
