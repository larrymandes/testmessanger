import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_admin_member.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';
import 'telegram_badge.dart';

class TelegramAdminMemberTile extends StatelessWidget {
  const TelegramAdminMemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.showDivider = true,
  });

  final TelegramAdminMember member;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final roleColor = member.isOwner
        ? theme.colors.linkColor
        : theme.colors.subtitleTextColor;
    final subtitle = _resolveSubtitle();

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
          children: [
            TelegramAvatar(
              image: member.avatarImage,
              fallbackText: member.avatarFallback.isNotEmpty
                  ? member.avatarFallback
                  : member.name,
              size: 40,
              isOnline: member.isOnline,
            ),
            const SizedBox(width: TelegramSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (member.isBot) ...[
                        const SizedBox(width: TelegramSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TelegramSpacing.xs,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colors.secondaryBgColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'BOT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colors.subtitleTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: TelegramSpacing.xxs),
                    Text(
                      subtitle,
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
                  member.roleLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: roleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (member.pendingReports > 0) ...[
                  const SizedBox(height: TelegramSpacing.xs),
                  TelegramBadge(count: member.pendingReports, maxCount: 999),
                ],
              ],
            ),
            const SizedBox(width: TelegramSpacing.xs),
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

  String? _resolveSubtitle() {
    final base = member.lastSeenLabel?.trim();
    if (member.isOnline) {
      if (base == null || base.isEmpty) {
        return 'online';
      }
      return 'online · $base';
    }
    if (base != null && base.isNotEmpty) {
      return base;
    }
    return null;
  }
}
