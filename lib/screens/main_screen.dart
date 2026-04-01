import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import '../services/email_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import 'chats_tab.dart';
import 'contacts_tab.dart';
import 'settings_tab.dart';

class MainScreen extends StatefulWidget {
  final String email;
  final String password;

  const MainScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Начинаем с Chats
  late EmailService _emailService;
  AsymmetricKeyPair<PublicKey, PrivateKey>? _myKeyPair;
  String? _myPublicKeyHex;

  @override
  void initState() {
    super.initState();
    _emailService = EmailService(
      email: widget.email,
      password: widget.password,
    );
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final account = await StorageService.getAccount(widget.email);
    if (account != null) {
      final privateKey = CryptoService.importPrivateKey(account['privateKey']!);
      final publicKey = CryptoService.importPublicKey(account['publicKey']!);
      _myKeyPair = AsymmetricKeyPair<PublicKey, PrivateKey>(publicKey, privateKey);
      _myPublicKeyHex = account['publicKey']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ContactsTab(
        email: widget.email,
        password: widget.password,
        emailService: _emailService,
        myPublicKeyHex: _myPublicKeyHex,
      ),
      ChatsTab(
        email: widget.email,
        password: widget.password,
        emailService: _emailService,
        myKeyPair: _myKeyPair,
        myPublicKeyHex: _myPublicKeyHex,
      ),
      SettingsTab(
        email: widget.email,
        emailService: _emailService,
        myPublicKeyHex: _myPublicKeyHex,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2),
            label: 'Контакты',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Настройки',
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
