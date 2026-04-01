import 'package:flutter/cupertino.dart';

import '../models/telegram_settings_network_policy.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsNetworkPoliciesCard extends StatelessWidget {
  const TelegramSettingsNetworkPoliciesCard({
    super.key,
    required this.policies,
    this.title = 'Network Policies',
    this.onPolicyChanged,
    this.onManageTap,
    this.manageLabel = 'Manage',
    this.emptyLabel = 'No network policies configured',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsNetworkPolicy> policies;
  final String title;
  final ValueChanged<TelegramSettingsNetworkPolicy>? onPolicyChanged;
  final VoidCallback? onManageTap;
  final String manageLabel;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.sectionBgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TelegramSpacing.m,
            TelegramSpacing.m,
            TelegramSpacing.m,
            TelegramSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onManageTap != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(24, 20),
                      onPressed: onManageTap,
                      child: Text(
                        manageLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TelegramSpacing.s),
              if (policies.isEmpty)
                Text(
                  emptyLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      for (var index = 0; index < policies.length; index++)
                        _PolicyTile(
                          policy: policies[index],
                          showDivider: index < policies.length - 1,
                          onChanged:
                              onPolicyChanged == null || policies[index].locked
                              ? null
                              : (enabled) => onPolicyChanged!(
                                  policies[index].copyWith(enabled: enabled),
                                ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({
    required this.policy,
    required this.showDivider,
    this.onChanged,
  });

  final TelegramSettingsNetworkPolicy policy;
  final bool showDivider;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final accentColor = policy.destructive
        ? colors.destructiveTextColor
        : colors.linkColor;
    final titleColor = policy.locked
        ? colors.subtitleTextColor
        : colors.textColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.s,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(color: colors.separatorColor, width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(policy.icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: TelegramSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        policy.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (policy.limitLabel != null &&
                        policy.limitLabel!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: TelegramSpacing.s),
                        child: _LimitBadge(
                          label: policy.limitLabel!,
                          color: accentColor,
                        ),
                      ),
                  ],
                ),
                if (policy.subtitle != null && policy.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: TelegramSpacing.xxs),
                  Text(
                    policy.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subtitleTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: TelegramSpacing.s),
          CupertinoSwitch(value: policy.enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LimitBadge extends StatelessWidget {
  const _LimitBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
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
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
