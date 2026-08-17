import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/models/analytics/MonthlySummary.dart';
import 'package:expenny/widgets/analytics/CategoryBreakdownSection.dart';
import 'package:expenny/widgets/analytics/MonthlySummarySection.dart';

/// Wraps a section in the minimum material scaffolding needed to pump it.
Widget wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  group('MonthlySummarySection', () {
    testWidgets('shows an empty hint when the month has no transactions',
        (tester) async {
      await tester.pumpWidget(
        wrap(const MonthlySummarySection(summary: MonthlySummary.zero())),
      );

      expect(find.textContaining('No transactions this month'), findsOneWidget);
      expect(find.text('Income'), findsNothing);
    });

    testWidgets('shows net, income, expense, and savings rate', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthlySummarySection(
          summary: MonthlySummary(
            income: 50000,
            expense: 15000,
            net: 35000,
            savingsRate: 70,
          ),
        )),
      );

      expect(find.text('₹35,000'), findsOneWidget);
      expect(find.text('₹50,000'), findsOneWidget);
      expect(find.text('₹15,000'), findsOneWidget);
      expect(find.text('70.0%'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('states the net outcome in words', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthlySummarySection(
          summary: MonthlySummary(
            income: 1000,
            expense: 2500,
            net: -1500,
            savingsRate: 0,
          ),
        )),
      );

      expect(find.text('Overspent this month'), findsOneWidget);
    });

    test('net state labels cover every outcome', () {
      expect(
        MonthlySummarySection.netStateLabel(NetState.positive),
        'Saved this month',
      );
      expect(
        MonthlySummarySection.netStateLabel(NetState.negative),
        'Overspent this month',
      );
      expect(
        MonthlySummarySection.netStateLabel(NetState.zero),
        'Broke even this month',
      );
    });
  });

  group('CategoryBreakdownSection', () {
    testWidgets('shows an empty hint when nothing was spent', (tester) async {
      await tester.pumpWidget(
        wrap(const CategoryBreakdownSection(
          breakdown: CategoryBreakdown.empty(),
        )),
      );

      expect(find.text('No spending recorded this month.'), findsOneWidget);
    });

    testWidgets('lists categories with amounts and percentages',
        (tester) async {
      await tester.pumpWidget(
        wrap(const CategoryBreakdownSection(
          breakdown: CategoryBreakdown(
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
          ),
        )),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('₹750'), findsOneWidget);
      expect(find.text('75.0%'), findsOneWidget);
      expect(find.text('Cab'), findsOneWidget);
      expect(find.text('₹250'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
      // Section total.
      expect(find.text('₹1,000'), findsOneWidget);
    });

    testWidgets('renders rows in the order supplied', (tester) async {
      await tester.pumpWidget(
        wrap(const CategoryBreakdownSection(
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
        )),
      );

      final cab = tester.getTopLeft(find.text('Cab')).dy;
      final food = tester.getTopLeft(find.text('Food')).dy;
      expect(cab, lessThan(food));
    });

    testWidgets('renders the folded Other group', (tester) async {
      await tester.pumpWidget(
        wrap(const CategoryBreakdownSection(
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
        )),
      );

      expect(find.text('Other'), findsOneWidget);
      expect(find.text('₹100'), findsOneWidget);
    });
  });
}
