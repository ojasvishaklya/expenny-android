import 'package:expenny/constants/DesignTokens.dart';
import 'package:expenny/models/SyncResult.dart';
import 'package:expenny/service/ConfigService.dart';
import 'package:expenny/service/DataService.dart';
import 'package:expenny/service/DateService.dart';
import 'package:expenny/service/SmsSyncService.dart';
import 'package:expenny/utils/CurrencyFormatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/BudgetProgressWidget.dart';
import '../widgets/PopupWidget.dart';

/// The Preferences screen, grouped into five Material 3 sections: Appearance,
/// Planning, Automation, Data, and Danger zone.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isSyncing = false;

  // --- Actions --------------------------------------------------------------

  /// Flips the persisted dark-mode setting. Reads the current value from
  /// [ConfigService] rather than a passed argument, so the row tap and the
  /// Switch resolve to the same single toggle and cannot disagree.
  void _toggleDarkMode() {
    Get.find<ConfigService>().toggleDarkMode();
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    // Guard the whole pipeline: if syncFromSms throws, the finally block still
    // clears _isSyncing so the row can never stay stuck in the importing state.
    SyncResult? result;
    try {
      result = await Get.find<SmsSyncService>().syncFromSms();
    } catch (_) {
      result = null;
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }

    if (!mounted) return;

    if (result == null) {
      // The sync threw before returning a result.
      showSnackBar(
        context: context,
        textContent: 'Could not import messages. Please try again.',
        color: Theme.of(context).colorScheme.error,
        duration: 5,
      );
      return;
    }

    if (result.error == SyncError.permissionDenied) {
      showSnackBar(
        context: context,
        textContent:
            'SMS permission required. Enable in Settings → Apps → Expenny → Permissions',
        color: Theme.of(context).colorScheme.tertiary,
        duration: 5,
      );
    } else if (result.error == SyncError.pluginUnavailable) {
      showSnackBar(
        context: context,
        textContent: 'Could not import messages. Please try again.',
        color: Theme.of(context).colorScheme.error,
        duration: 5,
      );
    } else {
      showSnackBar(
        context: context,
        textContent: result.imported > 0
            ? 'Imported ${result.imported} new transactions'
            : 'No new transactions found',
        color: Theme.of(context).colorScheme.primary,
        duration: 3,
      );
    }
  }

  Future<void> _handleExport() async {
    final response = await DataService().exportToExcel();
    if (!mounted) return;
    if (response.isError) {
      showSnackBar(
        context: context,
        textContent: response.response,
        color: Theme.of(context).colorScheme.error,
        duration: 5,
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await _confirmDelete();
    if (confirmed != true) return;
    if (!mounted) return;

    final response = await DataService().deleteAllTransactions();
    if (!mounted) return;

    showSnackBar(
      context: context,
      textContent: response.response,
      color: response.isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      duration: 5,
    );
  }

  Future<bool?> _confirmDelete() {
    final colors = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Are you sure you want to delete all data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('delete'),
          ),
        ],
      ),
    );
  }

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Preferences',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // --- Appearance ------------------------------------------------------
        const _SectionLabel('Appearance'),
        _SectionCard(
          children: [
            Obx(() {
              final isDark = Get.find<ConfigService>().isDarkMode.value;
              return _PreferenceRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark mode',
                subtitle: 'Use a darker palette that is easier on the eyes',
                toggled: isDark,
                onTap: _toggleDarkMode,
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => _toggleDarkMode(),
                ),
              );
            }),
          ],
        ),

        // --- Planning --------------------------------------------------------
        const _SectionLabel('Planning'),
        _SectionCard(
          children: [
            Obx(() {
              final budget = Get.find<ConfigService>().monthlyBudget.value;
              final budgetLabel =
                  budget != null ? formatRupees(budget) : 'Set budget';
              return _PreferenceRow(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Monthly budget',
                subtitle: 'Set a spending target to track against each month',
                semanticValue: budgetLabel,
                onTap: () => showMonthlyBudgetDialog(context),
                trailing: _TrailingValue(budgetLabel),
              );
            }),
          ],
        ),

        // --- Automation ------------------------------------------------------
        const _SectionLabel('Automation'),
        _SectionCard(
          children: [
            Obx(() {
              final subtitle = _lastSyncedSubtitle(
                Get.find<ConfigService>().lastSyncedAt.value,
              );
              return _PreferenceRow(
                icon: Icons.sms_outlined,
                title: 'Import from Messages',
                subtitle: _isSyncing ? 'Importing…' : subtitle,
                enabled: !_isSyncing,
                onTap: _handleSync,
                trailing: _isSyncing
                    ? const _StatusBadge('Importing…')
                    : const Icon(Icons.chevron_right),
              );
            }),
          ],
        ),

        // --- Data ------------------------------------------------------------
        const _SectionLabel('Data'),
        _SectionCard(
          children: [
            _PreferenceRow(
              icon: Icons.file_upload_outlined,
              title: 'Import data',
              subtitle: 'Bring transactions from a file',
              semanticValue: 'Coming soon',
              enabled: false,
              trailing: const _StatusBadge('Coming soon'),
            ),
            const _RowDivider(),
            _PreferenceRow(
              icon: Icons.file_download_outlined,
              title: 'Export to Excel',
              subtitle: 'Save every transaction to a spreadsheet',
              onTap: _handleExport,
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),

        // --- Danger zone -----------------------------------------------------
        const _SectionLabel('Danger zone'),
        _SectionCard(
          error: true,
          children: [
            _PreferenceRow(
              icon: Icons.delete_outline,
              title: 'Delete all data',
              subtitle: 'Permanently remove every transaction and setting',
              error: true,
              onTap: _handleDelete,
            ),
          ],
        ),
      ],
    );
  }

  /// Reactive subtitle for the SMS import row, derived from the real persisted
  /// [ConfigService.lastSyncedAt]. Returns `Not synced yet` when the value is
  /// absent or unparsable; otherwise the formatted local clock time.
  String _lastSyncedSubtitle(String? raw) {
    if (raw == null) return 'Not synced yet';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return 'Not synced yet';
    return 'Last synced ${DateService.formatTime(parsed.toLocal())}';
  }
}

// --- Presentational helpers -------------------------------------------------

/// A section label above a group of preference rows, e.g. `Appearance`.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 4),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A rounded surface grouping one or more preference rows. When [error] is set
/// it adopts the error container palette to isolate destructive actions.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children, this.error = false});

  final List<Widget> children;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final border =
        error ? colors.error.withValues(alpha: 0.5) : colors.outlineVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kDesignBorderRadius),
        border: Border.all(
          color: border,
          width: kDesignBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// A hairline divider between rows within the same card.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color:
          Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

/// A single tappable preference row with a leading icon tile, a title, a
/// subtitle, and optional trailing content.
///
/// A disabled row ([enabled] false) drops its ripple, dims its content, and
/// exposes disabled semantics. When [error] is set the row uses the error
/// palette for its leading tile, title, and icon.
class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.semanticValue,
    this.toggled,
    this.enabled = true,
    this.error = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? semanticValue;
  final bool? toggled;
  final bool enabled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final Color foreground = error ? colors.error : colors.onSurface;
    final Color subtitleColor =
        error ? colors.error.withValues(alpha: 0.8) : colors.onSurfaceVariant;
    final Color iconTileColor = error
        ? colors.error.withValues(alpha: 0.12)
        : colors.primary.withValues(alpha: 0.12);
    final Color iconColor = error ? colors.error : colors.primary;

    final content = Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconTileColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subtitleColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              // Reserve enough room for the row text on narrow screens while
              // still fitting the Switch, badge, or current value.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 128),
                child: IconTheme.merge(
                  data: IconThemeData(color: colors.onSurfaceVariant),
                  child: trailing!,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final bool interactive = enabled && onTap != null;

    // Fold the title and subtitle into a single label and exclude the
    // descendant text nodes, so the row is announced once as a coherent unit
    // rather than reading the title twice and orphaning the subtitle. This
    // mirrors the convention used elsewhere in the package (e.g.
    // BudgetProgressWidget). The tap action lives on this node for interactive
    // rows since the descendant InkWell semantics are excluded.
    return Semantics(
      button: interactive,
      enabled: enabled,
      toggled: toggled,
      label: '$title. $subtitle',
      value: semanticValue,
      onTap: interactive ? onTap : null,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: interactive
              ? Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    child: content,
                  ),
                )
              : content,
        ),
      ),
    );
  }
}

/// A right-aligned trailing value with a chevron affordance, used for rows that
/// open an editor (e.g. the monthly budget).
class _TrailingValue extends StatelessWidget {
  const _TrailingValue(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      ],
    );
  }
}

/// A compact pill communicating a row's transient or unavailable state, e.g.
/// `Coming soon` or `Importing…`.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
