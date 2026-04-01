import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramBulkBanActionBar extends StatelessWidget {
  const TelegramBulkBanActionBar({
    super.key,
    required this.selectedCount,
    this.visible = true,
    this.onUnban,
    this.onExtend,
    this.onDelete,
    this.onClearSelection,
    this.unbanLabel = 'Unban',
    this.extendLabel = 'Extend',
    this.deleteLabel = 'Delete',
  });

  final int selectedCount;
  final bool visible;
  final VoidCallback? onUnban;
  final VoidCallback? onExtend;
  final VoidCallback? onDelete;
  final VoidCallback? onClearSelection;
  final String unbanLabel;
  final String extendLabel;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final show = visible && selectedCount > 0;

    return IgnorePointer(
      ignoring: !show,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: show ? Offset.zero : const Offset(0, 0.3),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: show ? 1 : 0,
          child: SafeArea(
            top: false,
            child: Container(
              color: theme.colors.headerBgColor,
              padding: const EdgeInsets.fromLTRB(
                TelegramSpacing.s,
                TelegramSpacing.s,
                TelegramSpacing.s,
                TelegramSpacing.s,
              ),
              child: Row(
                children: [
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: TelegramSpacing.s,
                    ),
                    onPressed: onClearSelection,
                    child: Text(
                      '$selectedCount selected',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _BarActionButton(
                    label: unbanLabel,
                    icon: CupertinoIcons.check_mark_circled,
                    color: theme.colors.linkColor,
                    onPressed: onUnban,
                  ),
                  const SizedBox(width: TelegramSpacing.xs),
                  _BarActionButton(
                    label: extendLabel,
                    icon: CupertinoIcons.time_solid,
                    color: theme.colors.linkColor,
                    onPressed: onExtend,
                  ),
                  const SizedBox(width: TelegramSpacing.xs),
                  _BarActionButton(
                    label: deleteLabel,
                    icon: CupertinoIcons.delete_solid,
                    color: theme.colors.destructiveTextColor,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarActionButton extends StatelessWidget {
  const _BarActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return CupertinoButton(
      minimumSize: const Size(24, 24),
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.xs,
      ),
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: TelegramSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
