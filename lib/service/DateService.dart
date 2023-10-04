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

  static getFormattedPeriodString(DateTime date) {
    String monthName = DateService.monthNames[date.month];
    String year = date.year.toString();
    return monthName.toUpperCase().split('').join(' ') +
        '  ' +
        year.toUpperCase().split('').join(' ');
  }
}
