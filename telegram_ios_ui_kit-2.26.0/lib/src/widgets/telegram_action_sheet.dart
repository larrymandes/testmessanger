import 'package:flutter/cupertino.dart';

import '../models/telegram_action_item.dart';

class TelegramActionSheet {
  const TelegramActionSheet._();

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    required List<TelegramActionItem> actions,
    String cancelLabel = 'Cancel',
  }) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: title == null ? null : Text(title),
          message: message == null ? null : Text(message),
          actions: [
            for (final action in actions)
              CupertinoActionSheetAction(
                isDestructiveAction: action.isDestructive,
                onPressed: () async {
                  Navigator.of(context).pop();
                  await action.onPressed?.call();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (action.icon != null) ...[
                      Icon(action.icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(action.label),
                  ],
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelLabel),
          ),
        );
      },
    );
  }
}
