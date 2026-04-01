import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsCollapsibleSection extends StatefulWidget {
  const TelegramSettingsCollapsibleSection({
    super.key,
    required this.title,
    required this.children,
    this.footer,
    this.initiallyExpanded = true,
    this.onExpandedChanged,
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      TelegramSpacing.m,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
    this.expandLabel = 'Expand',
    this.collapseLabel = 'Collapse',
  });

  final String title;
  final List<Widget> children;
  final Widget? footer;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpandedChanged;
  final EdgeInsets margin;
  final String expandLabel;
  final String collapseLabel;

  @override
  State<TelegramSettingsCollapsibleSection> createState() =>
      _TelegramSettingsCollapsibleSectionState();
}

class _TelegramSettingsCollapsibleSectionState
    extends State<TelegramSettingsCollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    widget.onExpandedChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;

    return Padding(
      padding: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: TelegramSpacing.s,
              right: TelegramSpacing.s,
              bottom: TelegramSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colors.subtitleTextColor,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 20),
                  onPressed: _toggleExpanded,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _expanded ? widget.collapseLabel : widget.expandLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: TelegramSpacing.xs),
                      Icon(
                        _expanded
                            ? CupertinoIcons.chevron_up
                            : CupertinoIcons.chevron_down,
                        size: 12,
                        color: theme.colors.linkColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_expanded)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.children,
              ),
            ),
          if (_expanded) ...[widget.footer].whereType<Widget>(),
        ],
      ),
    );
  }
}
