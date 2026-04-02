import 'package:pointycastle/api.dart' show AsymmetricKeyPair, PublicKey, PrivateKey;
import 'crypto_service.dart';
import 'storage_service.dart';
import 'logger_service.dart';

/// AccountService - управление аккаунтами и ключами
/// Отвечает за:
/// - Генерацию ключей
/// - Загрузку ключей
/// - Сохранение аккаунтов
class AccountService {
  /// Загрузка или генерация ключей для аккаунта
  static Future<AccountData> loadOrGenerateAccount(String email) async {
    final account = await StorageService.getAccount(email);
    
    if (account != null) {
      // Загружаем существующие ключи
      LoggerService.log('AccountService: Loading existing keys for $email');
      
      final privateKey = CryptoService.importPrivateKey(account['privateKey']!);
      final publicKey = CryptoService.importPublicKey(account['publicKey']!);
      final keyPair = AsymmetricKeyPair<PublicKey, PrivateKey>(publicKey, privateKey);
      
      return AccountData(
        email: email,
        keyPair: keyPair,
        publicKeyHex: account['publicKey']!,
      );
    } else {
      // Генерируем новые ключи
      LoggerService.log('AccountService: Generating new keys for $email');
      
      final keyPair = await CryptoService.generateKeyPair();
      final publicKeyHex = CryptoService.exportPublicKey(keyPair);
      final privateKeyHex = CryptoService.exportPrivateKey(keyPair);
      
      await StorageService.saveAccount(
        email: email,
        privateKey: privateKeyHex,
        publicKey: publicKeyHex,
      );
      
      return AccountData(
        email: email,
        keyPair: keyPair,
        publicKeyHex: publicKeyHex,
      );
    }
  }
}

/// Данные аккаунта
class AccountData {
  final String email;
  final AsymmetricKeyPair<PublicKey, PrivateKey> keyPair;
  final String publicKeyHex;
  
  AccountData({
    required this.email,
    required this.keyPair,
    required this.publicKeyHex,
  });
}
