import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/email_service.dart';

class QRScreen extends StatelessWidget {
  final String myEmail;
  final String myPublicKey;

  const QRScreen({
    super.key,
    required this.myEmail,
    required this.myPublicKey,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = 'chatinvite:$myEmail:$myPublicKey:${DateTime.now().millisecondsSinceEpoch}';
    final theme = TelegramTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.colors.headerBgColor,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: theme.colors.accentTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text('Мой QR-код', style: TextStyle(color: theme.colors.textColor)),
      ),
      child: Container(
        color: theme.colors.bgColor,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 280,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  myEmail,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colors.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<String>(
                  future: CryptoService.getFingerprint(myPublicKey),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return Text(
                      'Fingerprint:\n${snapshot.data}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: theme.colors.subtitleTextColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                CupertinoButton.filled(
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.doc_on_clipboard, size: 20),
                      SizedBox(width: 8),
                      Text('Скопировать'),
                    ],
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: qrData));
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        content: const Text('Скопировано!'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScanQRScreen extends StatefulWidget {
  final String myEmail;
  final String myPublicKeyHex;
  final EmailService emailService;
  final Function(String contactEmail, String publicKey) onContactAdded;

  const ScanQRScreen({
    super.key,
    required this.myEmail,
    required this.myPublicKeyHex,
    required this.emailService,
    required this.onContactAdded,
  });

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = TelegramTheme.of(context);
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.colors.headerBgColor,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.back, color: theme.colors.accentTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text('Сканировать QR', style: TextStyle(color: theme.colors.textColor)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.camera_rotate, color: theme.colors.accentTextColor),
          onPressed: () => _controller.switchCamera(),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (_isProcessing) return;
                
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _processQRCode(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colors.bottomBarBgColor,
            child: Column(
              children: [
                Text(
                  'Наведите камеру на QR-код контакта',
                  style: TextStyle(fontSize: 16, color: theme.colors.textColor),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: const Text('Ввести вручную'),
                  onPressed: _showManualInput,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _processQRCode(String qrData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final parts = qrData.split(':');
      if (parts.length < 3 || parts[0] != 'chatinvite') {
        throw Exception('Неверный формат QR-кода');
      }

      final contactEmail = parts[1];
      final publicKey = parts[2];

      if (contactEmail == widget.myEmail) {
        throw Exception('Нельзя добавить самого себя');
      }

      // Проверяем, не добавлен ли уже
      final existing = await StorageService.getContact(widget.myEmail, contactEmail);
      if (existing != null) {
        throw Exception('Контакт уже добавлен');
      }

      // Сохраняем контакт
      await StorageService.saveContact(
        accountEmail: widget.myEmail,
        contactEmail: contactEmail,
        publicKey: publicKey,
      );

      // Отправляем invite обратно для взаимного добавления
      try {
        final inviteMessage = jsonEncode({
          'type': 'invite',
          'email': widget.myEmail,
          'pubkey': widget.myPublicKeyHex,
        });
        
        final encrypted = await CryptoService.encryptMessage(
          plaintext: inviteMessage,
          recipientPubKeyHex: publicKey,
          senderEmail: widget.myEmail,
          recipientEmail: contactEmail,
        );
        
        await widget.emailService.sendMessage(
          toEmail: contactEmail,
          encryptedPayload: jsonEncode(encrypted),
        );
      } catch (e) {
        // Контакт сохранён, но invite не отправлен
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Приглашение не отправлено: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Копировать',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: 'Ошибка отправки invite: $e'));
                },
              ),
            ),
          );
        }
      }

      if (mounted) {
        // Закрываем экран сканирования и возвращаемся в список чатов
        Navigator.pop(context);
        await widget.onContactAdded(contactEmail, publicKey);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Копировать',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Ошибка добавления контакта: $e'));
              },
            ),
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showManualInput() {
    final controller = TextEditingController();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Ввести QR данные'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'chatinvite:email:pubkey:token',
            maxLines: 3,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _processQRCode(controller.text);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
