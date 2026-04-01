import 'package:flutter/cupertino.dart';

import '../theme/telegram_theme.dart';

class TelegramSegmentedControl<T extends Object> extends StatelessWidget {
  const TelegramSegmentedControl({
    super.key,
    required this.values,
    required this.currentValue,
    this.onValueChanged,
  });

  final Map<T, String> values;
  final T currentValue;
  final ValueChanged<T>? onValueChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: currentValue,
      thumbColor: theme.colors.sectionBgColor,
      backgroundColor: theme.colors.secondaryBgColor,
      children: {
        for (final entry in values.entries)
          entry.key: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              entry.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colors.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      },
      onValueChanged: (value) {
        if (value == null) {
          return;
        }
        onValueChanged?.call(value);
      },
    );
  }
}
