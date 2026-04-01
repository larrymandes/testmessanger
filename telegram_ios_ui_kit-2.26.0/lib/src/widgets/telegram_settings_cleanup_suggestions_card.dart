import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_cleanup_suggestion.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsCleanupSuggestionsCard extends StatelessWidget {
  const TelegramSettingsCleanupSuggestionsCard({
    super.key,
    required this.suggestions,
    this.title = 'Cleanup Suggestions',
    this.onSelected,
    this.onRunCleanupTap,
    this.runCleanupLabel = 'Run Cleanup',
    this.emptyLabel = 'No cleanup suggestions',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsCleanupSuggestion> suggestions;
  final String title;
  final ValueChanged<TelegramSettingsCleanupSuggestion>? onSelected;
  final VoidCallback? onRunCleanupTap;
  final String runCleanupLabel;
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
                  if (onRunCleanupTap != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(24, 20),
                      onPressed: onRunCleanupTap,
                      child: Text(
                        runCleanupLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TelegramSpacing.s),
              if (suggestions.isEmpty)
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
                      for (var index = 0; index < suggestions.length; index++)
                        _SuggestionTile(
                          suggestion: suggestions[index],
                          showDivider: index < suggestions.length - 1,
                          onTap:
                              onSelected == null || !suggestions[index].enabled
                              ? null
                              : () => onSelected!(suggestions[index]),
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

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.showDivider,
    this.onTap,
  });

  final TelegramSettingsCleanupSuggestion suggestion;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final accentColor = suggestion.destructive
        ? colors.destructiveTextColor
        : colors.linkColor;
    final titleColor = onTap == null
        ? colors.subtitleTextColor
        : colors.textColor;

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
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(suggestion.icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (suggestion.subtitle != null &&
                        suggestion.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: TelegramSpacing.xxs),
                      Text(
                        suggestion.subtitle!,
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
              Text(
                suggestion.sizeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
}
