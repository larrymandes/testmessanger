import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramPinnedMessageBar extends StatelessWidget {
  const TelegramPinnedMessageBar({
    super.key,
    required this.title,
    required this.message,
    this.onTap,
    this.onClose,
  });

  final String title;
  final String message;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Material(
      color: theme.colors.headerBgColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TelegramSpacing.l,
            vertical: TelegramSpacing.s,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.colors.separatorColor, width: 0.5),
              bottom: BorderSide(
                color: theme.colors.separatorColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  color: theme.colors.linkColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.linkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                onPressed: onClose,
                padding: EdgeInsets.zero,
                minimumSize: const Size(20, 20),
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 18,
                  color: theme.colors.subtitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
