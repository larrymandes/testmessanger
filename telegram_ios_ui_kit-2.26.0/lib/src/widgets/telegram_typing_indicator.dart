import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramTypingIndicator extends StatefulWidget {
  const TelegramTypingIndicator({super.key, this.label = 'typing…'});

  final String label;

  @override
  State<TelegramTypingIndicator> createState() =>
      _TelegramTypingIndicatorState();
}

class _TelegramTypingIndicatorState extends State<TelegramTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.m,
        vertical: TelegramSpacing.s,
      ),
      decoration: BoxDecoration(
        color: theme.colors.incomingBubbleColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(controller: _controller, index: 0),
          const SizedBox(width: 3),
          _Dot(controller: _controller, index: 1),
          const SizedBox(width: 3),
          _Dot(controller: _controller, index: 2),
          const SizedBox(width: TelegramSpacing.s),
          Text(
            widget.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colors.subtitleTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.controller, required this.index});

  final AnimationController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final begin = index * 0.2;
    final end = begin + 0.6;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final curved = CurvedAnimation(
          parent: controller,
          curve: Interval(begin, end, curve: Curves.easeInOut),
        ).value;
        return Opacity(
          opacity: 0.35 + 0.65 * curved,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colors.subtitleTextColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
