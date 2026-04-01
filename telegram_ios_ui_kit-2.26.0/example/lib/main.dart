import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';

void main() {
  runApp(const TelegramExampleApp());
}

class TelegramExampleApp extends StatelessWidget {
  const TelegramExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final light = TelegramThemeData.light();
    final dark = TelegramThemeData.dark();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Telegram iOS UI Kit',
      theme: light.toThemeData(brightness: Brightness.light),
      darkTheme: dark.toThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final data = brightness == Brightness.dark ? dark : light;
        return TelegramTheme(
          data: data,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const TelegramUIKitShowcase(),
    );
  }
}

class TelegramUIKitShowcase extends StatefulWidget {
  const TelegramUIKitShowcase({super.key});

  @override
  State<TelegramUIKitShowcase> createState() => _TelegramUIKitShowcaseState();
}

class _TelegramUIKitShowcaseState extends State<TelegramUIKitShowcase> {
  int _tabIndex = 2;

  final List<TelegramContact> _contacts = const [
    TelegramContact(
      id: 'c1',
      name: 'Alice Johnson',
      subtitle: 'Product Designer',
      avatarFallback: 'AJ',
      isOnline: true,
      isVerified: true,
    ),
    TelegramContact(
      id: 'c2',
      name: 'Bob Chen',
      subtitle: 'Frontend Engineer',
      avatarFallback: 'BC',
      isOnline: true,
    ),
    TelegramContact(
      id: 'c3',
      name: 'Nova Support Bot',
      subtitle: 'Official bot · @nova_support_bot',
      avatarFallback: 'NB',
      isVerified: true,
    ),
    TelegramContact(
      id: 'c4',
      name: 'Design Team',
      subtitle: '24 members',
      avatarFallback: 'DT',
    ),
    TelegramContact(
      id: 'c5',
      name: 'Family',
      subtitle: '5 members',
      avatarFallback: 'FA',
    ),
  ];

  final List<TelegramCallLog> _calls = const [
    TelegramCallLog(
      id: 'call1',
      name: 'Alice Johnson',
      timeLabel: 'Today 09:10',
      durationLabel: '12:43',
      direction: TelegramCallDirection.outgoing,
      type: TelegramCallType.video,
      avatarFallback: 'AJ',
    ),
    TelegramCallLog(
      id: 'call2',
      name: 'Family',
      timeLabel: 'Yesterday 21:06',
      durationLabel: '02:15',
      direction: TelegramCallDirection.incoming,
      type: TelegramCallType.audio,
      avatarFallback: 'FA',
    ),
    TelegramCallLog(
      id: 'call3',
      name: 'Unknown Number',
      timeLabel: 'Yesterday 16:28',
      direction: TelegramCallDirection.missed,
      type: TelegramCallType.audio,
      avatarFallback: '??',
    ),
    TelegramCallLog(
      id: 'call4',
      name: 'Design Team',
      timeLabel: 'Mon 18:00',
      durationLabel: '18:22',
      direction: TelegramCallDirection.outgoing,
      type: TelegramCallType.audio,
      avatarFallback: 'DT',
    ),
  ];

  final List<TelegramStory> _stories = const [
    TelegramStory(id: 's1', title: 'Your Story', avatarFallback: 'ME'),
    TelegramStory(id: 's2', title: 'Alice', avatarFallback: 'AJ'),
    TelegramStory(id: 's3', title: 'Bob', avatarFallback: 'BC'),
    TelegramStory(
      id: 's4',
      title: 'Product',
      avatarFallback: 'PU',
      hasUnseenStories: false,
    ),
    TelegramStory(id: 's5', title: 'Family', avatarFallback: 'FA'),
  ];

  final List<TelegramChatPreview> _chats = const [
    TelegramChatPreview(
      id: '1',
      title: 'Design Team',
      subtitle: 'Alice: Please review the new mini app flow',
      timeLabel: '14:05',
      unreadCount: 3,
      avatarFallback: 'DT',
      isOnline: true,
      isPinned: true,
      folderId: 'work',
    ),
    TelegramChatPreview(
      id: '2',
      title: 'Nova Bot',
      subtitle: 'Use /menu to open commands',
      timeLabel: '13:52',
      unreadCount: 1,
      avatarFallback: 'NB',
      isMuted: true,
      folderId: 'bots',
    ),
    TelegramChatPreview(
      id: '3',
      title: 'Product Updates',
      subtitle: 'Weekly notes have been posted',
      timeLabel: 'Yesterday',
      avatarFallback: 'PU',
      folderId: 'work',
    ),
    TelegramChatPreview(
      id: '4',
      title: 'Family',
      subtitle: 'Mom: Dinner at 7 pm 🍜',
      timeLabel: 'Mon',
      avatarFallback: 'FA',
      unreadCount: 10,
      isOnline: true,
      folderId: 'private',
    ),
  ];

  final List<TelegramChatFolder> _chatFolders = const [
    TelegramChatFolder(id: 'all', title: 'All', unreadCount: 14),
    TelegramChatFolder(id: 'work', title: 'Work', unreadCount: 3),
    TelegramChatFolder(id: 'private', title: 'Private', unreadCount: 10),
    TelegramChatFolder(id: 'bots', title: 'Bots', unreadCount: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ContactsTab(contacts: _contacts),
      _CallsTab(calls: _calls),
      _ChatsTab(chats: _chats, stories: _stories, folders: _chatFolders),
      const _UIKitTab(),
      const _MiniAppsTab(),
      const _SettingsTab(),
    ];

    return Scaffold(
      body: pages[_tabIndex],
      bottomNavigationBar: TelegramBottomTabBar(
        items: const [
          TelegramTabItem(
            icon: CupertinoIcons.person_2,
            activeIcon: CupertinoIcons.person_2_fill,
            label: 'Contacts',
          ),
          TelegramTabItem(
            icon: CupertinoIcons.phone,
            activeIcon: CupertinoIcons.phone_fill,
            label: 'Calls',
          ),
          TelegramTabItem(
            icon: CupertinoIcons.chat_bubble_2,
            activeIcon: CupertinoIcons.chat_bubble_2_fill,
            label: 'Chats',
          ),
          TelegramTabItem(
            icon: CupertinoIcons.square_grid_2x2,
            activeIcon: CupertinoIcons.square_grid_2x2_fill,
            label: 'UI Kit',
          ),
          TelegramTabItem(
            icon: CupertinoIcons.app_badge,
            activeIcon: CupertinoIcons.app_badge_fill,
            label: 'Mini Apps',
          ),
          TelegramTabItem(
            icon: CupertinoIcons.settings,
            activeIcon: CupertinoIcons.settings_solid,
            label: 'Settings',
          ),
        ],
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
      ),
    );
  }
}

class _ContactsTab extends StatefulWidget {
  const _ContactsTab({required this.contacts});

  final List<TelegramContact> contacts;

  @override
  State<_ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<_ContactsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final contacts = widget.contacts
        .where(
          (contact) =>
              _query.isEmpty ||
              contact.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: theme.colors.secondaryBgColor,
      floatingActionButton: TelegramComposeFab(
        label: 'New Contact',
        icon: CupertinoIcons.person_crop_circle_badge_plus,
        onPressed: () {},
      ),
      body: Column(
        children: [
          TelegramNavigationBar(
            title: 'Contacts',
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Text(
                'Add',
                style: TextStyle(color: theme.colors.linkColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TelegramSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return TelegramContactListTile(
                  contact: contact,
                  trailing: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    size: 18,
                    color: theme.colors.linkColor,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _CallFilter { all, missed }

class _CallsTab extends StatefulWidget {
  const _CallsTab({required this.calls});

  final List<TelegramCallLog> calls;

  @override
  State<_CallsTab> createState() => _CallsTabState();
}

class _CallsTabState extends State<_CallsTab> {
  _CallFilter _filter = _CallFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final calls = _filter == _CallFilter.all
        ? widget.calls
        : widget.calls
              .where((call) => call.direction == TelegramCallDirection.missed)
              .toList(growable: false);

    return Scaffold(
      backgroundColor: theme.colors.secondaryBgColor,
      floatingActionButton: TelegramComposeFab(
        label: 'New Call',
        icon: CupertinoIcons.phone_fill,
        extended: false,
        onPressed: () {},
      ),
      body: Column(
        children: [
          TelegramNavigationBar(
            title: 'Calls',
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Text(
                'Edit',
                style: TextStyle(color: theme.colors.linkColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TelegramSegmentedControl<_CallFilter>(
              values: const {
                _CallFilter.all: 'All',
                _CallFilter.missed: 'Missed',
              },
              currentValue: _filter,
              onValueChanged: (value) => setState(() => _filter = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                return TelegramCallListTile(
                  call: call,
                  onTap: () {
                    TelegramToast.show(
                      context,
                      message: 'Calling ${call.name}...',
                    );
                  },
                  onInfoTap: () {
                    TelegramToast.show(context, message: 'Call details opened');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatsTab extends StatefulWidget {
  const _ChatsTab({
    required this.chats,
    required this.stories,
    required this.folders,
  });

  final List<TelegramChatPreview> chats;
  final List<TelegramStory> stories;
  final List<TelegramChatFolder> folders;

  @override
  State<_ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<_ChatsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedFolderId = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final chats = widget.chats
        .where(
          (chat) =>
              (_selectedFolderId == 'all' ||
                  chat.folderId == _selectedFolderId) &&
              (_query.isEmpty ||
                  chat.title.toLowerCase().contains(_query.toLowerCase()) ||
                  chat.subtitle.toLowerCase().contains(_query.toLowerCase())),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      floatingActionButton: TelegramComposeFab(
        label: 'New Message',
        icon: CupertinoIcons.square_pencil,
        onPressed: () {},
      ),
      body: Column(
        children: [
          TelegramNavigationBar(
            title: 'Chats',
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Text(
                'Edit',
                style: TextStyle(color: theme.colors.linkColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TelegramSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          TelegramStoriesStrip(stories: widget.stories),
          TelegramChatFoldersBar(
            folders: widget.folders,
            selectedFolderId: _selectedFolderId,
            onFolderSelected: (folder) {
              setState(() => _selectedFolderId = folder.id);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return TelegramChatListTile(
                  chat: chat,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _ConversationPage(chat: chat),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationPage extends StatefulWidget {
  const _ConversationPage({required this.chat});

  final TelegramChatPreview chat;

  @override
  State<_ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<_ConversationPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  bool _showReplyPreview = true;
  bool _showActionToolbar = true;
  bool _voicePlaying = false;
  bool _showJumpToLatest = false;
  double _voiceProgress = 0.42;
  int _wallpaperIndex = 0;
  int _pendingIncomingCount = 0;
  final Set<String> _selectedMessageIds = <String>{};
  final TelegramLinkPreview _linkPreview = const TelegramLinkPreview(
    url: 'https://core.telegram.org/bots/webapps',
    title: 'Web Apps for Bots',
    description:
        'Build rich mini app experiences that open directly in Telegram chats.',
    domain: 'core.telegram.org',
    siteName: 'Telegram Docs',
    thumbnailLabel: 'DOC',
  );
  final List<TelegramTimelineEvent> _timelineEvents = const [
    TelegramTimelineEvent(
      id: 'timeline_1',
      title: 'Design QA',
      timeLabel: '13:00',
      subtitle: 'Contrast and spacing verification',
      completed: true,
    ),
    TelegramTimelineEvent(
      id: 'timeline_2',
      title: 'iOS Snapshot',
      timeLabel: '14:00',
      subtitle: 'Generate screenshot set from simulator',
      current: true,
    ),
    TelegramTimelineEvent(
      id: 'timeline_3',
      title: 'Publish Dry Run',
      timeLabel: '16:00',
      subtitle: 'Validate package metadata and warnings',
    ),
  ];
  final List<TelegramChatWallpaper> _wallpapers = const [
    TelegramChatWallpaper.gradient(
      primaryColor: Color(0xFFF8FAFF),
      secondaryColor: Color(0xFFEFF4FF),
      patternColor: Color(0x332F6AFF),
    ),
    TelegramChatWallpaper.gradient(
      primaryColor: Color(0xFFFFF9F1),
      secondaryColor: Color(0xFFFFEFE1),
      patternColor: Color(0x33FF8F3D),
    ),
    TelegramChatWallpaper.gradient(
      primaryColor: Color(0xFFF4FFF8),
      secondaryColor: Color(0xFFE9FDF0),
      patternColor: Color(0x3330B870),
    ),
  ];

  final List<TelegramMessage> _messages = [
    const TelegramMessage(
      id: 'm1',
      text: 'Hey! Can we ship the bot button today?',
      timeLabel: '14:01',
      isOutgoing: false,
    ),
    const TelegramMessage(
      id: 'm2',
      text: 'Yes, I mapped Web App / Text Commands / Close App variants.',
      timeLabel: '14:03',
      isOutgoing: true,
      status: TelegramMessageStatus.read,
    ),
    const TelegramMessage(
      id: 'm3',
      text: 'Great. Let us also align call tiles and profile blocks.',
      timeLabel: '14:04',
      isOutgoing: false,
    ),
  ];
  List<TelegramReaction> _reactions = const [
    TelegramReaction(emoji: '👍', count: 4),
    TelegramReaction(emoji: '🔥', count: 2, selected: true),
    TelegramReaction(emoji: '❤️', count: 1),
  ];
  List<TelegramPollOption> _pollOptions = const [
    TelegramPollOption(
      id: 'p1',
      label: 'Ship today',
      votes: 12,
      selected: true,
    ),
    TelegramPollOption(id: 'p2', label: 'Ship tomorrow', votes: 7),
    TelegramPollOption(id: 'p3', label: 'Need review first', votes: 3),
  ];
  final List<TelegramReadReceipt> _readReceipts = const [
    TelegramReadReceipt(
      id: 'r1',
      name: 'Alice Johnson',
      avatarFallback: 'AJ',
      seenAtLabel: '14:10',
    ),
    TelegramReadReceipt(
      id: 'r2',
      name: 'Bob Chen',
      avatarFallback: 'BC',
      seenAtLabel: '14:10',
    ),
    TelegramReadReceipt(
      id: 'r3',
      name: 'Product QA',
      avatarFallback: 'PQ',
      seenAtLabel: '14:11',
    ),
  ];

  final List<String> _quickReplies = const [
    'Looks good 👌',
    'I will check now',
    'Can we call?',
    'Done',
  ];
  final List<List<TelegramKeyboardButton>> _botKeyboardRows = const [
    [
      TelegramKeyboardButton(
        label: 'Open Menu',
        icon: CupertinoIcons.square_grid_2x2,
      ),
      TelegramKeyboardButton(
        label: 'Help',
        icon: CupertinoIcons.question_circle,
      ),
    ],
    [
      TelegramKeyboardButton(
        label: 'Track Order',
        icon: CupertinoIcons.cube_box_fill,
      ),
      TelegramKeyboardButton(
        label: 'Stop Bot',
        icon: CupertinoIcons.stop_circle,
        isDestructive: true,
      ),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _messagesScrollController.addListener(_handleMessageListScroll);
  }

  @override
  void dispose() {
    _messagesScrollController
      ..removeListener(_handleMessageListScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _send(String value) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _messages.add(
        TelegramMessage(
          id: messageId,
          text: value,
          timeLabel: TimeOfDay.now().format(context),
          isOutgoing: true,
          status: TelegramMessageStatus.sending,
        ),
      );
      _showReplyPreview = false;
    });
    _scheduleScrollToLatest();
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      _updateMessageStatus(messageId, TelegramMessageStatus.delivered);
    });
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) {
        return;
      }
      _updateMessageStatus(messageId, TelegramMessageStatus.read);
    });
  }

  void _updateMessageStatus(String messageId, TelegramMessageStatus status) {
    setState(() {
      final index = _messages.indexWhere((message) => message.id == messageId);
      if (index < 0) {
        return;
      }
      final message = _messages[index];
      _messages[index] = TelegramMessage(
        id: message.id,
        text: message.text,
        timeLabel: message.timeLabel,
        isOutgoing: message.isOutgoing,
        status: status,
        isEdited: message.isEdited,
      );
    });
  }

  void _toggleReaction(TelegramReaction target) {
    setState(() {
      _reactions = _reactions
          .map(
            (reaction) => reaction.emoji == target.emoji
                ? reaction.copyWith(selected: !reaction.selected)
                : reaction,
          )
          .toList(growable: false);
    });
  }

  void _useQuickReply(String reply) {
    _controller.text = reply;
    _send(reply);
    _controller.clear();
  }

  void _togglePollOption(TelegramPollOption target) {
    setState(() {
      _pollOptions = _pollOptions
          .map(
            (option) => option.id == target.id
                ? option.copyWith(selected: !option.selected)
                : option.copyWith(selected: false),
          )
          .toList(growable: false);
    });
  }

  void _toggleVoicePlayback() {
    setState(() {
      _voicePlaying = !_voicePlaying;
      _voiceProgress = (_voiceProgress + (_voicePlaying ? 0.08 : 0.02)).clamp(
        0.0,
        1.0,
      );
    });
  }

  void _openLinkPreview() {
    TelegramToast.show(context, message: 'Opening ${_linkPreview.domain}...');
  }

  void _openContactMessage() {
    TelegramToast.show(context, message: 'Contact message composer opened');
  }

  void _openTimelineEvent(TelegramTimelineEvent event) {
    TelegramToast.show(context, message: 'Timeline: ${event.title}');
  }

  bool get _isNearBottom {
    if (!_messagesScrollController.hasClients) {
      return true;
    }
    final position = _messagesScrollController.position;
    final distance = position.maxScrollExtent - position.pixels;
    return distance < 96;
  }

  void _handleMessageListScroll() {
    final shouldShow = !_isNearBottom;
    if (shouldShow == _showJumpToLatest &&
        (shouldShow || _pendingIncomingCount == 0)) {
      return;
    }
    setState(() {
      _showJumpToLatest = shouldShow;
      if (!shouldShow) {
        _pendingIncomingCount = 0;
      }
    });
  }

  void _scheduleScrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messagesScrollController.hasClients) {
        return;
      }
      final position = _messagesScrollController.position.maxScrollExtent;
      _messagesScrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _jumpToLatest() async {
    if (!_messagesScrollController.hasClients) {
      return;
    }
    final position = _messagesScrollController.position.maxScrollExtent;
    await _messagesScrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) {
      return;
    }
    setState(() => _pendingIncomingCount = 0);
  }

  void _simulateIncomingMessage() {
    final shouldAutoScroll = _isNearBottom;
    final candidateMessages = [
      'Noted. I am preparing the final icon export.',
      'Can we confirm the dark mode contrast one more time?',
      'Great, I will send iOS screenshots in 2 minutes.',
    ];
    final text = candidateMessages[_messages.length % candidateMessages.length];
    setState(() {
      _messages.add(
        TelegramMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          timeLabel: TimeOfDay.now().format(context),
          isOutgoing: false,
        ),
      );
      if (!shouldAutoScroll) {
        _showJumpToLatest = true;
        _pendingIncomingCount += 1;
      } else {
        _pendingIncomingCount = 0;
      }
    });
    if (shouldAutoScroll) {
      _scheduleScrollToLatest();
    }
  }

  void _showReadReceipts() {
    final names = _readReceipts
        .take(3)
        .map((receipt) => receipt.name.split(' ').first)
        .join(', ');
    TelegramToast.show(context, message: 'Seen by $names');
  }

  bool _isLastOutgoingReadMessage(int index) {
    final current = _messages[index];
    if (!current.isOutgoing || current.status != TelegramMessageStatus.read) {
      return false;
    }
    for (var i = index + 1; i < _messages.length; i++) {
      final next = _messages[i];
      if (next.isOutgoing && next.status == TelegramMessageStatus.read) {
        return false;
      }
    }
    return true;
  }

  bool get _selectionMode => _selectedMessageIds.isNotEmpty;

  void _startSelectionForMessage(TelegramMessage message) {
    setState(() {
      _selectedMessageIds.add(message.id);
      _showActionToolbar = true;
    });
  }

  void _toggleSelectionForMessage(TelegramMessage message) {
    setState(() {
      if (_selectedMessageIds.contains(message.id)) {
        _selectedMessageIds.remove(message.id);
      } else {
        _selectedMessageIds.add(message.id);
      }
    });
  }

  void _clearMessageSelection() {
    setState(() {
      _selectedMessageIds.clear();
    });
  }

  void _selectAllMessages() {
    setState(() {
      _selectedMessageIds
        ..clear()
        ..addAll(_messages.map((message) => message.id));
    });
  }

  void _deleteSelectedMessages() {
    if (_selectedMessageIds.isEmpty) {
      return;
    }
    setState(() {
      _messages.removeWhere(
        (message) => _selectedMessageIds.contains(message.id),
      );
      _selectedMessageIds.clear();
    });
    TelegramToast.show(context, message: 'Selected messages deleted');
  }

  void _cycleWallpaper() {
    setState(() {
      _wallpaperIndex = (_wallpaperIndex + 1) % _wallpapers.length;
    });
    TelegramToast.show(
      context,
      message:
          'Wallpaper switched (${_wallpaperIndex + 1}/${_wallpapers.length})',
    );
  }

  Future<void> _showAttachmentPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return TelegramAttachmentPanel(
          title: 'Attachment',
          actions: [
            TelegramAttachmentAction(
              label: 'Photo',
              icon: CupertinoIcons.photo,
              onPressed: () async {
                if (!mounted) {
                  return;
                }
                TelegramToast.show(context, message: 'Photo picker opened');
              },
            ),
            TelegramAttachmentAction(
              label: 'File',
              icon: CupertinoIcons.doc_fill,
              onPressed: () async {
                if (!mounted) {
                  return;
                }
                TelegramToast.show(context, message: 'File picker opened');
              },
            ),
            TelegramAttachmentAction(
              label: 'Location',
              icon: CupertinoIcons.location_solid,
              onPressed: () async {
                if (!mounted) {
                  return;
                }
                TelegramToast.show(context, message: 'Location sent');
              },
            ),
            TelegramAttachmentAction(
              label: 'Poll',
              icon: CupertinoIcons.chart_bar_alt_fill,
              onPressed: () async {
                if (!mounted) {
                  return;
                }
                TelegramToast.show(context, message: 'Poll created');
              },
            ),
          ],
          onActionTap: (action) {
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  void _handleKeyboardTap(TelegramKeyboardButton button) {
    TelegramToast.show(context, message: 'Tapped: ${button.label}');
  }

  @override
  Widget build(BuildContext context) {
    final currentWallpaper = _wallpapers[_wallpaperIndex];
    final chatActions = [
      TelegramActionItem(
        label: 'Copy',
        icon: CupertinoIcons.doc_on_doc,
        onPressed: () async {
          TelegramToast.show(context, message: 'Message copied');
        },
      ),
      TelegramActionItem(
        label: 'Simulate',
        icon: CupertinoIcons.reply_all,
        onPressed: () async {
          _simulateIncomingMessage();
        },
      ),
      TelegramActionItem(
        label: 'Wallpaper',
        icon: CupertinoIcons.photo_fill_on_rectangle_fill,
        onPressed: () async {
          _cycleWallpaper();
        },
      ),
      TelegramActionItem(
        label: 'Delete',
        icon: CupertinoIcons.delete,
        isDestructive: true,
        onPressed: () async {
          TelegramToast.show(context, message: 'Selection deleted');
        },
      ),
    ];
    final selectionActions = [
      TelegramActionItem(
        label: 'Select All',
        icon: CupertinoIcons.checkmark_alt_circle,
        onPressed: () async {
          _selectAllMessages();
        },
      ),
      TelegramActionItem(
        label: 'Delete',
        icon: CupertinoIcons.delete,
        isDestructive: true,
        onPressed: () async {
          _deleteSelectedMessages();
        },
      ),
    ];
    final inlineInputTools = [
      TelegramAttachmentAction(
        label: 'Photo',
        icon: CupertinoIcons.photo_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Quick photo action');
        },
      ),
      TelegramAttachmentAction(
        label: 'File',
        icon: CupertinoIcons.doc_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Quick file action');
        },
      ),
      TelegramAttachmentAction(
        label: 'Location',
        icon: CupertinoIcons.location_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Quick location action');
        },
      ),
      TelegramAttachmentAction(
        label: 'Poll',
        icon: CupertinoIcons.chart_bar_alt_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Quick poll action');
        },
      ),
    ];
    final messageWidgets = <Widget>[
      const TelegramServiceMessageBubble(
        message: 'End-to-end encrypted messages',
        icon: CupertinoIcons.lock_shield_fill,
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: TelegramReferenceMessageCard(
          sender: 'Alice Johnson',
          message: 'Please check final icon spacing in navigation tab.',
          type: TelegramReferenceMessageType.forwarded,
          timeLabel: '14:00',
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TelegramLinkPreviewCard(
          preview: _linkPreview,
          onTap: _openLinkPreview,
        ),
      ),
      for (var i = 0; i < _messages.length; i++) ...[
        TelegramMessageSelectionWrapper(
          isOutgoing: _messages[i].isOutgoing,
          selectionMode: _selectionMode,
          selected: _selectedMessageIds.contains(_messages[i].id),
          onTap: _selectionMode
              ? () => _toggleSelectionForMessage(_messages[i])
              : null,
          onLongPress: () => _startSelectionForMessage(_messages[i]),
          child: TelegramChatBubble(message: _messages[i]),
        ),
        if (_isLastOutgoingReadMessage(i))
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TelegramReadReceiptsStrip(
                receipts: _readReceipts,
                onTap: _showReadReceipts,
              ),
            ),
          ),
        if (i == 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TelegramReactionBar(
                reactions: _reactions,
                onReactionTap: _toggleReaction,
              ),
            ),
          ),
        if (i == 1) const TelegramUnreadSeparator(),
        if (i == 2)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: TelegramFileMessageTile(
              fileName: 'Telegram_iOS_UI_Kit.fig',
              fileSizeLabel: '2.4 MB',
              timeLabel: '14:05',
              extension: 'FIG',
              caption: 'Community source file',
            ),
          ),
        if (i == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TelegramPollCard(
              question: 'When should we release the new UI kit build?',
              options: _pollOptions,
              totalVotersLabel: '22 votes · Quiz',
              onOptionTap: _togglePollOption,
            ),
          ),
        if (i == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TelegramVoiceMessageTile(
              durationLabel: '0:46',
              timeLabel: '14:06',
              progress: _voiceProgress,
              isPlaying: _voicePlaying,
              onPlayToggle: _toggleVoicePlayback,
            ),
          ),
        if (i == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TelegramLocationMessageTile(
              title: 'Telegram HQ',
              subtitle: 'Dubai · Live location',
              timeLabel: '14:07',
              onTap: () {
                TelegramToast.show(context, message: 'Location opened in map');
              },
            ),
          ),
        if (i == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TelegramContactMessageTile(
              name: 'Bot Support',
              phoneLabel: '+1 555 123 0000',
              timeLabel: '14:08',
              avatarFallback: 'BS',
              actionLabel: 'Send Message',
              onActionTap: _openContactMessage,
            ),
          ),
        if (i == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TelegramMediaAlbumMessage(
              items: const ['UI', 'Chat', 'Calls', 'Settings'],
              timeLabel: '14:09',
              caption: 'Updated iOS screenshots',
              onItemTap: (index) {
                TelegramToast.show(
                  context,
                  message: 'Album item #${index + 1} opened',
                );
              },
            ),
          ),
        if (i == 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TelegramScheduleTimeline(
              title: 'Release Timeline',
              events: _timelineEvents,
              onEventTap: _openTimelineEvent,
            ),
          ),
      ],
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: TelegramInlineKeyboard(
          rows: _botKeyboardRows,
          onButtonTap: _handleKeyboardTap,
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TelegramTypingIndicator(),
        ),
      ),
    ];

    return Scaffold(
      body: TelegramChatBackground(
        wallpaper: currentWallpaper,
        child: Column(
          children: [
            TelegramChatHeader(
              title: widget.chat.title,
              subtitle: 'last seen recently',
              avatarFallback: widget.chat.avatarFallback,
              onBack: () => Navigator.of(context).pop(),
              onVoiceCall: () {
                setState(() {
                  _showActionToolbar = !_showActionToolbar;
                });
              },
              onVideoCall: () {
                _cycleWallpaper();
              },
            ),
            if (_showActionToolbar || _selectionMode)
              TelegramChatActionToolbar(
                title: _selectionMode ? null : 'Quick Actions',
                selectedCount: _selectionMode
                    ? _selectedMessageIds.length
                    : null,
                actions: _selectionMode ? selectionActions : chatActions,
                trailing: CupertinoButton(
                  minimumSize: const Size.square(24),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (_selectionMode) {
                      _clearMessageSelection();
                      return;
                    }
                    setState(() => _showActionToolbar = false);
                  },
                  child: const Icon(CupertinoIcons.xmark_circle_fill, size: 18),
                ),
              ),
            TelegramPinnedMessageBar(
              title: 'Pinned Message',
              message: 'UI token review at 17:00',
              onClose: () {},
            ),
            Expanded(
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _messagesScrollController,
                    slivers: [
                      const TelegramStickyDateHeader(label: 'Today'),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed(
                            messageWidgets,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 10,
                    bottom: 12,
                    child: TelegramJumpToBottomButton(
                      visible: _showJumpToLatest,
                      unreadCount: _pendingIncomingCount,
                      onPressed: _jumpToLatest,
                    ),
                  ),
                ],
              ),
            ),
            if (_showReplyPreview)
              TelegramReplyPreviewBar(
                author: 'Alice Johnson',
                message: 'Please review the bot entrypoint copy',
                onClose: () => setState(() => _showReplyPreview = false),
              ),
            TelegramQuickRepliesBar(
              replies: _quickReplies,
              onReplyTap: _useQuickReply,
            ),
            TelegramExpandableMessageInputBar(
              controller: _controller,
              onSend: _send,
              onAttachPressed: _showAttachmentPanel,
              onVoicePressed: () {
                TelegramToast.show(context, message: 'Hold to record');
              },
              tools: inlineInputTools,
            ),
          ],
        ),
      ),
    );
  }
}

class _UIKitTab extends StatefulWidget {
  const _UIKitTab();

  @override
  State<_UIKitTab> createState() => _UIKitTabState();
}

class _UIKitTabState extends State<_UIKitTab> {
  bool _showNotice = true;
  String _showcaseAuditFilterId = 'all';
  int _showcaseBulkSelectedCount = 2;
  String _showcaseSearchScopeId = 'all';
  String _showcaseSearchDateRangeId = 'anytime';
  String _showcaseSearchSortId = 'relevance';
  String? _showcaseSavedSearchId;
  final TextEditingController _showcaseSearchController =
      TextEditingController();
  String _showcaseSearchQuery = '';
  List<String> _showcaseRecentQueries = const [
    'moderation',
    'telegram blue',
    'mini apps',
  ];
  List<String> _showcaseSuggestions = const [
    'phishing report',
    'design tokens',
    'release notes',
  ];
  bool _showcaseSearchSelectionMode = false;
  Set<String> _showcaseSelectedSearchResultIds = const <String>{};
  List<TelegramSearchExecution> _showcaseSearchExecutions = const [
    TelegramSearchExecution(
      id: 'execution_seed_1',
      query: 'design tokens',
      status: 'cached',
      scopeLabel: 'Chats',
      startedAtLabel: '2m ago',
      durationMs: 28,
      resultCount: 2,
      fromCache: true,
    ),
    TelegramSearchExecution(
      id: 'execution_seed_2',
      query: 'moderation',
      status: 'success',
      scopeLabel: 'Moderation',
      dateRangeLabel: 'Last 24h',
      startedAtLabel: '8m ago',
      durationMs: 45,
      resultCount: 3,
    ),
    TelegramSearchExecution(
      id: 'execution_seed_3',
      query: 'timeout report',
      status: 'failed',
      scopeLabel: 'All',
      startedAtLabel: '21m ago',
      durationMs: 91,
      resultCount: 0,
      errorMessage: 'Gateway timeout while querying the moderation index.',
    ),
  ];
  int _showcaseSearchExecutionSeed = 4;
  String? _showcaseHighlightedSearchOperatorId;
  static const List<TelegramSearchOperator> _showcaseSearchOperators = [
    TelegramSearchOperator(
      id: 'operator_from',
      label: 'From',
      token: 'from:alice',
      description: 'Filter by sender name',
      example: 'from:alice moderation',
      icon: CupertinoIcons.person_fill,
    ),
    TelegramSearchOperator(
      id: 'operator_in',
      label: 'In',
      token: 'in:#moderation',
      description: 'Filter by section or chat label',
      example: 'in:#moderation phishing',
      icon: CupertinoIcons.number,
    ),
    TelegramSearchOperator(
      id: 'operator_has_link',
      label: 'Has Link',
      token: 'has:link',
      description: 'Only items with external links',
      example: 'has:link release notes',
      icon: CupertinoIcons.link,
    ),
    TelegramSearchOperator(
      id: 'operator_media',
      label: 'Has Media',
      token: 'has:media',
      description: 'Only items with media mentions',
      example: 'has:media review',
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
    ),
    TelegramSearchOperator(
      id: 'operator_unread',
      label: 'Unread',
      token: 'is:unread',
      description: 'Only unread updates',
      example: 'is:unread moderation',
      icon: CupertinoIcons.envelope_badge_fill,
    ),
  ];
  static const List<TelegramSearchDateRange> _showcaseDateRanges = [
    TelegramSearchDateRange(
      id: 'anytime',
      label: 'Anytime',
      description: 'Include all matched results',
      icon: CupertinoIcons.clock_fill,
    ),
    TelegramSearchDateRange(
      id: 'today',
      label: 'Today',
      description: 'Only results from today',
      icon: CupertinoIcons.sun_max_fill,
    ),
    TelegramSearchDateRange(
      id: 'last24h',
      label: 'Last 24h',
      description: 'Today and yesterday updates',
      icon: CupertinoIcons.timer_fill,
    ),
    TelegramSearchDateRange(
      id: 'last7d',
      label: 'Last 7d',
      description: 'Recent weekly activity',
      icon: CupertinoIcons.calendar,
    ),
  ];
  final List<TelegramSavedSearch> _showcaseSavedSearches = const [
    TelegramSavedSearch(
      id: 'saved_moderation',
      label: 'Moderation Radar',
      query: 'moderation',
      description:
          'Track high-priority moderation activities and unresolved reports.',
      scopeId: 'moderation',
      scopeLabel: 'Moderation',
      sortId: 'unread',
      sortLabel: 'Unread',
      filterIds: ['priority', 'unread'],
      icon: CupertinoIcons.shield_fill,
      expectedCount: 3,
    ),
    TelegramSavedSearch(
      id: 'saved_design_tokens',
      label: 'Design Tokens',
      query: 'design tokens',
      description: 'Watch token updates and linked Figma notes in UI channels.',
      scopeId: 'chats',
      scopeLabel: 'Chats',
      sortId: 'newest',
      sortLabel: 'Newest',
      filterIds: ['links'],
      icon: CupertinoIcons.paintbrush_fill,
      expectedCount: 2,
    ),
    TelegramSavedSearch(
      id: 'saved_verified_media',
      label: 'Verified Media',
      query: 'media',
      description: 'Find verified media conversations ready for review.',
      scopeId: 'all',
      scopeLabel: 'All',
      sortId: 'relevance',
      sortLabel: 'Relevance',
      filterIds: ['verified', 'media'],
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
      expectedCount: 1,
    ),
  ];
  List<TelegramSearchAlert> _showcaseSearchAlerts = const [
    TelegramSearchAlert(
      id: 'alert_moderation',
      label: 'Moderation Escalations',
      query: 'moderation',
      scopeLabel: 'Moderation',
      triggerLabel: 'When unread appears',
      deliveryLabel: 'In-app + Push',
      icon: CupertinoIcons.bell_fill,
      enabled: true,
      unreadCount: 2,
    ),
    TelegramSearchAlert(
      id: 'alert_design',
      label: 'Design Token Diffs',
      query: 'design tokens',
      scopeLabel: 'Chats',
      triggerLabel: 'When new result appears',
      deliveryLabel: 'In-app',
      icon: CupertinoIcons.paintbrush_fill,
      enabled: true,
      unreadCount: 1,
    ),
    TelegramSearchAlert(
      id: 'alert_media',
      label: 'Verified Media Review',
      query: 'media',
      scopeLabel: 'All',
      triggerLabel: 'Daily digest',
      deliveryLabel: 'Summary',
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
      enabled: false,
    ),
  ];
  List<TelegramSearchFilterOption> _showcaseSearchFilters = const [
    TelegramSearchFilterOption(
      id: 'unread',
      label: 'Unread',
      description: 'Only show results with unread updates',
      icon: CupertinoIcons.envelope_badge_fill,
    ),
    TelegramSearchFilterOption(
      id: 'links',
      label: 'Has Link',
      description: 'Contains URL or external links',
      icon: CupertinoIcons.link,
      selected: true,
    ),
    TelegramSearchFilterOption(
      id: 'media',
      label: 'Media',
      description: 'Includes photo or video mentions',
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
    ),
    TelegramSearchFilterOption(
      id: 'verified',
      label: 'Verified',
      description: 'Only verified channels or sources',
      icon: CupertinoIcons.checkmark_seal_fill,
    ),
    TelegramSearchFilterOption(
      id: 'priority',
      label: 'Moderation',
      description: 'Focus on moderation queue and safety logs',
      icon: CupertinoIcons.shield_fill,
    ),
  ];
  final List<TelegramSearchResult> _showcaseSearchResults = const [
    TelegramSearchResult(
      id: 'search_result_1',
      title: 'Design Team',
      subtitle: 'Alice Johnson',
      sectionLabel: '#ui-kit',
      snippet: 'Telegram blue color token was updated with linked Figma notes.',
      timeLabel: '11:12',
      avatarFallback: 'DT',
      unreadCount: 2,
    ),
    TelegramSearchResult(
      id: 'search_result_2',
      title: 'Admin Log',
      subtitle: 'Auto Mod Bot',
      sectionLabel: '#moderation',
      snippet: 'Removed 4 spam messages with repeated phishing links.',
      timeLabel: '10:58',
      avatarFallback: 'AL',
    ),
    TelegramSearchResult(
      id: 'search_result_3',
      title: 'Telegram iOS UI Kit',
      subtitle: 'Pinned Announcement',
      sectionLabel: '#announcements',
      snippet: 'The latest component release introduces moderation drawers.',
      timeLabel: 'Yesterday',
      avatarFallback: 'TK',
      isVerified: true,
    ),
    TelegramSearchResult(
      id: 'search_result_4',
      title: 'Media Review',
      subtitle: 'Channel Assets',
      sectionLabel: '#media',
      snippet: 'Two video previews and one photo were approved in this review.',
      timeLabel: '09:32',
      avatarFallback: 'MR',
      unreadCount: 1,
    ),
  ];
  final List<TelegramTimelineEvent> _showcaseTimeline = const [
    TelegramTimelineEvent(
      id: 'showcase_timeline_1',
      title: 'Token Mapping',
      timeLabel: '10:00',
      completed: true,
    ),
    TelegramTimelineEvent(
      id: 'showcase_timeline_2',
      title: 'Widget Coverage',
      timeLabel: '11:30',
      subtitle: 'Chat + settings + interactions',
      current: true,
    ),
    TelegramTimelineEvent(
      id: 'showcase_timeline_3',
      title: 'pub.dev Publish',
      timeLabel: '13:00',
      subtitle: 'Finalize docs and changelog',
    ),
  ];
  final List<List<TelegramKeyboardButton>> _previewKeyboardRows = const [
    [
      TelegramKeyboardButton(
        label: 'Open App',
        icon: CupertinoIcons.play_fill,
        isPrimary: true,
      ),
      TelegramKeyboardButton(
        label: 'Help',
        icon: CupertinoIcons.question_circle,
      ),
    ],
    [
      TelegramKeyboardButton(label: 'Terms'),
      TelegramKeyboardButton(
        label: 'Delete',
        icon: CupertinoIcons.delete,
        isDestructive: true,
      ),
    ],
  ];
  List<TelegramChatPreview> _swipeChats = const [
    TelegramChatPreview(
      id: 'swipe_1',
      title: 'Archive Demo',
      subtitle: 'Swipe left for archive and delete actions',
      timeLabel: '10:32',
      unreadCount: 2,
      avatarFallback: 'AR',
      isOnline: true,
    ),
    TelegramChatPreview(
      id: 'swipe_2',
      title: 'Mute Demo',
      subtitle: 'Swipe to toggle mute quickly',
      timeLabel: '09:41',
      avatarFallback: 'MU',
    ),
    TelegramChatPreview(
      id: 'swipe_3',
      title: 'Pinned Demo',
      subtitle: 'Swipe right to pin conversation',
      timeLabel: 'Yesterday',
      avatarFallback: 'PI',
      isPinned: true,
    ),
  ];

  TelegramChatPreview _copyChat(
    TelegramChatPreview chat, {
    bool? isMuted,
    bool? isPinned,
    int? unreadCount,
    String? subtitle,
  }) {
    return TelegramChatPreview(
      id: chat.id,
      title: chat.title,
      subtitle: subtitle ?? chat.subtitle,
      timeLabel: chat.timeLabel,
      unreadCount: unreadCount ?? chat.unreadCount,
      avatarImage: chat.avatarImage,
      avatarFallback: chat.avatarFallback,
      isMuted: isMuted ?? chat.isMuted,
      isPinned: isPinned ?? chat.isPinned,
      isOnline: chat.isOnline,
      folderId: chat.folderId,
    );
  }

  void _updateChat(
    String chatId,
    TelegramChatPreview Function(TelegramChatPreview chat) transform,
  ) {
    setState(() {
      _swipeChats = _swipeChats
          .map((chat) => chat.id == chatId ? transform(chat) : chat)
          .toList(growable: false);
    });
  }

  void _removeChat(String chatId, String action) {
    TelegramChatPreview? chat;
    for (final value in _swipeChats) {
      if (value.id == chatId) {
        chat = value;
        break;
      }
    }
    if (chat == null) {
      return;
    }
    setState(() {
      _swipeChats = _swipeChats
          .where((value) => value.id != chatId)
          .toList(growable: false);
    });
    TelegramToast.show(context, message: '$action: ${chat.title}');
  }

  void _showKeyboardAction(TelegramKeyboardButton button) {
    TelegramToast.show(context, message: 'Keyboard: ${button.label}');
  }

  void _showTimelineAction(TelegramTimelineEvent event) {
    TelegramToast.show(context, message: 'Step: ${event.title}');
  }

  void _selectShowcaseAuditFilter(TelegramAdminAuditFilter filter) {
    setState(() => _showcaseAuditFilterId = filter.id);
  }

  Future<void> _openShowcaseModerationDrawer(
    TelegramModerationRequest request,
  ) async {
    await TelegramModerationDetailDrawer.show(
      context,
      request: request,
      tags: const ['Spam', 'External Link', 'Urgent'],
      evidenceCount: 3,
      reporterLabel: 'Reported by: Emma Rivera',
      messagePreview: 'Suspicious external link repeatedly shared in channel.',
      onApprove: () {
        TelegramToast.show(context, message: 'Approved from drawer');
      },
      onReject: () {
        TelegramToast.show(context, message: 'Rejected from drawer');
      },
      onOpenThread: () {
        TelegramToast.show(context, message: 'Thread opened from drawer');
      },
    );
  }

  void _setShowcaseBulkSelectedCount(int count) {
    if (count == _showcaseBulkSelectedCount) {
      return;
    }
    setState(() => _showcaseBulkSelectedCount = count);
  }

  void _setShowcaseSearchQuery(
    String value, {
    bool trackExecution = true,
    String? executionStatus,
    String? executionErrorMessage,
    bool? executionFromCache,
  }) {
    if (_showcaseSearchQuery == value && _showcaseSavedSearchId == null) {
      if (trackExecution) {
        _recordShowcaseSearchExecution(
          status: executionStatus,
          errorMessage: executionErrorMessage,
          fromCache: executionFromCache,
        );
      }
      return;
    }
    setState(() {
      _showcaseSearchQuery = value;
      _showcaseSavedSearchId = null;
      _showcaseHighlightedSearchOperatorId = null;
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
    if (trackExecution) {
      _recordShowcaseSearchExecution(
        status: executionStatus,
        errorMessage: executionErrorMessage,
        fromCache: executionFromCache,
      );
    }
  }

  void _selectShowcaseSearchSort(TelegramSearchSortOption option) {
    if (_showcaseSearchSortId == option.id && _showcaseSavedSearchId == null) {
      return;
    }
    setState(() {
      _showcaseSearchSortId = option.id;
      _showcaseSavedSearchId = null;
    });
    _recordShowcaseSearchExecution();
  }

  void _selectShowcaseSearchScope(TelegramSearchScope scope) {
    if (_showcaseSearchScopeId == scope.id && _showcaseSavedSearchId == null) {
      return;
    }
    setState(() {
      _showcaseSearchScopeId = scope.id;
      _showcaseSavedSearchId = null;
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
    _recordShowcaseSearchExecution();
  }

  void _selectShowcaseDateRange(TelegramSearchDateRange range) {
    if (_showcaseSearchDateRangeId == range.id &&
        _showcaseSavedSearchId == null) {
      return;
    }
    setState(() {
      _showcaseSearchDateRangeId = range.id;
      _showcaseSavedSearchId = null;
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
    _recordShowcaseSearchExecution();
  }

  void _clearShowcaseDateRange() {
    if (_showcaseSearchDateRangeId == 'anytime') {
      return;
    }
    setState(() {
      _showcaseSearchDateRangeId = 'anytime';
      _showcaseSavedSearchId = null;
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
    _recordShowcaseSearchExecution();
  }

  void _applyShowcaseSearchOperator(TelegramSearchOperator operator) {
    final token = operator.token.trim();
    if (token.isEmpty) {
      return;
    }
    final currentQuery = _showcaseSearchController.text.trim();
    final updatedQuery = currentQuery.isEmpty ? token : '$currentQuery $token';
    _showcaseSearchController.value = TextEditingValue(
      text: updatedQuery,
      selection: TextSelection.collapsed(offset: updatedQuery.length),
    );
    _setShowcaseSearchQuery(updatedQuery);
    _rememberShowcaseQuery(updatedQuery);
    setState(() => _showcaseHighlightedSearchOperatorId = operator.id);
    TelegramToast.show(context, message: 'Inserted ${operator.token}');
  }

  Future<void> _openShowcaseSearchOperatorsSheet() async {
    await TelegramSearchOperatorsSheet.show(
      context,
      operators: _showcaseSearchOperators,
      onSelected: _applyShowcaseSearchOperator,
    );
  }

  void _selectShowcaseSavedSearch(TelegramSavedSearch search) {
    final query = search.query.trim();
    setState(() {
      _showcaseSavedSearchId = search.id;
      _showcaseSearchQuery = query;
      _showcaseSearchScopeId = search.scopeId;
      _showcaseSearchDateRangeId = 'anytime';
      _showcaseSearchSortId = search.sortId;
      _showcaseSearchFilters = _showcaseSearchFilters
          .map(
            (filter) =>
                filter.copyWith(selected: search.filterIds.contains(filter.id)),
          )
          .toList(growable: false);
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
    _showcaseSearchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _rememberShowcaseQuery(query);
    _recordShowcaseSearchExecution(status: 'cached', fromCache: true);
  }

  void _clearShowcaseSavedSearchSelection() {
    if (_showcaseSavedSearchId == null) {
      return;
    }
    setState(() => _showcaseSavedSearchId = null);
  }

  TelegramSavedSearch? _resolveShowcaseSavedSearch(String? id) {
    if (id == null) {
      return null;
    }
    for (final search in _showcaseSavedSearches) {
      if (search.id == id) {
        return search;
      }
    }
    return null;
  }

  void _rememberShowcaseQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return;
    }
    setState(() {
      _showcaseRecentQueries = [
        normalized,
        ..._showcaseRecentQueries.where((item) => item != normalized),
      ].take(6).toList(growable: false);
    });
  }

  void _applyShowcaseRecentQuery(String query) {
    _showcaseSearchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _setShowcaseSearchQuery(query);
    _rememberShowcaseQuery(query);
  }

  void _removeShowcaseRecentQuery(String query) {
    setState(() {
      _showcaseRecentQueries = _showcaseRecentQueries
          .where((item) => item != query)
          .toList(growable: false);
    });
  }

  void _clearShowcaseRecentQueries() {
    if (_showcaseRecentQueries.isEmpty) {
      return;
    }
    setState(() => _showcaseRecentQueries = const []);
  }

  void _openShowcaseSearchResult(TelegramSearchResult result) {
    _rememberShowcaseQuery(result.title);
    TelegramToast.show(context, message: 'Opened ${result.title}');
  }

  void _toggleShowcaseSearchSelectionMode() {
    setState(() {
      if (_showcaseSearchSelectionMode) {
        _showcaseSearchSelectionMode = false;
        _showcaseSelectedSearchResultIds = const <String>{};
      } else {
        _showcaseSearchSelectionMode = true;
      }
    });
  }

  void _toggleShowcaseSearchResultSelection(TelegramSearchResult result) {
    setState(() {
      final selectedIds = _showcaseSelectedSearchResultIds.toSet();
      if (selectedIds.contains(result.id)) {
        selectedIds.remove(result.id);
      } else {
        selectedIds.add(result.id);
      }
      _showcaseSelectedSearchResultIds = selectedIds;
    });
  }

  void _selectAllShowcaseSearchResults(List<TelegramSearchResult> results) {
    if (results.isEmpty) {
      return;
    }
    setState(() {
      _showcaseSelectedSearchResultIds = results
          .map((result) => result.id)
          .toSet();
    });
  }

  void _clearShowcaseSearchResultSelection() {
    if (_showcaseSelectedSearchResultIds.isEmpty) {
      return;
    }
    setState(() => _showcaseSelectedSearchResultIds = const <String>{});
  }

  List<TelegramSearchResultAction> _buildShowcaseSearchResultActions(
    int selectedCount,
  ) {
    final hasSelection = selectedCount > 0;
    final countLabel = hasSelection ? '$selectedCount' : null;
    return [
      TelegramSearchResultAction(
        id: 'mark_read',
        label: 'Mark Read',
        icon: CupertinoIcons.envelope_open_fill,
        enabled: hasSelection,
        badgeLabel: countLabel,
      ),
      TelegramSearchResultAction(
        id: 'pin',
        label: 'Pin',
        icon: CupertinoIcons.pin_fill,
        enabled: hasSelection,
      ),
      TelegramSearchResultAction(
        id: 'forward',
        label: 'Forward',
        icon: CupertinoIcons.arrowshape_turn_up_right_fill,
        enabled: hasSelection,
      ),
      TelegramSearchResultAction(
        id: 'delete',
        label: 'Delete',
        icon: CupertinoIcons.delete_solid,
        destructive: true,
        enabled: hasSelection,
        badgeLabel: countLabel,
      ),
    ];
  }

  void _runShowcaseSearchResultAction(
    TelegramSearchResultAction action,
    List<TelegramSearchResult> selectedResults,
  ) {
    if (selectedResults.isEmpty) {
      return;
    }
    final count = selectedResults.length;
    switch (action.id) {
      case 'mark_read':
        TelegramToast.show(context, message: 'Marked $count results as read');
        break;
      case 'pin':
        TelegramToast.show(context, message: 'Pinned $count results');
        break;
      case 'forward':
        TelegramToast.show(context, message: 'Forwarded $count results');
        break;
      case 'delete':
        TelegramToast.show(context, message: 'Deleted $count results');
        break;
      default:
        TelegramToast.show(context, message: 'Action unavailable');
        break;
    }
    setState(() {
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
  }

  void _applyShowcaseSuggestion(String query) {
    _showcaseSearchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _setShowcaseSearchQuery(query);
    _rememberShowcaseQuery(query);
  }

  void _removeShowcaseSuggestion(String query) {
    setState(() {
      _showcaseSuggestions = _showcaseSuggestions
          .where((item) => item != query)
          .toList(growable: false);
    });
  }

  void _resetShowcaseSuggestions() {
    if (_showcaseSuggestions.isNotEmpty) {
      return;
    }
    setState(() {
      _showcaseSuggestions = const [
        'phishing report',
        'design tokens',
        'release notes',
      ];
    });
  }

  void _updateShowcaseSearchFilter(TelegramSearchFilterOption updated) {
    setState(() {
      _showcaseSearchFilters = _showcaseSearchFilters
          .map((filter) => filter.id == updated.id ? updated : filter)
          .toList(growable: false);
      _showcaseSavedSearchId = null;
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
    _recordShowcaseSearchExecution();
  }

  void _removeShowcaseSearchFilter(TelegramSearchFilterOption filter) {
    if (!filter.selected) {
      return;
    }
    _updateShowcaseSearchFilter(filter.copyWith(selected: false));
  }

  void _clearShowcaseSearchFilters() {
    final hasSelected = _showcaseSearchFilters.any((filter) => filter.selected);
    if (!hasSelected) {
      return;
    }
    setState(() {
      _showcaseSearchFilters = _showcaseSearchFilters
          .map((filter) => filter.copyWith(selected: false))
          .toList(growable: false);
      _showcaseSavedSearchId = null;
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
    });
    _recordShowcaseSearchExecution();
  }

  Future<void> _openShowcaseSearchFiltersSheet() async {
    await TelegramSearchFiltersSheet.show(
      context,
      options: _showcaseSearchFilters,
      onOptionChanged: _updateShowcaseSearchFilter,
      onReset: _clearShowcaseSearchFilters,
      onApply: () {
        final selectedCount = _showcaseSearchFilters
            .where((filter) => filter.selected)
            .length;
        TelegramToast.show(
          context,
          message: selectedCount == 0
              ? 'Applied with no filters'
              : 'Applied $selectedCount filters',
        );
      },
    );
  }

  Future<void> _openShowcaseSearchHistorySheet() async {
    await TelegramSearchHistorySheet.show(
      context,
      entries: _showcaseRecentQueries,
      onSelected: _applyShowcaseRecentQuery,
      onRemove: _removeShowcaseRecentQuery,
      onClearAll: _clearShowcaseRecentQueries,
    );
  }

  Future<void> _openShowcaseSearchExecutionsSheet() async {
    await TelegramSearchExecutionsSheet.show(
      context,
      executions: _showcaseSearchExecutions,
      onSelected: _applyShowcaseSearchExecution,
      onRetry: _retryShowcaseSearchExecution,
      onClearAll: _clearShowcaseSearchExecutions,
    );
  }

  void _clearShowcaseSearchExecutions() {
    if (_showcaseSearchExecutions.isEmpty) {
      return;
    }
    setState(() => _showcaseSearchExecutions = const []);
  }

  void _applyShowcaseSearchExecution(TelegramSearchExecution execution) {
    _restoreShowcaseSearchExecutionState(execution);
    _recordShowcaseSearchExecution(status: 'cached', fromCache: true);
    TelegramToast.show(
      context,
      message: 'Loaded execution: ${execution.query}',
    );
  }

  void _retryShowcaseSearchExecution(TelegramSearchExecution execution) {
    _restoreShowcaseSearchExecutionState(execution);
    final normalized = execution.query.trim().toLowerCase();
    final failed =
        normalized.contains('timeout') || normalized.contains('error');
    _recordShowcaseSearchExecution(
      status: failed ? 'failed' : 'success',
      errorMessage: failed
          ? 'Gateway timeout while querying the moderation index.'
          : null,
      fromCache: false,
    );
    TelegramToast.show(
      context,
      message: failed
          ? 'Retry failed: ${execution.query}'
          : 'Retried execution: ${execution.query}',
    );
  }

  void _restoreShowcaseSearchExecutionState(TelegramSearchExecution execution) {
    final query = execution.query.trim();
    final scopeId = _resolveShowcaseScopeIdByLabel(execution.scopeLabel);
    final dateRangeId = _resolveShowcaseDateRangeIdByLabel(
      execution.dateRangeLabel,
    );
    setState(() {
      _showcaseSearchQuery = query;
      _showcaseSavedSearchId = null;
      _showcaseHighlightedSearchOperatorId = null;
      _showcaseSearchSelectionMode = false;
      _showcaseSelectedSearchResultIds = const <String>{};
      if (scopeId != null) {
        _showcaseSearchScopeId = scopeId;
      }
      if (dateRangeId != null) {
        _showcaseSearchDateRangeId = dateRangeId;
      }
    });
    _showcaseSearchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _rememberShowcaseQuery(query);
  }

  Future<void> _openShowcaseSearchDateRangesSheet() async {
    await TelegramSearchDateRangesSheet.show(
      context,
      ranges: _showcaseDateRanges,
      selectedId: _showcaseSearchDateRangeId,
      onSelected: _selectShowcaseDateRange,
      onClear: _clearShowcaseDateRange,
      title: 'Search Date Range',
      clearLabel: 'Anytime',
    );
  }

  void _updateShowcaseSearchAlert(TelegramSearchAlert updated) {
    setState(() {
      _showcaseSearchAlerts = _showcaseSearchAlerts
          .map((alert) => alert.id == updated.id ? updated : alert)
          .toList(growable: false);
    });
  }

  void _disableAllShowcaseSearchAlerts() {
    if (_showcaseSearchAlerts.every((alert) => !alert.enabled)) {
      return;
    }
    setState(() {
      _showcaseSearchAlerts = _showcaseSearchAlerts
          .map((alert) => alert.copyWith(enabled: false))
          .toList(growable: false);
    });
  }

  void _applyShowcaseSearchAlert(TelegramSearchAlert alert) {
    _showcaseSearchController.value = TextEditingValue(
      text: alert.query,
      selection: TextSelection.collapsed(offset: alert.query.length),
    );
    _setShowcaseSearchQuery(alert.query);
    _rememberShowcaseQuery(alert.query);
    TelegramToast.show(context, message: 'Alert linked: ${alert.label}');
  }

  Future<void> _openShowcaseSearchAlertsSheet() async {
    await TelegramSearchAlertsSheet.show(
      context,
      alerts: _showcaseSearchAlerts,
      onAlertChanged: (updated) {
        _updateShowcaseSearchAlert(updated);
      },
      onTapAlert: _applyShowcaseSearchAlert,
      onDisableAll: _disableAllShowcaseSearchAlerts,
    );
  }

  List<TelegramSearchCommand> _buildShowcaseSearchCommands() {
    final activeFilterCount = _showcaseSearchFilters
        .where((filter) => filter.selected)
        .length;
    final operatorTokenCount = _extractShowcaseSearchOperatorTokens(
      _showcaseSearchQuery,
    ).length;
    final enabledAlertCount = _showcaseSearchAlerts
        .where((alert) => alert.enabled)
        .length;
    final activeSavedSearch = _resolveShowcaseSavedSearch(
      _showcaseSavedSearchId,
    );
    final hasQuery = _showcaseSearchQuery.trim().isNotEmpty;

    return [
      TelegramSearchCommand(
        id: 'clear_query',
        title: 'Clear Query',
        subtitle: 'Reset current keyword and results',
        icon: CupertinoIcons.clear_circled_solid,
        enabled: hasQuery,
      ),
      TelegramSearchCommand(
        id: 'clear_operators',
        title: 'Clear Operators',
        subtitle: 'Keep keywords and remove operator tokens',
        icon: CupertinoIcons.wand_stars_inverse,
        enabled: operatorTokenCount > 0,
        badgeLabel: operatorTokenCount > 0 ? '$operatorTokenCount' : null,
      ),
      TelegramSearchCommand(
        id: 'clear_filters',
        title: 'Clear Filters',
        subtitle: 'Remove all active search filters',
        icon: CupertinoIcons.slider_horizontal_3,
        enabled: activeFilterCount > 0,
        badgeLabel: activeFilterCount > 0 ? '$activeFilterCount' : null,
      ),
      TelegramSearchCommand(
        id: 'reset_scope',
        title: 'Reset Scope',
        subtitle: 'Switch search scope back to All',
        icon: CupertinoIcons.square_grid_2x2_fill,
        enabled: _showcaseSearchScopeId != 'all',
      ),
      TelegramSearchCommand(
        id: 'reset_date_range',
        title: 'Reset Date Range',
        subtitle: 'Return date range to Anytime',
        icon: CupertinoIcons.calendar_badge_minus,
        enabled: _showcaseSearchDateRangeId != 'anytime',
      ),
      TelegramSearchCommand(
        id: 'pause_alerts',
        title: 'Pause Alerts',
        subtitle: 'Disable all enabled search alerts',
        icon: CupertinoIcons.bell_slash_fill,
        enabled: enabledAlertCount > 0,
        badgeLabel: enabledAlertCount > 0 ? '$enabledAlertCount' : null,
      ),
      TelegramSearchCommand(
        id: 'reuse_saved',
        title: 'Reuse Saved Search',
        subtitle: activeSavedSearch == null
            ? 'Select a saved search preset first'
            : 'Re-run: ${activeSavedSearch.label}',
        icon: CupertinoIcons.bookmark_fill,
        enabled: activeSavedSearch != null,
      ),
      TelegramSearchCommand(
        id: 'clear_history',
        title: 'Clear History',
        subtitle: 'Remove all recent search records',
        icon: CupertinoIcons.trash_fill,
        destructive: true,
        enabled: _showcaseRecentQueries.isNotEmpty,
        badgeLabel: _showcaseRecentQueries.isNotEmpty
            ? '${_showcaseRecentQueries.length}'
            : null,
      ),
    ];
  }

  void _runShowcaseSearchCommand(TelegramSearchCommand command) {
    switch (command.id) {
      case 'clear_query':
        if (_showcaseSearchQuery.trim().isEmpty) {
          return;
        }
        _showcaseSearchController.clear();
        _setShowcaseSearchQuery('');
        TelegramToast.show(context, message: 'Search query cleared');
        break;
      case 'clear_operators':
        final rawTokens = _tokenizeShowcaseSearchQuery(
          _showcaseSearchController.text,
          toLowerCase: false,
        );
        final keywords = rawTokens
            .where((token) => !token.contains(':'))
            .toList(growable: false);
        if (keywords.length == rawTokens.length) {
          return;
        }
        final updatedQuery = keywords.join(' ').trim();
        _showcaseSearchController.value = TextEditingValue(
          text: updatedQuery,
          selection: TextSelection.collapsed(offset: updatedQuery.length),
        );
        _setShowcaseSearchQuery(updatedQuery);
        setState(() => _showcaseHighlightedSearchOperatorId = null);
        TelegramToast.show(context, message: 'Operator tokens cleared');
        break;
      case 'clear_filters':
        final before = _showcaseSearchFilters
            .where((item) => item.selected)
            .length;
        _clearShowcaseSearchFilters();
        if (before > 0) {
          TelegramToast.show(context, message: 'Cleared $before filters');
        }
        break;
      case 'reset_scope':
        if (_showcaseSearchScopeId == 'all') {
          return;
        }
        setState(() {
          _showcaseSearchScopeId = 'all';
          _showcaseSavedSearchId = null;
        });
        _recordShowcaseSearchExecution();
        TelegramToast.show(context, message: 'Scope reset to All');
        break;
      case 'reset_date_range':
        if (_showcaseSearchDateRangeId == 'anytime') {
          return;
        }
        _clearShowcaseDateRange();
        TelegramToast.show(context, message: 'Date range reset to Anytime');
        break;
      case 'pause_alerts':
        final before = _showcaseSearchAlerts
            .where((alert) => alert.enabled)
            .length;
        _disableAllShowcaseSearchAlerts();
        if (before > 0) {
          TelegramToast.show(context, message: 'Paused $before alerts');
        }
        break;
      case 'reuse_saved':
        final activeSavedSearch = _resolveShowcaseSavedSearch(
          _showcaseSavedSearchId,
        );
        if (activeSavedSearch == null) {
          return;
        }
        _selectShowcaseSavedSearch(activeSavedSearch);
        TelegramToast.show(
          context,
          message: 'Re-ran ${activeSavedSearch.label}',
        );
        break;
      case 'clear_history':
        final before = _showcaseRecentQueries.length;
        _clearShowcaseRecentQueries();
        if (before > 0) {
          TelegramToast.show(context, message: 'Cleared $before history items');
        }
        break;
      default:
        TelegramToast.show(context, message: 'Command unavailable');
        break;
    }
  }

  Future<void> _openShowcaseSearchCommandsSheet() async {
    await TelegramSearchCommandsSheet.show(
      context,
      commands: _buildShowcaseSearchCommands(),
      onSelected: _runShowcaseSearchCommand,
    );
  }

  bool _matchesShowcaseFilters(TelegramSearchResult result) {
    final activeFilterIds = _showcaseSearchFilters
        .where((filter) => filter.selected)
        .map((filter) => filter.id)
        .toSet();
    if (activeFilterIds.isEmpty) {
      return true;
    }

    final title = result.title.toLowerCase();
    final subtitle = result.subtitle?.toLowerCase() ?? '';
    final section = result.sectionLabel?.toLowerCase() ?? '';
    final snippet = result.snippet.toLowerCase();

    if (activeFilterIds.contains('unread') && result.unreadCount <= 0) {
      return false;
    }
    if (activeFilterIds.contains('links') &&
        !snippet.contains('link') &&
        !snippet.contains('http')) {
      return false;
    }
    if (activeFilterIds.contains('media') &&
        !snippet.contains('video') &&
        !snippet.contains('photo') &&
        !section.contains('media')) {
      return false;
    }
    if (activeFilterIds.contains('verified') && !result.isVerified) {
      return false;
    }
    if (activeFilterIds.contains('priority') &&
        !section.contains('moderation') &&
        !title.contains('admin') &&
        !subtitle.contains('mod')) {
      return false;
    }
    return true;
  }

  bool _matchesShowcaseScope(TelegramSearchResult result, {String? scopeId}) {
    final id = scopeId ?? _showcaseSearchScopeId;
    final title = result.title.toLowerCase();
    final subtitle = result.subtitle?.toLowerCase() ?? '';
    final section = result.sectionLabel?.toLowerCase() ?? '';
    switch (id) {
      case 'people':
        return subtitle.contains('alice') ||
            subtitle.contains('bot') ||
            subtitle.contains('johnson');
      case 'chats':
        return title.contains('team') ||
            title.contains('telegram') ||
            section.contains('ui-kit') ||
            section.contains('announcement');
      case 'moderation':
        return section.contains('moderation') ||
            title.contains('admin') ||
            subtitle.contains('mod');
      case 'all':
      default:
        return true;
    }
  }

  List<String> _tokenizeShowcaseSearchQuery(
    String query, {
    bool toLowerCase = true,
  }) {
    final source = toLowerCase ? query.toLowerCase() : query;
    return source
        .trim()
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  Set<String> _extractShowcaseSearchOperatorTokens(String query) {
    return _tokenizeShowcaseSearchQuery(
      query,
    ).where((token) => token.contains(':')).toSet();
  }

  String _extractShowcaseSearchKeywordQuery(String query) {
    final keywords = _tokenizeShowcaseSearchQuery(
      query,
    ).where((token) => !token.contains(':')).join(' ').trim();
    return keywords;
  }

  TelegramSearchOperator? _resolveShowcaseOperatorForToken(String token) {
    final normalized = token.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    for (final operator in _showcaseSearchOperators) {
      final operatorToken = operator.token.toLowerCase();
      if (normalized == operatorToken) {
        return operator;
      }
      final prefix = operatorToken.split(':').first;
      if (normalized.startsWith('$prefix:')) {
        return operator;
      }
    }
    return null;
  }

  List<TelegramSearchQueryToken> _buildShowcaseSearchQueryTokens(String query) {
    final rawTokens = _tokenizeShowcaseSearchQuery(query, toLowerCase: false);
    if (rawTokens.isEmpty) {
      return const [];
    }
    return rawTokens
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final tokenValue = entry.value;
          final operator = _resolveShowcaseOperatorForToken(tokenValue);
          final operatorLabel = operator?.label;
          return TelegramSearchQueryToken(
            id: 'query_token_$index',
            value: tokenValue,
            label: operatorLabel == null
                ? tokenValue
                : '$operatorLabel: $tokenValue',
            icon: operator?.icon,
            isOperator: tokenValue.contains(':'),
          );
        })
        .toList(growable: false);
  }

  void _removeShowcaseSearchQueryToken(TelegramSearchQueryToken token) {
    final rawTokens = _tokenizeShowcaseSearchQuery(
      _showcaseSearchController.text,
      toLowerCase: false,
    ).toList(growable: true);
    if (rawTokens.isEmpty) {
      return;
    }
    final index = rawTokens.indexOf(token.value);
    if (index < 0) {
      return;
    }
    rawTokens.removeAt(index);
    final updatedQuery = rawTokens.join(' ').trim();
    _showcaseSearchController.value = TextEditingValue(
      text: updatedQuery,
      selection: TextSelection.collapsed(offset: updatedQuery.length),
    );
    _setShowcaseSearchQuery(updatedQuery);
    if (_showcaseHighlightedSearchOperatorId != null &&
        token.isOperator &&
        (_resolveShowcaseOperatorForToken(token.value)?.id ==
            _showcaseHighlightedSearchOperatorId)) {
      setState(() => _showcaseHighlightedSearchOperatorId = null);
    }
  }

  void _clearShowcaseSearchQueryTokens() {
    if (_showcaseSearchQuery.trim().isEmpty) {
      return;
    }
    _showcaseSearchController.clear();
    _setShowcaseSearchQuery('');
    setState(() => _showcaseHighlightedSearchOperatorId = null);
  }

  bool _matchesShowcaseSearchOperatorTokens(
    TelegramSearchResult result,
    Set<String> tokens,
  ) {
    if (tokens.isEmpty) {
      return true;
    }
    final title = result.title.toLowerCase();
    final subtitle = result.subtitle?.toLowerCase() ?? '';
    final section = (result.sectionLabel ?? '').toLowerCase();
    final normalizedSection = section.replaceAll('#', '');
    final snippet = result.snippet.toLowerCase();

    for (final token in tokens) {
      if (token == 'has:link' &&
          !snippet.contains('link') &&
          !snippet.contains('http')) {
        return false;
      }
      if (token == 'has:media' &&
          !snippet.contains('photo') &&
          !snippet.contains('video') &&
          !section.contains('media')) {
        return false;
      }
      if (token == 'is:unread' && result.unreadCount <= 0) {
        return false;
      }
      if (token == 'is:verified' && !result.isVerified) {
        return false;
      }
      if (token.startsWith('from:')) {
        final sender = token.substring(5).trim();
        if (sender.isNotEmpty &&
            !title.contains(sender) &&
            !subtitle.contains(sender)) {
          return false;
        }
      }
      if (token.startsWith('in:')) {
        final channel = token.substring(3).replaceAll('#', '').trim();
        if (channel.isNotEmpty && !normalizedSection.contains(channel)) {
          return false;
        }
      }
    }
    return true;
  }

  String _resolveShowcaseDateRangeLabel(String id) {
    for (final range in _showcaseDateRanges) {
      if (range.id == id) {
        return range.label;
      }
    }
    return _showcaseDateRanges.first.label;
  }

  String _resolveShowcaseScopeLabel(String id) {
    switch (id) {
      case 'chats':
        return 'Chats';
      case 'people':
        return 'People';
      case 'moderation':
        return 'Moderation';
      case 'all':
      default:
        return 'All';
    }
  }

  String? _resolveShowcaseScopeIdByLabel(String? label) {
    final normalized = label?.trim().toLowerCase();
    switch (normalized) {
      case 'all':
        return 'all';
      case 'chats':
        return 'chats';
      case 'people':
        return 'people';
      case 'moderation':
        return 'moderation';
      default:
        return null;
    }
  }

  String? _resolveShowcaseDateRangeIdByLabel(String? label) {
    if (label == null || label.trim().isEmpty) {
      return null;
    }
    final normalized = label.trim().toLowerCase();
    for (final range in _showcaseDateRanges) {
      if (range.label.trim().toLowerCase() == normalized) {
        return range.id;
      }
    }
    return null;
  }

  int _estimateShowcaseSearchLatencyMs({String? query}) {
    final normalizedQuery = (query ?? _showcaseSearchQuery).trim();
    final activeFilterCount = _showcaseSearchFilters
        .where((filter) => filter.selected)
        .length;
    return 12 + normalizedQuery.length * 3 + activeFilterCount * 2;
  }

  void _recordShowcaseSearchExecution({
    String? status,
    String? errorMessage,
    bool? fromCache,
  }) {
    final query = _showcaseSearchQuery.trim();
    if (query.isEmpty) {
      return;
    }
    final scopeLabel = _resolveShowcaseScopeLabel(_showcaseSearchScopeId);
    final dateRangeLabel = _showcaseSearchDateRangeId == 'anytime'
        ? null
        : _resolveShowcaseDateRangeLabel(_showcaseSearchDateRangeId);
    final latest = _showcaseSearchExecutions.isEmpty
        ? null
        : _showcaseSearchExecutions.first;
    final inferredCache =
        latest != null &&
        latest.query.trim().toLowerCase() == query.toLowerCase() &&
        (latest.scopeLabel ?? '') == scopeLabel &&
        (latest.dateRangeLabel ?? '') == (dateRangeLabel ?? '');
    final resolvedFromCache = fromCache ?? inferredCache;
    final lowerQuery = query.toLowerCase();
    final shouldFail =
        lowerQuery.contains('timeout') || lowerQuery.contains('error');
    final resolvedStatus =
        status ??
        (shouldFail
            ? 'failed'
            : resolvedFromCache
            ? 'cached'
            : 'success');
    final resolvedErrorMessage =
        errorMessage ??
        ((resolvedStatus == 'failed' || resolvedStatus == 'error')
            ? 'Gateway timeout while querying the moderation index.'
            : null);
    final execution = TelegramSearchExecution(
      id: 'execution_${_showcaseSearchExecutionSeed++}',
      query: query,
      status: resolvedStatus,
      scopeLabel: scopeLabel,
      dateRangeLabel: dateRangeLabel,
      startedAtLabel: 'Just now',
      durationMs: _estimateShowcaseSearchLatencyMs(query: query),
      resultCount: _buildShowcaseSearchResults().length,
      errorMessage: resolvedErrorMessage,
      fromCache: resolvedFromCache,
    );
    setState(() {
      _showcaseSearchExecutions = [
        execution,
        ..._showcaseSearchExecutions,
      ].take(12).toList(growable: false);
    });
  }

  int _estimateShowcaseResultDaysAgo(TelegramSearchResult result) {
    final label = result.timeLabel.trim().toLowerCase();
    if (label.contains('today')) {
      return 0;
    }
    if (label.contains('yesterday')) {
      return 1;
    }
    final hasClockFormat = RegExp(r'^\d{1,2}:\d{2}$').hasMatch(label);
    if (hasClockFormat) {
      return 0;
    }
    return 8;
  }

  bool _matchesShowcaseDateRange(
    TelegramSearchResult result, {
    String? rangeId,
  }) {
    final id = rangeId ?? _showcaseSearchDateRangeId;
    final daysAgo = _estimateShowcaseResultDaysAgo(result);
    switch (id) {
      case 'today':
        return daysAgo == 0;
      case 'last24h':
        return daysAgo <= 1;
      case 'last7d':
        return daysAgo <= 7;
      case 'anytime':
      default:
        return true;
    }
  }

  int _countShowcaseScopeResults(String scopeId) {
    return _showcaseSearchResults.where((result) {
      return _matchesShowcaseScope(result, scopeId: scopeId) &&
          _matchesShowcaseDateRange(result);
    }).length;
  }

  String _formatShowcaseSearchGroupLabel(String value) {
    final cleaned = value.replaceAll('#', '').trim();
    if (cleaned.isEmpty) {
      return 'Results';
    }
    final words = cleaned
        .split(RegExp(r'[\s_]+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return 'Results';
    }
    return words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  IconData _resolveShowcaseSearchGroupIcon(String groupId) {
    switch (groupId) {
      case 'moderation':
        return CupertinoIcons.shield_fill;
      case 'announcements':
        return CupertinoIcons.speaker_2_fill;
      case 'media':
        return CupertinoIcons.photo_fill_on_rectangle_fill;
      case 'ui_kit':
        return CupertinoIcons.square_grid_2x2_fill;
      default:
        return CupertinoIcons.chat_bubble_2_fill;
    }
  }

  List<TelegramSearchResultGroup> _buildShowcaseSearchResultGroups(
    List<TelegramSearchResult> results,
  ) {
    if (results.isEmpty) {
      return const [];
    }
    final grouped = <String, List<TelegramSearchResult>>{};
    final labels = <String, String>{};

    for (final result in results) {
      final rawLabel = result.sectionLabel?.trim();
      final hasLabel = rawLabel != null && rawLabel.isNotEmpty;
      final groupId = hasLabel
          ? rawLabel
                .replaceAll('#', '')
                .toLowerCase()
                .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
                .replaceAll(RegExp(r'_+'), '_')
                .replaceAll(RegExp(r'^_|_$'), '')
          : 'results';
      final normalizedGroupId = groupId.isEmpty ? 'results' : groupId;
      labels[normalizedGroupId] = _formatShowcaseSearchGroupLabel(
        rawLabel ?? 'Results',
      );
      grouped.putIfAbsent(normalizedGroupId, () => <TelegramSearchResult>[]);
      grouped[normalizedGroupId]!.add(result);
    }

    return grouped.entries
        .map(
          (entry) => TelegramSearchResultGroup(
            id: entry.key,
            label: labels[entry.key] ?? 'Results',
            results: entry.value,
            icon: _resolveShowcaseSearchGroupIcon(entry.key),
          ),
        )
        .toList(growable: false);
  }

  List<TelegramSearchResult> _buildShowcaseSearchResults() {
    final operatorTokens = _extractShowcaseSearchOperatorTokens(
      _showcaseSearchQuery,
    );
    final query = _extractShowcaseSearchKeywordQuery(_showcaseSearchQuery);
    if (query.isEmpty && operatorTokens.isEmpty) {
      return const [];
    }

    final filteredResults = _showcaseSearchResults
        .where((result) {
          final title = result.title.toLowerCase();
          final subtitle = result.subtitle?.toLowerCase() ?? '';
          final section = result.sectionLabel?.toLowerCase() ?? '';
          final snippet = result.snippet.toLowerCase();
          final matchesKeyword =
              query.isEmpty ||
              title.contains(query) ||
              subtitle.contains(query) ||
              section.contains(query) ||
              snippet.contains(query);
          return matchesKeyword &&
              _matchesShowcaseSearchOperatorTokens(result, operatorTokens) &&
              _matchesShowcaseScope(result) &&
              _matchesShowcaseDateRange(result) &&
              _matchesShowcaseFilters(result);
        })
        .toList(growable: false);
    return _sortShowcaseSearchResults(filteredResults, query: query);
  }

  List<TelegramSearchResult> _sortShowcaseSearchResults(
    List<TelegramSearchResult> results, {
    required String query,
  }) {
    if (results.length <= 1) {
      return results;
    }
    final sorted = [...results];
    switch (_showcaseSearchSortId) {
      case 'newest':
        sorted.sort(
          (a, b) => _buildShowcaseRecencyScore(
            b,
          ).compareTo(_buildShowcaseRecencyScore(a)),
        );
        break;
      case 'unread':
        sorted.sort((a, b) {
          final unreadDiff = b.unreadCount.compareTo(a.unreadCount);
          if (unreadDiff != 0) {
            return unreadDiff;
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
      case 'title':
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'relevance':
      default:
        sorted.sort((a, b) {
          final diff =
              _buildShowcaseRelevanceScore(b, query) -
              _buildShowcaseRelevanceScore(a, query);
          if (diff != 0) {
            return diff;
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
    }
    return sorted;
  }

  int _buildShowcaseRelevanceScore(TelegramSearchResult result, String query) {
    if (query.trim().isEmpty) {
      var baseScore = 0;
      if (result.unreadCount > 0) {
        baseScore += 1;
      }
      if (result.isVerified) {
        baseScore += 1;
      }
      return baseScore;
    }
    final title = result.title.toLowerCase();
    final subtitle = result.subtitle?.toLowerCase() ?? '';
    final section = result.sectionLabel?.toLowerCase() ?? '';
    final snippet = result.snippet.toLowerCase();
    var score = 0;
    if (title.contains(query)) {
      score += 6;
    }
    if (subtitle.contains(query)) {
      score += 4;
    }
    if (section.contains(query)) {
      score += 3;
    }
    if (snippet.contains(query)) {
      score += 2;
    }
    if (result.unreadCount > 0) {
      score += 1;
    }
    if (result.isVerified) {
      score += 1;
    }
    return score;
  }

  int _buildShowcaseRecencyScore(TelegramSearchResult result) {
    final label = result.timeLabel.trim().toLowerCase();
    if (label.contains('today')) {
      return 10000;
    }
    if (label.contains('yesterday')) {
      return 10;
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(label);
    if (match != null) {
      final hour = int.tryParse(match.group(1) ?? '') ?? 0;
      final minute = int.tryParse(match.group(2) ?? '') ?? 0;
      return 1000 + hour * 60 + minute;
    }
    return 0;
  }

  @override
  void dispose() {
    _showcaseSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final attachmentPreviewActions = [
      TelegramAttachmentAction(label: 'Photo', icon: CupertinoIcons.photo_fill),
      TelegramAttachmentAction(
        label: 'Video',
        icon: CupertinoIcons.videocam_fill,
      ),
      TelegramAttachmentAction(label: 'File', icon: CupertinoIcons.doc_fill),
      TelegramAttachmentAction(
        label: 'Contact',
        icon: CupertinoIcons.person_crop_circle_fill,
      ),
    ];
    final expandableInputTools = [
      TelegramAttachmentAction(
        label: 'Photo',
        icon: CupertinoIcons.photo_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Expand tool: Photo');
        },
      ),
      TelegramAttachmentAction(
        label: 'File',
        icon: CupertinoIcons.doc_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Expand tool: File');
        },
      ),
      TelegramAttachmentAction(
        label: 'Location',
        icon: CupertinoIcons.location_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Expand tool: Location');
        },
      ),
      TelegramAttachmentAction(
        label: 'Poll',
        icon: CupertinoIcons.chart_bar_alt_fill,
        onPressed: () async {
          TelegramToast.show(context, message: 'Expand tool: Poll');
        },
      ),
    ];
    const showcaseReceipts = [
      TelegramReadReceipt(
        id: 'showcase_r1',
        name: 'Alice Johnson',
        avatarFallback: 'AJ',
      ),
      TelegramReadReceipt(
        id: 'showcase_r2',
        name: 'Bob Chen',
        avatarFallback: 'BC',
      ),
      TelegramReadReceipt(
        id: 'showcase_r3',
        name: 'Product QA',
        avatarFallback: 'PQ',
      ),
    ];
    const channelProfileStats = [
      TelegramChannelStatItem(
        label: 'Subscribers',
        value: '48.2K',
        icon: CupertinoIcons.person_3_fill,
      ),
      TelegramChannelStatItem(
        label: 'Media',
        value: '1.3K',
        icon: CupertinoIcons.photo_fill_on_rectangle_fill,
      ),
      TelegramChannelStatItem(
        label: 'Links',
        value: '418',
        icon: CupertinoIcons.link,
      ),
      TelegramChannelStatItem(
        label: 'Pinned',
        value: '12',
        icon: CupertinoIcons.pin_fill,
      ),
    ];
    final channelProfileActions = [
      TelegramChannelInfoAction(
        icon: CupertinoIcons.person_crop_circle_badge_plus,
        label: 'Join',
        onTap: () {
          TelegramToast.show(context, message: 'Join pressed');
        },
      ),
      TelegramChannelInfoAction(
        icon: CupertinoIcons.bell_fill,
        label: 'Mute',
        onTap: () {
          TelegramToast.show(context, message: 'Mute pressed');
        },
      ),
      TelegramChannelInfoAction(
        icon: CupertinoIcons.square_arrow_up,
        label: 'Share',
        onTap: () {
          TelegramToast.show(context, message: 'Share pressed');
        },
      ),
    ];
    const managementAdmins = [
      TelegramAdminMember(
        id: 'showcase_admin_1',
        name: 'Alex Morgan',
        roleLabel: 'Owner',
        avatarFallback: 'AM',
        isOwner: true,
        pendingReports: 2,
      ),
      TelegramAdminMember(
        id: 'showcase_admin_2',
        name: 'Auto Mod Bot',
        roleLabel: 'Bot',
        avatarFallback: 'AB',
        isBot: true,
      ),
    ];
    const managementPermissions = [
      TelegramPermissionToggle(
        id: 'showcase_perm_1',
        label: 'Pin Messages',
        description: 'Keep release notes visible to everyone.',
        icon: CupertinoIcons.pin_fill,
        enabled: true,
      ),
      TelegramPermissionToggle(
        id: 'showcase_perm_2',
        label: 'Delete Messages',
        description: 'Remove abuse or spam quickly.',
        icon: CupertinoIcons.delete_solid,
        enabled: false,
        destructive: true,
      ),
      TelegramPermissionToggle(
        id: 'showcase_perm_3',
        label: 'Transfer Ownership',
        description: 'Only owner can update this setting.',
        icon: CupertinoIcons.lock_shield_fill,
        enabled: false,
        locked: true,
      ),
    ];
    const moderationQueueDemo = [
      TelegramModerationRequest(
        id: 'showcase_review_1',
        title: 'Reported message in #general',
        subtitle: 'Contains external promotion link',
        timeLabel: '10:42',
        pendingCount: 3,
        highPriority: true,
      ),
      TelegramModerationRequest(
        id: 'showcase_review_2',
        title: 'Join request pending',
        subtitle: 'Needs admin approval',
        timeLabel: '09:18',
        pendingCount: 1,
      ),
    ];
    const moderationDetailDemo = TelegramModerationRequest(
      id: 'showcase_review_detail',
      title: 'Reported message in #announcements',
      subtitle: 'Potential phishing link shared in public announcement.',
      timeLabel: '11:02',
      pendingCount: 4,
      highPriority: true,
    );
    const moderationDetailTags = ['Phishing', 'External Link', 'Urgent'];
    const auditLogDemo = [
      TelegramAdminAuditLog(
        id: 'audit_1',
        actorName: 'Alex Morgan',
        actionLabel: 'promoted',
        targetLabel: 'Emma Rivera to Admin',
        timeLabel: 'Today 10:20',
        icon: CupertinoIcons.person_crop_circle_badge_plus,
      ),
      TelegramAdminAuditLog(
        id: 'audit_2',
        actorName: 'Auto Mod Bot',
        actionLabel: 'removed',
        targetLabel: '4 spam messages in #general',
        timeLabel: 'Today 09:58',
        icon: CupertinoIcons.delete_solid,
        highPriority: true,
      ),
    ];
    const bannedMembersDemo = [
      TelegramBannedMember(
        id: 'banned_1',
        name: 'SpamAccount_24',
        reasonLabel: 'Scam links and repeated phishing',
        untilLabel: 'Muted until Mar 12',
        avatarFallback: 'SA',
        restrictedBy: 'Alex Morgan',
      ),
      TelegramBannedMember(
        id: 'banned_2',
        name: 'PromoBot',
        reasonLabel: 'Unsolicited ads in restricted channel',
        untilLabel: 'Permanently banned',
        avatarFallback: 'PB',
        restrictedBy: 'Auto Mod Bot',
        canAppeal: false,
      ),
    ];
    const showcaseAuditFilters = [
      TelegramAdminAuditFilter(
        id: 'all',
        label: 'All',
        count: 2,
        icon: CupertinoIcons.square_list_fill,
      ),
      TelegramAdminAuditFilter(
        id: 'admin',
        label: 'Admin',
        count: 1,
        icon: CupertinoIcons.person_crop_circle_badge_plus,
      ),
      TelegramAdminAuditFilter(
        id: 'automation',
        label: 'Automation',
        count: 1,
        icon: CupertinoIcons.gear_solid,
      ),
    ];
    final filteredShowcaseAuditLogs = auditLogDemo
        .where((entry) {
          switch (_showcaseAuditFilterId) {
            case 'admin':
              return entry.actionLabel == 'promoted';
            case 'automation':
              return entry.actorName.contains('Bot') || entry.highPriority;
            case 'all':
            default:
              return true;
          }
        })
        .toList(growable: false);
    final showcaseSearchResults = _buildShowcaseSearchResults();
    final groupedShowcaseSearchResults = _buildShowcaseSearchResultGroups(
      showcaseSearchResults,
    );
    final showcaseSearchScopes = [
      TelegramSearchScope(
        id: 'all',
        label: 'All',
        count: _countShowcaseScopeResults('all'),
        icon: CupertinoIcons.square_grid_2x2_fill,
      ),
      TelegramSearchScope(
        id: 'chats',
        label: 'Chats',
        count: _countShowcaseScopeResults('chats'),
        icon: CupertinoIcons.chat_bubble_2_fill,
      ),
      TelegramSearchScope(
        id: 'people',
        label: 'People',
        count: _countShowcaseScopeResults('people'),
        icon: CupertinoIcons.person_2_fill,
      ),
      TelegramSearchScope(
        id: 'moderation',
        label: 'Moderation',
        count: _countShowcaseScopeResults('moderation'),
        icon: CupertinoIcons.shield_fill,
      ),
    ];
    const showcaseSortOptions = [
      TelegramSearchSortOption(
        id: 'relevance',
        label: 'Relevance',
        icon: CupertinoIcons.scope,
      ),
      TelegramSearchSortOption(
        id: 'newest',
        label: 'Newest',
        icon: CupertinoIcons.clock_fill,
      ),
      TelegramSearchSortOption(
        id: 'unread',
        label: 'Unread',
        icon: CupertinoIcons.envelope_badge_fill,
      ),
      TelegramSearchSortOption(
        id: 'title',
        label: 'Title',
        icon: CupertinoIcons.textformat,
      ),
    ];
    final activeShowcaseSearchFilterCount = _showcaseSearchFilters
        .where((filter) => filter.selected)
        .length;
    final enabledShowcaseAlertCount = _showcaseSearchAlerts
        .where((alert) => alert.enabled)
        .length;
    final unreadShowcaseAlertCount = _showcaseSearchAlerts
        .where((alert) => alert.enabled)
        .fold<int>(0, (total, alert) => total + alert.unreadCount);
    final selectedShowcaseScopeLabel = showcaseSearchScopes
        .firstWhere(
          (scope) => scope.id == _showcaseSearchScopeId,
          orElse: () => showcaseSearchScopes.first,
        )
        .label;
    final selectedShowcaseDateRangeLabel = _resolveShowcaseDateRangeLabel(
      _showcaseSearchDateRangeId,
    );
    final selectedShowcaseSortLabel = showcaseSortOptions
        .firstWhere(
          (option) => option.id == _showcaseSearchSortId,
          orElse: () => showcaseSortOptions.first,
        )
        .label;
    final activeShowcaseSavedSearch = _resolveShowcaseSavedSearch(
      _showcaseSavedSearchId,
    );
    final showcaseQueryTokens = _buildShowcaseSearchQueryTokens(
      _showcaseSearchQuery,
    );
    final showcaseOperatorTokenCount = showcaseQueryTokens
        .where((token) => token.isOperator)
        .length;
    final showcaseKeywordQuery = _extractShowcaseSearchKeywordQuery(
      _showcaseSearchQuery,
    );
    final showcaseSelectedVisibleResults = showcaseSearchResults
        .where((result) => _showcaseSelectedSearchResultIds.contains(result.id))
        .toList(growable: false);
    final showcaseSearchResultActions = _buildShowcaseSearchResultActions(
      showcaseSelectedVisibleResults.length,
    );
    final showcaseSearchLatencyMs = _estimateShowcaseSearchLatencyMs();
    final showcaseLatestExecution = _showcaseSearchExecutions.isEmpty
        ? null
        : _showcaseSearchExecutions.first;
    final showcaseExecutionSuccessCount = _showcaseSearchExecutions
        .where((execution) => execution.isSuccess)
        .length;
    final showcaseExecutionFailedCount = _showcaseSearchExecutions
        .where((execution) => execution.isFailure)
        .length;
    final showcaseExecutionDurations = _showcaseSearchExecutions
        .where((execution) => execution.durationMs != null)
        .map((execution) => execution.durationMs!)
        .toList(growable: false);
    final showcaseExecutionAverageDurationMs =
        showcaseExecutionDurations.isEmpty
        ? 0
        : (showcaseExecutionDurations.reduce((a, b) => a + b) /
                  showcaseExecutionDurations.length)
              .round();

    return Scaffold(
      backgroundColor: theme.colors.secondaryBgColor,
      body: CustomScrollView(
        slivers: [
          TelegramCollapsibleLargeTitle(
            title: 'UI Kit',
            minExtent: 76,
            maxExtent: 120,
            leading: CupertinoButton(
              minimumSize: const Size.square(24),
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.search, size: 22),
            ),
            trailing: CupertinoButton(
              minimumSize: const Size.square(24),
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.slider_horizontal_3, size: 22),
            ),
          ),
          if (_showNotice)
            SliverToBoxAdapter(
              child: TelegramNoticeBanner(
                title: 'Design Token Updated',
                message:
                    'New accent colors are synced from the Telegram theme.',
                icon: CupertinoIcons.info_circle_fill,
                actionLabel: 'Apply',
                onActionTap: () {
                  TelegramToast.show(context, message: 'Applied successfully');
                },
                onClose: () => setState(() => _showNotice = false),
              ),
            ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Swipe Actions'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final chat = _swipeChats[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TelegramSwipeActions(
                    endActions: [
                      TelegramSwipeAction(
                        label: chat.isMuted ? 'Unmute' : 'Mute',
                        icon: chat.isMuted
                            ? CupertinoIcons.bell_fill
                            : CupertinoIcons.bell_slash_fill,
                        onTap: () async {
                          _updateChat(
                            chat.id,
                            (value) =>
                                _copyChat(value, isMuted: !value.isMuted),
                          );
                        },
                      ),
                      TelegramSwipeAction(
                        label: 'Archive',
                        icon: CupertinoIcons.archivebox_fill,
                        onTap: () async => _removeChat(chat.id, 'Archived'),
                      ),
                      TelegramSwipeAction(
                        label: 'Delete',
                        icon: CupertinoIcons.delete_solid,
                        destructive: true,
                        onTap: () async => _removeChat(chat.id, 'Deleted'),
                      ),
                    ],
                    startActions: [
                      TelegramSwipeAction(
                        label: chat.isPinned ? 'Unpin' : 'Pin',
                        icon: CupertinoIcons.pin_fill,
                        onTap: () async {
                          _updateChat(
                            chat.id,
                            (value) =>
                                _copyChat(value, isPinned: !value.isPinned),
                          );
                        },
                      ),
                      TelegramSwipeAction(
                        label: chat.unreadCount > 0 ? 'Read' : 'Unread',
                        icon: CupertinoIcons.mail_solid,
                        onTap: () async {
                          _updateChat(
                            chat.id,
                            (value) => _copyChat(
                              value,
                              unreadCount: value.unreadCount > 0 ? 0 : 1,
                            ),
                          );
                        },
                      ),
                    ],
                    child: ColoredBox(
                      color: theme.colors.sectionBgColor,
                      child: TelegramChatListTile(
                        chat: chat,
                        onTap: () {
                          TelegramToast.show(
                            context,
                            message: 'Opened ${chat.title}',
                          );
                        },
                      ),
                    ),
                  ),
                );
              }, childCount: _swipeChats.length),
            ),
          ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Context Menu'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TelegramContextMenu(
                actions: [
                  TelegramActionItem(
                    label: 'Copy Message',
                    icon: CupertinoIcons.doc_on_doc,
                    onPressed: () async {
                      TelegramToast.show(context, message: 'Message copied');
                    },
                  ),
                  TelegramActionItem(
                    label: 'Pin in Chat',
                    icon: CupertinoIcons.pin_fill,
                    onPressed: () async {
                      TelegramToast.show(context, message: 'Pinned to top');
                    },
                  ),
                  TelegramActionItem(
                    label: 'Delete',
                    icon: CupertinoIcons.delete,
                    isDestructive: true,
                    onPressed: () async {
                      TelegramToast.show(context, message: 'Message deleted');
                    },
                  ),
                ],
                preview: TelegramContextMenuPreview(
                  title: 'Long press this block',
                  subtitle: 'Shows a Telegram-style iOS context menu',
                  leading: TelegramAvatar(fallbackText: 'UI', size: 36),
                  trailing: Icon(
                    CupertinoIcons.chat_bubble_text_fill,
                    color: theme.colors.linkColor,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colors.sectionBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Long press me to open quick actions.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colors.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Search Experience'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TelegramSearchBar(
                    controller: _showcaseSearchController,
                    hintText: 'Search messages, people, files',
                    onChanged: _setShowcaseSearchQuery,
                    onSubmitted: _rememberShowcaseQuery,
                  ),
                  const SizedBox(height: 8),
                  TelegramSearchOperatorsBar(
                    operators: _showcaseSearchOperators,
                    highlightedId: _showcaseHighlightedSearchOperatorId,
                    onSelected: _applyShowcaseSearchOperator,
                  ),
                  if (showcaseQueryTokens.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    TelegramSearchQueryTokensBar(
                      tokens: showcaseQueryTokens,
                      onRemove: _removeShowcaseSearchQueryToken,
                      onClearAll: _clearShowcaseSearchQueryTokens,
                    ),
                  ],
                  const SizedBox(height: 8),
                  TelegramRecentSearchesBar(
                    queries: _showcaseRecentQueries,
                    onSelected: _applyShowcaseRecentQuery,
                    onRemove: _removeShowcaseRecentQuery,
                    onClearAll: _clearShowcaseRecentQueries,
                  ),
                  const SizedBox(height: 8),
                  TelegramSearchScopesBar(
                    scopes: showcaseSearchScopes,
                    selectedId: _showcaseSearchScopeId,
                    onSelected: _selectShowcaseSearchScope,
                  ),
                  const SizedBox(height: 8),
                  TelegramSearchDateRangesBar(
                    ranges: _showcaseDateRanges,
                    selectedId: _showcaseSearchDateRangeId,
                    onSelected: _selectShowcaseDateRange,
                  ),
                  const SizedBox(height: 8),
                  TelegramSavedSearchesBar(
                    searches: _showcaseSavedSearches,
                    selectedId: _showcaseSavedSearchId,
                    onSelected: _selectShowcaseSavedSearch,
                    onClearSelection: _clearShowcaseSavedSearchSelection,
                    clearLabel: 'Detach',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: TelegramSpacing.xs,
                    runSpacing: TelegramSpacing.xs,
                    children: [
                      CupertinoButton(
                        minimumSize: const Size(24, 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TelegramSpacing.s,
                          vertical: TelegramSpacing.xs,
                        ),
                        color: theme.colors.sectionBgColor,
                        borderRadius: BorderRadius.circular(999),
                        onPressed: _openShowcaseSearchHistorySheet,
                        child: Text(
                          'History',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        minimumSize: const Size(24, 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TelegramSpacing.s,
                          vertical: TelegramSpacing.xs,
                        ),
                        color: theme.colors.sectionBgColor,
                        borderRadius: BorderRadius.circular(999),
                        onPressed: _openShowcaseSearchOperatorsSheet,
                        child: Text(
                          'Operators',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        minimumSize: const Size(24, 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TelegramSpacing.s,
                          vertical: TelegramSpacing.xs,
                        ),
                        color: _showcaseSearchDateRangeId == 'anytime'
                            ? theme.colors.sectionBgColor
                            : theme.colors.linkColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        onPressed: _openShowcaseSearchDateRangesSheet,
                        child: Text(
                          _showcaseSearchDateRangeId == 'anytime'
                              ? 'Date'
                              : selectedShowcaseDateRangeLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _showcaseSearchDateRangeId == 'anytime'
                                ? theme.colors.textColor
                                : theme.colors.linkColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        minimumSize: const Size(24, 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TelegramSpacing.s,
                          vertical: TelegramSpacing.xs,
                        ),
                        color: theme.colors.linkColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        onPressed: _openShowcaseSearchFiltersSheet,
                        child: Text(
                          activeShowcaseSearchFilterCount == 0
                              ? 'Filters'
                              : 'Filters ($activeShowcaseSearchFilterCount)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colors.linkColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        minimumSize: const Size(24, 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TelegramSpacing.s,
                          vertical: TelegramSpacing.xs,
                        ),
                        color: enabledShowcaseAlertCount == 0
                            ? theme.colors.sectionBgColor
                            : theme.colors.unreadBadgeColor.withValues(
                                alpha: 0.16,
                              ),
                        borderRadius: BorderRadius.circular(999),
                        onPressed: _openShowcaseSearchAlertsSheet,
                        child: Text(
                          enabledShowcaseAlertCount == 0
                              ? 'Alerts'
                              : unreadShowcaseAlertCount == 0
                              ? 'Alerts ($enabledShowcaseAlertCount)'
                              : 'Alerts ($unreadShowcaseAlertCount)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: enabledShowcaseAlertCount == 0
                                ? theme.colors.textColor
                                : theme.colors.unreadBadgeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        minimumSize: const Size(24, 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TelegramSpacing.s,
                          vertical: TelegramSpacing.xs,
                        ),
                        color: theme.colors.sectionBgColor,
                        borderRadius: BorderRadius.circular(999),
                        onPressed: _openShowcaseSearchCommandsSheet,
                        child: Text(
                          'Actions',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TelegramActiveSearchFiltersBar(
                    filters: _showcaseSearchFilters,
                    onRemove: _removeShowcaseSearchFilter,
                    onClearAll: _clearShowcaseSearchFilters,
                  ),
                  if (enabledShowcaseAlertCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: TelegramSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: TelegramSpacing.s,
                        vertical: TelegramSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.sectionBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.bell_fill,
                            size: 14,
                            color: theme.colors.unreadBadgeColor,
                          ),
                          const SizedBox(width: TelegramSpacing.xs),
                          Expanded(
                            child: Text(
                              unreadShowcaseAlertCount == 0
                                  ? '$enabledShowcaseAlertCount alerts are active'
                                  : '$enabledShowcaseAlertCount alerts active · $unreadShowcaseAlertCount new matches',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colors.subtitleTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (activeShowcaseSavedSearch != null) ...[
                    const SizedBox(height: 8),
                    TelegramSavedSearchCard(
                      search: activeShowcaseSavedSearch,
                      selected: true,
                      applyLabel: 'Re-run',
                      deleteLabel: 'Detach',
                      onApply: _selectShowcaseSavedSearch,
                      onDelete: (_) => _clearShowcaseSavedSearchSelection(),
                    ),
                  ],
                  if (_showcaseSearchQuery.trim().isEmpty)
                    if (_showcaseSuggestions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: TelegramSpacing.s),
                        child: TelegramSearchEmptyState(
                          title: 'No suggestions',
                          message: 'Use recent searches or add a new keyword.',
                          actionLabel: 'Reset Suggestions',
                          onActionPressed: _resetShowcaseSuggestions,
                        ),
                      )
                    else ...[
                      const SizedBox(height: 8),
                      for (var i = 0; i < _showcaseSuggestions.length; i++)
                        TelegramSearchSuggestionTile(
                          query: _showcaseSuggestions[i],
                          subtitle: 'Tap to run this quick search',
                          icon: i == 0
                              ? CupertinoIcons.sparkles
                              : CupertinoIcons.clock_fill,
                          showDivider: i < _showcaseSuggestions.length - 1,
                          onTap: () =>
                              _applyShowcaseSuggestion(_showcaseSuggestions[i]),
                          onRemove: () => _removeShowcaseSuggestion(
                            _showcaseSuggestions[i],
                          ),
                        ),
                    ]
                  else ...[
                    const SizedBox(height: 8),
                    TelegramSearchQueryInspectorCard(
                      query: _showcaseSearchQuery,
                      keyword: showcaseKeywordQuery,
                      tokenCount: showcaseQueryTokens.length,
                      operatorCount: showcaseOperatorTokenCount,
                      resultCount: showcaseSearchResults.length,
                      scopeLabel: selectedShowcaseScopeLabel,
                      dateRangeLabel: _showcaseSearchDateRangeId == 'anytime'
                          ? null
                          : selectedShowcaseDateRangeLabel,
                      sortLabel: selectedShowcaseSortLabel,
                    ),
                    const SizedBox(height: 8),
                    TelegramSearchExecutionStatusCard(
                      totalCount: _showcaseSearchExecutions.length,
                      successCount: showcaseExecutionSuccessCount,
                      failedCount: showcaseExecutionFailedCount,
                      averageDurationMs: showcaseExecutionAverageDurationMs,
                      latestExecution: showcaseLatestExecution,
                      onOpenHistory: _openShowcaseSearchExecutionsSheet,
                      onRerunLatest: showcaseLatestExecution == null
                          ? null
                          : () {
                              final execution = showcaseLatestExecution;
                              if (execution.isFailure) {
                                _retryShowcaseSearchExecution(execution);
                                return;
                              }
                              _applyShowcaseSearchExecution(execution);
                            },
                    ),
                    if (showcaseLatestExecution != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: TelegramSearchExecutionTile(
                          execution: showcaseLatestExecution,
                          onTap: _applyShowcaseSearchExecution,
                          onRetry: showcaseLatestExecution.isFailure
                              ? _retryShowcaseSearchExecution
                              : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (showcaseSearchResults.isEmpty)
                      TelegramSearchEmptyState(
                        title:
                            'No matches for "${_showcaseSearchQuery.trim()}"',
                        message:
                            'Try another keyword or remove one of the recent filters.',
                        actionLabel: 'Clear Search',
                        onActionPressed: () {
                          _showcaseSearchController.clear();
                          _setShowcaseSearchQuery('');
                        },
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TelegramSearchSortBar(
                            options: showcaseSortOptions,
                            selectedId: _showcaseSearchSortId,
                            onSelected: _selectShowcaseSearchSort,
                          ),
                          const SizedBox(height: 8),
                          TelegramSearchResultStatsBar(
                            query: _showcaseSearchQuery,
                            resultCount: showcaseSearchResults.length,
                            scopeLabel: selectedShowcaseScopeLabel,
                            dateRangeLabel:
                                _showcaseSearchDateRangeId == 'anytime'
                                ? null
                                : selectedShowcaseDateRangeLabel,
                            sortLabel: selectedShowcaseSortLabel,
                            activeFilterCount: activeShowcaseSearchFilterCount,
                            elapsedMs: showcaseSearchLatencyMs,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _showcaseSearchSelectionMode
                                    ? 'Selection Mode'
                                    : 'Result Actions',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colors.subtitleTextColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(24, 20),
                                onPressed: _toggleShowcaseSearchSelectionMode,
                                child: Text(
                                  _showcaseSearchSelectionMode
                                      ? 'Cancel'
                                      : 'Select',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colors.linkColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_showcaseSearchSelectionMode) ...[
                            TelegramSearchSelectionSummaryCard(
                              selectedCount:
                                  showcaseSelectedVisibleResults.length,
                              totalCount: showcaseSearchResults.length,
                              onSelectAll: () =>
                                  _selectAllShowcaseSearchResults(
                                    showcaseSearchResults,
                                  ),
                              onClearSelection:
                                  _clearShowcaseSearchResultSelection,
                              onExit: _toggleShowcaseSearchSelectionMode,
                            ),
                            const SizedBox(height: 8),
                            TelegramSearchResultActionBar(
                              actions: showcaseSearchResultActions,
                              onSelected: (action) =>
                                  _runShowcaseSearchResultAction(
                                    action,
                                    showcaseSelectedVisibleResults,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          TelegramSearchGroupHeader(
                            label: 'Grouped Results',
                            count: showcaseSearchResults.length,
                            icon: CupertinoIcons.square_grid_2x2_fill,
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 320,
                              child: CustomScrollView(
                                slivers: [
                                  for (
                                    var groupIndex = 0;
                                    groupIndex <
                                        groupedShowcaseSearchResults.length;
                                    groupIndex++
                                  ) ...[
                                    TelegramStickySearchGroupHeader(
                                      label:
                                          groupedShowcaseSearchResults[groupIndex]
                                              .label,
                                      count:
                                          groupedShowcaseSearchResults[groupIndex]
                                              .results
                                              .length,
                                      icon:
                                          groupedShowcaseSearchResults[groupIndex]
                                              .icon,
                                      backgroundColor:
                                          theme.colors.secondaryBgColor,
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final result =
                                              groupedShowcaseSearchResults[groupIndex]
                                                  .results[index];
                                          final selected =
                                              _showcaseSelectedSearchResultIds
                                                  .contains(result.id);
                                          final isLastGroup =
                                              groupIndex ==
                                              groupedShowcaseSearchResults
                                                      .length -
                                                  1;
                                          final isLastItem =
                                              index ==
                                              groupedShowcaseSearchResults[groupIndex]
                                                      .results
                                                      .length -
                                                  1;
                                          return DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? theme.colors.linkColor
                                                        .withValues(alpha: 0.1)
                                                  : null,
                                            ),
                                            child: TelegramSearchResultTile(
                                              result: result,
                                              highlightQuery:
                                                  _showcaseSearchQuery,
                                              showDivider:
                                                  !(isLastGroup && isLastItem),
                                              onTap: () {
                                                if (_showcaseSearchSelectionMode) {
                                                  _toggleShowcaseSearchResultSelection(
                                                    result,
                                                  );
                                                  return;
                                                }
                                                _openShowcaseSearchResult(
                                                  result,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        childCount:
                                            groupedShowcaseSearchResults[groupIndex]
                                                .results
                                                .length,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Composer Components'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const TelegramReplyPreviewBar(
                    author: 'Nova Bot',
                    message: '/menu to open quick actions and settings',
                    leadingIcon: CupertinoIcons.reply,
                  ),
                  const SizedBox(height: 10),
                  TelegramInlineKeyboard(
                    rows: _previewKeyboardRows,
                    onButtonTap: _showKeyboardAction,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: TelegramAttachmentPanel(
                      actions: attachmentPreviewActions,
                      wrapInSafeArea: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TelegramPollCard(
                    question: 'Which primary accent do you prefer?',
                    options: [
                      TelegramPollOption(
                        id: 'blue',
                        label: 'Telegram Blue',
                        votes: 14,
                        selected: true,
                      ),
                      TelegramPollOption(
                        id: 'green',
                        label: 'Mint Green',
                        votes: 6,
                      ),
                      TelegramPollOption(
                        id: 'purple',
                        label: 'Violet',
                        votes: 3,
                      ),
                    ],
                    totalVotersLabel: '23 votes',
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: TelegramExpandableMessageInputBar(
                      tools: expandableInputTools,
                      onAttachPressed: () {
                        TelegramToast.show(
                          context,
                          message: 'Attachment panel preview',
                        );
                      },
                      onSend: (value) {
                        TelegramToast.show(context, message: 'Send: $value');
                      },
                      onVoicePressed: () {
                        TelegramToast.show(context, message: 'Voice pressed');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Message Cards'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const TelegramReferenceMessageCard(
                    sender: 'Design Team',
                    message: 'Final dark mode palette in Figma was updated.',
                    type: TelegramReferenceMessageType.reply,
                    timeLabel: '15:22',
                  ),
                  const SizedBox(height: 10),
                  const TelegramLinkPreviewCard(
                    preview: TelegramLinkPreview(
                      url: 'https://core.telegram.org/api',
                      title: 'Telegram API',
                      description:
                          'Telegram APIs for secure chat experiences and bots.',
                      siteName: 'Telegram',
                      domain: 'core.telegram.org',
                      thumbnailLabel: 'API',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TelegramVoiceMessageTile(
                    durationLabel: '1:08',
                    timeLabel: '15:23',
                    progress: 0.6,
                    isPlaying: true,
                    onPlayToggle: () {
                      TelegramToast.show(
                        context,
                        message: 'Voice preview toggled',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const TelegramLocationMessageTile(
                    title: 'Downtown Office',
                    subtitle: 'Live location · 2 min ago',
                    timeLabel: '15:24',
                  ),
                  const TelegramServiceMessageBubble(
                    message: 'Messages in this chat are secured.',
                    icon: CupertinoIcons.checkmark_shield_fill,
                  ),
                  const SizedBox(height: 10),
                  TelegramContactMessageTile(
                    name: 'Support Hotline',
                    phoneLabel: '+1 555 777 8899',
                    timeLabel: '15:25',
                    avatarFallback: 'SH',
                    onActionTap: () {
                      TelegramToast.show(context, message: 'Contact opened');
                    },
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: TelegramReadReceiptsStrip(
                      receipts: showcaseReceipts,
                      timeLabel: '15:28',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TelegramJumpToBottomButton(
                      unreadCount: 4,
                      onPressed: () {
                        TelegramToast.show(context, message: 'Jump to latest');
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TelegramChatActionToolbar(
                    title: 'Selection Mode',
                    actions: [
                      TelegramActionItem(
                        label: 'Copy',
                        icon: CupertinoIcons.doc_on_doc,
                        onPressed: () async {
                          TelegramToast.show(context, message: 'Copied');
                        },
                      ),
                      TelegramActionItem(
                        label: 'Share',
                        icon: CupertinoIcons.share,
                        onPressed: () async {
                          TelegramToast.show(context, message: 'Shared');
                        },
                      ),
                      TelegramActionItem(
                        label: 'Delete',
                        icon: CupertinoIcons.delete,
                        isDestructive: true,
                        onPressed: () async {
                          TelegramToast.show(context, message: 'Deleted');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Channel Profile'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TelegramChannelInfoHeader(
                    title: 'Telegram iOS UI Kit',
                    subtitle: '@telegram_ios_ui_kit · public channel',
                    description:
                        'Reusable Flutter widgets aligned with Telegram iOS patterns.',
                    avatarFallback: 'TK',
                    isVerified: true,
                    actions: channelProfileActions,
                  ),
                  const SizedBox(height: 10),
                  TelegramChannelStatsGrid(
                    items: channelProfileStats,
                    onItemTap: (item) {
                      TelegramToast.show(
                        context,
                        message: '${item.label}: ${item.value}',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < managementAdmins.length; i++)
                    TelegramAdminMemberTile(
                      member: managementAdmins[i],
                      showDivider: i < managementAdmins.length - 1,
                      onTap: () {
                        TelegramToast.show(
                          context,
                          message: 'Admin: ${managementAdmins[i].name}',
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                  TelegramPermissionsPanel(
                    title: 'Admin Permissions',
                    toggles: managementPermissions,
                    onToggleChanged: (toggle, value) {
                      TelegramToast.show(
                        context,
                        message: '${toggle.label}: ${value ? 'On' : 'Off'}',
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TelegramModerationQueueCard(
                    requests: moderationQueueDemo,
                    onRequestTap: (request) {
                      TelegramToast.show(context, message: request.title);
                    },
                    onReviewAll: () {
                      TelegramToast.show(context, message: 'Review all tapped');
                    },
                  ),
                  const SizedBox(height: 10),
                  TelegramModerationDetailCard(
                    request: moderationDetailDemo,
                    tags: moderationDetailTags,
                    evidenceCount: 3,
                    onReject: () {
                      TelegramToast.show(context, message: 'Rejected report');
                    },
                    onApprove: () {
                      TelegramToast.show(context, message: 'Approved report');
                    },
                    onOpenThread: () {
                      TelegramToast.show(context, message: 'Thread opened');
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      minimumSize: const Size(24, 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: TelegramSpacing.s,
                        vertical: TelegramSpacing.xs,
                      ),
                      color: theme.colors.linkColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      onPressed: () =>
                          _openShowcaseModerationDrawer(moderationDetailDemo),
                      child: Text(
                        'Open Drawer',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TelegramAdminAuditFilterBar(
                    filters: showcaseAuditFilters,
                    selectedId: _showcaseAuditFilterId,
                    onSelected: _selectShowcaseAuditFilter,
                  ),
                  const SizedBox(height: 10),
                  if (filteredShowcaseAuditLogs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(TelegramSpacing.m),
                      decoration: BoxDecoration(
                        color: theme.colors.sectionBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No matching audit logs.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colors.subtitleTextColor,
                        ),
                      ),
                    ),
                  for (var i = 0; i < filteredShowcaseAuditLogs.length; i++)
                    TelegramAdminAuditLogTile(
                      entry: filteredShowcaseAuditLogs[i],
                      showDivider: i < filteredShowcaseAuditLogs.length - 1,
                      onTap: () {
                        TelegramToast.show(
                          context,
                          message:
                              'Audit: ${filteredShowcaseAuditLogs[i].actionLabel}',
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < bannedMembersDemo.length; i++)
                    TelegramBannedMemberTile(
                      member: bannedMembersDemo[i],
                      showDivider: i < bannedMembersDemo.length - 1,
                      onTap: () {
                        TelegramToast.show(
                          context,
                          message: bannedMembersDemo[i].reasonLabel,
                        );
                      },
                      onUnban: () {
                        TelegramToast.show(
                          context,
                          message: 'Unbanned ${bannedMembersDemo[i].name}',
                        );
                      },
                    ),
                  const SizedBox(height: 10),
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
                          onPressed: () => _setShowcaseBulkSelectedCount(1),
                          child: Text(
                            'Select 1',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colors.textColor,
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
                          color: theme.colors.sectionBgColor,
                          borderRadius: BorderRadius.circular(10),
                          onPressed: () => _setShowcaseBulkSelectedCount(
                            bannedMembersDemo.length,
                          ),
                          child: Text(
                            'Select All',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colors.textColor,
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
                          color: theme.colors.sectionBgColor,
                          borderRadius: BorderRadius.circular(10),
                          onPressed: () => _setShowcaseBulkSelectedCount(0),
                          child: Text(
                            'Clear',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colors.textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TelegramBulkBanActionBar(
                    selectedCount: _showcaseBulkSelectedCount,
                    onClearSelection: () => _setShowcaseBulkSelectedCount(0),
                    onUnban: () {
                      _setShowcaseBulkSelectedCount(0);
                      TelegramToast.show(context, message: 'Bulk unban done');
                    },
                    onExtend: () {
                      TelegramToast.show(
                        context,
                        message:
                            'Extended restrictions for $_showcaseBulkSelectedCount users',
                      );
                    },
                    onDelete: () {
                      _setShowcaseBulkSelectedCount(0);
                      TelegramToast.show(context, message: 'Bulk delete done');
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Layouts & Timeline'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 130,
                      child: TelegramChatBackground(
                        wallpaper: const TelegramChatWallpaper.gradient(
                          primaryColor: Color(0xFFF5F9FF),
                          secondaryColor: Color(0xFFE9F1FF),
                          patternColor: Color(0x332E66FF),
                        ),
                        patternSpacing: 32,
                        child: Center(
                          child: Text(
                            'Telegram Chat Background',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colors.textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TelegramMessageSelectionWrapper(
                    isOutgoing: true,
                    selectionMode: true,
                    selected: true,
                    child: const TelegramChatBubble(
                      message: TelegramMessage(
                        id: 'demo_selected',
                        text: 'Long press to enter selection mode.',
                        timeLabel: '15:27',
                        isOutgoing: true,
                        status: TelegramMessageStatus.delivered,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TelegramMediaAlbumMessage(
                    items: ['One', 'Two', 'Three', 'Four'],
                    caption: 'Album message preview',
                    timeLabel: '15:26',
                  ),
                  const SizedBox(height: 10),
                  TelegramScheduleTimeline(
                    title: 'Delivery Plan',
                    events: _showcaseTimeline,
                    onEventTap: _showTimelineAction,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 200,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.sectionBgColor,
                        ),
                        child: CustomScrollView(
                          slivers: [
                            const TelegramStickyDateHeader(
                              label: 'Yesterday',
                              showBottomDivider: true,
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate.fixed(const [
                                  TelegramChatBubble(
                                    message: TelegramMessage(
                                      id: 'sticky_demo_1',
                                      text: 'Sticky date header stays pinned.',
                                      timeLabel: '12:20',
                                      isOutgoing: false,
                                    ),
                                  ),
                                  TelegramChatBubble(
                                    message: TelegramMessage(
                                      id: 'sticky_demo_2',
                                      text: 'Perfect for long message history.',
                                      timeLabel: '12:21',
                                      isOutgoing: true,
                                      status: TelegramMessageStatus.read,
                                    ),
                                  ),
                                  TelegramChatBubble(
                                    message: TelegramMessage(
                                      id: 'sticky_demo_3',
                                      text: 'Matches Telegram iOS behavior.',
                                      timeLabel: '12:22',
                                      isOutgoing: false,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: TelegramSectionHeader(title: 'Large Title Header'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: MediaQuery(
                  data: MediaQuery.of(context).removePadding(removeTop: true),
                  child: TelegramLargeTitleHeader(
                    title: 'Archived Chats',
                    subtitle: '14 conversations',
                    showBottomDivider: false,
                    leading: CupertinoButton(
                      minimumSize: const Size.square(24),
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: const Icon(CupertinoIcons.back, size: 20),
                    ),
                    trailing: CupertinoButton(
                      minimumSize: const Size.square(24),
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      child: const Icon(CupertinoIcons.search, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAppsTab extends StatefulWidget {
  const _MiniAppsTab();

  @override
  State<_MiniAppsTab> createState() => _MiniAppsTabState();
}

class _MiniAppsTabState extends State<_MiniAppsTab> {
  TelegramMiniAppButtonType _selectedType = TelegramMiniAppButtonType.webApp;

  Future<void> _showDemoActionSheet() async {
    await TelegramActionSheet.show(
      context,
      title: 'Bot Actions',
      message: 'Choose what to do with this mini app',
      actions: [
        TelegramActionItem(
          label: 'Open App',
          icon: CupertinoIcons.play_fill,
          onPressed: () async {
            TelegramToast.show(context, message: 'Opening mini app...');
          },
        ),
        TelegramActionItem(
          label: 'Share',
          icon: CupertinoIcons.share,
          onPressed: () async {
            TelegramToast.show(context, message: 'Share link copied');
          },
        ),
        TelegramActionItem(
          label: 'Remove from Chat',
          icon: CupertinoIcons.trash,
          isDestructive: true,
          onPressed: () async {
            TelegramToast.show(context, message: 'Mini app removed');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final labels = <TelegramMiniAppButtonType, String>{
      TelegramMiniAppButtonType.webApp: 'Web App',
      TelegramMiniAppButtonType.textCommands: 'Text Commands',
      TelegramMiniAppButtonType.closeApp: 'Close App',
    };

    return ColoredBox(
      color: theme.colors.bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TelegramNavigationBar(title: 'Mini Apps'),
          const TelegramSectionHeader(title: 'Bot Button Variants'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TelegramSegmentedControl<TelegramMiniAppButtonType>(
              values: labels,
              currentValue: _selectedType,
              onValueChanged: (value) => setState(() => _selectedType = value),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TelegramMiniAppButton(
              label: labels[_selectedType]!,
              type: _selectedType,
              onPressed: _showDemoActionSheet,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showDemoActionSheet,
                    icon: const Icon(CupertinoIcons.ellipsis_circle),
                    label: const Text('Show Action Sheet'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      TelegramToast.show(
                        context,
                        message: 'Mini app opened successfully',
                        actionLabel: 'Undo',
                        onActionPressed: () {},
                      );
                    },
                    icon: const Icon(CupertinoIcons.bell_fill),
                    label: const Text('Show Toast'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const TelegramSectionHeader(title: 'Compose Area'),
          const Spacer(),
          const TelegramMessageInputBar(
            showSendButton: false,
            hintText: 'Message',
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  bool _notifications = true;
  bool _inAppSounds = true;
  bool _showMessagePreview = true;
  bool _vibrateOnAlert = true;
  bool _badgeAppIcon = true;
  bool _twoStepVerificationEnabled = true;
  bool _quietHoursEnabled = true;
  String _selectedAutoDownloadPresetId = 'auto_download_standard';
  String _selectedQuietHoursPresetId = 'quiet_hours_night';
  String _selectedNotificationToneId = 'tone_note';
  String _selectedLastSeenPrivacyId = 'last_seen_everyone';
  String _selectedAuditFilterId = 'all';
  final Set<String> _selectedBannedMemberIds = <String>{};
  List<TelegramSettingsNetworkPolicy> _networkPolicies = const [
    TelegramSettingsNetworkPolicy(
      id: 'network_wifi_media',
      title: 'Auto-Download on Wi-Fi',
      enabled: true,
      subtitle: 'Download photos and videos automatically',
      limitLabel: '20 MB',
      icon: CupertinoIcons.wifi,
    ),
    TelegramSettingsNetworkPolicy(
      id: 'network_mobile_media',
      title: 'Auto-Download on Mobile',
      enabled: false,
      subtitle: 'Download photos only on cellular data',
      limitLabel: '2 MB',
      icon: CupertinoIcons.antenna_radiowaves_left_right,
    ),
    TelegramSettingsNetworkPolicy(
      id: 'network_roaming',
      title: 'Allow Roaming Data',
      enabled: false,
      subtitle: 'Use data while abroad',
      limitLabel: 'Off',
      icon: CupertinoIcons.airplane,
      destructive: true,
    ),
  ];
  static const List<TelegramSettingsQuickAction> _profileQuickActions = [
    TelegramSettingsQuickAction(
      id: 'profile_action_qr',
      label: 'QR Code',
      icon: CupertinoIcons.qrcode,
    ),
    TelegramSettingsQuickAction(
      id: 'profile_action_saved',
      label: 'Saved',
      icon: CupertinoIcons.bookmark_fill,
      badgeLabel: '12',
    ),
    TelegramSettingsQuickAction(
      id: 'profile_action_devices',
      label: 'Devices',
      icon: CupertinoIcons.device_phone_portrait,
      badgeLabel: '3',
    ),
    TelegramSettingsQuickAction(
      id: 'profile_action_logout',
      label: 'Logout',
      icon: CupertinoIcons.square_arrow_right,
      destructive: true,
    ),
  ];
  static const List<TelegramSettingsUsageSegment> _storageUsageSegments = [
    TelegramSettingsUsageSegment(
      id: 'usage_media',
      label: 'Media',
      ratio: 0.46,
      valueLabel: '1.1 GB',
    ),
    TelegramSettingsUsageSegment(
      id: 'usage_files',
      label: 'Files',
      ratio: 0.24,
      valueLabel: '560 MB',
    ),
    TelegramSettingsUsageSegment(
      id: 'usage_cache',
      label: 'Cache',
      ratio: 0.18,
      valueLabel: '420 MB',
    ),
    TelegramSettingsUsageSegment(
      id: 'usage_other',
      label: 'Other',
      ratio: 0.12,
      valueLabel: '280 MB',
    ),
  ];
  static const List<TelegramSettingsSession> _activeSessions = [
    TelegramSettingsSession(
      id: 'session_current',
      deviceName: 'iPhone 15 Pro',
      platformLabel: 'iOS 18.2',
      locationLabel: 'San Francisco',
      lastActiveLabel: 'active now',
      isCurrentDevice: true,
      isOnline: true,
    ),
    TelegramSettingsSession(
      id: 'session_macos',
      deviceName: 'MacBook Pro',
      platformLabel: 'macOS',
      locationLabel: 'San Francisco',
      lastActiveLabel: '2m ago',
      icon: CupertinoIcons.device_laptop,
      isOnline: true,
    ),
    TelegramSettingsSession(
      id: 'session_ipad',
      deviceName: 'iPad',
      platformLabel: 'iPadOS',
      locationLabel: 'Los Angeles',
      lastActiveLabel: '45m ago',
      icon: CupertinoIcons.device_phone_portrait,
    ),
    TelegramSettingsSession(
      id: 'session_web',
      deviceName: 'Telegram Web',
      platformLabel: 'Chrome',
      locationLabel: 'New York',
      lastActiveLabel: '3h ago',
      icon: CupertinoIcons.globe,
    ),
  ];
  static const List<TelegramSettingsPrivacyException> _privacyExceptions = [
    TelegramSettingsPrivacyException(
      id: 'privacy_always_share',
      title: 'Always Share With',
      subtitle: 'Contacts that can always see last seen',
      countLabel: '18',
      icon: CupertinoIcons.eye_fill,
    ),
    TelegramSettingsPrivacyException(
      id: 'privacy_never_share',
      title: 'Never Share With',
      subtitle: 'Users excluded from visibility',
      countLabel: '4',
      icon: CupertinoIcons.eye_slash_fill,
    ),
    TelegramSettingsPrivacyException(
      id: 'privacy_blocked',
      title: 'Blocked Users',
      subtitle: 'Blocked contacts and bots',
      countLabel: '12',
      icon: CupertinoIcons.person_crop_circle_badge_xmark,
      destructive: true,
    ),
  ];
  static const List<TelegramSettingsSecurityEvent> _securityEvents = [
    TelegramSettingsSecurityEvent(
      id: 'security_login',
      title: 'New Login',
      subtitle: 'MacBook Pro · San Francisco',
      timeLabel: '2m ago',
      icon: CupertinoIcons.device_laptop,
    ),
    TelegramSettingsSecurityEvent(
      id: 'security_password',
      title: 'Password Changed',
      subtitle: 'Confirmed from this device',
      timeLabel: '1d ago',
      icon: CupertinoIcons.lock_shield_fill,
    ),
    TelegramSettingsSecurityEvent(
      id: 'security_recovery',
      title: 'Recovery Email Removed',
      subtitle: 'Unrecognized location',
      timeLabel: '3d ago',
      icon: CupertinoIcons.exclamationmark_octagon_fill,
      highRisk: true,
    ),
  ];
  static const List<TelegramSettingsSecurityAction> _twoStepActions = [
    TelegramSettingsSecurityAction(
      id: '2fa_password',
      title: 'Change Password',
      subtitle: 'Updated 3 months ago',
      icon: CupertinoIcons.lock_fill,
    ),
    TelegramSettingsSecurityAction(
      id: '2fa_recovery',
      title: 'Recovery Email',
      subtitle: 'alex@telegram.dev',
      icon: CupertinoIcons.mail,
    ),
    TelegramSettingsSecurityAction(
      id: '2fa_devices',
      title: 'Trusted Devices',
      subtitle: '3 trusted devices',
      icon: CupertinoIcons.device_phone_portrait,
    ),
    TelegramSettingsSecurityAction(
      id: '2fa_disable',
      title: 'Disable Two-Step Verification',
      subtitle: 'Requires password confirmation',
      icon: CupertinoIcons.exclamationmark_octagon_fill,
      destructive: true,
    ),
  ];
  static const List<TelegramSettingsConnectedApp> _connectedApps = [
    TelegramSettingsConnectedApp(
      id: 'app_wallet',
      name: 'Wallet Mini App',
      subtitle: 'Balance and transfers',
      lastUsedLabel: '5m ago',
      icon: CupertinoIcons.creditcard_fill,
      verified: true,
    ),
    TelegramSettingsConnectedApp(
      id: 'app_crm',
      name: 'CRM Bot',
      subtitle: 'Reads contact metadata',
      lastUsedLabel: '2h ago',
      icon: CupertinoIcons.briefcase_fill,
      warningCount: 1,
    ),
    TelegramSettingsConnectedApp(
      id: 'app_weather',
      name: 'Weather Alerts',
      subtitle: 'Location-based alerts',
      lastUsedLabel: '1d ago',
      icon: CupertinoIcons.cloud_sun_fill,
    ),
  ];
  static const List<TelegramSettingsAutoDownloadPreset> _autoDownloadPresets = [
    TelegramSettingsAutoDownloadPreset(
      id: 'auto_download_low',
      label: 'Low',
      mediaLimitLabel: 'Up to 256 KB',
      description: 'Restrict downloads to small files only',
    ),
    TelegramSettingsAutoDownloadPreset(
      id: 'auto_download_standard',
      label: 'Standard',
      mediaLimitLabel: 'Up to 2 MB',
      description: 'Recommended for most users',
    ),
    TelegramSettingsAutoDownloadPreset(
      id: 'auto_download_high',
      label: 'High',
      mediaLimitLabel: 'Up to 20 MB',
      description: 'Best quality media downloads',
    ),
    TelegramSettingsAutoDownloadPreset(
      id: 'auto_download_unlimited',
      label: 'Unlimited',
      mediaLimitLabel: 'No size limits',
      description: 'May consume significant data',
    ),
  ];
  static const List<TelegramSettingsDataUsageItem> _dataUsageItems = [
    TelegramSettingsDataUsageItem(
      id: 'data_usage_photos',
      title: 'Photos',
      valueLabel: '1.4 GB',
      subtitle: 'Auto-download on Wi-Fi',
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
    ),
    TelegramSettingsDataUsageItem(
      id: 'data_usage_videos',
      title: 'Videos',
      valueLabel: '2.8 GB',
      subtitle: 'Streaming up to 720p',
      icon: CupertinoIcons.videocam_fill,
      highlighted: true,
    ),
    TelegramSettingsDataUsageItem(
      id: 'data_usage_calls',
      title: 'Calls',
      valueLabel: '420 MB',
      subtitle: 'Use less data enabled',
      icon: CupertinoIcons.phone_fill,
    ),
    TelegramSettingsDataUsageItem(
      id: 'data_usage_files',
      title: 'Files',
      valueLabel: '910 MB',
      subtitle: 'Manual download only',
      icon: CupertinoIcons.doc_fill,
    ),
  ];
  static const List<TelegramSettingsCleanupSuggestion> _cleanupSuggestions = [
    TelegramSettingsCleanupSuggestion(
      id: 'cleanup_videos',
      title: 'Large Videos',
      sizeLabel: '1.9 GB',
      subtitle: 'Files older than 30 days',
      icon: CupertinoIcons.videocam_fill,
    ),
    TelegramSettingsCleanupSuggestion(
      id: 'cleanup_cache',
      title: 'Temporary Cache',
      sizeLabel: '740 MB',
      subtitle: 'Can be safely removed',
      icon: CupertinoIcons.archivebox_fill,
    ),
    TelegramSettingsCleanupSuggestion(
      id: 'cleanup_duplicates',
      title: 'Duplicate Files',
      sizeLabel: '320 MB',
      subtitle: 'Media saved in multiple chats',
      icon: CupertinoIcons.doc_on_doc,
      destructive: true,
    ),
  ];
  static const List<TelegramSettingsQuietHoursPreset> _quietHoursPresets = [
    TelegramSettingsQuietHoursPreset(
      id: 'quiet_hours_night',
      label: 'Night',
      timeRangeLabel: '22:00 - 07:00',
      daysLabel: 'Every day',
    ),
    TelegramSettingsQuietHoursPreset(
      id: 'quiet_hours_work',
      label: 'Work Focus',
      timeRangeLabel: '09:30 - 12:00',
      daysLabel: 'Mon - Fri',
    ),
    TelegramSettingsQuietHoursPreset(
      id: 'quiet_hours_weekend',
      label: 'Weekend',
      timeRangeLabel: '00:00 - 09:00',
      daysLabel: 'Sat - Sun',
    ),
  ];
  static const List<TelegramSettingsSyncStatusItem> _syncStatusItems = [
    TelegramSettingsSyncStatusItem(
      id: 'sync_contacts',
      title: 'Contacts',
      statusLabel: 'Synced',
      subtitle: 'Last sync 2m ago',
      icon: CupertinoIcons.person_2_fill,
    ),
    TelegramSettingsSyncStatusItem(
      id: 'sync_messages',
      title: 'Message History',
      statusLabel: 'In Progress',
      subtitle: 'Syncing recent conversations',
      icon: CupertinoIcons.chat_bubble_2_fill,
      inProgress: true,
    ),
    TelegramSettingsSyncStatusItem(
      id: 'sync_media',
      title: 'Media Index',
      statusLabel: 'Issue',
      subtitle: '3 files failed verification',
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
      warning: true,
    ),
  ];
  static const List<TelegramSettingsShortcut> _settingsShortcuts = [
    TelegramSettingsShortcut(
      id: 'shortcut_privacy',
      title: 'Privacy',
      subtitle: 'Last Seen, blocked users',
      icon: CupertinoIcons.lock_fill,
    ),
    TelegramSettingsShortcut(
      id: 'shortcut_devices',
      title: 'Devices',
      subtitle: '3 active sessions',
      icon: CupertinoIcons.device_phone_portrait,
      badgeLabel: '3',
    ),
    TelegramSettingsShortcut(
      id: 'shortcut_storage',
      title: 'Storage',
      subtitle: '2.3 GB used',
      icon: CupertinoIcons.archivebox_fill,
    ),
    TelegramSettingsShortcut(
      id: 'shortcut_language',
      title: 'Language',
      subtitle: 'English',
      icon: CupertinoIcons.globe,
    ),
  ];
  static const List<TelegramSettingsOption> _notificationToneOptions = [
    TelegramSettingsOption(
      id: 'tone_none',
      label: 'None',
      subtitle: 'Silent notifications',
      icon: CupertinoIcons.bell_slash_fill,
    ),
    TelegramSettingsOption(
      id: 'tone_note',
      label: 'Note',
      subtitle: 'Default Telegram tone',
      icon: CupertinoIcons.music_note,
    ),
    TelegramSettingsOption(
      id: 'tone_chime',
      label: 'Chime',
      subtitle: 'Soft system chime',
      icon: CupertinoIcons.waveform_path,
    ),
    TelegramSettingsOption(
      id: 'tone_signal',
      label: 'Signal',
      subtitle: 'High-priority alert tone',
      icon: CupertinoIcons.bell_fill,
    ),
  ];
  static const List<TelegramSettingsOption> _lastSeenPrivacyOptions = [
    TelegramSettingsOption(
      id: 'last_seen_everyone',
      label: 'Everyone',
      subtitle: 'Visible to all users',
      icon: CupertinoIcons.globe,
    ),
    TelegramSettingsOption(
      id: 'last_seen_contacts',
      label: 'My Contacts',
      subtitle: 'Visible to contacts only',
      icon: CupertinoIcons.person_2_fill,
    ),
    TelegramSettingsOption(
      id: 'last_seen_nobody',
      label: 'Nobody',
      subtitle: 'Hide from all users',
      icon: CupertinoIcons.eye_slash_fill,
    ),
  ];
  final List<TelegramChannelStatItem> _channelStats = const [
    TelegramChannelStatItem(
      label: 'Subscribers',
      value: '48.2K',
      icon: CupertinoIcons.person_3_fill,
    ),
    TelegramChannelStatItem(
      label: 'Media',
      value: '1.3K',
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
    ),
    TelegramChannelStatItem(
      label: 'Links',
      value: '418',
      icon: CupertinoIcons.link,
    ),
    TelegramChannelStatItem(
      label: 'Pinned',
      value: '12',
      icon: CupertinoIcons.pin_fill,
    ),
  ];
  final List<TelegramAdminMember> _adminMembers = const [
    TelegramAdminMember(
      id: 'admin_1',
      name: 'Alex Morgan',
      roleLabel: 'Owner',
      avatarFallback: 'AM',
      isOwner: true,
      isOnline: true,
      pendingReports: 2,
      lastSeenLabel: 'active now',
    ),
    TelegramAdminMember(
      id: 'admin_2',
      name: 'Emma Rivera',
      roleLabel: 'Admin',
      avatarFallback: 'ER',
      pendingReports: 1,
      lastSeenLabel: 'last seen 4m ago',
    ),
    TelegramAdminMember(
      id: 'admin_3',
      name: 'Auto Mod Bot',
      roleLabel: 'Bot',
      avatarFallback: 'AB',
      isBot: true,
      lastSeenLabel: 'running',
    ),
  ];
  List<TelegramPermissionToggle> _permissionToggles = const [
    TelegramPermissionToggle(
      id: 'perm_invite',
      label: 'Invite Members',
      description: 'Allow admins to invite new users directly.',
      icon: CupertinoIcons.person_add_solid,
      enabled: true,
    ),
    TelegramPermissionToggle(
      id: 'perm_pin',
      label: 'Pin Messages',
      description: 'Allow pinning important announcements.',
      icon: CupertinoIcons.pin_fill,
      enabled: true,
    ),
    TelegramPermissionToggle(
      id: 'perm_delete',
      label: 'Delete Messages',
      description: 'Remove spam and policy-violating content.',
      icon: CupertinoIcons.delete_solid,
      enabled: false,
      destructive: true,
    ),
    TelegramPermissionToggle(
      id: 'perm_transfer',
      label: 'Transfer Ownership',
      description: 'Only current owner can assign this permission.',
      icon: CupertinoIcons.lock_shield_fill,
      enabled: false,
      locked: true,
    ),
  ];
  final List<TelegramModerationRequest> _moderationRequests = const [
    TelegramModerationRequest(
      id: 'review_1',
      title: 'Reported message in #general',
      subtitle: 'Contains external promotion link',
      timeLabel: '10:42',
      pendingCount: 3,
      highPriority: true,
    ),
    TelegramModerationRequest(
      id: 'review_2',
      title: 'Join request pending',
      subtitle: 'Need admin approval for restricted invite',
      timeLabel: '09:18',
      pendingCount: 1,
    ),
    TelegramModerationRequest(
      id: 'review_3',
      title: 'Edited policy post',
      subtitle: 'Verify latest rules and translation sync',
      timeLabel: 'Yesterday',
    ),
  ];
  final List<TelegramAdminAuditLog> _auditLogs = const [
    TelegramAdminAuditLog(
      id: 'audit_1',
      actorName: 'Alex Morgan',
      actionLabel: 'promoted',
      targetLabel: 'Emma Rivera to Admin',
      timeLabel: 'Today 10:20',
      icon: CupertinoIcons.person_crop_circle_badge_plus,
    ),
    TelegramAdminAuditLog(
      id: 'audit_2',
      actorName: 'Auto Mod Bot',
      actionLabel: 'removed',
      targetLabel: '4 spam messages in #general',
      timeLabel: 'Today 09:58',
      icon: CupertinoIcons.delete_solid,
      highPriority: true,
    ),
    TelegramAdminAuditLog(
      id: 'audit_3',
      actorName: 'Emma Rivera',
      actionLabel: 'updated',
      targetLabel: 'Posting permissions for new members',
      timeLabel: 'Yesterday',
      icon: CupertinoIcons.gear_solid,
    ),
  ];
  List<TelegramBannedMember> _bannedMembers = const [
    TelegramBannedMember(
      id: 'banned_1',
      name: 'SpamAccount_24',
      reasonLabel: 'Scam links and repeated phishing',
      untilLabel: 'Muted until Mar 12',
      avatarFallback: 'SA',
      restrictedBy: 'Alex Morgan',
    ),
    TelegramBannedMember(
      id: 'banned_2',
      name: 'PromoBot',
      reasonLabel: 'Unsolicited ads in restricted channel',
      untilLabel: 'Permanently banned',
      avatarFallback: 'PB',
      restrictedBy: 'Auto Mod Bot',
      canAppeal: false,
    ),
  ];
  final List<TelegramMediaItem> _media = const [
    TelegramMediaItem(id: 'm1', label: 'Desk'),
    TelegramMediaItem(id: 'm2', label: 'Wireframe'),
    TelegramMediaItem(id: 'm3', label: 'Chat'),
    TelegramMediaItem(
      id: 'm4',
      label: 'Demo',
      isVideo: true,
      durationLabel: '00:29',
    ),
    TelegramMediaItem(id: 'm5', label: 'Sticker'),
    TelegramMediaItem(
      id: 'm6',
      label: 'Call',
      isVideo: true,
      durationLabel: '01:12',
    ),
  ];

  String _resolveSettingsOptionLabel(
    List<TelegramSettingsOption> options,
    String id, {
    String fallback = 'Unknown',
  }) {
    for (final option in options) {
      if (option.id == id) {
        return option.label;
      }
    }
    return fallback;
  }

  void _selectNotificationTone(TelegramSettingsOption option) {
    if (_selectedNotificationToneId == option.id) {
      return;
    }
    setState(() => _selectedNotificationToneId = option.id);
    TelegramToast.show(context, message: 'Tone: ${option.label}');
  }

  void _selectLastSeenPrivacy(TelegramSettingsOption option) {
    if (_selectedLastSeenPrivacyId == option.id) {
      return;
    }
    setState(() => _selectedLastSeenPrivacyId = option.id);
    TelegramToast.show(context, message: 'Last Seen: ${option.label}');
  }

  Future<void> _openNotificationToneSheet() async {
    await TelegramSettingsOptionsSheet.show(
      context,
      title: 'Notification Tone',
      options: _notificationToneOptions,
      selectedId: _selectedNotificationToneId,
      onSelected: _selectNotificationTone,
    );
  }

  Future<void> _openLastSeenPrivacySheet() async {
    await TelegramSettingsOptionsSheet.show(
      context,
      title: 'Last Seen & Online',
      options: _lastSeenPrivacyOptions,
      selectedId: _selectedLastSeenPrivacyId,
      onSelected: _selectLastSeenPrivacy,
    );
  }

  void _openSettingsShortcut(TelegramSettingsShortcut shortcut) {
    switch (shortcut.id) {
      case 'shortcut_privacy':
        _managePrivacyExceptions();
        break;
      case 'shortcut_devices':
        _manageSessions();
        break;
      case 'shortcut_storage':
        TelegramToast.show(context, message: 'Open storage usage');
        break;
      case 'shortcut_language':
        TelegramToast.show(context, message: 'Open language settings');
        break;
      default:
        TelegramToast.show(context, message: shortcut.title);
        break;
    }
  }

  void _openProfileQuickAction(TelegramSettingsQuickAction action) {
    switch (action.id) {
      case 'profile_action_qr':
        TelegramToast.show(context, message: 'Share QR code opened');
        break;
      case 'profile_action_saved':
        TelegramToast.show(context, message: 'Open saved messages');
        break;
      case 'profile_action_devices':
        _manageSessions();
        break;
      case 'profile_action_logout':
        TelegramToast.show(context, message: 'Log out requires confirmation');
        break;
      default:
        TelegramToast.show(context, message: action.label);
        break;
    }
  }

  void _openStorageUsageManager() {
    TelegramToast.show(context, message: 'Open storage manager');
  }

  void _openPrivacyException(TelegramSettingsPrivacyException item) {
    TelegramToast.show(context, message: '${item.title} tapped');
  }

  void _managePrivacyExceptions() {
    TelegramToast.show(context, message: 'Manage privacy exceptions');
  }

  void _openSecurityEvent(TelegramSettingsSecurityEvent event) {
    TelegramToast.show(context, message: event.title);
  }

  void _reviewSecurityEvents() {
    TelegramToast.show(context, message: 'Review security events');
  }

  void _openSyncStatusItem(TelegramSettingsSyncStatusItem item) {
    TelegramToast.show(context, message: '${item.title}: ${item.statusLabel}');
  }

  void _syncNow() {
    TelegramToast.show(context, message: 'Manual sync started');
  }

  void _manageTwoStepVerification() {
    TelegramToast.show(context, message: 'Manage two-step verification');
  }

  void _openTwoStepAction(TelegramSettingsSecurityAction action) {
    switch (action.id) {
      case '2fa_password':
        TelegramToast.show(context, message: 'Open password change flow');
        break;
      case '2fa_recovery':
        TelegramToast.show(context, message: 'Manage recovery email');
        break;
      case '2fa_devices':
        TelegramToast.show(context, message: 'Review trusted devices');
        break;
      case '2fa_disable':
        setState(() => _twoStepVerificationEnabled = false);
        TelegramToast.show(
          context,
          message: 'Two-step verification disabled in demo',
        );
        break;
      default:
        TelegramToast.show(context, message: action.title);
        break;
    }
  }

  void _openConnectedApp(TelegramSettingsConnectedApp app) {
    TelegramToast.show(context, message: 'Open ${app.name}');
  }

  void _manageConnectedApps() {
    TelegramToast.show(context, message: 'Manage connected apps');
  }

  void _revokeConnectedApp(TelegramSettingsConnectedApp app) {
    TelegramToast.show(context, message: 'Revoked ${app.name}');
  }

  void _openDataUsageItem(TelegramSettingsDataUsageItem item) {
    TelegramToast.show(context, message: '${item.title}: ${item.valueLabel}');
  }

  void _resetDataUsage() {
    TelegramToast.show(context, message: 'Data usage statistics reset');
  }

  void _toggleNetworkPolicy(TelegramSettingsNetworkPolicy updated) {
    setState(() {
      _networkPolicies = _networkPolicies
          .map((policy) => policy.id == updated.id ? updated : policy)
          .toList(growable: false);
    });
    TelegramToast.show(
      context,
      message: '${updated.title}: ${updated.enabled ? 'On' : 'Off'}',
    );
  }

  void _manageNetworkPolicies() {
    TelegramToast.show(context, message: 'Open network policy manager');
  }

  void _selectAutoDownloadPreset(TelegramSettingsAutoDownloadPreset preset) {
    if (_selectedAutoDownloadPresetId == preset.id) {
      return;
    }
    setState(() => _selectedAutoDownloadPresetId = preset.id);
    TelegramToast.show(context, message: 'Auto-download: ${preset.label}');
  }

  void _manageAutoDownloadPresets() {
    TelegramToast.show(context, message: 'Manage auto-download presets');
  }

  void _openCleanupSuggestion(TelegramSettingsCleanupSuggestion suggestion) {
    TelegramToast.show(
      context,
      message: '${suggestion.title}: ${suggestion.sizeLabel}',
    );
  }

  void _runStorageCleanup() {
    TelegramToast.show(context, message: 'Storage cleanup started');
  }

  void _toggleQuietHours(bool enabled) {
    setState(() => _quietHoursEnabled = enabled);
    TelegramToast.show(
      context,
      message: enabled ? 'Quiet hours enabled' : 'Quiet hours disabled',
    );
  }

  void _selectQuietHoursPreset(TelegramSettingsQuietHoursPreset preset) {
    if (_selectedQuietHoursPresetId == preset.id) {
      return;
    }
    setState(() => _selectedQuietHoursPresetId = preset.id);
    TelegramToast.show(context, message: 'Quiet hours: ${preset.label}');
  }

  void _customizeQuietHours() {
    TelegramToast.show(context, message: 'Customize quiet hours');
  }

  void _openSession(TelegramSettingsSession session) {
    TelegramToast.show(context, message: 'Session: ${session.deviceName}');
  }

  void _manageSessions() {
    TelegramToast.show(context, message: 'Manage active sessions');
  }

  void _viewAllSessions() {
    TelegramToast.show(context, message: 'Show all active sessions');
  }

  void _openChannelStat(TelegramChannelStatItem item) {
    TelegramToast.show(context, message: '${item.label}: ${item.value}');
  }

  void _openAdminMember(TelegramAdminMember member) {
    TelegramToast.show(context, message: 'Admin: ${member.name}');
  }

  void _togglePermission(TelegramPermissionToggle toggle, bool value) {
    if (toggle.locked) {
      return;
    }
    setState(() {
      _permissionToggles = _permissionToggles
          .map(
            (item) =>
                item.id == toggle.id ? item.copyWith(enabled: value) : item,
          )
          .toList(growable: false);
    });
  }

  void _openModerationRequest(TelegramModerationRequest request) {
    _openModerationDetailDrawer(request);
  }

  void _reviewAllModerationRequests() {
    TelegramToast.show(context, message: 'Review queue opened');
  }

  void _openModerationThread(TelegramModerationRequest request) {
    TelegramToast.show(context, message: 'Thread: ${request.title}');
  }

  void _approveModerationRequest(TelegramModerationRequest request) {
    TelegramToast.show(context, message: 'Approved: ${request.id}');
  }

  void _rejectModerationRequest(TelegramModerationRequest request) {
    TelegramToast.show(context, message: 'Rejected: ${request.id}');
  }

  void _openAuditLog(TelegramAdminAuditLog entry) {
    TelegramToast.show(
      context,
      message: '${entry.actorName} ${entry.actionLabel}',
    );
  }

  void _selectAuditFilter(TelegramAdminAuditFilter filter) {
    if (_selectedAuditFilterId == filter.id) {
      return;
    }
    setState(() => _selectedAuditFilterId = filter.id);
  }

  List<TelegramAdminAuditLog> _buildFilteredAuditLogs() {
    return _auditLogs
        .where((entry) {
          switch (_selectedAuditFilterId) {
            case 'critical':
              return entry.highPriority;
            case 'admin':
              return entry.actionLabel == 'promoted';
            case 'all':
            default:
              return true;
          }
        })
        .toList(growable: false);
  }

  Future<void> _openModerationDetailDrawer(
    TelegramModerationRequest request,
  ) async {
    await TelegramModerationDetailDrawer.show(
      context,
      request: request,
      tags: const ['Spam', 'External Link', 'Manual Review'],
      evidenceCount: request.highPriority ? 4 : 2,
      reporterLabel: 'Reported by community moderation queue',
      messagePreview: request.subtitle,
      onApprove: () => _approveModerationRequest(request),
      onReject: () => _rejectModerationRequest(request),
      onOpenThread: () => _openModerationThread(request),
    );
  }

  void _toggleBannedMemberSelection(TelegramBannedMember member) {
    final selected = _selectedBannedMemberIds.contains(member.id);
    setState(() {
      if (selected) {
        _selectedBannedMemberIds.remove(member.id);
      } else {
        _selectedBannedMemberIds.add(member.id);
      }
    });
  }

  void _clearBannedSelection() {
    if (_selectedBannedMemberIds.isEmpty) {
      return;
    }
    setState(() => _selectedBannedMemberIds.clear());
  }

  void _unbanSelectedMembers() {
    if (_selectedBannedMemberIds.isEmpty) {
      return;
    }
    final selectedCount = _selectedBannedMemberIds.length;
    setState(() {
      _bannedMembers = _bannedMembers
          .where((member) => !_selectedBannedMemberIds.contains(member.id))
          .toList(growable: false);
      _selectedBannedMemberIds.clear();
    });
    TelegramToast.show(context, message: 'Unbanned $selectedCount members');
  }

  void _extendSelectedRestrictions() {
    if (_selectedBannedMemberIds.isEmpty) {
      return;
    }
    TelegramToast.show(
      context,
      message:
          'Extended restrictions for ${_selectedBannedMemberIds.length} users',
    );
  }

  void _deleteSelectedRestrictions() {
    if (_selectedBannedMemberIds.isEmpty) {
      return;
    }
    final selectedCount = _selectedBannedMemberIds.length;
    setState(() {
      _bannedMembers = _bannedMembers
          .where((member) => !_selectedBannedMemberIds.contains(member.id))
          .toList(growable: false);
      _selectedBannedMemberIds.clear();
    });
    TelegramToast.show(
      context,
      message: 'Deleted $selectedCount restriction records',
    );
  }

  void _unbanMember(TelegramBannedMember member) {
    setState(() {
      _bannedMembers = _bannedMembers
          .where((item) => item.id != member.id)
          .toList(growable: false);
      _selectedBannedMemberIds.remove(member.id);
    });
    TelegramToast.show(context, message: 'Unbanned ${member.name}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final channelActions = [
      TelegramChannelInfoAction(
        icon: CupertinoIcons.person_crop_circle_badge_plus,
        label: 'Join',
        onTap: () {
          TelegramToast.show(context, message: 'Joined channel');
        },
      ),
      TelegramChannelInfoAction(
        icon: CupertinoIcons.bell_fill,
        label: 'Mute',
        onTap: () {
          TelegramToast.show(context, message: 'Muted updates');
        },
      ),
      TelegramChannelInfoAction(
        icon: CupertinoIcons.square_arrow_up,
        label: 'Share',
        onTap: () {
          TelegramToast.show(context, message: 'Invite link copied');
        },
      ),
    ];
    final criticalAuditCount = _auditLogs
        .where((entry) => entry.highPriority)
        .length;
    final adminAuditCount = _auditLogs
        .where((entry) => entry.actionLabel == 'promoted')
        .length;
    final filteredAuditLogs = _buildFilteredAuditLogs();
    final selectedNotificationToneLabel = _resolveSettingsOptionLabel(
      _notificationToneOptions,
      _selectedNotificationToneId,
      fallback: _notificationToneOptions.first.label,
    );
    final selectedLastSeenPrivacyLabel = _resolveSettingsOptionLabel(
      _lastSeenPrivacyOptions,
      _selectedLastSeenPrivacyId,
      fallback: _lastSeenPrivacyOptions.first.label,
    );
    final auditFilters = [
      TelegramAdminAuditFilter(
        id: 'all',
        label: 'All',
        count: _auditLogs.length,
        icon: CupertinoIcons.square_list_fill,
      ),
      TelegramAdminAuditFilter(
        id: 'critical',
        label: 'Critical',
        count: criticalAuditCount,
        icon: CupertinoIcons.exclamationmark_octagon_fill,
      ),
      TelegramAdminAuditFilter(
        id: 'admin',
        label: 'Admin',
        count: adminAuditCount,
        icon: CupertinoIcons.person_crop_circle_badge_plus,
      ),
    ];

    return ColoredBox(
      color: theme.colors.secondaryBgColor,
      child: Stack(
        children: [
          Column(
            children: [
              const TelegramNavigationBar(title: 'Settings'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: _selectedBannedMemberIds.isEmpty ? 16 : 108,
                  ),
                  children: [
                    TelegramSettingsAccountCard(
                      name: 'Alex Morgan',
                      subtitle: '@alex_morgan',
                      detail: '+1 555 123 4567',
                      badgeLabel: 'Premium',
                      avatarFallback: 'AM',
                      onTap: () {
                        TelegramToast.show(context, message: 'Open profile');
                      },
                    ),
                    TelegramSettingsQuickActionsBar(
                      actions: _profileQuickActions,
                      onSelected: _openProfileQuickAction,
                    ),
                    const TelegramSectionHeader(title: 'Storage Usage'),
                    TelegramSettingsUsageCard(
                      title: 'Device Storage',
                      totalLabel: '2.3 GB used',
                      segments: _storageUsageSegments,
                      onManageTap: _openStorageUsageManager,
                    ),
                    const TelegramSectionHeader(title: 'Storage Cleanup'),
                    TelegramSettingsCleanupSuggestionsCard(
                      suggestions: _cleanupSuggestions,
                      onSelected: _openCleanupSuggestion,
                      onRunCleanupTap: _runStorageCleanup,
                    ),
                    const TelegramSectionHeader(title: 'Data Usage'),
                    TelegramSettingsDataUsageCard(
                      subtitle: 'Updated 4 minutes ago',
                      items: _dataUsageItems,
                      onItemTap: _openDataUsageItem,
                      onResetTap: _resetDataUsage,
                    ),
                    const TelegramSectionHeader(title: 'Network Policies'),
                    TelegramSettingsNetworkPoliciesCard(
                      policies: _networkPolicies,
                      onPolicyChanged: _toggleNetworkPolicy,
                      onManageTap: _manageNetworkPolicies,
                    ),
                    const TelegramSectionHeader(title: 'Auto-Download'),
                    TelegramSettingsAutoDownloadCard(
                      presets: _autoDownloadPresets,
                      selectedId: _selectedAutoDownloadPresetId,
                      onSelected: _selectAutoDownloadPreset,
                      onManageTap: _manageAutoDownloadPresets,
                    ),
                    const TelegramSectionHeader(title: 'Quiet Hours'),
                    TelegramSettingsQuietHoursCard(
                      enabled: _quietHoursEnabled,
                      presets: _quietHoursPresets,
                      selectedPresetId: _selectedQuietHoursPresetId,
                      onEnabledChanged: _toggleQuietHours,
                      onPresetSelected: _selectQuietHoursPreset,
                      onCustomizeTap: _customizeQuietHours,
                    ),
                    const TelegramSectionHeader(title: 'Active Sessions'),
                    TelegramSettingsSessionsCard(
                      subtitle: '${_activeSessions.length} devices signed in',
                      sessions: _activeSessions,
                      onSessionTap: _openSession,
                      onManageTap: _manageSessions,
                      onViewAllTap: _viewAllSessions,
                    ),
                    const TelegramSectionHeader(title: 'Privacy Exceptions'),
                    TelegramSettingsPrivacyExceptionsCard(
                      description:
                          'Configure users that always or never bypass privacy defaults.',
                      items: _privacyExceptions,
                      onSelected: _openPrivacyException,
                      onManageTap: _managePrivacyExceptions,
                    ),
                    const TelegramSectionHeader(title: 'Security'),
                    TelegramSettingsSecurityEventsCard(
                      events: _securityEvents,
                      onEventTap: _openSecurityEvent,
                      onReviewAllTap: _reviewSecurityEvents,
                    ),
                    const TelegramSectionHeader(title: 'Cloud Sync'),
                    TelegramSettingsSyncStatusCard(
                      summaryLabel: 'Last full sync today at 09:42',
                      items: _syncStatusItems,
                      onItemTap: _openSyncStatusItem,
                      onSyncNowTap: _syncNow,
                    ),
                    const TelegramSectionHeader(title: 'Two-Step Verification'),
                    TelegramSettingsTwoStepCard(
                      enabled: _twoStepVerificationEnabled,
                      description:
                          'Protect your account with an additional password when logging in on new devices.',
                      actions: _twoStepActions,
                      onManageTap: _manageTwoStepVerification,
                      onActionSelected: _openTwoStepAction,
                    ),
                    const TelegramSectionHeader(title: 'Connected Apps'),
                    TelegramSettingsConnectedAppsCard(
                      apps: _connectedApps,
                      onSelected: _openConnectedApp,
                      onManageTap: _manageConnectedApps,
                      onRevokeTap: _revokeConnectedApp,
                    ),
                    const TelegramSectionHeader(title: 'Quick Access'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TelegramSettingsShortcutsGrid(
                        shortcuts: _settingsShortcuts,
                        onSelected: _openSettingsShortcut,
                      ),
                    ),
                    const TelegramSectionHeader(title: 'Channel Profile'),
                    TelegramChannelInfoHeader(
                      title: 'Telegram iOS UI Kit',
                      subtitle: '@telegram_ios_ui_kit · public channel',
                      description:
                          'Reusable Flutter widgets aligned with Telegram iOS patterns.',
                      avatarFallback: 'TK',
                      isVerified: true,
                      actions: channelActions,
                    ),
                    const TelegramSectionHeader(title: 'Channel Insights'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TelegramChannelStatsGrid(
                        items: _channelStats,
                        onItemTap: _openChannelStat,
                      ),
                    ),
                    const TelegramSectionHeader(title: 'Admin Team'),
                    for (var i = 0; i < _adminMembers.length; i++)
                      TelegramAdminMemberTile(
                        member: _adminMembers[i],
                        showDivider: i < _adminMembers.length - 1,
                        onTap: () => _openAdminMember(_adminMembers[i]),
                      ),
                    const TelegramSectionHeader(title: 'Group Permissions'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TelegramPermissionsPanel(
                        title: 'Default Permissions',
                        toggles: _permissionToggles,
                        onToggleChanged: _togglePermission,
                      ),
                    ),
                    const TelegramSectionHeader(title: 'Review Queue'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TelegramModerationQueueCard(
                        requests: _moderationRequests,
                        onReviewAll: _reviewAllModerationRequests,
                        onRequestTap: _openModerationRequest,
                      ),
                    ),
                    if (_moderationRequests.isNotEmpty) ...[
                      const TelegramSectionHeader(title: 'Moderation Detail'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: TelegramModerationDetailCard(
                          request: _moderationRequests.first,
                          tags: const [
                            'Spam',
                            'External Link',
                            'Manual Review',
                          ],
                          evidenceCount: 3,
                          onReject: () => _rejectModerationRequest(
                            _moderationRequests.first,
                          ),
                          onApprove: () => _approveModerationRequest(
                            _moderationRequests.first,
                          ),
                          onOpenThread: () =>
                              _openModerationThread(_moderationRequests.first),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CupertinoButton(
                            minimumSize: const Size(24, 24),
                            padding: const EdgeInsets.symmetric(
                              horizontal: TelegramSpacing.s,
                              vertical: TelegramSpacing.xs,
                            ),
                            color: theme.colors.linkColor.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            onPressed: () => _openModerationDetailDrawer(
                              _moderationRequests.first,
                            ),
                            child: Text(
                              'Open Drawer',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colors.linkColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const TelegramSectionHeader(title: 'Admin Audit Logs'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TelegramAdminAuditFilterBar(
                        filters: auditFilters,
                        selectedId: _selectedAuditFilterId,
                        onSelected: _selectAuditFilter,
                      ),
                    ),
                    if (filteredAuditLogs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          'No audit logs for this filter.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colors.subtitleTextColor,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < filteredAuditLogs.length; i++)
                        TelegramAdminAuditLogTile(
                          entry: filteredAuditLogs[i],
                          showDivider: i < filteredAuditLogs.length - 1,
                          onTap: () => _openAuditLog(filteredAuditLogs[i]),
                        ),
                    const TelegramSectionHeader(title: 'Restricted Members'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        'Tap rows to select members for bulk actions.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colors.subtitleTextColor,
                        ),
                      ),
                    ),
                    if (_bannedMembers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          'No banned members.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colors.subtitleTextColor,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < _bannedMembers.length; i++)
                        TelegramBannedMemberTile(
                          member: _bannedMembers[i],
                          showDivider: i < _bannedMembers.length - 1,
                          onTap: () {
                            _toggleBannedMemberSelection(_bannedMembers[i]);
                            final selected = _selectedBannedMemberIds.contains(
                              _bannedMembers[i].id,
                            );
                            TelegramToast.show(
                              context,
                              message: selected
                                  ? 'Selected ${_bannedMembers[i].name}'
                                  : 'Deselected ${_bannedMembers[i].name}',
                            );
                          },
                          onUnban: () => _unbanMember(_bannedMembers[i]),
                        ),
                    const TelegramSectionHeader(title: 'Shared Media'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TelegramMediaGrid(
                        items: _media,
                        onItemTap: (item) {
                          TelegramToast.show(
                            context,
                            message: 'Opened media ${item.id}',
                          );
                        },
                      ),
                    ),
                    const TelegramSectionHeader(title: 'Account'),
                    TelegramSettingsGroup(
                      children: [
                        TelegramSettingsCell(
                          title: 'Phone Number',
                          subtitle: '+1 555 123 4567',
                          onTap: () {},
                        ),
                        TelegramSettingsCell(
                          title: 'Username',
                          subtitle: '@telegram_ui_kit',
                          onTap: () {},
                        ),
                        TelegramSettingsCell(
                          title: 'Last Seen & Online',
                          subtitle: selectedLastSeenPrivacyLabel,
                          showDivider: false,
                          onTap: _openLastSeenPrivacySheet,
                        ),
                      ],
                    ),
                    const TelegramSectionHeader(title: 'Notifications'),
                    TelegramSettingsGroup(
                      children: [
                        TelegramSettingsCell(
                          title: 'Enable Notifications',
                          switchValue: _notifications,
                          showChevron: false,
                          onSwitchChanged: (value) {
                            setState(() => _notifications = value);
                          },
                        ),
                        TelegramSettingsCell(
                          title: 'Notification Tone',
                          subtitle: selectedNotificationToneLabel,
                          onTap: _openNotificationToneSheet,
                        ),
                        TelegramSettingsCell(
                          title: 'In-App Sounds',
                          switchValue: _inAppSounds,
                          showChevron: false,
                          showDivider: false,
                          onSwitchChanged: (value) {
                            setState(() => _inAppSounds = value);
                          },
                        ),
                      ],
                    ),
                    TelegramSettingsCollapsibleSection(
                      title: 'Advanced Notifications',
                      initiallyExpanded: false,
                      onExpandedChanged: (expanded) {
                        TelegramToast.show(
                          context,
                          message: expanded
                              ? 'Advanced notifications expanded'
                              : 'Advanced notifications collapsed',
                        );
                      },
                      footer: const TelegramSettingsSectionFooter(
                        message:
                            'Advanced rules apply to all chats unless overridden per-chat.',
                      ),
                      children: [
                        TelegramSettingsCell(
                          title: 'Show Message Preview',
                          switchValue: _showMessagePreview,
                          showChevron: false,
                          onSwitchChanged: (value) {
                            setState(() => _showMessagePreview = value);
                          },
                        ),
                        TelegramSettingsCell(
                          title: 'Vibrate on Alert',
                          switchValue: _vibrateOnAlert,
                          showChevron: false,
                          onSwitchChanged: (value) {
                            setState(() => _vibrateOnAlert = value);
                          },
                        ),
                        TelegramSettingsCell(
                          title: 'Badge App Icon',
                          switchValue: _badgeAppIcon,
                          showChevron: false,
                          showDivider: false,
                          onSwitchChanged: (value) {
                            setState(() => _badgeAppIcon = value);
                          },
                        ),
                      ],
                    ),
                    const TelegramSectionHeader(title: 'Danger Zone'),
                    TelegramSettingsGroup(
                      children: [
                        TelegramSettingsCell(
                          title: 'Delete Account',
                          destructive: true,
                          showChevron: false,
                          showDivider: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TelegramBulkBanActionBar(
              selectedCount: _selectedBannedMemberIds.length,
              visible: _selectedBannedMemberIds.isNotEmpty,
              onClearSelection: _clearBannedSelection,
              onUnban: _unbanSelectedMembers,
              onExtend: _extendSelectedRestrictions,
              onDelete: _deleteSelectedRestrictions,
            ),
          ),
        ],
      ),
    );
  }
}
