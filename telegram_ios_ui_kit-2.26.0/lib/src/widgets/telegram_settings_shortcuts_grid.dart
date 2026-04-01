import 'package:flutter/cupertino.dart';

import '../models/telegram_settings_shortcut.dart';
import '../theme/telegram_spacing.dart';
import 'telegram_settings_shortcut_tile.dart';

class TelegramSettingsShortcutsGrid extends StatelessWidget {
  const TelegramSettingsShortcutsGrid({
    super.key,
    required this.shortcuts,
    this.crossAxisCount = 2,
    this.onSelected,
  });

  final List<TelegramSettingsShortcut> shortcuts;
  final int crossAxisCount;
  final ValueChanged<TelegramSettingsShortcut>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (shortcuts.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveColumns = crossAxisCount.clamp(2, 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveColumns,
        crossAxisSpacing: TelegramSpacing.s,
        mainAxisSpacing: TelegramSpacing.s,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        return TelegramSettingsShortcutTile(
          shortcut: shortcut,
          onTap: onSelected,
        );
      },
    );
  }
}
