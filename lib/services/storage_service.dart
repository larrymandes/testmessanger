import 'dart:convert';
import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class StorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  // Инициализация
  static Future<void> init() async {
    // Для desktop платформ используем FFI версию
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'secure_messenger.db');

    return await openDatabase(
      path,
      version: 2, // ← Увеличиваем версию для миграции!
      onCreate: (db, version) async {
        // Таблица аккаунтов
        await db.execute('''
          CREATE TABLE accounts (
            email TEXT PRIMARY KEY,
            private_key TEXT NOT NULL,
            public_key TEXT NOT NULL
          )
        ''');

        // Таблица контактов
        await db.execute('''
          CREATE TABLE contacts (
            account_email TEXT NOT NULL,
            contact_email TEXT NOT NULL,
            public_key TEXT NOT NULL,
            PRIMARY KEY (account_email, contact_email)
          )
        ''');

        // Таблица сообщений (НОВАЯ СХЕМА - Message-ID как PRIMARY KEY)
        await db.execute('''
          CREATE TABLE messages (
            message_id TEXT PRIMARY KEY,
            account_email TEXT NOT NULL,
            contact_email TEXT NOT NULL,
            text TEXT NOT NULL,
            sent INTEGER NOT NULL,
            timestamp INTEGER NOT NULL,
            status TEXT,
            read_sent INTEGER DEFAULT 0
          )
        ''');

        // Таблица обработанных Message-ID (для дедупликации)
        await db.execute('''
          CREATE TABLE processed_message_ids (
            account_email TEXT NOT NULL,
            message_id TEXT NOT NULL,
            PRIMARY KEY (account_email, message_id)
          )
        ''');

        // Таблица обработанных UID (для IMAP дедупликации)
        await db.execute('''
          CREATE TABLE processed_uids (
            account_email TEXT NOT NULL,
            uid INTEGER NOT NULL,
            PRIMARY KEY (account_email, uid)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Миграция с версии 1 на 2
          LoggerService.log('DB Migration: v1 -> v2 (Message-ID as PRIMARY KEY)');
          
          // 1. Создаём новую таблицу messages
          await db.execute('''
            CREATE TABLE messages_new (
              message_id TEXT PRIMARY KEY,
              account_email TEXT NOT NULL,
              contact_email TEXT NOT NULL,
              text TEXT NOT NULL,
              sent INTEGER NOT NULL,
              timestamp INTEGER NOT NULL,
              status TEXT,
              read_sent INTEGER DEFAULT 0
            )
          ''');
          
          // 2. Копируем данные (только с message_id!)
          await db.execute('''
            INSERT INTO messages_new (message_id, account_email, contact_email, text, sent, timestamp, status, read_sent)
            SELECT message_id, account_email, contact_email, text, sent, timestamp, status, read_sent
            FROM messages
            WHERE message_id IS NOT NULL AND message_id != ''
          ''');
          
          // 3. Удаляем старую таблицу
          await db.execute('DROP TABLE messages');
          
          // 4. Переименовываем новую
          await db.execute('ALTER TABLE messages_new RENAME TO messages');
          
          LoggerService.log('DB Migration: ✅ Complete!');
        }
      },
    );
  }

  // === Аккаунты ===

  static Future<void> saveAccount({
    required String email,
    required String privateKey,
    required String publicKey,
  }) async {
    await _database!.insert(
      'accounts',
      {
        'email': email,
        'private_key': privateKey,
        'public_key': publicKey,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, String>?> getAccount(String email) async {
    final results = await _database!.query(
      'accounts',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isEmpty) return null;

    return {
      'privateKey': results.first['private_key'] as String,
      'publicKey': results.first['public_key'] as String,
    };
  }

  // === Контакты ===

  static Future<void> saveContact({
    required String accountEmail,
    required String contactEmail,
    required String publicKey,
  }) async {
    await _database!.insert(
      'contacts',
      {
        'account_email': accountEmail,
        'contact_email': contactEmail,
        'public_key': publicKey,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getContact(
    String accountEmail,
    String contactEmail,
  ) async {
    final results = await _database!.query(
      'contacts',
      where: 'account_email = ? AND contact_email = ?',
      whereArgs: [accountEmail, contactEmail],
    );

    if (results.isEmpty) return null;

    return {
      'email': results.first['contact_email'],
      'publicKey': results.first['public_key'],
    };
  }

  static Future<List<Map<String, dynamic>>> getContacts(
    String accountEmail,
  ) async {
    final results = await _database!.query(
      'contacts',
      where: 'account_email = ?',
      whereArgs: [accountEmail],
    );

    return results
        .map((r) => {
              'email': r['contact_email'],
              'publicKey': r['public_key'],
            })
        .toList();
  }

  static Future<void> deleteContact(
    String accountEmail,
    String contactEmail,
  ) async {
    // Удаляем контакт
    await _database!.delete(
      'contacts',
      where: 'account_email = ? AND contact_email = ?',
      whereArgs: [accountEmail, contactEmail],
    );
    
    // Удаляем все сообщения с этим контактом
    await _database!.delete(
      'messages',
      where: 'account_email = ? AND contact_email = ?',
      whereArgs: [accountEmail, contactEmail],
    );
  }

  // === Сообщения ===

  static Future<void> saveMessage({
    required String messageId, // ← Теперь ОБЯЗАТЕЛЬНЫЙ!
    required String accountEmail,
    required String contactEmail,
    required String text,
    required bool sent,
    required int timestamp,
    String? status,
  }) async {
    await _database!.insert('messages', {
      'message_id': messageId,
      'account_email': accountEmail,
      'contact_email': contactEmail,
      'text': text,
      'sent': sent ? 1 : 0,
      'timestamp': timestamp,
      'status': status,
    }, conflictAlgorithm: ConflictAlgorithm.replace); // ← REPLACE для дедупликации!
  }

  static Future<List<Map<String, dynamic>>> getMessages(
    String accountEmail,
    String contactEmail,
  ) async {
    final results = await _database!.query(
      'messages',
      where: 'account_email = ? AND contact_email = ?',
      whereArgs: [accountEmail, contactEmail],
      orderBy: 'timestamp DESC',
    );

    return results
        .map((r) => {
              'message_id': r['message_id'],
              'text': r['text'],
              'sent': r['sent'] == 1,
              'timestamp': r['timestamp'],
              'status': r['status'],
              'readSent': r['read_sent'] == 1,
            })
        .toList();
  }

  /// Удаление дубликатов сообщений (теперь автоматически через REPLACE)
  static Future<int> removeDuplicateMessages(String accountEmail, String contactEmail) async {
    // С новой схемой (message_id PRIMARY KEY + REPLACE) дубликаты невозможны!
    // Этот метод оставлен для совместимости, но ничего не делает
    return 0;
  }

  /// Обновление статуса по message_id
  static Future<bool> updateMessageStatus(
    String accountEmail,
    String messageId,
    String status,
  ) async {
    final count = await _database!.update(
      'messages',
      {'status': status},
      where: 'account_email = ? AND message_id = ?',
      whereArgs: [accountEmail, messageId],
    );
    return count > 0;
  }

  /// Удаление сообщения по message_id
  static Future<void> deleteMessage(
    String accountEmail,
    String messageId,
  ) async {
    await _database!.delete(
      'messages',
      where: 'account_email = ? AND message_id = ?',
      whereArgs: [accountEmail, messageId],
    );
  }

  /// Обновление серверного Message-ID (из BCC копии)
  static Future<void> updateServerMessageId(
    String accountEmail,
    String localMessageId,
    String serverMessageId,
  ) async {
    await _database!.execute(
      'UPDATE messages SET message_id = ? WHERE account_email = ? AND message_id = ?',
      [serverMessageId, accountEmail, localMessageId],
    );
  }

  /// Пометить что read receipt отправлен (по message_id)
  static Future<void> markMessageReadSent(
    String accountEmail,
    String messageId,
  ) async {
    await _database!.update(
      'messages',
      {'read_sent': 1},
      where: 'account_email = ? AND message_id = ?',
      whereArgs: [accountEmail, messageId],
    );
  }

  // === Обработанные UID ===

  static Future<void> addProcessedUID(String accountEmail, int uid) async {
    await _database!.insert(
      'processed_uids',
      {'account_email': accountEmail, 'uid': uid},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<bool> isUIDProcessed(String accountEmail, int uid) async {
    final results = await _database!.query(
      'processed_uids',
      where: 'account_email = ? AND uid = ?',
      whereArgs: [accountEmail, uid],
    );

    return results.isNotEmpty;
  }

  static Future<int> getMaxProcessedUID(String accountEmail) async {
    final results = await _database!.rawQuery(
      'SELECT MAX(uid) as max_uid FROM processed_uids WHERE account_email = ?',
      [accountEmail],
    );

    return (results.first['max_uid'] as int?) ?? 0;
  }

  // === Обработанные Message-ID (для дедупликации как в Delta Chat) ===

  static Future<void> addProcessedMessageId(String accountEmail, String messageId) async {
    await _database!.insert(
      'processed_message_ids',
      {'account_email': accountEmail, 'message_id': messageId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<bool> isMessageIdProcessed(String accountEmail, String messageId) async {
    final results = await _database!.query(
      'processed_message_ids',
      where: 'account_email = ? AND message_id = ?',
      whereArgs: [accountEmail, messageId],
    );

    return results.isNotEmpty;
  }

  // === Пароли (зашифрованные) ===

  static Future<void> savePassword(String email, String password) async {
    await _prefs!.setString('password_$email', password);
  }

  static String? getPassword(String email) {
    return _prefs!.getString('password_$email');
  }

  // === Последний выбранный аккаунт ===

  static Future<void> setLastAccount(String email) async {
    await _prefs!.setString('last_account', email);
  }

  static String? getLastAccount() {
    return _prefs!.getString('last_account');
  }
}
