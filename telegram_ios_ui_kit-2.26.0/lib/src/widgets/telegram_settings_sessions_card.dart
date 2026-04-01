import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_session.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsSessionsCard extends StatelessWidget {
  const TelegramSettingsSessionsCard({
    super.key,
    required this.sessions,
    this.title = 'Active Sessions',
    this.subtitle,
    this.onSessionTap,
    this.onManageTap,
    this.manageLabel = 'Manage',
    this.onViewAllTap,
    this.viewAllLabel = 'View All',
    this.maxVisible = 3,
    this.emptyLabel = 'No active sessions',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  }) : assert(maxVisible > 0);

  final List<TelegramSettingsSession> sessions;
  final String title;
  final String? subtitle;
  final ValueChanged<TelegramSettingsSession>? onSessionTap;
  final VoidCallback? onManageTap;
  final String manageLabel;
  final VoidCallback? onViewAllTap;
  final String viewAllLabel;
  final int maxVisible;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final visibleSessions = sessions.take(maxVisible).toList(growable: false);
    final hasHiddenSessions = sessions.length > visibleSessions.length;

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
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: TelegramSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                ),
              ],
              const SizedBox(height: TelegramSpacing.s),
              if (visibleSessions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: TelegramSpacing.s,
                  ),
                  child: Text(
                    emptyLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subtitleTextColor,
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < visibleSessions.length;
                        index++
                      )
                        _SessionTile(
                          session: visibleSessions[index],
                          onTap: onSessionTap == null
                              ? null
                              : () => onSessionTap!(visibleSessions[index]),
                          showDivider: index < visibleSessions.length - 1,
                        ),
                    ],
                  ),
                ),
              if (hasHiddenSessions && onViewAllTap != null) ...[
                const SizedBox(height: TelegramSpacing.s),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 20),
                  onPressed: onViewAllTap,
                  child: Text(
                    '$viewAllLabel (${sessions.length})',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.showDivider,
    this.onTap,
  });

  final TelegramSettingsSession session;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TelegramSpacing.s,
            vertical: TelegramSpacing.s,
          ),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: colors.separatorColor,
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: colors.secondaryBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(session.icon, size: 16, color: colors.linkColor),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.deviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: TelegramSpacing.xxs),
                    Text(
                      _subtitle(session),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TelegramSpacing.s),
              _SessionStatus(session: session),
              const SizedBox(width: TelegramSpacing.xs),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: colors.subtitleTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(TelegramSettingsSession session) {
    final location = session.locationLabel;
    if (location != null && location.isNotEmpty) {
      return '${session.platformLabel} · $location';
    }
    return session.platformLabel;
  }
}

class _SessionStatus extends StatelessWidget {
  const _SessionStatus({required this.session});

  final TelegramSettingsSession session;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    if (session.isCurrentDevice) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.linkColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TelegramSpacing.s,
            vertical: TelegramSpacing.xxs,
          ),
          child: Text(
            'This Device',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.linkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    if (session.isOnline) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: colors.onlineIndicatorColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: TelegramSpacing.xxs),
          Text(
            'Online',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onlineIndicatorColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Text(
      session.lastActiveLabel,
      style: theme.textTheme.labelSmall?.copyWith(
        color: colors.subtitleTextColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
