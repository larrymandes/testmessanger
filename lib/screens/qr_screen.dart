import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/email_service.dart';
import '../services/logger_service.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой QR-код'),
      ),
      body: Center(
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: qrData));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Скопировано!')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Скопировать'),
              ),
            ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
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
            child: Column(
              children: [
                const Text(
                  'Наведите камеру на QR-код контакта',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _showManualInput,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Ввести вручную'),
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
        if (mounted) {
          // Останавливаем камеру
          await _controller.stop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Контакт уже добавлен'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Сохраняем контакт
      await StorageService.saveContact(
        accountEmail: widget.myEmail,
        contactEmail: contactEmail,
        publicKey: publicKey,
      );
      
      LoggerService.log('QR: Contact $contactEmail saved locally');

      // Отправляем invite обратно для взаимного добавления
      try {
        LoggerService.log('QR: Sending invite to $contactEmail...');
        
        final inviteMessage = jsonEncode({
          'type': 'invite',
          'email': widget.myEmail,
          'pubkey': widget.myPublicKeyHex,
        });
        
        LoggerService.log('QR: Encrypting invite...');
        
        final encrypted = await CryptoService.encryptMessage(
          plaintext: inviteMessage,
          recipientPubKeyHex: publicKey,
          senderEmail: widget.myEmail,
          recipientEmail: contactEmail,
        );
        
        LoggerService.log('QR: Sending via SMTP...');
        
        await widget.emailService.sendMessage(
          toEmail: contactEmail,
          encryptedPayload: jsonEncode(encrypted),
        );
        
        LoggerService.log('QR: Invite sent successfully!');
        
        if (mounted) {
          // Останавливаем камеру
          await _controller.stop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Контакт добавлен и приглашение отправлено'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Закрываем экран сканирования
          Navigator.pop(context);
          
          // Уведомляем родителя
          await widget.onContactAdded(contactEmail, publicKey);
        }
      } catch (e) {
        // Контакт сохранён, но invite не отправлен
        if (mounted) {
          // Останавливаем камеру
          await _controller.stop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Контакт добавлен, но приглашение не отправлено: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Копировать',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: 'Ошибка отправки invite: $e'));
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
          
          // Закрываем экран сканирования
          Navigator.pop(context);
          
          // Уведомляем родителя
          await widget.onContactAdded(contactEmail, publicKey);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Копировать',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Ошибка добавления контакта: $e'));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ввести QR данные'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'chatinvite:email:pubkey:token',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
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
