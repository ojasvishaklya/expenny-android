import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/analytics/MonthComparison.dart';
import 'package:expenny/models/analytics/TrendSeries.dart';
import 'package:expenny/service/AnalyticsService.dart';
import 'package:expenny/widgets/analytics/MonthComparisonSection.dart';
import 'package:expenny/widgets/analytics/MonthTrendSection.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

/// Builds a six-month series ending at the given month, with a value in the
/// final (selected) month so the series is not treated as empty.
TrendSeries seriesEndingAt(int year, int month, {double income = 1000}) {
  final points = <TrendPoint>[];
  for (var offset = 5; offset >= 0; offset--) {
    final date = DateTime(year, month - offset, 1);
    final isSelected = offset == 0;
    points.add(TrendPoint(
      year: date.year,
      month: date.month,
      income: isSelected ? income : 0,
      expense: 0,
      isSelected: isSelected,
    ));
  }
  return TrendSeries(points: points);
}

void main() {
  group('MonthTrendSection', () {
    testWidgets('labels all six months and marks the selected one',
        (tester) async {
      await tester.pumpWidget(
        wrap(MonthTrendSection(series: seriesEndingAt(2026, 8))),
      );

      expect(find.text('Mar'), findsOneWidget);
      expect(find.text('Apr'), findsOneWidget);
      expect(find.text('May'), findsOneWidget);
      expect(find.text('Jun'), findsOneWidget);
      expect(find.text('Jul'), findsOneWidget);
      // The selected month is bulleted.
      expect(find.text('• Aug'), findsOneWidget);
    });

    testWidgets('shows an income and expense legend', (tester) async {
      await tester.pumpWidget(
        wrap(MonthTrendSection(series: seriesEndingAt(2026, 8))),
      );

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('shows an empty hint naming the range bounds', (tester) async {
      final empty = AnalyticsService.trend(
        year: 2026,
        month: 8,
        transactions: [],
      );

      await tester.pumpWidget(wrap(MonthTrendSection(series: empty)));

      expect(
        find.textContaining('No transactions between Mar 2026 and Aug 2026'),
        findsOneWidget,
      );
    });

    test('range label names both years when the window spans two', () {
      expect(
          MonthTrendSection.rangeLabel(seriesEndingAt(2026, 2)), '2025 - 2026');
      expect(MonthTrendSection.rangeLabel(seriesEndingAt(2026, 8)), '2026');
    });

    test('month abbreviations are three letters', () {
      expect(MonthTrendSection.monthAbbreviation(1), 'Jan');
      expect(MonthTrendSection.monthAbbreviation(9), 'Sep');
      expect(MonthTrendSection.monthAbbreviation(12), 'Dec');
    });
  });

  group('MonthComparisonSection', () {
    testWidgets('explains when there is no baseline to compare against',
        (tester) async {
      await tester.pumpWidget(
        wrap(const MonthComparisonSection(
          comparison: MonthComparison.unavailable(),
        )),
      );

      expect(
        find.textContaining('No transactions last month'),
        findsOneWidget,
      );
    });

    testWidgets('reports higher spending with the percentage', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthComparisonSection(
          comparison: MonthComparison(
            isAvailable: true,
            currentExpense: 1500,
            previousExpense: 1000,
            difference: 500,
            percentChange: 50,
            direction: ChangeDirection.higher,
            categoryChanges: [],
          ),
        )),
      );

      expect(
        find.text('You spent ₹500 more than last month'),
        findsOneWidget,
      );
      expect(find.text('50.0%'), findsOneWidget);
    });

    testWidgets('reports lower spending', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthComparisonSection(
          comparison: MonthComparison(
            isAvailable: true,
            currentExpense: 750,
            previousExpense: 1000,
            difference: 250,
            percentChange: -25,
            direction: ChangeDirection.lower,
            categoryChanges: [],
          ),
        )),
      );

      expect(
        find.text('You spent ₹250 less than last month'),
        findsOneWidget,
      );
      // The magnitude is shown; the direction is carried by the sentence.
      expect(find.text('25.0%'), findsOneWidget);
    });

    testWidgets('omits the percentage when there is no baseline expense',
        (tester) async {
      await tester.pumpWidget(
        wrap(const MonthComparisonSection(
          comparison: MonthComparison(
            isAvailable: true,
            currentExpense: 800,
            previousExpense: 0,
            difference: 800,
            percentChange: null,
            direction: ChangeDirection.newSpending,
            categoryChanges: [],
          ),
        )),
      );

      expect(find.textContaining('nothing to compare'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('lists the biggest category movers', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthComparisonSection(
          comparison: MonthComparison(
            isAvailable: true,
            currentExpense: 3000,
            previousExpense: 1000,
            difference: 2000,
            percentChange: 200,
            direction: ChangeDirection.higher,
            categoryChanges: [
              CategoryChange(
                tagId: 'food',
                label: 'Food',
                currentAmount: 2000,
                previousAmount: 1000,
                difference: 1000,
                percentChange: 100,
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
        )),
      );

      expect(find.text('Biggest movers'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('₹1,000'), findsOneWidget);
      expect(find.text('more'), findsOneWidget);
      expect(find.text('Cab'), findsOneWidget);
      expect(find.text('₹900'), findsOneWidget);
      expect(find.text('new'), findsOneWidget);
    });

    test('direction labels cover every case', () {
      expect(MonthComparisonSection.directionLabel(ChangeDirection.higher),
          'more');
      expect(
          MonthComparisonSection.directionLabel(ChangeDirection.lower), 'less');
      expect(MonthComparisonSection.directionLabel(ChangeDirection.noChange),
          'no change');
      expect(MonthComparisonSection.directionLabel(ChangeDirection.newSpending),
          'new');
      expect(MonthComparisonSection.directionLabel(ChangeDirection.disappeared),
          'stopped');
    });
  });
}
