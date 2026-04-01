import 'package:flutter/material.dart';

import '../models/telegram_read_receipt.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramReadReceiptsStrip extends StatelessWidget {
  const TelegramReadReceiptsStrip({
    super.key,
    required this.receipts,
    this.maxVisible = 3,
    this.avatarSize = 18,
    this.overlap = 5,
    this.prefixLabel = 'Seen by',
    this.timeLabel,
    this.onTap,
  });

  final List<TelegramReadReceipt> receipts;
  final int maxVisible;
  final double avatarSize;
  final double overlap;
  final String prefixLabel;
  final String? timeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    final safeMaxVisible = maxVisible < 1 ? 1 : maxVisible;
    final visibleReceipts = receipts
        .take(safeMaxVisible)
        .toList(growable: false);
    final overflowCount = receipts.length - visibleReceipts.length;
    final step = avatarSize - overlap <= 0 ? avatarSize : avatarSize - overlap;
    final avatarCount = visibleReceipts.length + (overflowCount > 0 ? 1 : 0);
    final avatarWidth = avatarSize + (avatarCount - 1) * step;
    final label = _label();

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: avatarWidth,
          height: avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < visibleReceipts.length; i++)
                Positioned(
                  left: i * step,
                  child: _ReceiptAvatar(
                    size: avatarSize,
                    receipt: visibleReceipts[i],
                  ),
                ),
              if (overflowCount > 0)
                Positioned(
                  left: visibleReceipts.length * step,
                  child: _OverflowAvatar(
                    size: avatarSize,
                    count: overflowCount,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: TelegramSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colors.subtitleTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }

  String _label() {
    final base = receipts.length == 1
        ? '$prefixLabel ${receipts.first.name}'
        : '$prefixLabel ${receipts.length}';
    final effectiveTime = _effectiveTimeLabel();
    if (effectiveTime == null) {
      return base;
    }
    return '$base · $effectiveTime';
  }

  String? _effectiveTimeLabel() {
    final provided = timeLabel?.trim();
    if (provided != null && provided.isNotEmpty) {
      return provided;
    }
    for (final receipt in receipts) {
      final value = receipt.seenAtLabel?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}

class _ReceiptAvatar extends StatelessWidget {
  const _ReceiptAvatar({required this.size, required this.receipt});

  final double size;
  final TelegramReadReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final fallback = receipt.avatarFallback.isNotEmpty
        ? receipt.avatarFallback
        : receipt.name;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colors.headerBgColor, width: 1.4),
      ),
      child: TelegramAvatar(
        image: receipt.avatarImage,
        fallbackText: fallback,
        size: size,
      ),
    );
  }
}

class _OverflowAvatar extends StatelessWidget {
  const _OverflowAvatar({required this.size, required this.count});

  final double size;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colors.secondaryBgColor,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colors.headerBgColor, width: 1.4),
      ),
      child: Text(
        '+$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colors.subtitleTextColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
