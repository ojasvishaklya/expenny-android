import 'package:flutter/material.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// Headline figures for the selected month: what came in, what went out,
/// what is left, and how much of the income was retained.
///
/// The net outcome is stated in words as well as colour so the result does
/// not depend on colour perception.
class MonthlySummarySection extends StatelessWidget {
  final MonthlySummary summary;

  const MonthlySummarySection({Key? key, required this.summary})
      : super(key: key);

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

    if (summary.isEmpty) {
      return const AnalyticsSection(
        title: 'Summary',
        child: AnalyticsEmptyHint(
          message: 'No transactions this month. Add one to see your summary.',
        ),
      );
    }

    final netColor = switch (summary.netState) {
      NetState.positive => Colors.green,
      NetState.negative => Colors.red,
      NetState.zero => theme.colorScheme.onSurfaceVariant,
    };

    return AnalyticsSection(
      title: 'Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            formatRupees(summary.net),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: netColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            netStateLabel(summary.netState),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  icon: Icons.arrow_downward,
                  iconColor: Colors.green,
                  label: 'Income',
                  value: formatRupees(summary.income),
                ),
              ),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.arrow_upward,
                  iconColor: Colors.red,
                  label: 'Expense',
                  value: formatRupees(summary.expense),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Savings rate',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                formatPercent(summary.savingsRate),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One labelled figure within the summary row.
class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
