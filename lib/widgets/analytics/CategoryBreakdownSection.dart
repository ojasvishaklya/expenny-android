import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expenny/models/TransactionTag.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// Where the month's money went, as a donut paired with a complete text legend.
///
/// The chart is decorative: every group's label, amount, and share is also
/// written out in the legend and in one semantic summary, so the breakdown is
/// fully readable without interpreting colour or arc size.
class CategoryBreakdownSection extends StatelessWidget {
  const CategoryBreakdownSection({super.key, required this.breakdown});

  final CategoryBreakdown breakdown;

  /// Width below which the donut and legend stack instead of sharing a row.
  static const double stackBelowWidth = 400;

  static const double _chartSize = 150;
  static const double _ringThickness = 26;

  /// Icon and colour identity for a group. `Other` has no single tag, so it
  /// takes a neutral theme colour rather than a category identity.
  static _GroupIdentity identityFor(CategoryGroup group, ColorScheme colors) {
    if (group.isOther) {
      return _GroupIdentity(Icons.more_horiz, colors.onSurfaceVariant);
    }
    final tag = TransactionTag.getTagById(group.tagIds.first);
    return _GroupIdentity(tag.icon, tag.color);
  }

  /// The complete spoken equivalent of the chart and legend.
  static String semanticSummary(CategoryBreakdown breakdown) {
    final parts = breakdown.groups
        .map((group) => '${group.label}, ${formatRupees(group.amount)}, '
            '${formatPercent(group.percent)}');
    return 'Spending by category. ${parts.join('. ')}.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (breakdown.isEmpty) {
      return const AnalyticsSection(
        title: 'Spending by category',
        child: AnalyticsEmptyHint(
          message: 'No spending recorded this month.',
        ),
      );
    }

    final donut = _Donut(breakdown: breakdown);
    final legend = _Legend(breakdown: breakdown);

    return AnalyticsSection(
      title: 'Spending by category',
      trailing: Text(
        '${formatRupees(breakdown.totalExpense)} total',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
      ),
      semanticLabel: semanticSummary(breakdown),
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < stackBelowWidth) {
              return Column(
                children: [
                  Center(child: donut),
                  const SizedBox(height: 16),
                  legend,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                donut,
                const SizedBox(width: 20),
                Expanded(child: legend),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GroupIdentity {
  const _GroupIdentity(this.icon, this.color);

  final IconData icon;
  final Color color;
}

class _Donut extends StatelessWidget {
  const _Donut({required this.breakdown});

  final CategoryBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: CategoryBreakdownSection._chartSize,
      height: CategoryBreakdownSection._chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              startDegreeOffset: -90,
              // Must be set explicitly: the default is double.infinity, which
              // would collapse the ring.
              centerSpaceRadius: CategoryBreakdownSection._chartSize / 2 -
                  CategoryBreakdownSection._ringThickness,
              pieTouchData: PieTouchData(enabled: false),
              borderData: FlBorderData(show: false),
              sections: [
                for (final group in breakdown.groups)
                  PieChartSectionData(
                    value: group.amount,
                    color: CategoryBreakdownSection.identityFor(group, colors)
                        .color,
                    radius: CategoryBreakdownSection._ringThickness,
                    // Labels live in the legend, not on the arcs.
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatRupees(breakdown.totalExpense),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                breakdown.groups.length == 1
                    ? '1 category'
                    : '${breakdown.groups.length} categories',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.breakdown});

  final CategoryBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in breakdown.groups) _LegendRow(group: group),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.group});

  final CategoryGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final identity = CategoryBreakdownSection.identityFor(group, colors);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(identity.icon, size: 16, color: identity.color),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              group.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Grouped amounts contain no break opportunities, so they cannot
          // soft-wrap. Scaling down inside this slot keeps large figures fully
          // readable without clipping or pushing the row past its bounds.
          Flexible(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                formatRupees(group.amount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                formatPercent(group.percent),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
