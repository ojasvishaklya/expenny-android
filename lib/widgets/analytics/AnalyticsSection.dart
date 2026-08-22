import 'package:flutter/material.dart';

/// Shared radius and padding for dashboard panels, taken as direction from the
/// dashboard mockup rather than as a pixel-exact reproduction.
const double kAnalyticsPanelRadius = 16;
const double kAnalyticsPanelPadding = 16;

/// Padding used when horizontal space is tight, so a panel keeps usable
/// content width at a 320 logical pixel viewport.
const double kAnalyticsPanelPaddingCompact = 12;

/// Text scale beyond which heading rows stack instead of sitting side by side.
const double kAnalyticsStackTextScale = 1.3;

/// A dashboard section: a sentence-case heading, an optional trailing detail,
/// and content that sits inside an [AnalyticsOutlinedPanel] by default.
///
/// Headings are rendered exactly as supplied — no uppercase transformation —
/// so callers control the wording and casing.
class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.outlined = true,
    this.semanticLabel,
  });

  final String title;

  /// Optional trailing detail shown beside the heading, such as a total or a
  /// range. It stacks below the heading when space or text scale demands it.
  final Widget? trailing;

  final Widget child;

  /// Whether [child] is wrapped in an [AnalyticsOutlinedPanel]. The summary
  /// hero sets this to false because it supplies its own container.
  final bool outlined;

  /// Optional container semantic label describing the whole section.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final heading = Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );

    // A plain Row cannot hold a long heading beside a long trailing value at
    // narrow widths or large text scales, so stack them when either is tight.
    final shouldStack =
        MediaQuery.textScalerOf(context).scale(1) > kAnalyticsStackTextScale;

    Widget headingRow;
    if (trailing == null) {
      headingRow = heading;
    } else if (shouldStack) {
      headingRow = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: 4),
          trailing!,
        ],
      );
    } else {
      headingRow = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          const SizedBox(width: 8),
          Flexible(child: trailing!),
        ],
      );
    }

    final panel = outlined ? AnalyticsOutlinedPanel(child: child) : child;

    // The label describes the section's content, so it wraps only the content.
    // Wrapping the heading too would merge the heading text into the label and
    // leave the heading unreadable as its own node.
    final labelledPanel = semanticLabel == null
        ? panel
        : Semantics(
            container: true,
            label: semanticLabel,
            child: panel,
          );

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headingRow,
          const SizedBox(height: 10),
          labelledPanel,
        ],
      ),
    );
  }
}

/// A bordered, unelevated container for dashboard section content.
///
/// Sections are separated by outline and whitespace rather than shadow, so the
/// dashboard reads as one calm surface in both light and dark themes.
class AnalyticsOutlinedPanel extends StatelessWidget {
  const AnalyticsOutlinedPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 340
            ? kAnalyticsPanelPaddingCompact
            : kAnalyticsPanelPadding;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(kAnalyticsPanelRadius),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: child,
        );
      },
    );
  }
}

/// Short explanatory text shown in place of a section's content when there is
/// nothing to display for the selected month.
class AnalyticsEmptyHint extends StatelessWidget {
  const AnalyticsEmptyHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
