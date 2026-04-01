import 'package:flutter/material.dart';

import '../models/telegram_chat_folder.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_badge.dart';

class TelegramChatFoldersBar extends StatelessWidget {
  const TelegramChatFoldersBar({
    super.key,
    required this.folders,
    required this.selectedFolderId,
    required this.onFolderSelected,
  });

  final List<TelegramChatFolder> folders;
  final String selectedFolderId;
  final ValueChanged<TelegramChatFolder> onFolderSelected;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.l),
        itemCount: folders.length,
        separatorBuilder: (_, index) =>
            const SizedBox(width: TelegramSpacing.s),
        itemBuilder: (context, index) {
          final folder = folders[index];
          final selected = folder.id == selectedFolderId;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onFolderSelected(folder),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TelegramSpacing.m,
                vertical: TelegramSpacing.s,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colors.linkColor
                    : theme.colors.secondaryBgColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    folder.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? theme.colors.buttonTextColor
                          : theme.colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (folder.unreadCount > 0) ...[
                    const SizedBox(width: TelegramSpacing.s),
                    TelegramBadge(
                      count: folder.unreadCount,
                      color: selected ? Colors.white24 : null,
                      textColor: selected
                          ? theme.colors.buttonTextColor
                          : theme.colors.buttonTextColor,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
