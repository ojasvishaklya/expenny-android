import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/widgets/analytics/CategoryBreakdownSection.dart';
import 'package:expenny/widgets/analytics/MonthlySummarySection.dart';

import 'support/dashboard_harness.dart';

final _august = DateTime(2026, 8, 1);

const _populatedSummary = MonthlySummary(
  income: 25500,
  expense: 13040,
  net: 12460,
  savingsRate: 48.9,
);

const _twoGroups = CategoryBreakdown(
  totalExpense: 1000,
  groups: [
    CategoryGroup(
      tagIds: {'food'},
      label: 'Food',
      amount: 750,
      percent: 75,
    ),
    CategoryGroup(
      tagIds: {'cab'},
      label: 'Cab',
      amount: 250,
      percent: 25,
    ),
  ],
);

void main() {
  group('MonthlySummarySection', () {
    testWidgets('shows an empty hint naming the displayed month',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          summary: const MonthlySummary.zero(),
          displayedMonth: _august,
        ),
      ));

      expect(
        find.textContaining('No transactions in August 2026'),
        findsOneWidget,
      );
      // An empty month must not present zero totals as loaded activity.
      expect(find.text('Income'), findsNothing);
      expect(find.text('₹0'), findsNothing);
    });

    testWidgets('shows net, income, expense, and savings rate', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
      ));

      expect(find.text('₹12,460'), findsOneWidget);
      expect(find.text('₹25,500'), findsOneWidget);
      expect(find.text('₹13,040'), findsOneWidget);
      expect(find.text('48.9%'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Savings rate'), findsOneWidget);
    });

    testWidgets('attributes the hero to the displayed month', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          summary: _populatedSummary,
          displayedMonth: DateTime(2025, 12, 1),
        ),
      ));

      expect(find.text('December 2025 net'), findsOneWidget);
    });

    testWidgets('states the net outcome in the summary semantics',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          summary: const MonthlySummary(
            income: 1000,
            expense: 2500,
            net: -1500,
            savingsRate: 0,
          ),
          displayedMonth: _august,
        ),
      ));

      // The net direction is carried in the summary semantics as a whole word,
      // not shown as visible text beside the figure.
      expect(find.text('Negative'), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp(r'\bNegative\b')),
        findsOneWidget,
      );
    });

    testWidgets('exposes one concise summary semantic', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
      ));

      expect(
        find.bySemanticsLabel(RegExp(
          r'August 2026 summary\. Net ₹12,460, Positive\. '
          r'Income ₹25,500\. Expense ₹13,040\. Savings rate 48\.9%\.',
        )),
        findsOneWidget,
      );
    });

    testWidgets('uses the primary container role for the hero', (tester) async {
      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
      ));

      final decorated = tester.widgetList<Container>(find.byType(Container));
      final colors = testLightTheme().colorScheme;
      final matches = decorated.where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration &&
            decoration.color == colors.primaryContainer;
      });

      expect(matches, isNotEmpty);
    });

    testWidgets('stacks money tiles at 320px without overflow', (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          // Deliberately large figures to stress the amount slot.
          summary: const MonthlySummary(
            income: 98765432,
            expense: 87654321,
            net: 11111111,
            savingsRate: 11.2,
          ),
          displayedMonth: _august,
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('₹9,87,65,432'), findsOneWidget);
      expect(find.text('₹8,76,54,321'), findsOneWidget);
    });

    testWidgets('survives a doubled text scale at 320px', (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(wrapSection(
        MonthlySummarySection(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
        textScale: 2.0,
      ));

      expect(tester.takeException(), isNull);
      // The net direction is semantic-only; a visible money value proves the
      // hero still renders at a doubled text scale.
      expect(find.text('₹12,460'), findsOneWidget);
    });

    test('net state labels cover every outcome', () {
      expect(
        MonthlySummarySection.netStateLabel(NetState.positive),
        'Positive',
      );
      expect(
        MonthlySummarySection.netStateLabel(NetState.negative),
        'Negative',
      );
      expect(
        MonthlySummarySection.netStateLabel(NetState.zero),
        'Even',
      );
    });
  });

  group('CategoryBreakdownSection', () {
    testWidgets('shows an empty hint and no chart when nothing was spent',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        const CategoryBreakdownSection(
          breakdown: CategoryBreakdown.empty(),
        ),
      ));

      expect(find.text('No spending recorded this month.'), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('renders a donut with one section per group', (tester) async {
      await tester.pumpWidget(
        wrapSection(const CategoryBreakdownSection(breakdown: _twoGroups)),
      );

      final chart = tester.widget<PieChart>(find.byType(PieChart));
      expect(chart.data.sections.length, 2);
      expect(chart.data.sections.map((s) => s.value).toList(), [750, 250]);
      // Arc labels are suppressed; the legend carries the text.
      expect(chart.data.sections.every((s) => s.showTitle), isFalse);
      // A non-infinite centre space is what makes it a donut rather than a pie.
      expect(chart.data.centerSpaceRadius, isNot(double.infinity));
    });

    testWidgets('lists every group with label, amount, and percentage',
        (tester) async {
      await tester.pumpWidget(
        wrapSection(const CategoryBreakdownSection(breakdown: _twoGroups)),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('₹750'), findsOneWidget);
      expect(find.text('75.0%'), findsOneWidget);
      expect(find.text('Cab'), findsOneWidget);
      expect(find.text('₹250'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
      // The section no longer shows a trailing total; the donut centre shows
      // the category count over the plural noun instead.
      expect(find.text('₹1,000 total'), findsNothing);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('categories'), findsOneWidget);
    });

    testWidgets('preserves the order supplied by the service', (tester) async {
      await tester.pumpWidget(wrapSection(
        const CategoryBreakdownSection(
          breakdown: CategoryBreakdown(
            totalExpense: 900,
            groups: [
              CategoryGroup(
                tagIds: {'cab'},
                label: 'Cab',
                amount: 600,
                percent: 66.7,
              ),
              CategoryGroup(
                tagIds: {'food'},
                label: 'Food',
                amount: 300,
                percent: 33.3,
              ),
            ],
          ),
        ),
      ));

      final cab = tester.getTopLeft(find.text('Cab')).dy;
      final food = tester.getTopLeft(find.text('Food')).dy;
      expect(cab, lessThan(food));
    });

    testWidgets('renders the aggregated Other group', (tester) async {
      await tester.pumpWidget(wrapSection(
        const CategoryBreakdownSection(
          breakdown: CategoryBreakdown(
            totalExpense: 500,
            groups: [
              CategoryGroup(
                tagIds: {'food'},
                label: 'Food',
                amount: 400,
                percent: 80,
              ),
              CategoryGroup(
                tagIds: {'loan', 'gym'},
                label: 'Other',
                amount: 100,
                percent: 20,
                isOther: true,
              ),
            ],
          ),
        ),
      ));

      expect(find.text('Other'), findsOneWidget);
      expect(find.text('₹100'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('exposes a complete semantic equivalent of the chart',
        (tester) async {
      await tester.pumpWidget(
        wrapSection(const CategoryBreakdownSection(breakdown: _twoGroups)),
      );

      expect(
        find.bySemanticsLabel(
          'Spending by category. Food, ₹750, 75.0%. Cab, ₹250, 25.0%.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('stacks the donut above the legend at 320px', (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(
        wrapSection(const CategoryBreakdownSection(breakdown: _twoGroups)),
      );

      expect(tester.takeException(), isNull);

      final donut = tester.getCenter(find.byType(PieChart)).dy;
      final firstLegendRow = tester.getCenter(find.text('Food')).dy;
      expect(donut, lessThan(firstLegendRow));
    });

    testWidgets('renders in the dark theme without error', (tester) async {
      await tester.pumpWidget(wrapSection(
        const CategoryBreakdownSection(breakdown: _twoGroups),
        dark: true,
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
    });

    test('semantic summary lists every group in order', () {
      expect(
        CategoryBreakdownSection.semanticSummary(_twoGroups),
        'Spending by category. Food, ₹750, 75.0%. Cab, ₹250, 25.0%.',
      );
    });
  });
}
