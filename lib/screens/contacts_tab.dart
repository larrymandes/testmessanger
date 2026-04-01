import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/email_service.dart';
import 'qr_screen.dart';

class ContactsTab extends StatefulWidget {
  final String email;
  final String password;
  final EmailService emailService;
  final String? myPublicKeyHex;

  const ContactsTab({
    super.key,
    required this.email,
    required this.password,
    required this.emailService,
    this.myPublicKeyHex,
  });

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    _contacts = await StorageService.getContacts(widget.email);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = TelegramTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ContactsHeaderDelegate(theme: theme),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (_contacts.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(theme))
          else
            _buildContactList(theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TelegramThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.person_2, size: 80, color: theme.colors.subtitleTextColor),
          const SizedBox(height: 16),
          Text(
            'Нет контактов',
            style: TextStyle(fontSize: 20, color: theme.colors.subtitleTextColor),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            child: const Text('Добавить контакт'),
            onPressed: _showAddContactOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildContactList(TelegramThemeData theme) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final contact = _contacts[index];
          final email = contact['email'] as String;
          
          return TelegramContactListTile(
            avatar: TelegramAvatar(
              text: email[0].toUpperCase(),
              size: 56,
            ),
            name: email,
            onTap: () => _showContactDetails(contact),
          );
        },
        childCount: _contacts.length,
      ),
    );
  }

  void _showContactDetails(Map<String, dynamic> contact) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(contact['email']),
        message: FutureBuilder<String>(
          future: CryptoService.getFingerprint(contact['publicKey']),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            return Text(
              'Fingerprint:\n${snapshot.data}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            );
          },
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Открыть чат
            },
            child: const Text('Написать сообщение'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ),
    );
  }

  void _showAddContactOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Добавить контакт'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showMyQR();
            },
            child: const Text('Показать мой QR-код'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _scanQR();
            },
            child: const Text('Сканировать QR-код'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
      ),
    );
  }

  void _showMyQR() {
    if (widget.myPublicKeyHex == null) return;
    
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => QRScreen(
          myEmail: widget.email,
          myPublicKey: widget.myPublicKeyHex!,
        ),
      ),
    );
  }

  void _scanQR() async {
    if (widget.myPublicKeyHex == null) return;
    
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ScanQRScreen(
          myEmail: widget.email,
          myPublicKeyHex: widget.myPublicKeyHex!,
          emailService: widget.emailService,
          onContactAdded: (email, pubKey) async {
            await _loadContacts();
          },
        ),
      ),
    );
  }
}


class _ContactsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TelegramThemeData theme;

  _ContactsHeaderDelegate({required this.theme});

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 96;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    
    return Container(
      color: theme.colors.headerBgColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: progress,
                      child: Text(
                        'Контакты',
                        style: TextStyle(
                          color: theme.colors.textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(CupertinoIcons.add, color: theme.colors.accentTextColor),
                      onPressed: () {
                        final state = context.findAncestorStateOfType<_ContactsTabState>();
                        state?._showAddContactOptions();
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (progress < 1)
              Opacity(
                opacity: 1 - progress,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Контакты',
                      style: TextStyle(
                        color: theme.colors.textColor,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ContactsHeaderDelegate oldDelegate) => false;
}
