import 'package:flutter/material.dart';

/// Consistent wrapper for the analytics screen's sections: a small title
/// followed by content, separated from neighbouring sections by whitespace
/// rather than cards or shadows.
class AnalyticsSection extends StatelessWidget {
  final String title;

  /// Optional trailing widget shown on the title row, e.g. a total.
  final Widget? trailing;

  final Widget child;

  const AnalyticsSection({
    Key? key,
    required this.title,
    required this.child,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Short explanatory text shown in place of a section's content when there is
/// nothing to display for the selected month.
class AnalyticsEmptyHint extends StatelessWidget {
  final String message;

  const AnalyticsEmptyHint({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
