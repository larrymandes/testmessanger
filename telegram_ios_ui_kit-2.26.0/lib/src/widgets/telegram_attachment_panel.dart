import 'dart:async';

import 'package:flutter/material.dart';

import '../models/telegram_attachment_action.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramAttachmentPanel extends StatelessWidget {
  const TelegramAttachmentPanel({
    super.key,
    required this.actions,
    this.onActionTap,
    this.title = 'Attach',
    this.crossAxisCount = 4,
    this.wrapInSafeArea = true,
  });

  final List<TelegramAttachmentAction> actions;
  final ValueChanged<TelegramAttachmentAction>? onActionTap;
  final String title;
  final int crossAxisCount;
  final bool wrapInSafeArea;

  void _handleTap(TelegramAttachmentAction action) {
    onActionTap?.call(action);
    final callback = action.onPressed;
    if (callback != null) {
      unawaited(callback());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    final panel = Container(
      decoration: BoxDecoration(
        color: theme.colors.headerBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          top: BorderSide(color: theme.colors.separatorColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        TelegramSpacing.l,
        TelegramSpacing.s,
        TelegramSpacing.l,
        TelegramSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colors.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TelegramSpacing.m),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: TelegramSpacing.m,
              crossAxisSpacing: TelegramSpacing.m,
              childAspectRatio: 0.84,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              final actionColor = action.color ?? theme.colors.linkColor;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _handleTap(action),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: actionColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(action.icon, size: 24, color: actionColor),
                    ),
                    const SizedBox(height: TelegramSpacing.s),
                    Text(
                      action.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    if (!wrapInSafeArea) {
      return panel;
    }
    return SafeArea(top: false, child: panel);
  }
}
