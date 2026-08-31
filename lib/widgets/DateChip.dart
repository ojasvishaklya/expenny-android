import 'package:flutter/material.dart';
import 'package:expenny/service/DateService.dart';

/// A chip showing the transaction date (e.g. `Today`, `12 August`, optionally
/// with the time) that opens the platform date picker on tap.
///
/// Reports the chosen day via [onChanged]; if the user dismisses the picker the
/// callback is not fired.
class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    required this.onChanged,
    this.showTime = false,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  /// When true, appends the time-of-day (used in the edit flow).
  final bool showTime;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Preserve the original time-of-day; only the calendar day changes.
      onChanged(DateTime(
        picked.year,
        picked.month,
        picked.day,
        date.hour,
        date.minute,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = showTime
        ? '${DateService.humanReadableDate(date)} · ${DateService.formatTime(date)}'
        : DateService.humanReadableDate(date);

    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: colors.outlineVariant)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
