import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/service/DateService.dart';

void main() {
  group('DateService.formatTime', () {
    test('formats afternoon time in 12-hour clock', () {
      expect(DateService.formatTime(DateTime(2026, 8, 12, 13, 24)), '1:24 PM');
    });

    test('formats morning time with zero-padded minutes', () {
      expect(DateService.formatTime(DateTime(2026, 8, 12, 9, 8)), '9:08 AM');
    });

    test('midnight renders as 12:00 AM', () {
      expect(DateService.formatTime(DateTime(2026, 8, 12, 0, 0)), '12:00 AM');
    });

    test('noon renders as 12:00 PM', () {
      expect(DateService.formatTime(DateTime(2026, 8, 12, 12, 0)), '12:00 PM');
    });
  });

  group('DateService.dateGroupLabel', () {
    final now = DateTime(2026, 8, 23, 17, 3);

    test('returns Today for the current calendar day', () {
      expect(
        DateService.dateGroupLabel(DateTime(2026, 8, 23, 1, 15), now: now),
        'Today',
      );
    });

    test('returns "day month" for another day this year', () {
      expect(
        DateService.dateGroupLabel(DateTime(2026, 8, 12, 10, 2), now: now),
        '12 August',
      );
    });

    test('includes the year for a different year', () {
      expect(
        DateService.dateGroupLabel(DateTime(2025, 12, 31, 23, 0), now: now),
        '31 December 2025',
      );
    });

    test('same day-of-month in a different month is not Today', () {
      expect(
        DateService.dateGroupLabel(DateTime(2026, 7, 23), now: now),
        '23 July',
      );
    });
  });

  group('DateService.dateGroupKey', () {
    test('zero-pads month and day', () {
      expect(DateService.dateGroupKey(DateTime(2026, 8, 5)), '2026-08-05');
    });

    test('distinct days produce distinct keys, same day shares a key', () {
      final a = DateService.dateGroupKey(DateTime(2026, 8, 12, 1, 0));
      final b = DateService.dateGroupKey(DateTime(2026, 8, 12, 23, 0));
      final c = DateService.dateGroupKey(DateTime(2026, 8, 13, 0, 0));
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
