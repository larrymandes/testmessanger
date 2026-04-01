import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_search_result.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';
import 'telegram_highlighted_text.dart';

class TelegramSearchResultTile extends StatelessWidget {
  const TelegramSearchResultTile({
    super.key,
    required this.result,
    this.onTap,
    this.showDivider = true,
    this.highlightQuery = '',
  });

  final TelegramSearchResult result;
  final VoidCallback? onTap;
  final bool showDivider;
  final String highlightQuery;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final subtitle = result.subtitle?.trim();
    final sectionLabel = result.sectionLabel?.trim();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.l,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TelegramAvatar(
              image: result.avatarImage,
              fallbackText: result.avatarFallback.isNotEmpty
                  ? result.avatarFallback
                  : result.title,
              size: 38,
            ),
            const SizedBox(width: TelegramSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TelegramHighlightedText(
                                text: result.title,
                                query: highlightQuery,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colors.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                highlightStyle: theme.textTheme.titleMedium
                                    ?.copyWith(
                                      color: theme.colors.linkColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            if (result.isVerified) ...[
                              const SizedBox(width: TelegramSpacing.xs),
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                size: 15,
                                color: theme.colors.linkColor,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (result.timeLabel.trim().isNotEmpty) ...[
                        const SizedBox(width: TelegramSpacing.s),
                        Text(
                          result.timeLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colors.subtitleTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: TelegramSpacing.xxs),
                    TelegramHighlightedText(
                      text: subtitle,
                      query: highlightQuery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.linkColor,
                        fontWeight: FontWeight.w600,
                      ),
                      highlightStyle: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.linkColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  if (sectionLabel != null && sectionLabel.isNotEmpty) ...[
                    const SizedBox(height: TelegramSpacing.xxs),
                    TelegramHighlightedText(
                      text: sectionLabel,
                      query: highlightQuery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                      highlightStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.linkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: TelegramSpacing.xxs),
                  TelegramHighlightedText(
                    text: result.snippet,
                    query: highlightQuery,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.textColor,
                      height: 1.28,
                    ),
                    highlightStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.linkColor,
                      fontWeight: FontWeight.w700,
                      height: 1.28,
                    ),
                  ),
                ],
              ),
            ),
            if (result.unreadCount > 0) ...[
              const SizedBox(width: TelegramSpacing.s),
              _UnreadBadge(unreadCount: result.unreadCount),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colors.linkColor,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colors.buttonTextColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
