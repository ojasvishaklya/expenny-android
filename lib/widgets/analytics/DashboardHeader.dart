import 'package:flutter/material.dart';

/// The dashboard's title block.
///
/// Deliberately action-free: adding a transaction and editing the budget are
/// reached from their existing locations, so the header stays a heading rather
/// than a toolbar. An optional [subtitle] sits beneath the title as supporting
/// context; it is plain supporting text, not a second heading.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, this.subtitle});

  /// Exact visible title for the dashboard.
  static const String title = 'Dashboard';

  /// Optional supporting line shown beneath the title. Omitted entirely when
  /// null, leaving a title-only header.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final heading = Semantics(
      header: true,
      child: Text(
        title,
        // Title typography is matched to the mockup locally rather than
        // through the app-wide theme: 28px, the closest supported weight to
        // the mockup's 680 (w700), and a tight -0.04em tracking (-1.12px at
        // 28px). The onSurface colour and header semantics are preserved.
        style: theme.textTheme.headlineSmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.12,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );

    final subtitleText = subtitle;
    if (subtitleText == null) {
      return heading;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
        const SizedBox(height: 4),
        Text(
          subtitleText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
