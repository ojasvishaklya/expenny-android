import 'package:flutter/material.dart';

/// The dashboard's title block.
///
/// Deliberately action-free: adding a transaction and editing the budget are
/// reached from their existing locations, so the header stays a heading rather
/// than a toolbar.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  /// Exact visible title for the dashboard.
  static const String title = 'Dashboard';

  /// Supporting line describing what the screen contains.
  static const String subtitle = 'Your monthly money story';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
