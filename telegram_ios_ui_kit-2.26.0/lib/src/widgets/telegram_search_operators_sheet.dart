import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_search_operator.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchOperatorsSheet extends StatelessWidget {
  const TelegramSearchOperatorsSheet({
    super.key,
    required this.operators,
    this.onSelected,
    this.onClose,
    this.closeOnSelect = true,
    this.title = 'Search Operators',
  });

  final List<TelegramSearchOperator> operators;
  final ValueChanged<TelegramSearchOperator>? onSelected;
  final VoidCallback? onClose;
  final bool closeOnSelect;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required List<TelegramSearchOperator> operators,
    ValueChanged<TelegramSearchOperator>? onSelected,
    VoidCallback? onClose,
    bool closeOnSelect = true,
    String title = 'Search Operators',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSearchOperatorsSheet(
          operators: operators,
          onSelected: onSelected,
          onClose: onClose,
          closeOnSelect: closeOnSelect,
          title: title,
        );
      },
    );
  }

  void _handleTap(BuildContext context, TelegramSearchOperator operator) {
    onSelected?.call(operator);
    if (closeOnSelect) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.headerBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.fromLTRB(
          TelegramSpacing.m,
          TelegramSpacing.s,
          TelegramSpacing.m,
          TelegramSpacing.m,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colors.separatorColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: TelegramSpacing.s),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CupertinoButton(
                  minimumSize: const Size.square(24),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose?.call();
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: theme.colors.subtitleTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TelegramSpacing.xs),
            if (operators.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TelegramSpacing.l),
                child: Center(
                  child: Text(
                    'No operators.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: operators.length,
                    itemBuilder: (context, index) {
                      final operator = operators[index];
                      return _OperatorTile(
                        operator: operator,
                        showDivider: index < operators.length - 1,
                        onTap: () => _handleTap(context, operator),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OperatorTile extends StatelessWidget {
  const _OperatorTile({
    required this.operator,
    required this.onTap,
    required this.showDivider,
  });

  final TelegramSearchOperator operator;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final subtitleParts = <String>[
      if (operator.description != null && operator.description!.trim().isNotEmpty)
        operator.description!.trim(),
      if (operator.example != null && operator.example!.trim().isNotEmpty)
        operator.example!.trim(),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: theme.colors.separatorColor,
                  width: 0.8,
                ),
              )
            : null,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.m,
          vertical: TelegramSpacing.s,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            if (operator.icon != null) ...[
              Icon(operator.icon, size: 16, color: theme.colors.linkColor),
              const SizedBox(width: TelegramSpacing.s),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${operator.label} · ${operator.token}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                      child: Text(
                        subtitleParts.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colors.subtitleTextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: theme.colors.subtitleTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
