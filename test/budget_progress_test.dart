import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/analytics/CategoryBreakdown.dart';
import 'package:expenny/widgets/BudgetProgressWidget.dart';

/// Covers the pure budget helpers and the pure segment-allocation contract for
/// the segmented budget bar (Task 4).
///
/// NOTE (Task 4 test deferral): The `BudgetProgressWidget rendering` group of
/// `testWidgets` cases is intentionally commented out below and deferred, and
/// NO tests in this file have been executed as part of Task 4. The user
/// explicitly deferred all unit/widget test execution for Task 4 because the
/// test-run timeout handling is currently unreliable; running the widget cases
/// risks a non-terminating run.
///
/// The widget cases additionally depend on platform-channel setup
/// (`registerConfigService` mocks `path_provider` and initialises
/// `GetStorage`, and the Edit-action case drives `showMonthlyBudgetDialog` with
/// `pumpAndSettle`). Even though the harness seeds `monthlyBudget.value`
/// directly to avoid `setMonthlyBudget` → `home_widget`, that setup is exactly
/// the "problematic widget/platform setup" the deferral instruction calls out.
/// They are preserved as commented specifications with per-scenario TODOs so
/// the contract they describe is not lost, and must be re-enabled and run once
/// timeout handling is fixed.
///
/// The pure `test(...)` groups below require no binding, platform channel, or
/// pump, so they remain as the deterministic description of the contract. They
/// were NOT run here either (execution deferred), but carry no run-hang risk.

/// A three-category breakdown that under-fills a 1000 budget (spent 600).
const _threeUnder = CategoryBreakdown(
  totalExpense: 600,
  groups: [
    CategoryGroup(tagIds: {'food'}, label: 'Food', amount: 300, percent: 50),
    CategoryGroup(
        tagIds: {'transport'}, label: 'Transport', amount: 200, percent: 33.3),
    CategoryGroup(
        tagIds: {'shopping'}, label: 'Shopping', amount: 100, percent: 16.7),
  ],
);

// NOTE (Task 4 deferred widget-test helpers): `_configWithBudget(...)` and
// `_budget(...)` previously seeded `ConfigService.monthlyBudget.value` via
// `registerConfigService()` and wrapped the widget with `wrapSection(...)` from
// `support/dashboard_harness.dart`. They are removed here alongside the
// deferred `BudgetProgressWidget rendering` group because they exist solely for
// the platform-channel-backed widget cases. Restore them (and the
// `flutter/material.dart`, `ConfigService`, `CategoryVisualIdentity`, and
// `support/dashboard_harness.dart` imports) when re-enabling those cases after
// timeout handling is fixed.

void main() {
  group('computeProgress', () {
    test('returns 0.0 when budget is 0', () {
      expect(computeProgress(100, 0), 0.0);
    });

    test('returns 0.0 when budget is negative', () {
      expect(computeProgress(100, -50), 0.0);
    });

    test('returns 0.0 when expense is 0', () {
      expect(computeProgress(0, 1000), 0.0);
    });

    test('returns correct ratio for expense less than budget', () {
      expect(computeProgress(500, 1000), 0.5);
    });

    test('returns 1.0 when expense equals budget', () {
      expect(computeProgress(1000, 1000), 1.0);
    });

    test('caps at 1.0 when expense exceeds budget', () {
      expect(computeProgress(2000, 1000), 1.0);
    });

    test('handles small fractional values', () {
      expect(computeProgress(1, 3), closeTo(0.333, 0.001));
    });
  });

  group('isOverBudget', () {
    test('returns false when expense is below budget', () {
      expect(isOverBudget(500, 1000), false);
    });

    test('returns true when expense equals budget', () {
      expect(isOverBudget(1000, 1000), true);
    });

    test('returns true when expense exceeds budget', () {
      expect(isOverBudget(1500, 1000), true);
    });
  });

  group('budgetUsedPercent', () {
    test('returns 0 for a non-positive budget', () {
      expect(budgetUsedPercent(100, 0), 0.0);
      expect(budgetUsedPercent(100, -50), 0.0);
    });

    test('returns the consumed share of the budget', () {
      expect(budgetUsedPercent(500, 1000), 50.0);
      expect(budgetUsedPercent(1000, 1000), 100.0);
    });

    test('is not capped when overspending', () {
      expect(budgetUsedPercent(1500, 1000), 150.0);
    });

    test('matches the percentage the dashboard renders', () {
      expect(budgetUsedPercent(13040, 20000), closeTo(65.2, 0.001));
    });
  });

  group('budgetDifference', () {
    test('is positive when under budget', () {
      expect(budgetDifference(12000, 50000), 38000);
    });

    test('is zero when exactly on budget', () {
      expect(budgetDifference(50000, 50000), 0);
    });

    test('is negative when over budget', () {
      expect(budgetDifference(52000, 50000), -2000);
    });
  });

  group('remainingBudget', () {
    test('is the unspent budget when under', () {
      expect(remainingBudget(600, 1000), 400);
    });

    test('is zero at exact equality', () {
      expect(remainingBudget(1000, 1000), 0);
    });

    test('floors at zero when over budget rather than going negative', () {
      expect(remainingBudget(1500, 1000), 0);
    });
  });

  group('validateBudgetInput', () {
    test('returns null for empty string (clear budget)', () {
      expect(validateBudgetInput(''), null);
    });

    test('returns null for whitespace-only string (clear budget)', () {
      expect(validateBudgetInput('   '), null);
    });

    test('returns null for valid positive number', () {
      expect(validateBudgetInput('5000'), null);
    });

    test('returns null for valid decimal number', () {
      expect(validateBudgetInput('1234.56'), null);
    });

    test('returns error for non-numeric input', () {
      expect(validateBudgetInput('abc'), 'Please enter a valid number');
    });

    test('returns error for zero', () {
      expect(validateBudgetInput('0'), 'Budget must be a positive amount');
    });

    test('returns error for negative number', () {
      expect(validateBudgetInput('-100'), 'Budget must be a positive amount');
    });

    test('returns error for a value that parses to infinity', () {
      expect(validateBudgetInput('1e400'), 'Please enter a valid number');
    });
  });

  group('budgetSegments (pure allocation)', () {
    test('returns nothing for a non-positive budget', () {
      expect(budgetSegments(_threeUnder, 0), isEmpty);
      expect(budgetSegments(_threeUnder, -100), isEmpty);
    });

    test('is a single idle segment when no categories were spent', () {
      final segments = budgetSegments(const CategoryBreakdown.empty(), 1000);
      expect(segments, hasLength(1));
      expect(segments.single.isIdle, true);
      expect(segments.single.fraction, 1.0);
    });

    test('allocates one category then idle for the remainder', () {
      final segments = budgetSegments(
        const CategoryBreakdown(
          totalExpense: 250,
          groups: [
            CategoryGroup(
                tagIds: {'food'}, label: 'Food', amount: 250, percent: 100),
          ],
        ),
        1000,
      );
      expect(segments, hasLength(2));
      expect(segments[0].isIdle, false);
      expect(segments[0].group!.label, 'Food');
      expect(segments[0].fraction, closeTo(0.25, 1e-9));
      expect(segments[1].isIdle, true);
      expect(segments[1].fraction, closeTo(0.75, 1e-9));
    });

    test('lays categories down in the order supplied, then idle', () {
      final segments = budgetSegments(_threeUnder, 1000);
      expect(segments.map((s) => s.isIdle ? 'idle' : s.group!.label).toList(),
          ['Food', 'Transport', 'Shopping', 'idle']);
      expect(segments[0].fraction, closeTo(0.3, 1e-9));
      expect(segments[1].fraction, closeTo(0.2, 1e-9));
      expect(segments[2].fraction, closeTo(0.1, 1e-9));
      expect(segments[3].fraction, closeTo(0.4, 1e-9));
    });

    test('caps cumulative fill at 1 and drops later categories on overspend',
        () {
      // 700 + 500 = 1200 against a 1000 budget: the second category is clipped
      // to the remaining 0.3 and no idle segment is emitted.
      final segments = budgetSegments(
        const CategoryBreakdown(
          totalExpense: 1200,
          groups: [
            CategoryGroup(
                tagIds: {'food'}, label: 'Food', amount: 700, percent: 58.3),
            CategoryGroup(
                tagIds: {'transport'},
                label: 'Transport',
                amount: 500,
                percent: 41.7),
          ],
        ),
        1000,
      );
      expect(segments, hasLength(2));
      expect(segments[0].fraction, closeTo(0.7, 1e-9));
      expect(segments[1].group!.label, 'Transport');
      expect(segments[1].fraction, closeTo(0.3, 1e-9));
      expect(segments.any((s) => s.isIdle), false);
      // Cumulative fill never exceeds the track.
      final total = segments.fold<double>(0, (sum, s) => sum + s.fraction);
      expect(total, closeTo(1.0, 1e-9));
    });

    test('fills the track exactly with no idle when spend equals budget', () {
      final segments = budgetSegments(
        const CategoryBreakdown(
          totalExpense: 1000,
          groups: [
            CategoryGroup(
                tagIds: {'food'}, label: 'Food', amount: 600, percent: 60),
            CategoryGroup(
                tagIds: {'transport'},
                label: 'Transport',
                amount: 400,
                percent: 40),
          ],
        ),
        1000,
      );
      expect(segments, hasLength(2));
      expect(segments.any((s) => s.isIdle), false);
      final total = segments.fold<double>(0, (sum, s) => sum + s.fraction);
      expect(total, closeTo(1.0, 1e-9));
    });

    test('accounts for a gap between segment sum and spend without overflow',
        () {
      // Group amounts need not sum to the spend; each segment is still bounded
      // and the cumulative fill is clamped to the track.
      final segments = budgetSegments(
        const CategoryBreakdown(
          totalExpense: 900,
          groups: [
            CategoryGroup(
                tagIds: {'food'}, label: 'Food', amount: 900, percent: 100),
          ],
        ),
        1000,
      );
      final total = segments.fold<double>(0, (sum, s) => sum + s.fraction);
      expect(total, closeTo(1.0, 1e-9));
      expect(segments.last.isIdle, true);
      expect(segments.last.fraction, closeTo(0.1, 1e-9));
    });
  });

  // ---------------------------------------------------------------------------
  // TODO(Task 4): DEFERRED WIDGET TESTS — execution deferred by user (timeout
  // handling unreliable). The group below is commented out, NOT deleted, so the
  // rendering contract it pins is preserved verbatim. Re-enable, restore the
  // `_configWithBudget`/`_budget` helpers and the `flutter/material.dart`,
  // `ConfigService`, `CategoryVisualIdentity`, and `support/dashboard_harness.dart`
  // imports, then run once the test timeout is fixed. Deferred, unverified
  // scenarios (each maps 1:1 to a commented `testWidgets` case):
  //   1. no-budget hint + Edit action shown when budget unset; no " left" copy.
  //   2. all-idle bar + "\u20b90 of \u20b91,000 \u00b7 \u20b91,000 left" + "0.0% used" when nothing spent.
  //   3. one category segment + idle remainder ("\u20b9250 of \u20b91,000 \u00b7 \u20b9750 left", "25.0% used").
  //   4. multiple category segments drawn in supplied order with shared
  //      CategoryVisualIdentity colours ("\u20b9600 of \u20b91,000 \u00b7 \u20b9400 left", "60.0% used").
  //   5. over budget: cumulative fill capped, NO idle, "Over budget by \u20b9200",
  //      "120.0% used", no " left" copy (error semantics).
  //   6. exact budget: full track, "\u20b91,000 of \u20b91,000 \u00b7 \u20b90 left", "100.0% used",
  //      no false "Over budget" overage, isOverBudget(1000,1000)==true.
  //   7. large-amount Indian grouping in caption/used line.
  //   8. semantics state spent/budget/utilisation/category splits; decorative
  //      bar excluded via ExcludeSemantics.
  //   9. renders at 320dp without overflow.
  //  10. renders at 2.0x text scale without overflow.
  //  11. renders in dark theme without error.
  //  12. Edit action opens the shared showMonthlyBudgetDialog (Monthly Budget /
  //      Save / Cancel).
  // The pure `test(...)` groups above already verify the underlying allocation
  // and helper math these cases exercise; only the rendered/semantic surface
  // and the dialog wiring remain unverified until the group is run.
  // ---------------------------------------------------------------------------
  /*
  group('BudgetProgressWidget rendering', () {
    testWidgets('shows the no-budget hint and Edit action when unset',
        (tester) async {
      await _configWithBudget(null);

      await tester.pumpWidget(
        _budget(expense: 500, breakdown: _threeUnder),
      );

      expect(
        find.textContaining('No budget set'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Edit'), findsOneWidget);
      expect(find.textContaining(' left'), findsNothing);
    });

    testWidgets('renders an all-idle bar when nothing was spent',
        (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(expense: 0, breakdown: const CategoryBreakdown.empty()),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('₹0 of ₹1,000 · ₹1,000 left'), findsOneWidget);
      expect(find.text('0.0% used'), findsOneWidget);
    });

    testWidgets('renders one category segment plus idle remainder',
        (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(
          expense: 250,
          breakdown: const CategoryBreakdown(
            totalExpense: 250,
            groups: [
              CategoryGroup(
                  tagIds: {'food'}, label: 'Food', amount: 250, percent: 100),
            ],
          ),
        ),
      );

      expect(find.text('₹250 of ₹1,000 · ₹750 left'), findsOneWidget);
      expect(find.text('25.0% used'), findsOneWidget);
    });

    testWidgets('draws multiple category segments in supplied order',
        (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(expense: 600, breakdown: _threeUnder),
      );

      // Each non-idle category segment renders its shared identity colour.
      final colors = testLightTheme().colorScheme;
      final expectedColors = _threeUnder.groups
          .map((g) => categoryIdentityFor(g, colors).color)
          .toList();

      final boxes = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .map((b) => b.color)
          .toList();
      for (final c in expectedColors) {
        expect(boxes, contains(c));
      }
      expect(find.text('₹600 of ₹1,000 · ₹400 left'), findsOneWidget);
      expect(find.text('60.0% used'), findsOneWidget);
    });

    testWidgets('caps cumulative fill and shows no idle when over budget',
        (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(
          expense: 1200,
          breakdown: const CategoryBreakdown(
            totalExpense: 1200,
            groups: [
              CategoryGroup(
                  tagIds: {'food'}, label: 'Food', amount: 700, percent: 58.3),
              CategoryGroup(
                  tagIds: {'transport'},
                  label: 'Transport',
                  amount: 500,
                  percent: 41.7),
            ],
          ),
        ),
      );

      // Genuine overspend: error copy and utilisation above 100%.
      expect(find.text('Over budget by ₹200'), findsOneWidget);
      expect(find.text('120.0% used'), findsOneWidget);
      expect(find.textContaining(' left'), findsNothing);
    });

    testWidgets('at exact budget shows full track, 100%, zero remaining',
        (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(
          expense: 1000,
          breakdown: const CategoryBreakdown(
            totalExpense: 1000,
            groups: [
              CategoryGroup(
                  tagIds: {'food'}, label: 'Food', amount: 600, percent: 60),
              CategoryGroup(
                  tagIds: {'transport'},
                  label: 'Transport',
                  amount: 400,
                  percent: 40),
            ],
          ),
        ),
      );

      // No false-positive overage at expense == budget, but zero remaining.
      expect(find.text('₹1,000 of ₹1,000 · ₹0 left'), findsOneWidget);
      expect(find.text('100.0% used'), findsOneWidget);
      expect(find.textContaining('Over budget'), findsNothing);
      // Contract preserved at the boundary.
      expect(isOverBudget(1000, 1000), true);
    });

    testWidgets('formats large rupee amounts with Indian grouping',
        (tester) async {
      await _configWithBudget(200000);

      await tester.pumpWidget(
        _budget(
          expense: 130400,
          breakdown: const CategoryBreakdown(
            totalExpense: 130400,
            groups: [
              CategoryGroup(
                  tagIds: {'rent'},
                  label: 'Rent',
                  amount: 130400,
                  percent: 100),
            ],
          ),
        ),
      );

      expect(
        find.text('₹1,30,400 of ₹2,00,000 · ₹69,600 left'),
        findsOneWidget,
      );
      expect(find.text('65.2% used'), findsOneWidget);
    });

    testWidgets('states spent, budget, utilisation, and category splits '
        'in semantics with decorative segments excluded', (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(expense: 600, breakdown: _threeUnder),
      );

      expect(
        find.bySemanticsLabel(
          'Monthly budget, ₹600 spent of ₹1,000, 60.0% used, ₹400 left. '
          'By category: Food, ₹300. Transport, ₹200. Shopping, ₹100.',
        ),
        findsOneWidget,
      );
      // The bar itself is decorative: the section is wrapped in ExcludeSemantics.
      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('renders at 320dp without overflow', (tester) async {
      await setSurface(tester, kNarrowSurface);
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(expense: 600, breakdown: _threeUnder),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('60.0% used'), findsOneWidget);
    });

    testWidgets('renders at large text scale without overflow', (tester) async {
      await setSurface(tester, kNarrowSurface);
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(expense: 600, breakdown: _threeUnder, textScale: 2.0),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('60.0% used'), findsOneWidget);
    });

    testWidgets('renders in the dark theme without error', (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(expense: 600, breakdown: _threeUnder, dark: true),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('60.0% used'), findsOneWidget);
    });

    testWidgets('Edit action opens the shared monthly budget dialog',
        (tester) async {
      await _configWithBudget(1000);

      await tester.pumpWidget(
        _budget(expense: 600, breakdown: _threeUnder),
      );

      await tester.tap(find.widgetWithText(TextButton, 'Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Budget'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });
  });
  */
}
