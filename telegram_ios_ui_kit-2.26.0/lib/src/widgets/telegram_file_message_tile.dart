import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramFileMessageTile extends StatelessWidget {
  const TelegramFileMessageTile({
    super.key,
    required this.fileName,
    required this.fileSizeLabel,
    required this.timeLabel,
    this.extension = 'DOC',
    this.caption,
    this.isOutgoing = false,
    this.downloadProgress,
    this.onTap,
  });

  final String fileName;
  final String fileSizeLabel;
  final String timeLabel;
  final String extension;
  final String? caption;
  final bool isOutgoing;
  final double? downloadProgress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final bubbleColor = isOutgoing
        ? theme.colors.outgoingBubbleColor
        : theme.colors.incomingBubbleColor;
    final progressValue = downloadProgress?.clamp(0.0, 1.0);

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 290),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme.colors.linkColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          extension.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colors.linkColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: TelegramSpacing.s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colors.textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: TelegramSpacing.xxs),
                            Text(
                              fileSizeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colors.subtitleTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.arrow_down_circle_fill,
                        size: 18,
                        color: theme.colors.linkColor,
                      ),
                    ],
                  ),
                  if (progressValue != null) ...[
                    const SizedBox(height: TelegramSpacing.s),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        value: progressValue,
                        valueColor: AlwaysStoppedAnimation(theme.colors.linkColor),
                        backgroundColor: theme.colors.separatorColor,
                      ),
                    ),
                  ],
                  if (caption != null) ...[
                    const SizedBox(height: TelegramSpacing.s),
                    Text(
                      caption!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.textColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: TelegramSpacing.s),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      timeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
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
