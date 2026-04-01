import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';
import '../services/storage_service.dart';
import '../services/crypto_service.dart';
import '../services/email_service.dart';
import 'account_select_screen.dart';
import 'qr_screen.dart';

class SettingsTab extends StatefulWidget {
  final String email;
  final EmailService emailService;
  final String? myPublicKeyHex;

  const SettingsTab({
    super.key,
    required this.email,
    required this.emailService,
    this.myPublicKeyHex,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> with AutomaticKeepAliveClientMixin {
  String? _fingerprint;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFingerprint();
  }

  Future<void> _loadFingerprint() async {
    final account = await StorageService.getAccount(widget.email);
    if (account != null) {
      final fp = await CryptoService.getFingerprint(account['publicKey']!);
      setState(() => _fingerprint = fp);
    }
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
            delegate: _SettingsHeaderDelegate(theme: theme),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildProfileSection(theme),
                const SizedBox(height: 24),
                _buildAccountSection(theme),
                const SizedBox(height: 24),
                _buildDataSection(theme),
                const SizedBox(height: 24),
                _buildAboutSection(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(TelegramThemeData theme) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          TelegramAvatar(
            text: widget.email[0].toUpperCase(),
            size: 80,
          ),
          const SizedBox(height: 12),
          Text(
            widget.email,
            style: TextStyle(
              color: theme.colors.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(TelegramThemeData theme) {
    return TelegramSettingsGroup(
      header: 'АККАУНТ',
      children: [
        TelegramSettingsCell(
          leading: Icon(CupertinoIcons.person, color: theme.colors.accentTextColor),
          title: widget.email,
          subtitle: _fingerprint,
          onTap: () {},
        ),
        TelegramSettingsCell(
          leading: Icon(CupertinoIcons.arrow_right_arrow_left, color: theme.colors.accentTextColor),
          title: 'Сменить аккаунт',
          onTap: _switchAccount,
        ),
      ],
    );
  }

  Widget _buildDataSection(TelegramThemeData theme) {
    return TelegramSettingsGroup(
      header: 'ДАННЫЕ',
      children: [
        TelegramSettingsCell(
          leading: Icon(CupertinoIcons.arrow_down_doc, color: theme.colors.accentTextColor),
          title: 'Экспорт данных',
          subtitle: 'Сохранить ключи и чаты',
          onTap: _showComingSoon,
        ),
        TelegramSettingsCell(
          leading: Icon(CupertinoIcons.arrow_up_doc, color: theme.colors.accentTextColor),
          title: 'Импорт данных',
          subtitle: 'Восстановить из файла',
          onTap: _showComingSoon,
        ),
      ],
    );
  }

  Widget _buildAboutSection(TelegramThemeData theme) {
    return TelegramSettingsGroup(
      header: 'О ПРИЛОЖЕНИИ',
      children: [
        TelegramSettingsCell(
          leading: Icon(CupertinoIcons.info, color: theme.colors.accentTextColor),
          title: 'Secure Messenger',
          subtitle: 'E2EE over Email • v1.0.0',
          onTap: () {},
        ),
      ],
    );
  }

  void _switchAccount() {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => const AccountSelectScreen()),
      (route) => false,
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

  void _showComingSoon() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('В разработке'),
        content: const Text('Эта функция скоро появится'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('В разработке'),
        content: const Text('Эта функция скоро появится'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _loadContacts() async {
    // Stub для обновления после добавления контакта
  }
}


class _SettingsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TelegramThemeData theme;

  _SettingsHeaderDelegate({required this.theme});

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
              child: Center(
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    'Настройки',
                    style: TextStyle(
                      color: theme.colors.textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
                      'Настройки',
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
  bool shouldRebuild(covariant _SettingsHeaderDelegate oldDelegate) => false;
}
