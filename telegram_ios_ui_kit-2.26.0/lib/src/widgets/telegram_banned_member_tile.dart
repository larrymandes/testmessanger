import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_banned_member.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramBannedMemberTile extends StatelessWidget {
  const TelegramBannedMemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onUnban,
    this.showDivider = true,
    this.unbanLabel = 'Unban',
  });

  final TelegramBannedMember member;
  final VoidCallback? onTap;
  final VoidCallback? onUnban;
  final bool showDivider;
  final String unbanLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final restrictedByText = member.restrictedBy?.trim();

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
            TelegramAvatar(
              image: member.avatarImage,
              fallbackText: member.avatarFallback.isNotEmpty
                  ? member.avatarFallback
                  : member.name,
              size: 38,
            ),
            const SizedBox(width: TelegramSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TelegramSpacing.xxs),
                  Text(
                    member.reasonLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.destructiveTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TelegramSpacing.xxs),
                  Text(
                    member.untilLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                  if (restrictedByText != null &&
                      restrictedByText.isNotEmpty) ...[
                    const SizedBox(height: TelegramSpacing.xxs),
                    Text(
                      'By $restrictedByText',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            if (onUnban != null)
              CupertinoButton(
                minimumSize: const Size(24, 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: TelegramSpacing.s,
                  vertical: TelegramSpacing.xs,
                ),
                color: theme.colors.linkColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                onPressed: onUnban,
                child: Text(
                  unbanLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.linkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Icon(
                CupertinoIcons.chevron_forward,
                size: 15,
                color: theme.colors.subtitleTextColor,
              ),
          ],
        ),
      ),
    );
  }
}
