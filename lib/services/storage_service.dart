import 'dart:convert';
import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      version: 1,
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

        // Таблица сообщений
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account_email TEXT NOT NULL,
            contact_email TEXT NOT NULL,
            text TEXT NOT NULL,
            sent INTEGER NOT NULL,
            timestamp INTEGER NOT NULL,
            status TEXT,
            uid TEXT,
            read_sent INTEGER DEFAULT 0
          )
        ''');

        // Таблица обработанных UID
        await db.execute('''
          CREATE TABLE processed_uids (
            account_email TEXT NOT NULL,
            uid INTEGER NOT NULL,
            PRIMARY KEY (account_email, uid)
          )
        ''');
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

  // === Сообщения ===

  static Future<void> saveMessage({
    required String accountEmail,
    required String contactEmail,
    required String text,
    required bool sent,
    required int timestamp,
    String? status,
    String? uid,
  }) async {
    await _database!.insert('messages', {
      'account_email': accountEmail,
      'contact_email': contactEmail,
      'text': text,
      'sent': sent ? 1 : 0,
      'timestamp': timestamp,
      'status': status,
      'uid': uid,
    });
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
              'id': r['id'],
              'text': r['text'],
              'sent': r['sent'] == 1,
              'timestamp': r['timestamp'],
              'status': r['status'],
              'uid': r['uid'],
              'readSent': r['read_sent'] == 1,
            })
        .toList();
  }

  static Future<void> updateMessageStatus(
    String accountEmail,
    String uid,
    String status,
  ) async {
    await _database!.update(
      'messages',
      {'status': status},
      where: 'account_email = ? AND uid = ?',
      whereArgs: [accountEmail, uid],
    );
  }

  static Future<void> markMessageReadSent(
    String accountEmail,
    String uid,
  ) async {
    await _database!.update(
      'messages',
      {'read_sent': 1},
      where: 'account_email = ? AND uid = ?',
      whereArgs: [accountEmail, uid],
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
