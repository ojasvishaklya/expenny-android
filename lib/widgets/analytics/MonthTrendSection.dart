import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expenny/models/analytics/TrendSeries.dart';
import 'package:expenny/service/DateService.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:expenny/widgets/analytics/AnalyticsSection.dart';

/// Six months of income against expense, oldest to newest, so a single month's
/// figures can be read in context.
///
/// The displayed month is marked with a bullet and a bold label as well as
/// stronger bars, and every value is repeated in one semantic summary, so the
/// chart never depends on colour or bar height alone.
class MonthTrendSection extends StatelessWidget {
  const MonthTrendSection({super.key, required this.series});

  final TrendSeries series;

  static const double _chartHeight = 215;

  /// Three-letter month abbreviation for a 1-indexed month.
  static String monthAbbreviation(int month) =>
      DateService.monthAbbreviation(month);

  /// Range label covering both bounds with year context, e.g.
  /// `Mar 2026 – Aug 2026` or `Sep 2025 – Feb 2026`.
  static String rangeLabel(TrendSeries series) {
    if (series.points.isEmpty) return '';
    final first = series.points.first;
    final last = series.points.last;
    return '${monthAbbreviation(first.month)} ${first.year} – '
        '${monthAbbreviation(last.month)} ${last.year}';
  }

  /// Compact axis label for a monetary value, e.g. `₹0`, `₹10k`, `₹1.5L`.
  ///
  /// Used only for axis readability; full values remain in the legend rows and
  /// the semantic summary.
  static String compactAxisLabel(double value) {
    if (value <= 0) return '₹0';
    if (value >= 100000) {
      final lakhs = value / 100000;
      final text = lakhs >= 10 || lakhs == lakhs.roundToDouble()
          ? lakhs.round().toString()
          : lakhs.toStringAsFixed(1);
      return '₹${text}L';
    }
    if (value >= 1000) {
      final thousands = value / 1000;
      final text = thousands >= 10 || thousands == thousands.roundToDouble()
          ? thousands.round().toString()
          : thousands.toStringAsFixed(1);
      return '₹${text}k';
    }
    return '₹${value.round()}';
  }

  /// A rounded ceiling at or above the largest value, so gridlines land on
  /// readable numbers.
  static double axisCeiling(double maxValue) {
    if (maxValue <= 0) return 0;
    final magnitude = maxValue < 1000
        ? 100.0
        : maxValue < 10000
            ? 1000.0
            : maxValue < 100000
                ? 10000.0
                : 100000.0;
    return (maxValue / magnitude).ceil() * magnitude;
  }

  /// The complete spoken equivalent of the chart.
  static String semanticSummary(TrendSeries series) {
    final parts = series.points.map((point) {
      final prefix = point.isSelected ? 'Selected month ' : '';
      return '$prefix${monthAbbreviation(point.month)} ${point.year}, '
          'income ${formatRupees(point.income)}, '
          'expense ${formatRupees(point.expense)}';
    });
    return 'Six month trend. ${parts.join('. ')}.';
  }

  /// Income series colour, resolved for the active [brightness].
  ///
  /// Light mode uses the app's canonical income green (matching the
  /// Transactions ledger and the summary hero); dark mode lifts it to a
  /// brighter green so the bars stay legible on the dark surface rather than
  /// sinking into it. The two series are also distinguished by legend shape,
  /// so the colours carry emphasis, not meaning, alone.
  static Color incomeColorFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF81C784) // green 300 — reads clearly on dark
          : const Color(0xFF2E7D32); // canonical income green

  /// Expense series colour, resolved for the active [brightness]. Light mode
  /// uses the canonical expense red; dark mode uses a lighter red that keeps
  /// contrast against the dark surface.
  static Color expenseColorFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFFFF8A80) // light red — legible on dark
          : const Color(0xFFBA1A1A); // canonical expense red

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (series.isEmpty) {
      final first = series.points.first;
      final last = series.points.last;
      return AnalyticsSection(
        title: 'Six-month trend',
        child: AnalyticsEmptyHint(
          message: 'No transactions between '
              '${monthAbbreviation(first.month)} ${first.year} and '
              '${monthAbbreviation(last.month)} ${last.year}.',
        ),
      );
    }

    final incomeColor = incomeColorFor(colors.brightness);
    final expenseColor = expenseColorFor(colors.brightness);
    final ceiling = axisCeiling(series.maxValue);

    return AnalyticsSection(
      title: 'Six-month trend',
      semanticLabel: semanticSummary(series),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _LegendKey(
                  color: incomeColor,
                  label: 'Income',
                  isRounded: true,
                ),
                _LegendKey(
                  color: expenseColor,
                  label: 'Expense',
                  isRounded: false,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: _chartHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Six groups of two rods must fit the available width, so rod
                  // width is derived from constraints rather than fixed.
                  final perGroup = (constraints.maxWidth - 40) / 6;
                  final rodWidth = (perGroup / 3).clamp(5.0, 12.0);

                  return BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: ceiling,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: ceiling / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: colors.outlineVariant,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: ceiling / 4,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                compactAxisLabel(value),
                                textAlign: TextAlign.right,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= series.points.length) {
                                return const SizedBox.shrink();
                              }
                              final point = series.points[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  point.isSelected
                                      ? '• ${monthAbbreviation(point.month)}'
                                      : monthAbbreviation(point.month),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: point.isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: point.isSelected
                                        ? colors.onSurface
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < series.points.length; i++)
                          _barGroup(
                            index: i,
                            point: series.points[i],
                            rodWidth: rodWidth,
                            incomeColor: incomeColor,
                            expenseColor: expenseColor,
                            outline: colors.onSurface,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup({
    required int index,
    required TrendPoint point,
    required double rodWidth,
    required Color incomeColor,
    required Color expenseColor,
    required Color outline,
  }) {
    // Unselected months are dimmed and unoutlined; the selected month keeps
    // full colour, a wider rod, and a border, so it stands out by shape as
    // well as tone.
    final selected = point.isSelected;
    final border = selected
        ? BorderSide(color: outline, width: 1)
        : const BorderSide(width: 0);

    BarChartRodData rod(double value, Color color) => BarChartRodData(
          toY: value,
          width: selected ? rodWidth + 1 : rodWidth,
          borderRadius: BorderRadius.circular(2),
          borderSide: border,
          color: selected ? color : color.withValues(alpha: 0.4),
        );

    return BarChartGroupData(
      x: index,
      barsSpace: 3,
      barRods: [
        rod(point.income, incomeColor),
        rod(point.expense, expenseColor),
      ],
    );
  }
}

/// A legend key using both colour and shape, so the two series remain
/// distinguishable without colour perception.
class _LegendKey extends StatelessWidget {
  const _LegendKey({
    required this.color,
    required this.label,
    required this.isRounded,
  });

  final Color color;
  final String label;
  final bool isRounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: isRounded ? BoxShape.circle : BoxShape.rectangle,
          ),
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
