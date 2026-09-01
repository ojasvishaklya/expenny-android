import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/widgets/DisplayCard.dart';

import 'support/dashboard_harness.dart';

final _august = DateTime(2026, 8, 1);

const _populatedSummary = MonthlySummary(
  income: 25500,
  expense: 13040,
  net: 12460,
  savingsRate: 48.9,
);

void main() {
  group('DisplayCard net hero', () {
    testWidgets('shows an empty hint naming the displayed month',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
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
        DisplayCard(
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
        DisplayCard(
          summary: _populatedSummary,
          displayedMonth: DateTime(2025, 12, 1),
        ),
      ));

      expect(find.text('December 2025 net'), findsOneWidget);
    });

    testWidgets('shows direction icons on the income and expense tiles',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
      ));

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('uses tertiary for income and error for expense icons',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
      ));

      final colors = testLightTheme().colorScheme;
      final up = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      final down = tester.widget<Icon>(find.byIcon(Icons.arrow_downward));

      expect(up.color, colors.tertiary);
      expect(down.color, colors.error);
    });

    testWidgets('states a positive net outcome in the summary semantics',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
      ));

      // The net direction is carried in the summary semantics as a whole word,
      // not shown as visible text beside the figure.
      expect(find.text('Positive'), findsNothing);
      expect(find.bySemanticsLabel(RegExp(r'\bPositive\b')), findsOneWidget);
    });

    testWidgets('states a negative net outcome in the summary semantics',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: const MonthlySummary(
            income: 1000,
            expense: 2500,
            net: -1500,
            savingsRate: 0,
          ),
          displayedMonth: _august,
        ),
      ));

      expect(find.text('Negative'), findsNothing);
      expect(find.bySemanticsLabel(RegExp(r'\bNegative\b')), findsOneWidget);
      // A negative net renders as a signed rupee value.
      expect(find.text('-₹1,500'), findsOneWidget);
    });

    testWidgets('states an even net outcome for a zero net', (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: const MonthlySummary(
            income: 1000,
            expense: 1000,
            net: 0,
            savingsRate: 0,
          ),
          displayedMonth: _august,
        ),
      ));

      expect(find.bySemanticsLabel(RegExp(r'\bEven\b')), findsOneWidget);
      expect(find.text('₹0'), findsOneWidget);
    });

    testWidgets('exposes one concise summary semantic including net direction',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
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
        DisplayCard(
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

    testWidgets('clamps the savings bar at the boundaries', (tester) async {
      // Rate above 100 clamps the bar to full without error.
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: const MonthlySummary(
            income: 1000,
            expense: 0,
            net: 1000,
            savingsRate: 100,
          ),
          displayedMonth: _august,
        ),
      ));

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 1.0);
    });

    testWidgets('draws a zero savings bar for a zero rate', (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: const MonthlySummary(
            income: 1000,
            expense: 1500,
            net: -500,
            savingsRate: 0,
          ),
          displayedMonth: _august,
        ),
      ));

      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.0);
    });

    testWidgets('stacks money tiles at 320px without overflow', (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(wrapSection(
        DisplayCard(
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
        DisplayCard(
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

    testWidgets('renders in the dark theme without error', (tester) async {
      await tester.pumpWidget(wrapSection(
        DisplayCard(
          summary: _populatedSummary,
          displayedMonth: _august,
        ),
        dark: true,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('₹12,460'), findsOneWidget);
    });

    test('net state labels cover every outcome', () {
      expect(DisplayCard.netStateLabel(NetState.positive), 'Positive');
      expect(DisplayCard.netStateLabel(NetState.negative), 'Negative');
      expect(DisplayCard.netStateLabel(NetState.zero), 'Even');
    });
  });
}
