/// Formats [amount] as a rupee amount using Indian digit grouping
/// (e.g. 1234567 -> "₹12,34,567"), matching the grouping produced by the
/// native widget's `NumberFormat.getNumberInstance(Locale("en", "IN"))` in
/// SpendWidgetProvider.kt. Keep both in sync if the format ever changes.
///
/// Rounds to the nearest whole rupee — this app does not display paise.
String formatRupees(double amount) {
  final rounded = amount.round();
  final sign = rounded < 0 ? '-' : '';
  final digits = rounded.abs().toString();

  if (digits.length <= 3) {
    return '$sign₹$digits';
  }

  final lastThree = digits.substring(digits.length - 3);
  final rest = digits.substring(0, digits.length - 3);
  return '$sign₹${_groupInPairs(rest)},$lastThree';
}

/// Groups [digits] into comma-separated pairs starting from the right,
/// e.g. "1234" -> "12,34", "123" -> "1,23".
String _groupInPairs(String digits) {
  final groups = <String>[];
  var remaining = digits;
  while (remaining.length > 2) {
    groups.insert(0, remaining.substring(remaining.length - 2));
    remaining = remaining.substring(0, remaining.length - 2);
  }
  if (remaining.isNotEmpty) {
    groups.insert(0, remaining);
  }
  return groups.join(',');
}
