import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_media_item.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramMediaGrid extends StatelessWidget {
  const TelegramMediaGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 3,
    this.onItemTap,
  });

  final List<TelegramMediaItem> items;
  final int crossAxisCount;
  final ValueChanged<TelegramMediaItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: TelegramSpacing.s,
        mainAxisSpacing: TelegramSpacing.s,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onItemTap == null ? null : () => onItemTap!(item),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colors.secondaryBgColor,
              borderRadius: BorderRadius.circular(10),
              image: item.image == null
                  ? null
                  : DecorationImage(image: item.image!, fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                if (item.image == null)
                  Center(
                    child: Icon(
                      CupertinoIcons.photo,
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                if (item.label != null)
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 6,
                    child: Text(
                      item.label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                if (item.isVideo)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.durationLabel ?? '0:00',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
