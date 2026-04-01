import 'package:flutter/material.dart';

import '../models/telegram_link_preview.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramLinkPreviewCard extends StatelessWidget {
  const TelegramLinkPreviewCard({
    super.key,
    required this.preview,
    this.isOutgoing = false,
    this.maxWidth = 300,
    this.onTap,
  });

  final TelegramLinkPreview preview;
  final bool isOutgoing;
  final double maxWidth;
  final VoidCallback? onTap;

  String _resolveDomain() {
    if (preview.domain != null && preview.domain!.trim().isNotEmpty) {
      return preview.domain!;
    }
    final uri = Uri.tryParse(preview.url);
    if (uri == null || uri.host.isEmpty) {
      return preview.url;
    }
    return uri.host;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final bubbleColor = isOutgoing
        ? theme.colors.outgoingBubbleColor
        : theme.colors.incomingBubbleColor;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
          child: InkWell(
            borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(TelegramSpacing.m),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 68,
                    margin: const EdgeInsets.only(right: TelegramSpacing.s),
                    decoration: BoxDecoration(
                      color: theme.colors.linkColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  if (preview.thumbnailLabel != null) ...[
                    Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.only(right: TelegramSpacing.s),
                      decoration: BoxDecoration(
                        color: theme.colors.linkColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        preview.thumbnailLabel!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colors.linkColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (preview.siteName != null) ...[
                          Text(
                            preview.siteName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colors.linkColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: TelegramSpacing.xxs),
                        ],
                        Text(
                          preview.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: TelegramSpacing.xxs),
                        Text(
                          preview.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colors.subtitleTextColor,
                          ),
                        ),
                        const SizedBox(height: TelegramSpacing.s),
                        Text(
                          _resolveDomain(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colors.linkColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
