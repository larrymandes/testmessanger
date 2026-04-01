import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchBar extends StatelessWidget {
  const TelegramSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final value = controller?.text ?? '';
    final showClear = value.isNotEmpty;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colors.secondaryBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.m),
      child: Row(
        children: [
          Icon(CupertinoIcons.search, size: 18, color: colors.hintColor),
          const SizedBox(width: TelegramSpacing.s),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hintText,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.hintColor,
                ),
              ),
            ),
          ),
          if (showClear)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(20, 20),
              onPressed: () {
                controller?.clear();
                onChanged?.call('');
                onClear?.call();
              },
              child: Icon(
                CupertinoIcons.clear_circled_solid,
                size: 18,
                color: colors.hintColor,
              ),
            ),
        ],
      ),
    );
  }
}
