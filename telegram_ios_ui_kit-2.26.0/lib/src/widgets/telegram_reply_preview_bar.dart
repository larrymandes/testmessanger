import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramReplyPreviewBar extends StatelessWidget {
  const TelegramReplyPreviewBar({
    super.key,
    required this.author,
    required this.message,
    this.title = 'Replying to',
    this.leadingIcon,
    this.accentColor,
    this.onTap,
    this.onClose,
  });

  final String author;
  final String message;
  final String title;
  final IconData? leadingIcon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final markerColor = accentColor ?? theme.colors.linkColor;
    final content = Container(
      color: theme.colors.headerBgColor,
      padding: const EdgeInsets.fromLTRB(
        TelegramSpacing.m,
        TelegramSpacing.s,
        TelegramSpacing.s,
        TelegramSpacing.s,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            margin: const EdgeInsets.only(right: TelegramSpacing.s),
            decoration: BoxDecoration(
              color: markerColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 16, color: markerColor),
            const SizedBox(width: TelegramSpacing.s),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$title $author',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: markerColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TelegramSpacing.xxs),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colors.subtitleTextColor,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            CupertinoButton(
              minimumSize: const Size.square(24),
              padding: EdgeInsets.zero,
              onPressed: onClose,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 18,
                color: theme.colors.subtitleTextColor,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return GestureDetector(onTap: onTap, child: content);
  }
}
