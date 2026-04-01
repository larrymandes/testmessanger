import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramSettingsAccountCard extends StatelessWidget {
  const TelegramSettingsAccountCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.detail,
    this.avatarImage,
    this.avatarFallback = '',
    this.badgeLabel,
    this.onTap,
    this.showChevron = true,
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      TelegramSpacing.m,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final String name;
  final String subtitle;
  final String? detail;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final String? badgeLabel;
  final VoidCallback? onTap;
  final bool showChevron;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    return Padding(
      padding: margin,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.sectionBgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                TelegramSpacing.m,
                TelegramSpacing.m,
                TelegramSpacing.l,
                TelegramSpacing.m,
              ),
              child: Row(
                children: [
                  TelegramAvatar(
                    image: avatarImage,
                    fallbackText: avatarFallback.isNotEmpty
                        ? avatarFallback
                        : name,
                    size: 56,
                  ),
                  const SizedBox(width: TelegramSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: TelegramSpacing.xs),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.subtitleTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (detail != null && detail!.isNotEmpty) ...[
                          const SizedBox(height: TelegramSpacing.xs),
                          Text(
                            detail!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.subtitleTextColor.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: TelegramSpacing.s),
                  if (badgeLabel != null && badgeLabel!.isNotEmpty) ...[
                    _Badge(label: badgeLabel!),
                    const SizedBox(width: TelegramSpacing.s),
                  ],
                  if (showChevron)
                    Icon(
                      CupertinoIcons.chevron_forward,
                      size: 16,
                      color: colors.subtitleTextColor,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.linkColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.s,
          vertical: TelegramSpacing.xxs,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colors.linkColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
