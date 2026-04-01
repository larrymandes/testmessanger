import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_search_suggestion_tile.dart';

class TelegramSearchHistorySheet extends StatefulWidget {
  const TelegramSearchHistorySheet({
    super.key,
    required this.entries,
    this.onSelected,
    this.onRemove,
    this.onClearAll,
    this.onClose,
    this.title = 'Search History',
    this.clearLabel = 'Clear All',
  });

  final List<String> entries;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onRemove;
  final VoidCallback? onClearAll;
  final VoidCallback? onClose;
  final String title;
  final String clearLabel;

  static Future<void> show(
    BuildContext context, {
    required List<String> entries,
    ValueChanged<String>? onSelected,
    ValueChanged<String>? onRemove,
    VoidCallback? onClearAll,
    String title = 'Search History',
    String clearLabel = 'Clear All',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSearchHistorySheet(
          entries: entries,
          onSelected: onSelected,
          onRemove: onRemove,
          onClearAll: onClearAll,
          title: title,
          clearLabel: clearLabel,
        );
      },
    );
  }

  @override
  State<TelegramSearchHistorySheet> createState() =>
      _TelegramSearchHistorySheetState();
}

class _TelegramSearchHistorySheetState
    extends State<TelegramSearchHistorySheet> {
  late List<String> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.entries.toList(growable: false);
  }

  void _removeEntry(String query) {
    setState(() {
      _entries = _entries
          .where((value) => value != query)
          .toList(growable: false);
    });
    widget.onRemove?.call(query);
  }

  void _clearEntries() {
    if (_entries.isEmpty) {
      return;
    }
    setState(() => _entries = const []);
    widget.onClearAll?.call();
  }

  void _selectEntry(String query) {
    widget.onSelected?.call(query);
    Navigator.of(context).pop();
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
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_entries.isNotEmpty)
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero,
                    onPressed: _clearEntries,
                    child: Text(
                      widget.clearLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.linkColor,
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
            const SizedBox(height: TelegramSpacing.xs),
            if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TelegramSpacing.l,
                ),
                child: Center(
                  child: Text(
                    'No recent searches.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final query = _entries[index];
                    return TelegramSearchSuggestionTile(
                      query: query,
                      subtitle: 'Tap to reuse query',
                      icon: CupertinoIcons.time,
                      showDivider: index < _entries.length - 1,
                      onTap: () => _selectEntry(query),
                      onRemove: () => _removeEntry(query),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
