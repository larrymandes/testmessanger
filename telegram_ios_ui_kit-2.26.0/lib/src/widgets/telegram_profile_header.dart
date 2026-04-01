import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

@immutable
class TelegramProfileAction {
  const TelegramProfileAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

class TelegramProfileHeader extends StatelessWidget {
  const TelegramProfileHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.avatarImage,
    this.avatarFallback = '',
    this.actions = const [],
  });

  final String name;
  final String subtitle;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final List<TelegramProfileAction> actions;

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
            fallbackText: avatarFallback.isNotEmpty ? avatarFallback : name,
            size: 80,
          ),
          const SizedBox(height: TelegramSpacing.m),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colors.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TelegramSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colors.subtitleTextColor,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: TelegramSpacing.l),
            Row(
              children: [
                for (final action in actions)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _TelegramProfileActionButton(action: action),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TelegramProfileActionButton extends StatelessWidget {
  const _TelegramProfileActionButton({required this.action});

  final TelegramProfileAction action;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.secondaryBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: TelegramSpacing.m,
          horizontal: TelegramSpacing.s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 18, color: theme.colors.linkColor),
            const SizedBox(height: TelegramSpacing.xs),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colors.linkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
