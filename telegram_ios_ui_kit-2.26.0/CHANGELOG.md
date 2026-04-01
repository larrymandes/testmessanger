## 2.26.0

* Added sync-status model `TelegramSettingsSyncStatusItem`.
* Added Telegram-style sync overview widget `TelegramSettingsSyncStatusCard` with issue badge and manual sync action.
* Updated Settings demo with cloud sync section and sync item interactions.
* Added widget tests for sync status rendering, callbacks, and empty state.

## 2.25.0

* Added network policy model `TelegramSettingsNetworkPolicy`.
* Added Telegram-style network policy manager widget `TelegramSettingsNetworkPoliciesCard` with toggle rows.
* Updated Settings demo with network policies section and policy toggle handlers.
* Added widget tests for policy card rendering, switch callbacks, and empty state.

## 2.24.0

* Added quiet-hours preset model `TelegramSettingsQuietHoursPreset`.
* Added Telegram-style quiet-hours scheduler widget `TelegramSettingsQuietHoursCard` with switch toggle and selectable presets.
* Updated Settings demo with quiet-hours section and interactive preset switching.
* Added widget tests for quiet-hours card callbacks, preset selection, toggle behavior, and empty state.

## 2.23.0

* Added cleanup suggestion model `TelegramSettingsCleanupSuggestion`.
* Added Telegram-style storage cleanup widget `TelegramSettingsCleanupSuggestionsCard`.
* Updated Settings demo with storage cleanup suggestions and cleanup trigger callback.
* Added widget tests for cleanup suggestion selection, cleanup action, and empty state rendering.

## 2.22.0

* Added auto-download preset model `TelegramSettingsAutoDownloadPreset`.
* Added Telegram-style auto-download selector widget `TelegramSettingsAutoDownloadCard`.
* Updated Settings demo with selectable auto-download presets and management callback.
* Added widget tests for preset selection behavior, manage action, and empty state.

## 2.21.0

* Added data usage model `TelegramSettingsDataUsageItem`.
* Added Telegram-style data usage analytics widget `TelegramSettingsDataUsageCard` with highlighted usage rows and reset action.
* Updated Settings demo with data usage section and interaction callbacks.
* Added widget tests for data usage card rendering, row selection, reset action, and empty state.

## 2.20.0

* Added security action model `TelegramSettingsSecurityAction`.
* Added Telegram-style two-step verification widget `TelegramSettingsTwoStepCard` with status badge and action list.
* Updated Settings demo with a dedicated two-step verification section and interactive action callbacks.
* Added widget tests for two-step card rendering, action callbacks, and empty-state behavior.

## 2.19.0

* Added connected app model `TelegramSettingsConnectedApp`.
* Added Telegram-style connected apps management widget `TelegramSettingsConnectedAppsCard` with revoke actions and warning badges.
* Updated Settings demo with connected app section and interaction callbacks.
* Added widget tests for connected app card callbacks and empty state rendering.

## 2.18.0

* Added security event model `TelegramSettingsSecurityEvent`.
* Added Telegram-style security timeline widget `TelegramSettingsSecurityEventsCard` with high-risk count badge.
* Updated Settings demo with security events section and review interactions.
* Added widget tests for security event card rendering, callback handling, and empty state.

## 2.17.0

* Added privacy exception model `TelegramSettingsPrivacyException`.
* Added Telegram-style privacy overrides widget `TelegramSettingsPrivacyExceptionsCard` with per-row count badges.
* Updated Settings demo with dedicated privacy exceptions section and management callbacks.
* Added widget tests for privacy exception card rendering, selection callbacks, and empty state.

## 2.16.0

* Added active session model `TelegramSettingsSession` for device/session metadata.
* Added Telegram-style sessions card widget `TelegramSettingsSessionsCard` with per-session status badges and optional view-all action.
* Updated Settings demo with active session management section and session interaction callbacks.
* Added widget tests for sessions card rendering, callbacks, status labels, and empty state.

## 2.15.0

* Added storage usage model `TelegramSettingsUsageSegment`.
* Added Telegram-style usage analytics card widget `TelegramSettingsUsageCard` with stacked ratio rail and legend rows.
* Updated Settings demo with device storage section and interactive manage action.
* Added widget tests for usage card rendering, manage callback, and empty-state fallback.

## 2.14.0

* Added settings account header widget `TelegramSettingsAccountCard` with premium badge and optional detail line.
* Added settings action model `TelegramSettingsQuickAction` and action grid widget `TelegramSettingsQuickActionsBar`.
* Updated Settings demo with Telegram-style account card and quick profile actions (QR/Saved/Devices/Logout).
* Added widget tests for account card rendering/tap and quick actions selection/disabled behavior.

## 2.13.0

* Added collapsible settings section widget `TelegramSettingsCollapsibleSection`.
* Added settings helper footer widget `TelegramSettingsSectionFooter`.
* Updated Settings demo with collapsible advanced notification controls and section footer guidance text.
* Added widget tests for collapsible section toggling and footer rendering.

## 2.12.0

* Added settings shortcut model `TelegramSettingsShortcut`.
* Added shortcut widgets: `TelegramSettingsShortcutTile` and `TelegramSettingsShortcutsGrid`.
* Updated Settings demo with quick access shortcuts (privacy/devices/storage/language) and shortcut actions.
* Added widget tests for shortcut tile callbacks and shortcuts grid selection.

## 2.11.0

* Added settings option model `TelegramSettingsOption`.
* Added settings picker widgets: `TelegramSettingsOptionTile` and `TelegramSettingsOptionsSheet`.
* Updated Settings demo with picker-driven cells (`Last Seen & Online`, `Notification Tone`) using modal option sheets.
* Added widget tests for settings option tile callbacks and settings option sheet selection/empty states.

## 2.10.0

* Added iOS-style grouped settings container `TelegramSettingsGroup`.
* Extended `TelegramSettingsCell` with `showDivider` for rounded grouped sections.
* Updated Settings example to use grouped settings sections for account, notifications, and destructive actions.
* Added widget tests for grouped settings rendering and switch toggling.

## 2.9.0

* Added search execution model `TelegramSearchExecution` with status helpers (`isSuccess`, `isFailure`, `isRunning`).
* Added execution widgets: `TelegramSearchExecutionTile`, `TelegramSearchExecutionStatusCard`, and `TelegramSearchExecutionsSheet`.
* Upgraded UI Kit search demo with execution telemetry (status summary, latest run card, execution history sheet, and retry/replay interactions).
* Added widget tests for execution tile callbacks, execution status metrics card, and execution sheet selection/retry/clear workflows.

## 2.8.0

* Added search-result action model `TelegramSearchResultAction`.
* Added selection widgets: `TelegramSearchResultActionBar` and `TelegramSearchSelectionSummaryCard`.
* Upgraded UI Kit search demo with result selection mode, selectable grouped result rows, and bulk result actions.
* Added widget tests for selection summary interactions and result-action bar callbacks.

## 2.7.0

* Added query-token model `TelegramSearchQueryToken`.
* Added query-token widgets: `TelegramSearchQueryTokensBar` and `TelegramSearchQueryInspectorCard`.
* Upgraded UI Kit search demo with removable query token chips, query inspector metadata card, and operator-clearing quick command.
* Added widget tests for query-token bar callbacks and query-inspector card rendering.

## 2.6.0

* Added search-operator model `TelegramSearchOperator`.
* Added operator widgets: `TelegramSearchOperatorsBar` and `TelegramSearchOperatorsSheet`.
* Upgraded UI Kit search demo with operator chips, operator picker sheet, token insertion workflow, and operator-aware result filtering.
* Added widget tests for operator-bar callbacks and operator-sheet selection flow.

## 2.5.0

* Added date-range model `TelegramSearchDateRange`.
* Added date-range widgets: `TelegramSearchDateRangesBar` and `TelegramSearchDateRangesSheet`.
* Extended `TelegramSearchResultStatsBar` with optional date-range metadata (`dateRangeLabel`).
* Upgraded UI Kit search demo with interactive date-range chips, date-range sheet controls, and query filtering by selected range.
* Added widget tests for date-range bar/sheet interactions and stats-bar range metadata rendering.

## 2.4.0

* Added search-command model `TelegramSearchCommand`.
* Added search-command widgets: `TelegramSearchCommandTile` and `TelegramSearchCommandsSheet`.
* Upgraded UI Kit search demo with quick command actions (clear query/filters, reset scope, pause alerts, reuse saved search, clear history).
* Added widget tests for command tile callbacks and command-sheet selection flow.

## 2.3.0

* Added search-alert model `TelegramSearchAlert`.
* Added search-alert widgets: `TelegramSearchAlertTile` and `TelegramSearchAlertsSheet`.
* Upgraded UI Kit search demo with alert management (enable/disable), active alert indicators, and alert-linked quick search restore.
* Added widget tests for alert tile callbacks and alert-sheet interactions.

## 2.2.0

* Added saved-search model `TelegramSavedSearch`.
* Added saved-search widgets: `TelegramSavedSearchesBar` and `TelegramSavedSearchCard`.
* Upgraded UI Kit search demo with one-tap saved-search state restore (query/scope/sort/filters), detachable preset chips, and active saved-search detail cards.
* Added widget tests for saved-search bar callbacks and saved-search card actions.

## 2.1.0

* Added search-sort model `TelegramSearchSortOption`.
* Added search management widgets: `TelegramSearchSortBar`, `TelegramSearchResultStatsBar`, and `TelegramSearchHistorySheet`.
* Upgraded UI Kit search demo with sort switching, result stats metadata, and a searchable history-management sheet.
* Added widget tests for sort bar, result stats bar, and search history sheet behaviors.

## 2.0.0

* Added grouped-search model `TelegramSearchResultGroup`.
* Added search-highlighting and grouping widgets: `TelegramHighlightedText`, `TelegramSearchGroupHeader`, and `TelegramStickySearchGroupHeader`.
* Enhanced `TelegramSearchResultTile` with inline keyword highlighting support via `highlightQuery`.
* Upgraded UI Kit search demo with grouped results and sticky search group headers.
* Added widget tests for highlighted text rendering and search group header components.

## 1.9.0

* Added search-filter model `TelegramSearchFilterOption`.
* Added filter widgets: `TelegramSearchFiltersSheet` and `TelegramActiveSearchFiltersBar`.
* Upgraded UI Kit search demo with interactive filter sheet, active filter chips, and result filtering logic.
* Added widget tests for active-filter callbacks and filter-sheet interactions.

## 1.8.0

* Added search-scope model `TelegramSearchScope`.
* Added search-scope widgets: `TelegramSearchScopesBar` and `TelegramSearchSuggestionTile`.
* Upgraded UI Kit search demo with scope switching (All/Chats/People/Moderation) and removable suggestion rows.
* Added widget tests covering scope selection and suggestion-tile interactions.

## 1.7.0

* Added search-result model `TelegramSearchResult`.
* Added search-experience widgets: `TelegramSearchResultTile`, `TelegramSearchEmptyState`, and `TelegramRecentSearchesBar`.
* Upgraded UI Kit example with interactive search demo (query memory, recent chips, result cards, and empty state).
* Added widget tests covering recent-search callbacks, search-result tile interactions, and empty-state actions.

## 1.6.0

* Added admin filtering model `TelegramAdminAuditFilter`.
* Added management widgets: `TelegramAdminAuditFilterBar`, `TelegramModerationDetailDrawer`, and `TelegramBulkBanActionBar`.
* Upgraded UI Kit and Settings examples with audit-log filters, moderation detail drawers, and bulk restricted-member actions.
* Added widget tests covering filter-bar selection, moderation-drawer actions, and bulk action bar callbacks.

## 1.5.0

* Added advanced moderation models: `TelegramAdminAuditLog` and `TelegramBannedMember`.
* Added moderation widgets: `TelegramAdminAuditLogTile`, `TelegramModerationDetailCard`, and `TelegramBannedMemberTile`.
* Upgraded UI Kit and Settings examples with moderation detail cards, admin audit logs, and restricted-member management flows.
* Added widget tests for new audit log, moderation detail, and banned-member components.

## 1.4.0

* Added channel-management models: `TelegramAdminMember`, `TelegramPermissionToggle`, and `TelegramModerationRequest`.
* Added admin tooling widgets: `TelegramAdminMemberTile`, `TelegramPermissionsPanel`, and `TelegramModerationQueueCard`.
* Upgraded Settings and UI Kit examples with admin team lists, permission controls, and moderation queue previews.
* Added widget tests covering admin tile rendering, permission toggle callbacks, and moderation queue actions.

## 1.3.0

* Added `TelegramChannelInfoHeader` to support Telegram-style channel/group profile headers with verified state and quick actions.
* Added `TelegramChannelStatsGrid` for compact metric cards such as subscribers, media, links, and pinned counters.
* Upgraded UI Kit showcase and Settings example with channel-profile sections and interactive stat actions.
* Added widget tests for channel info header actions and stats grid tap callbacks.

## 1.2.0

* Added `TelegramServiceMessageBubble` for Telegram-style centered system/service notices.
* Added `TelegramJumpToBottomButton` with animated visibility and unread-count badge support.
* Upgraded conversation example with scroll-aware jump-to-latest behavior and simulated incoming message action.
* Added system-message and jump-button previews to the UI Kit showcase.
* Added widget tests for service bubble and jump-to-bottom button components.

## 1.1.0

* Added read-receipt model `TelegramReadReceipt` and new `TelegramReadReceiptsStrip` widget for seen-by avatar summaries.
* Added `TelegramStickyDateHeader` sliver component for pinned date labels in long chat lists.
* Added `TelegramExpandableMessageInputBar` with animated quick tools row for richer composer interactions.
* Upgraded conversation example to include sticky date header, outgoing read receipts, and expandable composer actions.
* Expanded UI Kit showcase with read-receipt strip demo, sticky-header scrolling demo, and expandable input preview.
* Added widget tests for read receipts, sticky date header behavior, and expandable input bar interactions.

## 1.0.0

* Added wallpaper model `TelegramChatWallpaper` and extended `TelegramChatBackground` with configurable wallpaper/pattern parameters.
* Added `TelegramMessageSelectionWrapper` for long-press style selection UX in message lists.
* Enhanced `TelegramChatBubble` with animated outgoing status transitions and sending indicator support.
* Upgraded conversation example with wallpaper switching and interactive message selection mode.
* Expanded UI Kit showcase with selection-wrapper and wallpaper demos.
* Added widget tests for status indicator, selection wrapper, and wallpaper background configuration.

## 0.9.0

* Added layout and timeline support with `TelegramChatBackground`, `TelegramMediaAlbumMessage`, and `TelegramScheduleTimeline`.
* Added timeline model `TelegramTimelineEvent`.
* Upgraded conversation demo with media album and release timeline cards.
* Upgraded conversation container to use reusable `TelegramChatBackground`.
* Expanded UI Kit showcase with layout/timeline section.
* Added widget tests for background, album, and timeline widgets.

## 0.8.0

* Added link/location/contact message support with `TelegramLinkPreviewCard`, `TelegramLocationMessageTile`, and `TelegramContactMessageTile`.
* Added link model `TelegramLinkPreview`.
* Enhanced conversation example with link preview, location card, and contact card demos.
* Expanded UI Kit message-card section to include link/location/contact patterns.
* Added widget tests for new link/location/contact components.

## 0.7.0

* Added message widgets: `TelegramVoiceMessageTile`, `TelegramReferenceMessageCard`, `TelegramChatActionToolbar`.
* Upgraded conversation demo with forwarded/reply card, voice message bubble, and selection action toolbar.
* Expanded UI Kit tab with message-card section for voice/reference/toolbar patterns.
* Added widget tests for new message widgets.

## 0.6.0

* Added composer models: `TelegramAttachmentAction`, `TelegramKeyboardButton`.
* Added new composer widgets: `TelegramAttachmentPanel`, `TelegramReplyPreviewBar`.
* Added bot/file widgets: `TelegramInlineKeyboard`, `TelegramFileMessageTile`, `TelegramPollCard`.
* Upgraded conversation demo with attachment panel bottom sheet, reply preview bar, file message tile, and inline bot keyboard.
* Expanded UI Kit tab with composer component demos.
* Added widget tests for new composer and keyboard/file components.

## 0.5.0

* Added interaction model `TelegramSwipeAction`.
* Added interaction widgets: `TelegramSwipeActions`, `TelegramContextMenu`, `TelegramNoticeBanner`.
* Added large-title widgets: `TelegramLargeTitleHeader`, `TelegramCollapsibleLargeTitle`.
* Expanded example app with a dedicated **UI Kit** tab demonstrating swipe actions, context menu, notice banner, and large-title headers.
* Added widget tests for newly introduced interaction widgets.

## 0.4.0

* Added chat-scene components: `TelegramChatHeader`, `TelegramTypingIndicator`, `TelegramQuickRepliesBar`, `TelegramReactionBar`.
* Added media component: `TelegramMediaGrid` with support for image/video metadata overlays.
* Added models: `TelegramMediaItem`, `TelegramReaction`.
* Extended `TelegramChatPreview` with `folderId` for chat folder filtering scenarios.
* Upgraded example conversation page with chat header, unread separator, reactions, quick replies, and typing indicator.
* Upgraded example settings page with shared media grid demo.
* Added widget tests for message-scene components.

## 0.3.0

* Added advanced interaction widgets: `TelegramActionSheet`, `TelegramToast`, `TelegramComposeFab`.
* Added chat organization widgets: `TelegramChatFoldersBar`, `TelegramUnreadSeparator`.
* Added new models: `TelegramChatFolder`, `TelegramActionItem`.
* Upgraded example with chat folders, action sheet/toast demo, unread separator, and compose FAB usage.
* Added widget tests for advanced components.

## 0.2.0

* Expanded component coverage for Telegram iOS-style UI.
* Added new data models: `TelegramContact`, `TelegramCallLog`, `TelegramStory`.
* Added search and story widgets: `TelegramSearchBar`, `TelegramStoryAvatar`, `TelegramStoriesStrip`.
* Added list/profile widgets: `TelegramContactListTile`, `TelegramCallListTile`, `TelegramProfileHeader`.
* Added chat utilities: `TelegramDateSeparator`, `TelegramPinnedMessageBar`.
* Added `TelegramColors.fromTelegramTheme()` and `toTelegramThemeMap()` to map Telegram color tokens.
* Upgraded example app to a five-tab showcase (Contacts / Calls / Chats / Mini Apps / Settings).

## 0.1.0

* Initial Telegram iOS-style Flutter UI Kit release.
* Added design token theme layer (`TelegramThemeData`, `TelegramColors`).
* Added chat widgets (`TelegramChatListTile`, `TelegramChatBubble`, `TelegramMessageInputBar`).
* Added structural widgets (`TelegramNavigationBar`, `TelegramBottomTabBar`, `TelegramSectionHeader`).
* Added form/settings widgets (`TelegramSettingsCell`, `TelegramSegmentedControl`).
* Added utility widgets (`TelegramAvatar`, `TelegramBadge`, `TelegramMiniAppButton`).
* Added runnable example app and package tests.

## 0.0.1

* Bootstrap package structure.
