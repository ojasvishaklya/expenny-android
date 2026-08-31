class DateService {
  // List of month names
  static List<String> monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String humanReadableDate(DateTime date) {
    DateTime now = DateTime.now();

    if (date.year == now.year) {
      if (date.month == now.month && date.day == now.day) {
        return 'Today'; // Return "Today" for the current day
      } else {
        return '${monthNames[date.month]} ${date.day}'; // Return "Month Date" for the current year
      }
    } else {
      return '${monthNames[date.month]} ${date.day} ${date.year}'; // Return "Month Date Year" for different year
    }
  }

  static DateTime getFirstDayOfCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Three-letter abbreviation for a 1-indexed [month], e.g. 1 -> 'Jan'.
  static String monthAbbreviation(int month) =>
      monthNames[month].substring(0, 3);

  /// Full month name with year, e.g. 'August 2026'. Used for accessible labels
  /// and headings where the period must be unambiguous.
  static String monthYear(DateTime date) =>
      '${monthNames[date.month]} ${date.year}';

  /// Abbreviated month with year, e.g. 'Aug 2026'. Used where space is tight
  /// but year context must remain visible, such as month chips.
  static String shortMonthYear(DateTime date) =>
      '${monthAbbreviation(date.month)} ${date.year}';

  /// Whether [a] and [b] fall in the same calendar month, ignoring day.
  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static getFormattedPeriodString(DateTime date) {
    String monthName = DateService.monthNames[date.month];
    String year = date.year.toString();
    return monthName.toUpperCase().split('').join(' ') +
        '  ' +
        year.toUpperCase().split('').join(' ');
  }

  /// Formats the time-of-day of [date] as a 12-hour clock string, e.g.
  /// `1:24 PM`. Midnight renders as `12:00 AM` and noon as `12:00 PM`.
  /// Used for the trailing time under a transaction amount.
  static String formatTime(DateTime date) {
    final period = date.hour < 12 ? 'AM' : 'PM';
    int hour12 = date.hour % 12;
    if (hour12 == 0) hour12 = 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  /// The heading shown above a day's transactions in the grouped ledger.
  ///
  /// Returns `Today` for [now]'s calendar day, `12 August` for another day in
  /// the same year, and `12 August 2025` for a day in a different year — the
  /// year is only added when it would otherwise be ambiguous. [now] defaults
  /// to the system clock but is injectable for tests.
  static String dateGroupLabel(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }
    if (date.year == today.year) {
      return '${date.day} ${monthNames[date.month]}';
    }
    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  /// A stable calendar-day key for grouping transactions, e.g. `2026-08-12`.
  /// Independent of time-of-day so all of a day's transactions share a group.
  static String dateGroupKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
