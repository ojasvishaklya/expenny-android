import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/widgets/analytics/CategoryBreakdownSection.dart';

import 'support/dashboard_harness.dart';

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
  group('CategoryBreakdownSection', () {
    testWidgets('shows an empty hint and no rows when nothing was spent',
        (tester) async {
      await tester.pumpWidget(wrapSection(
        const CategoryBreakdownSection(
          breakdown: CategoryBreakdown.empty(),
        ),
      ));

      expect(find.text('No spending recorded this month.'), findsOneWidget);
      // No category names render for an empty breakdown.
      expect(find.text('Food'), findsNothing);
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

    test('scales share bars relative to the largest group', () {
      // The leader fills the track; the rest are drawn in proportion to it.
      expect(
        CategoryBreakdownSection.barFraction(_twoGroups, _twoGroups.groups[0]),
        1.0,
      );
      expect(
        CategoryBreakdownSection.barFraction(_twoGroups, _twoGroups.groups[1]),
        closeTo(0.3333, 0.001),
      );
    });

    test('bar fraction is zero when there is nothing to scale against', () {
      expect(
        CategoryBreakdownSection.barFraction(
          const CategoryBreakdown.empty(),
          const CategoryGroup(
            tagIds: {'food'},
            label: 'Food',
            amount: 0,
            percent: 0,
          ),
        ),
        0,
      );
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

    testWidgets('exposes a complete semantic equivalent of the list',
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

    testWidgets('renders the list at 320px without overflow', (tester) async {
      await setSurface(tester, kNarrowSurface);

      await tester.pumpWidget(
        wrapSection(const CategoryBreakdownSection(breakdown: _twoGroups)),
      );

      expect(tester.takeException(), isNull);
      final food = tester.getTopLeft(find.text('Food')).dy;
      final cab = tester.getTopLeft(find.text('Cab')).dy;
      expect(food, lessThan(cab));
    });

    testWidgets('renders in the dark theme without error', (tester) async {
      await tester.pumpWidget(wrapSection(
        const CategoryBreakdownSection(breakdown: _twoGroups),
        dark: true,
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Cab'), findsOneWidget);
    });

    test('semantic summary lists every group in order', () {
      expect(
        CategoryBreakdownSection.semanticSummary(_twoGroups),
        'Spending by category. Food, ₹750, 75.0%. Cab, ₹250, 25.0%.',
      );
    });
  });
}
