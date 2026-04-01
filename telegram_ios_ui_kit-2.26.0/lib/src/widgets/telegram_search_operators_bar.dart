import 'package:flutter/cupertino.dart';

import '../models/telegram_search_operator.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchOperatorsBar extends StatelessWidget {
  const TelegramSearchOperatorsBar({
    super.key,
    required this.operators,
    this.highlightedId,
    this.onSelected,
    this.showToken = true,
  });

  final List<TelegramSearchOperator> operators;
  final String? highlightedId;
  final ValueChanged<TelegramSearchOperator>? onSelected;
  final bool showToken;

  @override
  Widget build(BuildContext context) {
    if (operators.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: operators.length,
        separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          final operator = operators[index];
          final highlighted = highlightedId == operator.id;
          final foregroundColor = highlighted
              ? theme.colors.buttonTextColor
              : theme.colors.textColor;
          final backgroundColor = highlighted
              ? theme.colors.linkColor
              : theme.colors.sectionBgColor;

          return CupertinoButton(
            minimumSize: const Size(24, 24),
            padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.s),
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            onPressed: onSelected == null ? null : () => onSelected!(operator),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (operator.icon != null) ...[
                  Icon(operator.icon, size: 13, color: foregroundColor),
                  const SizedBox(width: TelegramSpacing.xxs),
                ],
                Text(
                  operator.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showToken && operator.token.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: TelegramSpacing.xxs),
                    child: Text(
                      operator.token,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: foregroundColor.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
