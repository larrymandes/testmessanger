import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' show Random;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/gcm.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';
import 'package:pointycastle/key_agreement/ecdh.dart';

class CryptoService {
  // Генерация ключевой пары ECDH P-256
  static Future<AsymmetricKeyPair<PublicKey, PrivateKey>> generateKeyPair() async {
    final keyParams = ECKeyGeneratorParameters(ECCurve_secp256r1());
    final random = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    random.seed(KeyParameter(Uint8List.fromList(seeds)));
    
    final generator = ECKeyGenerator()
      ..init(ParametersWithRandom(keyParams, random));
    
    return generator.generateKeyPair();
  }

  // Экспорт публичного ключа в hex
  static String exportPublicKey(AsymmetricKeyPair keyPair) {
    final publicKey = keyPair.publicKey as ECPublicKey;
    final bytes = publicKey.Q!.getEncoded(false);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // Экспорт приватного ключа в hex
  static String exportPrivateKey(AsymmetricKeyPair keyPair) {
    final privateKey = keyPair.privateKey as ECPrivateKey;
    final bytes = privateKey.d!.toRadixString(16).padLeft(64, '0');
    return bytes;
  }

  // Импорт публичного ключа из hex
  static ECPublicKey importPublicKey(String hex) {
    final bytes = _hexToBytes(hex);
    final params = ECCurve_secp256r1();
    final point = params.curve.decodePoint(bytes);
    return ECPublicKey(point, params);
  }

  // Импорт приватного ключа из hex
  static ECPrivateKey importPrivateKey(String hex) {
    final d = BigInt.parse(hex, radix: 16);
    final params = ECCurve_secp256r1();
    return ECPrivateKey(d, params);
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
    final agreement = ECDHBasicAgreement();
    agreement.init(ephemeralKeyPair.privateKey as ECPrivateKey);
    final sharedSecret = agreement.calculateAgreement(recipientPubKey);
    final sharedSecretBytes = _encodeBigInt(sharedSecret);

    // Nonce
    final nonce = _generateNonce(12);

    // AAD (Associated Authenticated Data)
    final aad = jsonEncode({
      'from': senderEmail,
      'to': recipientEmail,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });

    // AES-GCM шифрование
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(sharedSecretBytes),
      128,
      nonce,
      utf8.encode(aad),
    );
    cipher.init(true, params);

    final plainBytes = utf8.encode(plaintext);
    final ciphertext = cipher.process(plainBytes);

    final ephemeralPubKeyHex = exportPublicKey(ephemeralKeyPair);

    return {
      'c': base64Encode(ciphertext),
      'n': base64Encode(nonce),
      'e': ephemeralPubKeyHex,
      'a': base64Encode(utf8.encode(aad)),
    };
  }

  // Расшифровка сообщения
  static Future<String> decryptMessage({
    required Map<String, String> encrypted,
    required AsymmetricKeyPair myKeyPair,
  }) async {
    final ciphertext = base64Decode(encrypted['c']!);
    final nonce = base64Decode(encrypted['n']!);
    final ephemeralPubKey = importPublicKey(encrypted['e']!);
    final aad = base64Decode(encrypted['a']!);

    // ECDH для получения shared secret
    final agreement = ECDHBasicAgreement();
    agreement.init(myKeyPair.privateKey as ECPrivateKey);
    final sharedSecret = agreement.calculateAgreement(ephemeralPubKey);
    final sharedSecretBytes = _encodeBigInt(sharedSecret);

    // AES-GCM расшифровка
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(sharedSecretBytes),
      128,
      nonce,
      aad,
    );
    cipher.init(false, params);

    final plaintext = cipher.process(ciphertext);
    return utf8.decode(plaintext);
  }

  // Генерация fingerprint
  static Future<String> getFingerprint(String publicKeyHex) async {
    final bytes = _hexToBytes(publicKeyHex);
    final digest = SHA256Digest();
    final hash = digest.process(bytes);
    final hashHex = hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    
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

  static Uint8List _encodeBigInt(BigInt number) {
    final bytes = (number.toRadixString(16).padLeft(64, '0'));
    return _hexToBytes(bytes);
  }
}
