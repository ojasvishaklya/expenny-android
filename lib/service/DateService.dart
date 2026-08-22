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
}
