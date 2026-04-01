import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_quiet_hours_preset.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsQuietHoursCard extends StatelessWidget {
  const TelegramSettingsQuietHoursCard({
    super.key,
    required this.enabled,
    required this.presets,
    required this.selectedPresetId,
    this.title = 'Quiet Hours',
    this.onEnabledChanged,
    this.onPresetSelected,
    this.onCustomizeTap,
    this.customizeLabel = 'Customize',
    this.emptyLabel = 'No quiet-hour presets configured',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final bool enabled;
  final List<TelegramSettingsQuietHoursPreset> presets;
  final String selectedPresetId;
  final String title;
  final ValueChanged<bool>? onEnabledChanged;
  final ValueChanged<TelegramSettingsQuietHoursPreset>? onPresetSelected;
  final VoidCallback? onCustomizeTap;
  final String customizeLabel;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final selected = presets
        .where((preset) => preset.id == selectedPresetId)
        .cast<TelegramSettingsQuietHoursPreset?>()
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
                  CupertinoSwitch(value: enabled, onChanged: onEnabledChanged),
                ],
              ),
              const SizedBox(height: TelegramSpacing.s),
              if (enabled && selected != null)
                Text(
                  '${selected.label} · ${selected.timeRangeLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                )
              else
                Text(
                  'Quiet hours disabled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                ),
              if (onCustomizeTap != null) ...[
                const SizedBox(height: TelegramSpacing.s),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 20),
                  onPressed: onCustomizeTap,
                  child: Text(
                    customizeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
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
                      _PresetCard(
                        preset: preset,
                        selected: preset.id == selectedPresetId,
                        onTap:
                            !enabled ||
                                !preset.enabled ||
                                onPresetSelected == null
                            ? null
                            : () => onPresetSelected!(preset),
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

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset, required this.selected, this.onTap});

  final TelegramSettingsQuietHoursPreset preset;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final backgroundColor = selected
        ? colors.linkColor.withValues(alpha: 0.14)
        : colors.secondaryBgColor;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TelegramSpacing.s,
            vertical: TelegramSpacing.s,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                preset.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onTap == null
                      ? colors.subtitleTextColor
                      : colors.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TelegramSpacing.xxs),
              Text(
                preset.timeRangeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.subtitleTextColor,
                ),
              ),
              if (preset.daysLabel != null && preset.daysLabel!.isNotEmpty) ...[
                const SizedBox(height: TelegramSpacing.xxs),
                Text(
                  preset.daysLabel!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.subtitleTextColor.withValues(alpha: 0.9),
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
