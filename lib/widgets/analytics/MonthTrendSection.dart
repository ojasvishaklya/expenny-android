import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expenny/models/analytics/TrendSeries.dart';
import 'package:expenny/service/DateService.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// Six months of income against expense, oldest to newest, so a single
/// month's figures can be read in context.
///
/// The selected month is emphasised by opacity and marked with a bullet in its
/// axis label, so it is identifiable without relying on colour alone.
class MonthTrendSection extends StatelessWidget {
  final TrendSeries series;

  const MonthTrendSection({Key? key, required this.series}) : super(key: key);

  static const double _chartHeight = 180;

  /// Three-letter month abbreviation for the given 1-indexed month.
  static String monthAbbreviation(int month) =>
      DateService.monthNames[month].substring(0, 3);

  /// Heading suffix naming the years the range covers, e.g. "2025 - 2026".
  static String rangeLabel(TrendSeries series) {
    if (series.points.isEmpty) return '';
    final first = series.points.first;
    final last = series.points.last;
    return series.spansTwoYears
        ? '${first.year} - ${last.year}'
        : '${last.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incomeColor = Colors.green;
    final expenseColor = Colors.red;

    if (series.isEmpty) {
      final first = series.points.first;
      final last = series.points.last;
      return AnalyticsSection(
        title: 'Last 6 months',
        child: AnalyticsEmptyHint(
          message: 'No transactions between '
              '${monthAbbreviation(first.month)} ${first.year} and '
              '${monthAbbreviation(last.month)} ${last.year}.',
        ),
      );
    }

    return AnalyticsSection(
      title: 'Last 6 months',
      trailing: Text(
        rangeLabel(series),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _LegendDot(color: incomeColor, label: 'Income'),
              const SizedBox(width: 16),
              _LegendDot(color: expenseColor, label: 'Expense'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: _chartHeight,
            child: BarChart(
              BarChartData(
                minY: 0,
                // Headroom above the tallest bar so it doesn't touch the top.
                maxY: series.maxValue * 1.15,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= series.points.length) {
                          return const SizedBox.shrink();
                        }
                        final point = series.points[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            point.isSelected
                                ? '• ${monthAbbreviation(point.month)}'
                                : monthAbbreviation(point.month),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: point.isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: point.isSelected
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < series.points.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: series.points[i].income,
                          width: 7,
                          borderRadius: BorderRadius.circular(2),
                          // Unselected months are dimmed so the selected month
                          // reads as the focus of the chart.
                          color: series.points[i].isSelected
                              ? incomeColor
                              : incomeColor.withValues(alpha: 0.4),
                        ),
                        BarChartRodData(
                          toY: series.points[i].expense,
                          width: 7,
                          borderRadius: BorderRadius.circular(2),
                          color: series.points[i].isSelected
                              ? expenseColor
                              : expenseColor.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Text equivalent of the chart: the same six months and figures are
          // available without interpreting bar heights or colours.
          Semantics(
            label: series.points
                .map((point) =>
                    '${monthAbbreviation(point.month)} ${point.year}: '
                    'income ${formatRupees(point.income)}, '
                    'expense ${formatRupees(point.expense)}')
                .join('. '),
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
