import 'package:flutter/material.dart';

import '../models/telegram_settings_quick_action.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsQuickActionsBar extends StatelessWidget {
  const TelegramSettingsQuickActionsBar({
    super.key,
    required this.actions,
    this.onSelected,
    this.columns = 4,
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsQuickAction> actions;
  final ValueChanged<TelegramSettingsQuickAction>? onSelected;
  final int columns;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final safeColumns = columns < 1 ? 1 : columns;
          const spacing = TelegramSpacing.s;
          final itemWidth =
              (constraints.maxWidth - (safeColumns - 1) * spacing) /
              safeColumns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final action in actions)
                SizedBox(
                  width: itemWidth,
                  child: _ActionTile(
                    action: action,
                    onTap: onSelected == null
                        ? null
                        : () => onSelected!(action),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, this.onTap});

  final TelegramSettingsQuickAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final baseForeground = action.destructive
        ? colors.destructiveTextColor
        : colors.linkColor;
    final enabled = onTap != null && action.enabled;
    final foregroundColor = enabled
        ? baseForeground
        : colors.subtitleTextColor.withValues(alpha: 0.72);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            TelegramSpacing.s,
            TelegramSpacing.s,
            TelegramSpacing.s,
            TelegramSpacing.m,
          ),
          decoration: BoxDecoration(
            color: colors.sectionBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _ActionBadge(
                  label: action.badgeLabel,
                  foregroundColor: foregroundColor,
                ),
              ),
              SizedBox(
                height: 32,
                width: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foregroundColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(action.icon, size: 18, color: foregroundColor),
                ),
              ),
              const SizedBox(height: TelegramSpacing.s),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.label, required this.foregroundColor});

  final String? label;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) {
      return const SizedBox(height: 16);
    }
    final theme = context.telegramTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: foregroundColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.s,
          vertical: TelegramSpacing.xxs,
        ),
        child: Text(
          label!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
