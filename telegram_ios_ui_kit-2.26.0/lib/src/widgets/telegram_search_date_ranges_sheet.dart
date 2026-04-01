import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_search_date_range.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchDateRangesSheet extends StatelessWidget {
  const TelegramSearchDateRangesSheet({
    super.key,
    required this.ranges,
    this.selectedId,
    this.onSelected,
    this.onClear,
    this.onClose,
    this.title = 'Date Range',
    this.clearLabel = 'Anytime',
  });

  final List<TelegramSearchDateRange> ranges;
  final String? selectedId;
  final ValueChanged<TelegramSearchDateRange>? onSelected;
  final VoidCallback? onClear;
  final VoidCallback? onClose;
  final String title;
  final String clearLabel;

  static Future<void> show(
    BuildContext context, {
    required List<TelegramSearchDateRange> ranges,
    String? selectedId,
    ValueChanged<TelegramSearchDateRange>? onSelected,
    VoidCallback? onClear,
    String title = 'Date Range',
    String clearLabel = 'Anytime',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSearchDateRangesSheet(
          ranges: ranges,
          selectedId: selectedId,
          onSelected: onSelected,
          onClear: onClear,
          title: title,
          clearLabel: clearLabel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final hasActiveSelection =
        selectedId != null &&
        selectedId!.trim().isNotEmpty &&
        selectedId != 'anytime';

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
                if (hasActiveSelection)
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onClear?.call();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      clearLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.linkColor,
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
            if (ranges.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TelegramSpacing.l,
                ),
                child: Center(
                  child: Text(
                    'No date ranges.',
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
                    itemCount: ranges.length,
                    itemBuilder: (context, index) {
                      final range = ranges[index];
                      final selected = selectedId == range.id;
                      return _RangeTile(
                        range: range,
                        selected: selected,
                        showDivider: index < ranges.length - 1,
                        onTap: () {
                          onSelected?.call(range);
                          Navigator.of(context).pop();
                        },
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

class _RangeTile extends StatelessWidget {
  const _RangeTile({
    required this.range,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  final TelegramSearchDateRange range;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;

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
            if (range.icon != null) ...[
              Icon(range.icon, size: 16, color: theme.colors.linkColor),
              const SizedBox(width: TelegramSpacing.s),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    range.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (range.description != null &&
                      range.description!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                      child: Text(
                        range.description!,
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
              selected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              size: 18,
              color: selected
                  ? theme.colors.linkColor
                  : theme.colors.subtitleTextColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
