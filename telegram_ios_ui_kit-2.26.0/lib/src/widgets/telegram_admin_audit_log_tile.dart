import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_admin_audit_log.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramAdminAuditLogTile extends StatelessWidget {
  const TelegramAdminAuditLogTile({
    super.key,
    required this.entry,
    this.onTap,
    this.showDivider = true,
  });

  final TelegramAdminAuditLog entry;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final accentColor = entry.highPriority
        ? theme.colors.destructiveTextColor
        : theme.colors.linkColor;
    final icon = entry.icon ?? CupertinoIcons.doc_text_fill;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.l,
          vertical: TelegramSpacing.m,
        ),
        decoration: BoxDecoration(
          color: theme.colors.sectionBgColor,
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: theme.colors.separatorColor,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15, color: accentColor),
            ),
            const SizedBox(width: TelegramSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.actorName} ${entry.actionLabel}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (entry.targetLabel != null &&
                      entry.targetLabel!.trim().isNotEmpty) ...[
                    const SizedBox(height: TelegramSpacing.xxs),
                    Text(
                      entry.targetLabel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.timeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colors.subtitleTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: TelegramSpacing.xs),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 14,
                  color: theme.colors.subtitleTextColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
