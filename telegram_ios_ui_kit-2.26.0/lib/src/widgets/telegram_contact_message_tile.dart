import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramContactMessageTile extends StatelessWidget {
  const TelegramContactMessageTile({
    super.key,
    required this.name,
    required this.phoneLabel,
    required this.timeLabel,
    this.avatarImage,
    this.avatarFallback = '',
    this.isOutgoing = false,
    this.actionLabel = 'Message',
    this.onTap,
    this.onActionTap,
  });

  final String name;
  final String phoneLabel;
  final String timeLabel;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final bool isOutgoing;
  final String actionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final bubbleColor = isOutgoing
        ? theme.colors.outgoingBubbleColor
        : theme.colors.incomingBubbleColor;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 292),
        child: Material(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
          child: InkWell(
            borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(TelegramSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TelegramAvatar(
                        image: avatarImage,
                        fallbackText: avatarFallback.isNotEmpty
                            ? avatarFallback
                            : name,
                        size: 44,
                      ),
                      const SizedBox(width: TelegramSpacing.s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colors.textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: TelegramSpacing.xxs),
                            Text(
                              phoneLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colors.subtitleTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TelegramSpacing.s),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onActionTap,
                          icon: const Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            size: 16,
                          ),
                          label: Text(actionLabel),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colors.linkColor,
                            side: BorderSide(
                              color: theme.colors.linkColor.withValues(
                                alpha: 0.25,
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: TelegramSpacing.s),
                      Text(
                        timeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colors.subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
