import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramNoticeBanner extends StatelessWidget {
  const TelegramNoticeBanner({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onTap,
    this.onClose,
    this.actionLabel,
    this.onActionTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: TelegramSpacing.l,
      vertical: TelegramSpacing.s,
    ),
    this.margin = const EdgeInsets.all(TelegramSpacing.l),
    this.backgroundColor,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final bannerColor =
        backgroundColor ?? theme.colors.linkColor.withValues(alpha: 0.1);

    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colors.linkColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: theme.colors.linkColor),
              const SizedBox(width: TelegramSpacing.s),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TelegramSpacing.xxs),
                  ],
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colors.textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: TelegramSpacing.s),
              TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colors.linkColor,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.s,
                    vertical: TelegramSpacing.xxs,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.linkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (onClose != null) ...[
              const SizedBox(width: TelegramSpacing.xs),
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
          ],
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }
    return GestureDetector(onTap: onTap, child: content);
  }
}
