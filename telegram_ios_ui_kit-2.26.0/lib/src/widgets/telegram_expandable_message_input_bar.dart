import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_attachment_action.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramExpandableMessageInputBar extends StatefulWidget {
  const TelegramExpandableMessageInputBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onSend,
    this.onAttachPressed,
    this.onVoicePressed,
    this.hintText = 'Message',
    this.showSendButton = true,
    this.tools = const [],
    this.initiallyExpanded = false,
    this.onExpandedChanged,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSend;
  final VoidCallback? onAttachPressed;
  final VoidCallback? onVoicePressed;
  final String hintText;
  final bool showSendButton;
  final List<TelegramAttachmentAction> tools;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<TelegramExpandableMessageInputBar> createState() =>
      _TelegramExpandableMessageInputBarState();
}

class _TelegramExpandableMessageInputBarState
    extends State<TelegramExpandableMessageInputBar> {
  late bool _expanded;
  final TextEditingController _internalController = TextEditingController();

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded && widget.tools.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant TelegramExpandableMessageInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded && widget.tools.isNotEmpty;
    }
    if (widget.tools.isEmpty && _expanded) {
      _expanded = false;
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  void _setExpanded(bool value) {
    if (_expanded == value) {
      return;
    }
    setState(() => _expanded = value);
    widget.onExpandedChanged?.call(value);
  }

  void _submit([String? rawValue]) {
    final value = (rawValue ?? _controller.text).trim();
    if (value.isEmpty) {
      return;
    }
    widget.onSend?.call(value);
    _controller.clear();
    if (_expanded) {
      _setExpanded(false);
    }
  }

  void _handleToolTap(TelegramAttachmentAction action) {
    final callback = action.onPressed;
    if (callback != null) {
      unawaited(callback());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final hasTools = widget.tools.isNotEmpty;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _InputToolsRow(
                tools: widget.tools,
                onToolTap: _handleToolTap,
              ),
              crossFadeState: _expanded && hasTools
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
              sizeCurve: Curves.easeOutCubic,
            ),
            if (_expanded && hasTools)
              const SizedBox(height: TelegramSpacing.s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasTools) ...[
                  _CircleActionButton(
                    icon: _expanded
                        ? CupertinoIcons.chevron_down_circle_fill
                        : CupertinoIcons.plus_circle_fill,
                    iconColor: colors.linkColor,
                    onPressed: () => _setExpanded(!_expanded),
                  ),
                  const SizedBox(width: TelegramSpacing.s),
                ],
                if (widget.onAttachPressed != null) ...[
                  _CircleActionButton(
                    icon: CupertinoIcons.paperclip,
                    onPressed: widget.onAttachPressed,
                  ),
                  const SizedBox(width: TelegramSpacing.s),
                ],
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
                      controller: _controller,
                      focusNode: widget.focusNode,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _submit,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.textColor,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.hintColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TelegramSpacing.s),
                _CircleActionButton(
                  icon: widget.showSendButton
                      ? CupertinoIcons.paperplane_fill
                      : CupertinoIcons.mic,
                  iconColor: colors.linkColor,
                  onPressed: () {
                    if (widget.showSendButton) {
                      _submit();
                      return;
                    }
                    widget.onVoicePressed?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputToolsRow extends StatelessWidget {
  const _InputToolsRow({required this.tools, required this.onToolTap});

  final List<TelegramAttachmentAction> tools;
  final ValueChanged<TelegramAttachmentAction> onToolTap;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        separatorBuilder: (_, index) =>
            const SizedBox(width: TelegramSpacing.s),
        itemBuilder: (context, index) {
          final action = tools[index];
          return _InputToolButton(
            action: action,
            onPressed: () => onToolTap(action),
          );
        },
      ),
    );
  }
}

class _InputToolButton extends StatelessWidget {
  const _InputToolButton({required this.action, required this.onPressed});

  final TelegramAttachmentAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final iconColor = action.color ?? theme.colors.linkColor;

    return CupertinoButton(
      minimumSize: const Size(64, 64),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(action.icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: TelegramSpacing.xs),
          Text(
            action.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
