import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/crypto_service.dart';
import '../services/chat_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой QR-код'),
      ),
      body: FutureBuilder<String>(
        future: CryptoService.getEmojiFingerprint(myPublicKey),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final fingerprint = snapshot.data!;
          final qrData = 'chatinvite:$myEmail:$myPublicKey:$fingerprint';
          
          return Center(
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
                future: CryptoService.getEmojiFingerprint(myPublicKey),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  return Text(
                    '${snapshot.data}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
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
          );
        },
      ),
    );
  }
}

class ScanQRScreen extends StatefulWidget {
  final ChatService chatService;
  final Function(String contactEmail, String publicKey) onContactAdded;

  const ScanQRScreen({
    super.key,
    required this.chatService,
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
      // 1. Парсим QR данные
      final parts = qrData.split(':');
      if (parts.length < 4 || parts[0] != 'chatinvite') {
        throw Exception('Неверный формат QR-кода');
      }

      final contactEmail = parts[1];
      final publicKey = parts[2];
      final expectedFingerprint = parts[3];
      
      LoggerService.log('QR: Scanned contact: $contactEmail');
      LoggerService.log('QR: Expected fingerprint: $expectedFingerprint');
      
      // 2. Вычисляем fingerprint из публичного ключа
      final actualFingerprint = await CryptoService.getEmojiFingerprint(publicKey);
      LoggerService.log('QR: Actual fingerprint: $actualFingerprint');
      
      // 3. ПРОВЕРКА: Fingerprint должен совпадать!
      if (actualFingerprint != expectedFingerprint) {
        LoggerService.log('QR: ❌ MITM ATTACK DETECTED! Fingerprints do not match!');
        throw Exception('⚠️ ОПАСНОСТЬ! Обнаружена попытка подмены ключа!\n\nFingerprint не совпадает. Возможна MITM атака.');
      }
      
      LoggerService.log('QR: ✅ Fingerprint verified!');

      // 4. Вызываем сервис (вся логика там)
      await widget.chatService.addContactWithInvite(
        contactEmail: contactEmail,
        contactPublicKey: publicKey,
      );
      
      // 3. Успех - показываем уведомление
      if (mounted) {
        await _controller.stop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Контакт добавлен и приглашение отправлено'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.pop(context);
        await widget.onContactAdded(contactEmail, publicKey);
      }
    } catch (e) {
      LoggerService.log('QR: ❌ Error: $e');
      
      // Ошибка - показываем пользователю
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Ошибка: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Копировать',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Ошибка: $e'));
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
