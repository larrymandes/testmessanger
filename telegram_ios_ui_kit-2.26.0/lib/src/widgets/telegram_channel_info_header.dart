import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

@immutable
class TelegramChannelInfoAction {
  const TelegramChannelInfoAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;
}

class TelegramChannelInfoHeader extends StatelessWidget {
  const TelegramChannelInfoHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.avatarImage,
    this.avatarFallback = '',
    this.isVerified = false,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final String? description;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final bool isVerified;
  final List<TelegramChannelInfoAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;

    return Container(
      color: theme.colors.sectionBgColor,
      padding: const EdgeInsets.fromLTRB(
        TelegramSpacing.l,
        TelegramSpacing.xl,
        TelegramSpacing.l,
        TelegramSpacing.l,
      ),
      child: Column(
        children: [
          TelegramAvatar(
            image: avatarImage,
            fallbackText: avatarFallback.isNotEmpty ? avatarFallback : title,
            size: 84,
          ),
          const SizedBox(height: TelegramSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: TelegramSpacing.xs),
                Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: theme.colors.linkColor,
                  size: 18,
                ),
              ],
            ],
          ),
          const SizedBox(height: TelegramSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colors.subtitleTextColor,
            ),
          ),
          if (description != null && description!.trim().isNotEmpty) ...[
            const SizedBox(height: TelegramSpacing.s),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colors.textColor,
                height: 1.3,
              ),
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: TelegramSpacing.l),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: TelegramSpacing.s,
              runSpacing: TelegramSpacing.s,
              children: [
                for (final action in actions)
                  _ChannelActionButton(action: action),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChannelActionButton extends StatelessWidget {
  const _ChannelActionButton({required this.action});

  final TelegramChannelInfoAction action;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final foregroundColor = action.destructive
        ? theme.colors.destructiveTextColor
        : theme.colors.linkColor;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.m,
        vertical: TelegramSpacing.s,
      ),
      minimumSize: const Size(88, 34),
      borderRadius: BorderRadius.circular(999),
      color: theme.colors.secondaryBgColor,
      onPressed: action.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, size: 16, color: foregroundColor),
          const SizedBox(width: TelegramSpacing.xs),
          Text(
            action.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
