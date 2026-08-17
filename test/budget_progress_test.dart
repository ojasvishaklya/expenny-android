import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/widgets/BudgetProgressWidget.dart';

/// Covers the pure budget helpers.
///
/// Widget-level coverage of [BudgetProgressWidget] is deliberately omitted:
/// seeding a budget goes through `ConfigService.setMonthlyBudget`, which calls
/// `WidgetService.updateBudgetWidget()` and awaits `home_widget` platform
/// channels that never complete under `flutter_test`, hanging the run. The
/// no-budget rendering path is still exercised through the dashboard screen
/// tests, and the arithmetic below is what the widget displays.
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

  group('formatBudgetLabel', () {
    test('formats expense and budget with rupee symbol and Indian grouping',
        () {
      expect(formatBudgetLabel(12000, 50000), '₹12,000 / ₹50,000');
    });

    test('formats zero expense', () {
      expect(formatBudgetLabel(0, 50000), '₹0 / ₹50,000');
    });

    test('rounds to integer', () {
      expect(formatBudgetLabel(12345.67, 50000.99), '₹12,346 / ₹50,001');
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
      // 13,040 of 20,000 is the figure shown in the budget panel.
      expect(budgetUsedPercent(13040, 20000), closeTo(65.2, 0.001));
    });
  });

  group('formatBudgetRemainder', () {
    test('reports what is left when under budget', () {
      expect(formatBudgetRemainder(12000, 50000), '₹38,000 left');
    });

    test('reports zero left when exactly on budget', () {
      expect(formatBudgetRemainder(50000, 50000), '₹0 left');
    });

    test('reports the overage when over budget', () {
      expect(formatBudgetRemainder(52000, 50000), '₹2,000 over');
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
}
