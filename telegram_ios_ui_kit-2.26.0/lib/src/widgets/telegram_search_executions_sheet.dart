import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_search_execution.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_search_execution_tile.dart';

class TelegramSearchExecutionsSheet extends StatefulWidget {
  const TelegramSearchExecutionsSheet({
    super.key,
    required this.executions,
    this.onSelected,
    this.onRetry,
    this.onClearAll,
    this.onClose,
    this.title = 'Search Executions',
    this.clearLabel = 'Clear All',
  });

  final List<TelegramSearchExecution> executions;
  final ValueChanged<TelegramSearchExecution>? onSelected;
  final ValueChanged<TelegramSearchExecution>? onRetry;
  final VoidCallback? onClearAll;
  final VoidCallback? onClose;
  final String title;
  final String clearLabel;

  static Future<void> show(
    BuildContext context, {
    required List<TelegramSearchExecution> executions,
    ValueChanged<TelegramSearchExecution>? onSelected,
    ValueChanged<TelegramSearchExecution>? onRetry,
    VoidCallback? onClearAll,
    VoidCallback? onClose,
    String title = 'Search Executions',
    String clearLabel = 'Clear All',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSearchExecutionsSheet(
          executions: executions,
          onSelected: onSelected,
          onRetry: onRetry,
          onClearAll: onClearAll,
          onClose: onClose,
          title: title,
          clearLabel: clearLabel,
        );
      },
    );
  }

  @override
  State<TelegramSearchExecutionsSheet> createState() =>
      _TelegramSearchExecutionsSheetState();
}

class _TelegramSearchExecutionsSheetState
    extends State<TelegramSearchExecutionsSheet> {
  late List<TelegramSearchExecution> _executions;

  @override
  void initState() {
    super.initState();
    _executions = widget.executions.toList(growable: false);
  }

  void _clearExecutions() {
    if (_executions.isEmpty) {
      return;
    }
    setState(() => _executions = const []);
    widget.onClearAll?.call();
  }

  void _retryExecution(TelegramSearchExecution execution) {
    widget.onRetry?.call(execution);
  }

  void _selectExecution(TelegramSearchExecution execution) {
    widget.onSelected?.call(execution);
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
                if (_executions.isNotEmpty)
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero,
                    onPressed: _clearExecutions,
                    child: Text(
                      widget.clearLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.destructiveTextColor,
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
            const SizedBox(height: TelegramSpacing.xs),
            if (_executions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TelegramSpacing.l,
                ),
                child: Center(
                  child: Text(
                    'No executions yet.',
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
                    itemCount: _executions.length,
                    itemBuilder: (context, index) {
                      final execution = _executions[index];
                      return TelegramSearchExecutionTile(
                        execution: execution,
                        showDivider: index < _executions.length - 1,
                        onTap: _selectExecution,
                        onRetry: execution.isFailure ? _retryExecution : null,
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
