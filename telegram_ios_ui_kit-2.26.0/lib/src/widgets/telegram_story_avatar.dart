import 'package:flutter/material.dart';

import '../models/telegram_story.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramStoryAvatar extends StatelessWidget {
  const TelegramStoryAvatar({
    super.key,
    required this.story,
    this.size = 62,
    this.onTap,
    this.showTitle = true,
  });

  final TelegramStory story;
  final double size;
  final VoidCallback? onTap;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final ring = story.hasUnseenStories
        ? [theme.colors.linkColor, theme.colors.onlineIndicatorColor]
        : [theme.colors.separatorColor, theme.colors.separatorColor];

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: ring),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colors.bgColor,
        ),
        padding: const EdgeInsets.all(2),
        child: TelegramAvatar(
          image: story.avatarImage,
          fallbackText: story.avatarFallback.isNotEmpty
              ? story.avatarFallback
              : story.title,
          size: size - 10,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          if (showTitle) ...[
            const SizedBox(height: TelegramSpacing.xs),
            SizedBox(
              width: size + 12,
              child: Text(
                story.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colors.textColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
