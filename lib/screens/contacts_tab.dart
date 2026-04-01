import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/email_service.dart';
import 'qr_screen.dart';
import '../theme/app_theme.dart';

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
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.headerBgColor,
        border: null,
        middle: const Text('Контакты', style: TextStyle(color: AppTheme.textColor)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, color: AppTheme.accentTextColor),
          onPressed: _showAddContactOptions,
        ),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.person_2, size: 80, color: AppTheme.subtitleTextColor),
          const SizedBox(height: 16),
          const Text(
            'Нет контактов',
            style: TextStyle(fontSize: 20, color: AppTheme.subtitleTextColor),
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

  Widget _buildContactList() {
    return ListView.separated(
      itemCount: _contacts.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: AppTheme.sectionSeparatorColor,
        indent: 72,
      ),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final email = contact['email'] as String;
        
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showContactDetails(contact),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.bgColor,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTextColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      email[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 17,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: AppTheme.subtitleTextColor,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
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
