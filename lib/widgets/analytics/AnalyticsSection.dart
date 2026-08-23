import 'package:flutter/material.dart';

/// Shared radius and padding for dashboard panels, taken as direction from the
/// dashboard mockup rather than as a pixel-exact reproduction.
///
/// [kAnalyticsPanelRadius] is the single control for every analytics panel's
/// corner radius: change it here and all panels round consistently through
/// their shared `BorderRadius.circular(kAnalyticsPanelRadius)` usage.
const double kAnalyticsPanelRadius = 8;
const double kAnalyticsPanelPadding = 16;

/// Width of the thin outline drawn around every [AnalyticsOutlinedPanel].
/// Tune this single value to make the border hairline-thin or more prominent.
const double kAnalyticsPanelBorderWidth = 0.5;

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
    this.keepTrailingInline = false,
  });

  final String title;

  /// Optional trailing detail shown beside the heading, such as a total or a
  /// range. It stacks below the heading when space or text scale demands it.
  final Widget? trailing;

  /// When true, [trailing] always stays on the heading line and never stacks
  /// below the title at large text scales. The budget header opts in so its
  /// fixed-width Edit action stays pinned to the far right; every other caller
  /// keeps the default adaptive stacking behaviour.
  final bool keepTrailingInline;

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
    // narrow widths or large text scales, so stack them when either is tight —
    // unless the caller opts to keep the trailing widget inline.
    final shouldStack = !keepTrailingInline &&
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: heading),
          const SizedBox(width: 8),
          Align(
            alignment: Alignment.centerRight,
            child: trailing!,
          ),
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

/// A thin, unelevated outlined container for dashboard section content.
///
/// The panel carries no shadow; it is set apart by a hairline
/// `colors.outlineVariant` border (see [kAnalyticsPanelBorderWidth]) and its
/// rounded corners alone, so the dashboard stays calm and flat in both light
/// and dark themes.
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
            border: Border.all(
              color: colors.outlineVariant,
              width: kAnalyticsPanelBorderWidth,
            ),
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
