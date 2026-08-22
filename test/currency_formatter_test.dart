import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';

void main() {
  group('formatRupees', () {
    test('formats amounts under 1000 without grouping', () {
      expect(formatRupees(0), '₹0');
      expect(formatRupees(5), '₹5');
      expect(formatRupees(999), '₹999');
    });

    test('groups thousands with a single comma', () {
      expect(formatRupees(1000), '₹1,000');
      expect(formatRupees(12000), '₹12,000');
      expect(formatRupees(999999), '₹9,99,999');
    });

    test('groups using Indian digit grouping (lakhs, crores)', () {
      expect(formatRupees(100000), '₹1,00,000');
      expect(formatRupees(1234567), '₹12,34,567');
      expect(formatRupees(10000000), '₹1,00,00,000');
    });

    test('rounds fractional amounts to the nearest rupee', () {
      expect(formatRupees(12345.67), '₹12,346');
      expect(formatRupees(50000.99), '₹50,001');
      expect(formatRupees(50000.49), '₹50,000');
    });

    test('handles negative amounts', () {
      expect(formatRupees(-500), '-₹500');
      expect(formatRupees(-12345), '-₹12,345');
    });
  });

  group('formatPercent', () {
    test('formats to a single decimal place', () {
      expect(formatPercent(0), '0.0%');
      expect(formatPercent(42.35), '42.4%');
      expect(formatPercent(100), '100.0%');
    });

    test('rounds to the nearest tenth', () {
      expect(formatPercent(33.333), '33.3%');
      expect(formatPercent(66.666), '66.7%');
    });

    test('handles negative percentages', () {
      expect(formatPercent(-12.5), '-12.5%');
    });

    test('renders non-finite values as zero', () {
      expect(formatPercent(double.nan), '0.0%');
      expect(formatPercent(double.infinity), '0.0%');
      expect(formatPercent(double.negativeInfinity), '0.0%');
    });

    test('allows values above 100 percent', () {
      expect(formatPercent(137.42), '137.4%');
    });
  });
}
