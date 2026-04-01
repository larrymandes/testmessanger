import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_moderation_request.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_moderation_detail_card.dart';

class TelegramModerationDetailDrawer extends StatelessWidget {
  const TelegramModerationDetailDrawer({
    super.key,
    required this.request,
    this.tags = const [],
    this.evidenceCount = 0,
    this.reporterLabel,
    this.messagePreview,
    this.onApprove,
    this.onReject,
    this.onOpenThread,
    this.onClose,
    this.title = 'Moderation Detail',
  });

  final TelegramModerationRequest request;
  final List<String> tags;
  final int evidenceCount;
  final String? reporterLabel;
  final String? messagePreview;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onOpenThread;
  final VoidCallback? onClose;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required TelegramModerationRequest request,
    List<String> tags = const [],
    int evidenceCount = 0,
    String? reporterLabel,
    String? messagePreview,
    VoidCallback? onApprove,
    VoidCallback? onReject,
    VoidCallback? onOpenThread,
    String title = 'Moderation Detail',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TelegramModerationDetailDrawer(
          request: request,
          tags: tags,
          evidenceCount: evidenceCount,
          reporterLabel: reporterLabel,
          messagePreview: messagePreview,
          onApprove: onApprove,
          onReject: onReject,
          onOpenThread: onOpenThread,
          title: title,
        );
      },
    );
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
            if (reporterLabel != null && reporterLabel!.trim().isNotEmpty) ...[
              const SizedBox(height: TelegramSpacing.xs),
              Text(
                reporterLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colors.subtitleTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (messagePreview != null && messagePreview!.trim().isNotEmpty) ...[
              const SizedBox(height: TelegramSpacing.s),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TelegramSpacing.s),
                decoration: BoxDecoration(
                  color: theme.colors.sectionBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colors.separatorColor, width: 0.5),
                ),
                child: Text(
                  messagePreview!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colors.textColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
            const SizedBox(height: TelegramSpacing.s),
            TelegramModerationDetailCard(
              request: request,
              tags: tags,
              evidenceCount: evidenceCount,
              onApprove: () {
                onApprove?.call();
                Navigator.of(context).pop();
              },
              onReject: () {
                onReject?.call();
                Navigator.of(context).pop();
              },
              onOpenThread: () {
                onOpenThread?.call();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
