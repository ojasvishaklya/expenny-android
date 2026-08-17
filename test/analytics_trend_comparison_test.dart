import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/models/analytics/TrendSeries.dart';
import 'package:expenny/service/AnalyticsService.dart';
import 'package:expenny/widgets/analytics/MonthComparisonSection.dart';
import 'package:expenny/widgets/analytics/MonthTrendSection.dart';

import 'support/dashboard_harness.dart';

final _august = DateTime(2026, 8, 1);

/// Builds a six-month series ending at the given month, with values in the
/// final (selected) month so the series is not treated as empty.
TrendSeries seriesEndingAt(
  int year,
  int month, {
  double income = 1000,
  double expense = 600,
}) {
  final points = <TrendPoint>[];
  for (var offset = 5; offset >= 0; offset--) {
    final date = DateTime(year, month - offset, 1);
    final isSelected = offset == 0;
    points.add(TrendPoint(
      year: date.year,
      month: date.month,
      income: isSelected ? income : 0,
      expense: isSelected ? expense : 0,
      isSelected: isSelected,
    ));
  }
  return TrendSeries(points: points);
}

const _higherComparison = MonthComparison(
  isAvailable: true,
  currentExpense: 1500,
  previousExpense: 1000,
  difference: 500,
  percentChange: 50,
  direction: ChangeDirection.higher,
  categoryChanges: [],
);

void main() {
  group('MonthTrendSection', () {
    testWidgets('labels all six months and marks the selected one',
        (tester) async {
      await tester.pumpWidget(
        wrapSection(MonthTrendSection(series: seriesEndingAt(2026, 8))),
      );

      expect(find.text('Mar'), findsOneWidget);
      expect(find.text('Apr'), findsOneWidget);
      expect(find.text('May'), findsOneWidget);
      expect(find.text('Jun'), findsOneWidget);
      expect(find.text('Jul'), findsOneWidget);
      // A bullet plus bold weight marks the selection without relying on colour.
      expect(find.text('• Aug'), findsOneWidget);
    });

    testWidgets('shows a range label carrying both years', (tester) async {
      await tester.pumpWidget(
        wrapSection(MonthTrendSection(series: seriesEndingAt(2026, 2))),
      );

      expect(find.text('Sep 2025 – Feb 2026'), findsOneWidget);
    });

    testWidgets('shows an income and expense legend', (tester) async {
      await tester.pumpWidget(
        wrapSection(MonthTrendSection(series: seriesEndingAt(2026, 8))),
      );

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('draws horizontal gridlines and monetary axis labels',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthTrendSection(series: seriesEndingAt(2026, 8, income: 30000)),
      ));

      final chart = tester.widget<BarChart>(find.byType(BarChart));
      expect(chart.data.gridData.show, isTrue);
      expect(chart.data.gridData.drawVerticalLine, isFalse);
      expect(chart.data.titlesData.leftTitles.sideTitles.showTitles, isTrue);
      expect(chart.data.barGroups.length, 6);

      // Axis ceiling rounds above the largest value so labels land on round
      // numbers.
      expect(chart.data.maxY, 30000);
      expect(find.text('₹30k'), findsOneWidget);
      expect(find.text('₹0'), findsOneWidget);
    });

    testWidgets('gives the selected month a wider, outlined rod',
        (tester) async {
      await tester.pumpWidget(
        wrapSection(MonthTrendSection(series: seriesEndingAt(2026, 8))),
      );

      final chart = tester.widget<BarChart>(find.byType(BarChart));
      final selected = chart.data.barGroups.last.barRods.first;
      final other = chart.data.barGroups.first.barRods.first;

      expect(selected.width, greaterThan(other.width));
      expect(selected.borderSide.width, greaterThan(0));
      expect(other.borderSide.width, 0);
    });

    testWidgets('exposes a complete semantic equivalent', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthTrendSection(
          series: TrendSeries(points: [
            const TrendPoint(
              year: 2026,
              month: 7,
              income: 2000,
              expense: 800,
              isSelected: false,
            ),
            const TrendPoint(
              year: 2026,
              month: 8,
              income: 3000,
              expense: 900,
              isSelected: true,
            ),
          ]),
        ),
      ));

      expect(
        find.bySemanticsLabel(RegExp(
          r'Jul 2026, income ₹2,000, expense ₹800\. '
          r'Selected month Aug 2026, income ₹3,000, expense ₹900\.',
        )),
        findsOneWidget,
      );
    });

    testWidgets('shows an empty hint naming the range bounds', (tester) async {
      final empty = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [],
      );

      await tester.pumpWidget(wrapSection(MonthTrendSection(series: empty)));

      expect(
        find.textContaining('No transactions between Mar 2026 and Aug 2026'),
        findsOneWidget,
      );
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('fits six groups at 320px without overflow', (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(wrapSection(
        MonthTrendSection(series: seriesEndingAt(2026, 8, income: 150000)),
      ));

      expect(tester.takeException(), isNull);

      final chart = tester.widget<BarChart>(find.byType(BarChart));
      expect(chart.data.barGroups.length, 6);
      expect(find.text('₹1.5L'), findsOneWidget);
    });

    testWidgets('renders in the dark theme without error', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthTrendSection(series: seriesEndingAt(2026, 8)),
        dark: true,
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(BarChart), findsOneWidget);
    });

    test('range label names both years only when the window spans two', () {
      expect(
        MonthTrendSection.rangeLabel(seriesEndingAt(2026, 2)),
        'Sep 2025 – Feb 2026',
      );
      expect(
        MonthTrendSection.rangeLabel(seriesEndingAt(2026, 8)),
        'Mar 2026 – Aug 2026',
      );
    });

    test('month abbreviations are three letters', () {
      expect(MonthTrendSection.monthAbbreviation(1), 'Jan');
      expect(MonthTrendSection.monthAbbreviation(9), 'Sep');
      expect(MonthTrendSection.monthAbbreviation(12), 'Dec');
    });

    test('compact axis labels stay readable across magnitudes', () {
      expect(MonthTrendSection.compactAxisLabel(0), '₹0');
      expect(MonthTrendSection.compactAxisLabel(500), '₹500');
      expect(MonthTrendSection.compactAxisLabel(10000), '₹10k');
      expect(MonthTrendSection.compactAxisLabel(2500), '₹2.5k');
      expect(MonthTrendSection.compactAxisLabel(100000), '₹1L');
      expect(MonthTrendSection.compactAxisLabel(150000), '₹1.5L');
    });

    test('axis ceiling rounds up to a readable interval', () {
      expect(MonthTrendSection.axisCeiling(0), 0);
      expect(MonthTrendSection.axisCeiling(950), 1000);
      expect(MonthTrendSection.axisCeiling(12500), 20000);
      expect(MonthTrendSection.axisCeiling(30000), 30000);
    });
  });

  group('MonthComparisonSection', () {
    testWidgets('names the previous month in its heading', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: _higherComparison,
          displayedMonth: _august,
        ),
      ));

      expect(find.text('Compared with July 2026'), findsOneWidget);
    });

    testWidgets('names the previous month across a year boundary',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: _higherComparison,
          displayedMonth: DateTime(2026, 1, 1),
        ),
      ));

      expect(find.text('Compared with December 2025'), findsOneWidget);
    });

    testWidgets('explains when there is no baseline', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: const MonthComparison.unavailable(),
          displayedMonth: _august,
        ),
      ));

      expect(
        find.textContaining('No transactions last month'),
        findsOneWidget,
      );
    });

    testWidgets('reports higher spending with amount and percentage',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: _higherComparison,
          displayedMonth: _august,
        ),
      ));

      expect(find.text('You spent ₹500 more overall'), findsOneWidget);
      expect(find.text('50.0%'), findsOneWidget);
      expect(find.text('Higher'), findsOneWidget);
    });

    testWidgets('reports lower spending', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: const MonthComparison(
            isAvailable: true,
            currentExpense: 750,
            previousExpense: 1000,
            difference: 250,
            percentChange: -25,
            direction: ChangeDirection.lower,
            categoryChanges: [],
          ),
          displayedMonth: _august,
        ),
      ));

      expect(find.text('You spent ₹250 less overall'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
      expect(find.text('Lower'), findsOneWidget);
    });

    testWidgets('shows an amount instead of a percentage when undefined',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: const MonthComparison(
            isAvailable: true,
            currentExpense: 800,
            previousExpense: 0,
            difference: 800,
            percentChange: null,
            direction: ChangeDirection.newSpending,
            categoryChanges: [],
          ),
          displayedMonth: _august,
        ),
      ));

      expect(find.text('Spending began this month'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      // No synthetic percentage is invented without a baseline.
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('lists category changes in the supplied order', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          displayedMonth: _august,
          comparison: const MonthComparison(
            isAvailable: true,
            currentExpense: 3000,
            previousExpense: 1000,
            difference: 2000,
            percentChange: 200,
            direction: ChangeDirection.higher,
            categoryChanges: [
              CategoryChange(
                tagId: 'grocery',
                label: 'Grocery',
                currentAmount: 400,
                previousAmount: 100,
                difference: 300,
                percentChange: 300,
                direction: ChangeDirection.higher,
              ),
              CategoryChange(
                tagId: 'cab',
                label: 'Cab',
                currentAmount: 900,
                previousAmount: 0,
                difference: 900,
                percentChange: null,
                direction: ChangeDirection.newSpending,
              ),
            ],
          ),
        ),
      ));

      expect(find.text('2 notable changes'), findsOneWidget);
      expect(find.text('Grocery spending increased'), findsOneWidget);
      expect(find.text('New Cab spending'), findsOneWidget);

      final grocery =
          tester.getTopLeft(find.text('Grocery spending increased'));
      final cab = tester.getTopLeft(find.text('New Cab spending'));
      expect(grocery.dy, lessThan(cab.dy));
    });

    testWidgets('wraps without overflow at 320px and doubled text scale',
        (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: _higherComparison,
          displayedMonth: _august,
        ),
        textScale: 2.0,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Higher'), findsOneWidget);
    });

    testWidgets('renders in the dark theme without error', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthComparisonSection(
          comparison: _higherComparison,
          displayedMonth: _august,
        ),
        dark: true,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Higher'), findsOneWidget);
    });

    test('direction labels cover every case', () {
      expect(MonthComparisonSection.directionLabel(ChangeDirection.higher),
          'Higher');
      expect(MonthComparisonSection.directionLabel(ChangeDirection.lower),
          'Lower');
      expect(MonthComparisonSection.directionLabel(ChangeDirection.noChange),
          'No change');
      expect(MonthComparisonSection.directionLabel(ChangeDirection.newSpending),
          'New');
      expect(MonthComparisonSection.directionLabel(ChangeDirection.disappeared),
          'Stopped');
    });

    test('category sentences cover every direction', () {
      CategoryChange change(ChangeDirection direction) => CategoryChange(
            tagId: 'food',
            label: 'Food',
            currentAmount: 100,
            previousAmount: 50,
            difference: 50,
            percentChange: 100,
            direction: direction,
          );

      expect(
        MonthComparisonSection.categorySentence(change(ChangeDirection.higher)),
        'Food spending increased',
      );
      expect(
        MonthComparisonSection.categorySentence(change(ChangeDirection.lower)),
        'Food spending decreased',
      );
      expect(
        MonthComparisonSection.categorySentence(
            change(ChangeDirection.noChange)),
        'Food spending was unchanged',
      );
      expect(
        MonthComparisonSection.categorySentence(
            change(ChangeDirection.newSpending)),
        'New Food spending',
      );
      expect(
        MonthComparisonSection.categorySentence(
            change(ChangeDirection.disappeared)),
        'Food spending stopped',
      );
    });

    test('heading is derived from the displayed month', () {
      expect(
        MonthComparisonSection.headingFor(DateTime(2026, 3, 1)),
        'Compared with February 2026',
      );
    });
  });
}
