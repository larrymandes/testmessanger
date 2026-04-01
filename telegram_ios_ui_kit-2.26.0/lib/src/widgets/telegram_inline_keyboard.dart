import 'dart:async';

import 'package:flutter/material.dart';

import '../models/telegram_keyboard_button.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramInlineKeyboard extends StatelessWidget {
  const TelegramInlineKeyboard({
    super.key,
    required this.rows,
    this.onButtonTap,
    this.padding = const EdgeInsets.all(TelegramSpacing.s),
    this.rowSpacing = TelegramSpacing.s,
    this.columnSpacing = TelegramSpacing.s,
  });

  final List<List<TelegramKeyboardButton>> rows;
  final ValueChanged<TelegramKeyboardButton>? onButtonTap;
  final EdgeInsetsGeometry padding;
  final double rowSpacing;
  final double columnSpacing;

  void _handleTap(TelegramKeyboardButton button) {
    onButtonTap?.call(button);
    final callback = button.onPressed;
    if (callback != null) {
      unawaited(callback());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colors.headerBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.separatorColor, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
            Row(
              children: [
                for (var index = 0; index < rows[rowIndex].length; index++) ...[
                  if (index > 0) SizedBox(width: columnSpacing),
                  Expanded(
                    child: _KeyboardButtonView(
                      button: rows[rowIndex][index],
                      onTap: _handleTap,
                    ),
                  ),
                ],
              ],
            ),
            if (rowIndex < rows.length - 1) SizedBox(height: rowSpacing),
          ],
        ],
      ),
    );
  }
}

class _KeyboardButtonView extends StatelessWidget {
  const _KeyboardButtonView({required this.button, required this.onTap});

  final TelegramKeyboardButton button;
  final ValueChanged<TelegramKeyboardButton> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final foreground = button.isDestructive
        ? theme.colors.destructiveTextColor
        : button.isPrimary
        ? theme.colors.buttonTextColor
        : theme.colors.linkColor;
    final background = button.isPrimary
        ? theme.colors.linkColor
        : theme.colors.secondaryBgColor;

    return TextButton(
      onPressed: () => onTap(button),
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.s,
          vertical: TelegramSpacing.s,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (button.icon != null) ...[
            Icon(button.icon, size: 15),
            const SizedBox(width: TelegramSpacing.xs),
          ],
          Flexible(
            child: Text(
              button.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
