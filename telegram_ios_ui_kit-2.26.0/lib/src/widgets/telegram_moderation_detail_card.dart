import 'package:flutter/cupertino.dart';

import '../models/telegram_moderation_request.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramModerationDetailCard extends StatelessWidget {
  const TelegramModerationDetailCard({
    super.key,
    required this.request,
    this.tags = const [],
    this.evidenceCount = 0,
    this.approveLabel = 'Approve',
    this.rejectLabel = 'Reject',
    this.openThreadLabel = 'Open Thread',
    this.onApprove,
    this.onReject,
    this.onOpenThread,
  });

  final TelegramModerationRequest request;
  final List<String> tags;
  final int evidenceCount;
  final String approveLabel;
  final String rejectLabel;
  final String openThreadLabel;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onOpenThread;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final headerColor = request.highPriority
        ? theme.colors.destructiveTextColor
        : theme.colors.linkColor;
    final normalizedEvidenceCount = evidenceCount < 0 ? 0 : evidenceCount;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colors.separatorColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(TelegramSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: headerColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.exclamationmark_shield_fill,
                  size: 14,
                  color: headerColor,
                ),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Text(
                  request.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                request.timeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colors.subtitleTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: TelegramSpacing.s),
          Text(
            request.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colors.subtitleTextColor,
              height: 1.3,
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: TelegramSpacing.s),
            Wrap(
              spacing: TelegramSpacing.xs,
              runSpacing: TelegramSpacing.xs,
              children: [
                for (final tag in tags)
                  _TagChip(label: tag, accentColor: headerColor),
              ],
            ),
          ],
          if (normalizedEvidenceCount > 0) ...[
            const SizedBox(height: TelegramSpacing.s),
            Text(
              '$normalizedEvidenceCount attachments attached',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colors.subtitleTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: TelegramSpacing.m),
          Row(
            children: [
              _ActionButton(
                label: rejectLabel,
                icon: CupertinoIcons.xmark_circle_fill,
                color: theme.colors.destructiveTextColor,
                onPressed: onReject,
              ),
              const SizedBox(width: TelegramSpacing.s),
              _ActionButton(
                label: approveLabel,
                icon: CupertinoIcons.check_mark_circled_solid,
                color: theme.colors.linkColor,
                onPressed: onApprove,
              ),
              const Spacer(),
              CupertinoButton(
                minimumSize: const Size(24, 24),
                padding: EdgeInsets.zero,
                onPressed: onOpenThread,
                child: Text(
                  openThreadLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.linkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return CupertinoButton(
      minimumSize: const Size(24, 24),
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.xs,
      ),
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: TelegramSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
