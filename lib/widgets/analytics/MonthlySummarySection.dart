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

  /// Concise word describing the month's net result, carried in the summary
  /// semantics so the net direction is always stated in text, never by colour
  /// alone.
  static String netStateLabel(NetState state) {
    switch (state) {
      case NetState.positive:
        return 'Positive';
      case NetState.negative:
        return 'Negative';
      case NetState.zero:
        return 'Even';
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
              // The net amount shrinks to fit the available width rather than
              // clipping. Its direction is stated in the section semantics
              // instead of beside the figure, so it stays accessible without a
              // visible state word.
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
    final colors = theme.colorScheme;
    final onContainer = colors.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // A translucent surface tint over the primaryContainer hero, derived
        // from the theme rather than a fixed white, so it lifts the tile in
        // light mode and stays legible in dark mode.
        color: colors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: onContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 2),
          // Grouped amounts have no break opportunities, so they are scaled
          // down within their own slot rather than allowed to overflow the
          // tile.
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
      ),
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
    final colors = theme.colorScheme;
    final onContainer = colors.onPrimaryContainer;

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
            // Primary fill on a low-alpha primary track, matching the mockup
            // while staying a semantic theme role that keeps contrast over the
            // primaryContainer hero in both light and dark themes.
            backgroundColor: colors.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        ),
      ],
    );
  }
}
