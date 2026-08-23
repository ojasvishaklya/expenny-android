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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      header: true,
      child: Text(
        title,
        // Title typography is matched to the mockup locally rather than
        // through the app-wide theme: Inter, 28px, the closest supported
        // weight to the mockup's 680 (w700), and a tight -0.04em tracking
        // (-1.12px at 28px). The onSurface colour and header semantics are
        // preserved.
        style: theme.textTheme.headlineSmall?.copyWith(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.12,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
