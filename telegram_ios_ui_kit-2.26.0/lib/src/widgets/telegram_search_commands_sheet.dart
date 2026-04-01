import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_search_command.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_search_command_tile.dart';

class TelegramSearchCommandsSheet extends StatelessWidget {
  const TelegramSearchCommandsSheet({
    super.key,
    required this.commands,
    this.onSelected,
    this.onClose,
    this.closeOnSelect = true,
    this.title = 'Search Actions',
  });

  final List<TelegramSearchCommand> commands;
  final ValueChanged<TelegramSearchCommand>? onSelected;
  final VoidCallback? onClose;
  final bool closeOnSelect;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required List<TelegramSearchCommand> commands,
    ValueChanged<TelegramSearchCommand>? onSelected,
    VoidCallback? onClose,
    bool closeOnSelect = true,
    String title = 'Search Actions',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSearchCommandsSheet(
          commands: commands,
          onSelected: onSelected,
          onClose: onClose,
          closeOnSelect: closeOnSelect,
          title: title,
        );
      },
    );
  }

  void _handleSelected(BuildContext context, TelegramSearchCommand command) {
    onSelected?.call(command);
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
            if (commands.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TelegramSpacing.l,
                ),
                child: Center(
                  child: Text(
                    'No actions available.',
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
                    itemCount: commands.length,
                    itemBuilder: (context, index) {
                      final command = commands[index];
                      return TelegramSearchCommandTile(
                        command: command,
                        showDivider: index < commands.length - 1,
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
