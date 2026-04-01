import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_chat_preview.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';
import 'telegram_badge.dart';

class TelegramChatListTile extends StatelessWidget {
  const TelegramChatListTile({super.key, required this.chat, this.onTap});

  final TelegramChatPreview chat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.tileRadius.x),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.l,
          vertical: TelegramSpacing.s,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TelegramAvatar(
              image: chat.avatarImage,
              fallbackText: chat.avatarFallback.isNotEmpty
                  ? chat.avatarFallback
                  : chat.title,
              size: 52,
              isOnline: chat.isOnline,
            ),
            const SizedBox(width: TelegramSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: TelegramSpacing.s),
                      Text(
                        chat.timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colors.subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TelegramSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colors.subtitleTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: TelegramSpacing.s),
                      if (chat.isPinned)
                        Icon(
                          CupertinoIcons.pin_fill,
                          size: 14,
                          color: theme.colors.subtitleTextColor,
                        ),
                      if (chat.isMuted)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: TelegramSpacing.xs,
                          ),
                          child: Icon(
                            CupertinoIcons.bell_slash_fill,
                            size: 14,
                            color: theme.colors.subtitleTextColor,
                          ),
                        ),
                      if (chat.unreadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: TelegramSpacing.s,
                          ),
                          child: TelegramBadge(count: chat.unreadCount),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
