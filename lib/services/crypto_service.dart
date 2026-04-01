import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' show Random;
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/export.dart' hide Mac;

class CryptoService {
  // Генерация ключевой пары ECDH P-256
  static Future<SimpleKeyPair> generateKeyPair() async {
    final algorithm = Ecdh.p256(length: 32);
    final keyPair = await algorithm.newKeyPair();
    return keyPair as SimpleKeyPair;
  }

  // Экспорт публичного ключа в hex
  static Future<String> exportPublicKey(SimpleKeyPair keyPair) async {
    final publicKey = await keyPair.extractPublicKey();
    final bytes = publicKey.bytes;
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // Экспорт приватного ключа в hex
  static Future<String> exportPrivateKey(SimpleKeyPair keyPair) async {
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    return privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // Импорт публичного ключа из hex
  static SimplePublicKey importPublicKey(String hex) {
    final bytes = _hexToBytes(hex);
    return SimplePublicKey(bytes, type: KeyPairType.p256);
  }

  // Импорт приватного ключа из hex
  static Future<SimpleKeyPair> importPrivateKey(String hex) async {
    final bytes = _hexToBytes(hex);
    return SimpleKeyPairData(
      bytes,
      publicKey: SimplePublicKey([], type: KeyPairType.p256),
      type: KeyPairType.p256,
    );
  }

  // Шифрование сообщения
  static Future<Map<String, String>> encryptMessage({
    required String plaintext,
    required String recipientPubKeyHex,
    required String senderEmail,
    required String recipientEmail,
  }) async {
    // Генерируем ephemeral ключ
    final ephemeralKeyPair = await generateKeyPair();
    final recipientPubKey = importPublicKey(recipientPubKeyHex);

    // ECDH для получения shared secret
    final algorithm = Ecdh.p256(length: 32);
    final sharedSecret = await algorithm.sharedSecretKey(
      keyPair: ephemeralKeyPair,
      remotePublicKey: recipientPubKey,
    );

    // Nonce
    final nonce = _generateNonce(12);

    // AAD (Associated Authenticated Data)
    final aad = jsonEncode({
      'from': senderEmail,
      'to': recipientEmail,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });

    // AES-GCM шифрование
    final aesGcm = AesGcm.with256bits();
    final secretKeyBytes = await sharedSecret.extractBytes();
    final secretKey = SecretKey(secretKeyBytes);

    final ciphertext = await aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
      aad: utf8.encode(aad),
    );

    final ephemeralPubKeyHex = await exportPublicKey(ephemeralKeyPair);

    return {
      'c': base64Encode(ciphertext.cipherText),
      'n': base64Encode(nonce),
      'e': ephemeralPubKeyHex,
      'a': base64Encode(utf8.encode(aad)),
    };
  }

  // Расшифровка сообщения
  static Future<String> decryptMessage({
    required Map<String, String> encrypted,
    required SimpleKeyPair myKeyPair,
  }) async {
    final ciphertext = base64Decode(encrypted['c']!);
    final nonce = base64Decode(encrypted['n']!);
    final ephemeralPubKey = importPublicKey(encrypted['e']!);
    final aad = base64Decode(encrypted['a']!);

    // ECDH для получения shared secret
    final algorithm = Ecdh.p256(length: 32);
    final sharedSecret = await algorithm.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: ephemeralPubKey,
    );

    // AES-GCM расшифровка
    final aesGcm = AesGcm.with256bits();
    final secretKeyBytes = await sharedSecret.extractBytes();
    final secretKey = SecretKey(secretKeyBytes);

    final secretBox = SecretBox(ciphertext, nonce: nonce, mac: Mac.empty);
    final plaintext = await aesGcm.decrypt(
      secretBox,
      secretKey: secretKey,
      aad: aad,
    );

    return utf8.decode(plaintext);
  }

  // Генерация fingerprint
  static Future<String> getFingerprint(String publicKeyHex) async {
    final bytes = _hexToBytes(publicKeyHex);
    final sha256 = Sha256();
    final hash = await sha256.hash(bytes);
    final hashHex = hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    
    // Берём первые 32 символа и форматируем
    final formatted = hashHex.substring(0, 32);
    return RegExp('.{1,4}').allMatches(formatted).map((m) => m.group(0)).join(' ');
  }

  // Вспомогательные функции
  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  static Uint8List _generateNonce(int length) {
    final secureRandom = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    
    return secureRandom.nextBytes(length);
  }
}
