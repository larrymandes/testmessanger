import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_auto_download_preset.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsAutoDownloadCard extends StatelessWidget {
  const TelegramSettingsAutoDownloadCard({
    super.key,
    required this.presets,
    required this.selectedId,
    this.title = 'Auto-Download',
    this.onSelected,
    this.onManageTap,
    this.manageLabel = 'Manage',
    this.emptyLabel = 'No presets available',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsAutoDownloadPreset> presets;
  final String selectedId;
  final ValueChanged<TelegramSettingsAutoDownloadPreset>? onSelected;
  final VoidCallback? onManageTap;
  final String title;
  final String manageLabel;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final selectedPreset = presets
        .where((item) => item.id == selectedId)
        .firstOrNull;

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
              if (selectedPreset != null) ...[
                const SizedBox(height: TelegramSpacing.xs),
                Text(
                  '${selectedPreset.label} · ${selectedPreset.mediaLimitLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                ),
              ],
              const SizedBox(height: TelegramSpacing.s),
              if (presets.isEmpty)
                Text(
                  emptyLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                )
              else
                Wrap(
                  spacing: TelegramSpacing.s,
                  runSpacing: TelegramSpacing.s,
                  children: [
                    for (final preset in presets)
                      _PresetChip(
                        preset: preset,
                        selected: preset.id == selectedId,
                        onTap: onSelected == null || !preset.enabled
                            ? null
                            : () => onSelected!(preset),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.preset, required this.selected, this.onTap});

  final TelegramSettingsAutoDownloadPreset preset;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final backgroundColor = selected
        ? colors.linkColor.withValues(alpha: 0.14)
        : colors.secondaryBgColor;
    final textColor = selected ? colors.linkColor : colors.textColor;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TelegramSpacing.s,
            vertical: TelegramSpacing.s,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onTap == null ? colors.subtitleTextColor : textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TelegramSpacing.xxs),
              Text(
                preset.mediaLimitLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.subtitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
