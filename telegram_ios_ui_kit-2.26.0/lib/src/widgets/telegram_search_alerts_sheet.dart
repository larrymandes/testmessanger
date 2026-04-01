import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_search_alert.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_search_alert_tile.dart';

class TelegramSearchAlertsSheet extends StatefulWidget {
  const TelegramSearchAlertsSheet({
    super.key,
    required this.alerts,
    this.onAlertChanged,
    this.onTapAlert,
    this.onDisableAll,
    this.onClose,
    this.title = 'Search Alerts',
    this.disableAllLabel = 'Disable All',
  });

  final List<TelegramSearchAlert> alerts;
  final ValueChanged<TelegramSearchAlert>? onAlertChanged;
  final ValueChanged<TelegramSearchAlert>? onTapAlert;
  final VoidCallback? onDisableAll;
  final VoidCallback? onClose;
  final String title;
  final String disableAllLabel;

  static Future<void> show(
    BuildContext context, {
    required List<TelegramSearchAlert> alerts,
    ValueChanged<TelegramSearchAlert>? onAlertChanged,
    ValueChanged<TelegramSearchAlert>? onTapAlert,
    VoidCallback? onDisableAll,
    String title = 'Search Alerts',
    String disableAllLabel = 'Disable All',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramSearchAlertsSheet(
          alerts: alerts,
          onAlertChanged: onAlertChanged,
          onTapAlert: onTapAlert,
          onDisableAll: onDisableAll,
          title: title,
          disableAllLabel: disableAllLabel,
        );
      },
    );
  }

  @override
  State<TelegramSearchAlertsSheet> createState() =>
      _TelegramSearchAlertsSheetState();
}

class _TelegramSearchAlertsSheetState extends State<TelegramSearchAlertsSheet> {
  late List<TelegramSearchAlert> _alerts;

  @override
  void initState() {
    super.initState();
    _alerts = widget.alerts.toList(growable: false);
  }

  void _updateAlert(TelegramSearchAlert alert, bool value) {
    final updated = alert.copyWith(enabled: value);
    setState(() {
      _alerts = _alerts
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
    });
    widget.onAlertChanged?.call(updated);
  }

  void _disableAll() {
    if (_alerts.every((alert) => !alert.enabled)) {
      return;
    }
    setState(() {
      _alerts = _alerts
          .map((alert) => alert.copyWith(enabled: false))
          .toList(growable: false);
    });
    widget.onDisableAll?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final hasEnabledAlert = _alerts.any((alert) => alert.enabled);

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
                if (hasEnabledAlert)
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: EdgeInsets.zero,
                    onPressed: _disableAll,
                    child: Text(
                      widget.disableAllLabel,
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
            if (_alerts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: TelegramSpacing.l,
                ),
                child: Center(
                  child: Text(
                    'No alerts yet.',
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
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      final alert = _alerts[index];
                      return TelegramSearchAlertTile(
                        alert: alert,
                        showDivider: index < _alerts.length - 1,
                        onTap: () => widget.onTapAlert?.call(alert),
                        onChanged: (value) => _updateAlert(alert, value),
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
