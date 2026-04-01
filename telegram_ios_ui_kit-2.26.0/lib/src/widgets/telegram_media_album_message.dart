import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramMediaAlbumMessage extends StatelessWidget {
  const TelegramMediaAlbumMessage({
    super.key,
    required this.items,
    required this.timeLabel,
    this.caption,
    this.isOutgoing = false,
    this.crossAxisCount = 2,
    this.onItemTap,
  });

  final List<String> items;
  final String timeLabel;
  final String? caption;
  final bool isOutgoing;
  final int crossAxisCount;
  final ValueChanged<int>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    final bubbleColor = isOutgoing
        ? theme.colors.outgoingBubbleColor
        : theme.colors.incomingBubbleColor;
    final effectiveCrossAxisCount = crossAxisCount.clamp(1, 4).toInt();
    final ratio = items.length == 1 ? 1.7 : 1.0;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 302),
        child: Container(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
          ),
          padding: const EdgeInsets.all(TelegramSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: effectiveCrossAxisCount,
                  mainAxisSpacing: TelegramSpacing.xs,
                  crossAxisSpacing: TelegramSpacing.xs,
                  childAspectRatio: ratio,
                ),
                itemBuilder: (context, index) {
                  return _AlbumItem(
                    label: items[index],
                    onTap: onItemTap == null ? null : () => onItemTap!(index),
                  );
                },
              ),
              if (caption != null) ...[
                const SizedBox(height: TelegramSpacing.s),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.xs,
                  ),
                  child: Text(
                    caption!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.textColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: TelegramSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TelegramSpacing.xs,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    timeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumItem extends StatelessWidget {
  const _AlbumItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              theme.colors.linkColor.withValues(alpha: 0.3),
              theme.colors.onlineIndicatorColor.withValues(alpha: 0.28),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colors.buttonTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
