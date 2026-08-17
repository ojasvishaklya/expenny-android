import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/widgets/BudgetProgressWidget.dart';

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
    test('formats expense and budget with rupee symbol', () {
      expect(formatBudgetLabel(12000, 50000), '₹12000 / ₹50000');
    });

    test('formats zero expense', () {
      expect(formatBudgetLabel(0, 50000), '₹0 / ₹50000');
    });

    test('rounds to integer', () {
      expect(formatBudgetLabel(12345.67, 50000.99), '₹12346 / ₹50001');
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
  });
}
