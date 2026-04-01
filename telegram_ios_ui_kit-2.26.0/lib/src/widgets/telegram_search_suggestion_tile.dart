import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchSuggestionTile extends StatelessWidget {
  const TelegramSearchSuggestionTile({
    super.key,
    required this.query,
    this.subtitle,
    this.icon = CupertinoIcons.clock,
    this.onTap,
    this.onRemove,
    this.showDivider = true,
  });

  final String query;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final subtitleText = subtitle?.trim();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.m,
          vertical: TelegramSpacing.s,
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
            Icon(icon, size: 17, color: theme.colors.subtitleTextColor),
            const SizedBox(width: TelegramSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitleText != null && subtitleText.isNotEmpty) ...[
                    const SizedBox(height: TelegramSpacing.xxs),
                    Text(
                      subtitleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onRemove != null)
              CupertinoButton(
                minimumSize: const Size(20, 20),
                padding: EdgeInsets.zero,
                onPressed: onRemove,
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 16,
                  color: theme.colors.hintColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
