import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'account_select_screen.dart';

class SettingsTab extends StatefulWidget {
  final String email;

  const SettingsTab({
    super.key,
    required this.email,
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
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppTheme.headerBgColor,
        border: null,
        middle: Text('Настройки', style: TextStyle(color: AppTheme.textColor)),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 24),
            // Профиль
            _buildProfileSection(),
            const SizedBox(height: 24),
            // Аккаунт
            _buildSection(
              title: 'АККАУНТ',
              items: [
                _buildSettingsItem(
                  icon: CupertinoIcons.person,
                  title: widget.email,
                  subtitle: _fingerprint,
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: CupertinoIcons.arrow_right_arrow_left,
                  title: 'Сменить аккаунт',
                  onTap: _switchAccount,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Данные
            _buildSection(
              title: 'ДАННЫЕ',
              items: [
                _buildSettingsItem(
                  icon: CupertinoIcons.arrow_down_doc,
                  title: 'Экспорт данных',
                  subtitle: 'Сохранить ключи и чаты',
                  onTap: () {
                    // TODO: Экспорт
                    _showComingSoon();
                  },
                ),
                _buildSettingsItem(
                  icon: CupertinoIcons.arrow_up_doc,
                  title: 'Импорт данных',
                  subtitle: 'Восстановить из файла',
                  onTap: () {
                    // TODO: Импорт
                    _showComingSoon();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // О приложении
            _buildSection(
              title: 'О ПРИЛОЖЕНИИ',
              items: [
                _buildSettingsItem(
                  icon: CupertinoIcons.info,
                  title: 'Secure Messenger',
                  subtitle: 'E2EE over Email • v1.0.0',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentTextColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.email[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.email,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.sectionHeaderTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          color: AppTheme.sectionBgColor,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.sectionSeparatorColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentTextColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 17,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.subtitleTextColor,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
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
    if (_myPublicKeyHex == null) return;
    
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => QRScreen(
          myEmail: widget.email,
          myPublicKey: _myPublicKeyHex!,
        ),
      ),
    );
  }

  void _scanQR() async {
    if (_myPublicKeyHex == null) return;
    
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ScanQRScreen(
          myEmail: widget.email,
          myPublicKeyHex: _myPublicKeyHex!,
          emailService: _emailService,
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

  @override
  void dispose() {
    _emailService.disconnect();
    super.dispose();
  }
}
