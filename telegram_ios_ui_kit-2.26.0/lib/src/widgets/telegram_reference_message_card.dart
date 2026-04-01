import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

enum TelegramReferenceMessageType { reply, forwarded }

class TelegramReferenceMessageCard extends StatelessWidget {
  const TelegramReferenceMessageCard({
    super.key,
    required this.sender,
    required this.message,
    this.type = TelegramReferenceMessageType.reply,
    this.timeLabel,
    this.isOutgoing = false,
    this.onTap,
  });

  final String sender;
  final String message;
  final TelegramReferenceMessageType type;
  final String? timeLabel;
  final bool isOutgoing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final bubbleColor = isOutgoing
        ? theme.colors.outgoingBubbleColor
        : theme.colors.incomingBubbleColor;
    final tag = type == TelegramReferenceMessageType.reply
        ? 'Reply to'
        : 'Forwarded from';
    final icon = type == TelegramReferenceMessageType.reply
        ? CupertinoIcons.reply
        : CupertinoIcons.arrowshape_turn_up_right;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 286),
        child: Material(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
          child: InkWell(
            borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TelegramSpacing.m,
                TelegramSpacing.s,
                TelegramSpacing.m,
                TelegramSpacing.s,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 38,
                    margin: const EdgeInsets.only(right: TelegramSpacing.s),
                    decoration: BoxDecoration(
                      color: theme.colors.linkColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 13,
                              color: theme.colors.linkColor,
                            ),
                            const SizedBox(width: TelegramSpacing.xs),
                            Flexible(
                              child: Text(
                                '$tag $sender',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colors.linkColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TelegramSpacing.xxs),
                        Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (timeLabel != null) ...[
                    const SizedBox(width: TelegramSpacing.s),
                    Text(
                      timeLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
