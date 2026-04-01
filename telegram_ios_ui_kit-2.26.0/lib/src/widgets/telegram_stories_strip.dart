import 'package:flutter/material.dart';

import '../models/telegram_story.dart';
import '../theme/telegram_spacing.dart';
import 'telegram_story_avatar.dart';

class TelegramStoriesStrip extends StatelessWidget {
  const TelegramStoriesStrip({
    super.key,
    required this.stories,
    this.onStoryTap,
    this.padding = const EdgeInsets.symmetric(horizontal: TelegramSpacing.l),
  });

  final List<TelegramStory> stories;
  final ValueChanged<TelegramStory>? onStoryTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: stories.length,
        separatorBuilder: (_, index) =>
            const SizedBox(width: TelegramSpacing.m),
        itemBuilder: (context, index) {
          final story = stories[index];
          return TelegramStoryAvatar(
            story: story,
            onTap: onStoryTap == null ? null : () => onStoryTap!(story),
          );
        },
      ),
    );
  }
}
