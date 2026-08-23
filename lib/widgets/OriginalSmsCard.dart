import 'package:flutter/material.dart';

/// Read-only card showing the original bank SMS a transaction was imported
/// from, for user verification. Shown only in the edit flow when `rawSms` is
/// present.
class OriginalSmsCard extends StatelessWidget {
  const OriginalSmsCard({
    super.key,
    required this.rawSms,
    this.bank,
  });

  final String rawSms;
  final String? bank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.hoverColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sms_outlined, size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 7),
              Text(
                (bank == null || bank!.isEmpty) ? 'Original message' : bank!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rawSms,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
