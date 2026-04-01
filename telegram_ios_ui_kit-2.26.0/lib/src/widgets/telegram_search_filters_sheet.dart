import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_search_filter_option.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchFiltersSheet extends StatefulWidget {
  const TelegramSearchFiltersSheet({
    super.key,
    required this.options,
    this.onOptionChanged,
    this.onApply,
    this.onReset,
    this.onClose,
    this.title = 'Search Filters',
    this.resetLabel = 'Reset',
    this.applyLabel = 'Apply',
  });

  final List<TelegramSearchFilterOption> options;
  final ValueChanged<TelegramSearchFilterOption>? onOptionChanged;
  final VoidCallback? onApply;
  final VoidCallback? onReset;
  final VoidCallback? onClose;
  final String title;
  final String resetLabel;
  final String applyLabel;

  static Future<void> show(
    BuildContext context, {
    required List<TelegramSearchFilterOption> options,
    ValueChanged<TelegramSearchFilterOption>? onOptionChanged,
    VoidCallback? onApply,
    VoidCallback? onReset,
    String title = 'Search Filters',
    String resetLabel = 'Reset',
    String applyLabel = 'Apply',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSearchFiltersSheet(
          options: options,
          onOptionChanged: onOptionChanged,
          onApply: onApply,
          onReset: onReset,
          title: title,
          resetLabel: resetLabel,
          applyLabel: applyLabel,
        );
      },
    );
  }

  @override
  State<TelegramSearchFiltersSheet> createState() =>
      _TelegramSearchFiltersSheetState();
}

class _TelegramSearchFiltersSheetState
    extends State<TelegramSearchFiltersSheet> {
  late List<TelegramSearchFilterOption> _options;

  @override
  void initState() {
    super.initState();
    _options = widget.options.toList(growable: false);
  }

  void _updateOption(TelegramSearchFilterOption updated) {
    setState(() {
      _options = _options
          .map((option) => option.id == updated.id ? updated : option)
          .toList(growable: false);
    });
    widget.onOptionChanged?.call(updated);
  }

  void _resetFilters() {
    final changed = _options.where((option) => option.selected).toList();
    if (changed.isEmpty) {
      widget.onReset?.call();
      return;
    }
    setState(() {
      _options = _options
          .map((option) => option.copyWith(selected: false))
          .toList(growable: false);
    });
    for (final option in changed) {
      widget.onOptionChanged?.call(option.copyWith(selected: false));
    }
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final selectedCount = _options.where((option) => option.selected).length;

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
                    widget.title,
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
                    widget.onClose?.call();
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: theme.colors.subtitleTextColor,
                  ),
                ),
              ],
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _options.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: TelegramSpacing.xxs),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return _FilterOptionTile(
                    option: option,
                    onChanged: option.locked
                        ? null
                        : (value) =>
                              _updateOption(option.copyWith(selected: value)),
                  );
                },
              ),
            ),
            const SizedBox(height: TelegramSpacing.s),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: const EdgeInsets.symmetric(
                      vertical: TelegramSpacing.s,
                    ),
                    color: theme.colors.sectionBgColor,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: _resetFilters,
                    child: Text(
                      widget.resetLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TelegramSpacing.s),
                Expanded(
                  child: CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: const EdgeInsets.symmetric(
                      vertical: TelegramSpacing.s,
                    ),
                    color: theme.colors.linkColor,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: () {
                      widget.onApply?.call();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      '${widget.applyLabel} ($selectedCount)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.buttonTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  const _FilterOptionTile({required this.option, this.onChanged});

  final TelegramSearchFilterOption option;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final description = option.description?.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.s,
      ),
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (option.icon != null) ...[
            Icon(option.icon, size: 17, color: theme.colors.subtitleTextColor),
            const SizedBox(width: TelegramSpacing.s),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: TelegramSpacing.xxs),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: option.selected,
            onChanged: option.locked ? null : onChanged,
          ),
        ],
      ),
    );
  }
}
