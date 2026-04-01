import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_message.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramChatBubble extends StatelessWidget {
  const TelegramChatBubble({
    super.key,
    required this.message,
    this.maxWidth = 0.78,
    this.animateStatus = true,
  });

  final TelegramMessage message;
  final double maxWidth;
  final bool animateStatus;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final align = message.isOutgoing
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;
    final bgColor = message.isOutgoing
        ? colors.outgoingBubbleColor
        : colors.incomingBubbleColor;
    final fgColor =
        message.isOutgoing && Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : colors.textColor;

    return Row(
      mainAxisAlignment: align,
      children: [
        Flexible(
          child: FractionallySizedBox(
            widthFactor: maxWidth,
            alignment: message.isOutgoing
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: TelegramSpacing.xs),
              padding: const EdgeInsets.fromLTRB(
                TelegramSpacing.m,
                TelegramSpacing.s,
                TelegramSpacing.m,
                TelegramSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(theme.messageBubbleRadius.x),
                  topRight: Radius.circular(theme.messageBubbleRadius.x),
                  bottomLeft: Radius.circular(
                    message.isOutgoing ? theme.messageBubbleRadius.x : 4,
                  ),
                  bottomRight: Radius.circular(
                    message.isOutgoing ? 4 : theme.messageBubbleRadius.x,
                  ),
                ),
                border: Border.all(
                  width: Theme.of(context).brightness == Brightness.dark
                      ? 0
                      : 0.4,
                  color: colors.separatorColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: fgColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: TelegramSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isEdited)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: TelegramSpacing.xs,
                          ),
                          child: Text(
                            'edited',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.subtitleTextColor,
                            ),
                          ),
                        ),
                      Text(
                        message.timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtitleTextColor,
                        ),
                      ),
                      if (message.isOutgoing)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: TelegramSpacing.xs,
                          ),
                          child: animateStatus
                              ? AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildStatusWidget(context),
                                )
                              : _buildStatusWidget(context),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _statusIcon(TelegramMessageStatus status) {
    switch (status) {
      case TelegramMessageStatus.sending:
        return CupertinoIcons.time;
      case TelegramMessageStatus.sent:
        return CupertinoIcons.check_mark;
      case TelegramMessageStatus.delivered:
        return CupertinoIcons.check_mark_circled;
      case TelegramMessageStatus.read:
        return CupertinoIcons.check_mark_circled_solid;
    }
  }

  Widget _buildStatusWidget(BuildContext context) {
    final theme = context.telegramTheme;
    final color = message.status == TelegramMessageStatus.read
        ? theme.colors.linkColor
        : theme.colors.subtitleTextColor;
    if (message.status == TelegramMessageStatus.sending) {
      return CupertinoActivityIndicator(
        key: const ValueKey<String>('status_sending'),
        radius: 6,
      );
    }
    return Icon(
      _statusIcon(message.status),
      key: ValueKey<TelegramMessageStatus>(message.status),
      size: 14,
      color: color,
    );
  }
}
