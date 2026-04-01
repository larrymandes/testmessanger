import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramMessageInputBar extends StatelessWidget {
  const TelegramMessageInputBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onSend,
    this.onAttachPressed,
    this.onVoicePressed,
    this.showSendButton = true,
    this.hintText = 'Message',
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSend;
  final VoidCallback? onAttachPressed;
  final VoidCallback? onVoicePressed;
  final bool showSendButton;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    return SafeArea(
      top: false,
      child: Container(
        color: colors.headerBgColor,
        padding: const EdgeInsets.fromLTRB(
          TelegramSpacing.s,
          TelegramSpacing.s,
          TelegramSpacing.s,
          TelegramSpacing.s,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CircleActionButton(
              icon: CupertinoIcons.paperclip,
              onPressed: onAttachPressed,
            ),
            const SizedBox(width: TelegramSpacing.s),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 36,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: colors.secondaryBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: TelegramSpacing.m,
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) {
                      return;
                    }
                    onSend?.call(value.trim());
                    controller?.clear();
                  },
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.textColor,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.hintColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            _CircleActionButton(
              icon: showSendButton
                  ? CupertinoIcons.paperplane_fill
                  : CupertinoIcons.mic,
              iconColor: colors.linkColor,
              onPressed: () {
                if (showSendButton) {
                  final value = controller?.text.trim() ?? '';
                  if (value.isEmpty) {
                    return;
                  }
                  onSend?.call(value);
                  controller?.clear();
                  return;
                }
                onVoicePressed?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minimumSize: const Size(36, 36),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colors.secondaryBgColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 19,
          color: iconColor ?? theme.colors.subtitleTextColor,
        ),
      ),
    );
  }
}
