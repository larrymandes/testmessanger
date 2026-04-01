import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_option.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_settings_option_tile.dart';

class TelegramSettingsOptionsSheet extends StatelessWidget {
  const TelegramSettingsOptionsSheet({
    super.key,
    required this.options,
    this.selectedId,
    this.onSelected,
    this.onClose,
    this.onClear,
    this.closeOnSelect = true,
    this.title = 'Choose Option',
    this.clearLabel = 'Clear',
  });

  final List<TelegramSettingsOption> options;
  final String? selectedId;
  final ValueChanged<TelegramSettingsOption>? onSelected;
  final VoidCallback? onClose;
  final VoidCallback? onClear;
  final bool closeOnSelect;
  final String title;
  final String clearLabel;

  static Future<void> show(
    BuildContext context, {
    required List<TelegramSettingsOption> options,
    String? selectedId,
    ValueChanged<TelegramSettingsOption>? onSelected,
    VoidCallback? onClose,
    VoidCallback? onClear,
    bool closeOnSelect = true,
    String title = 'Choose Option',
    String clearLabel = 'Clear',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSettingsOptionsSheet(
          options: options,
          selectedId: selectedId,
          onSelected: onSelected,
          onClose: onClose,
          onClear: onClear,
          closeOnSelect: closeOnSelect,
          title: title,
          clearLabel: clearLabel,
        );
      },
    );
  }

  void _handleSelected(BuildContext context, TelegramSettingsOption option) {
    onSelected?.call(option);
    if (closeOnSelect) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.headerBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.fromLTRB(
          TelegramSpacing.m,
          TelegramSpacing.s,
          TelegramSpacing.m,
          TelegramSpacing.m,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colors.separatorColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: TelegramSpacing.s),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onClear != null)
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero,
                    onPressed: onClear,
                    child: Text(
                      clearLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.destructiveTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                CupertinoButton(
                  minimumSize: const Size.square(24),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose?.call();
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: theme.colors.subtitleTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TelegramSpacing.xs),
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TelegramSpacing.l,
                ),
                child: Center(
                  child: Text(
                    'No options available.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return TelegramSettingsOptionTile(
                        option: option,
                        selected: option.id == selectedId,
                        showDivider: index < options.length - 1,
                        onTap: (value) => _handleSelected(context, value),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
