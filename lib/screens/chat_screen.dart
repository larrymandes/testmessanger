import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'dart:convert';
import '../services/chat_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';

class ChatScreen extends StatefulWidget {
  final String contactEmail;
  final String contactPublicKey;
  final ChatService chatService;

  const ChatScreen({
    super.key,
    required this.contactEmail,
    required this.contactPublicKey,
    required this.chatService,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatController = InMemoryChatController();
  late Function() _messageCallback; // Сохраняем ссылку на callback
  late Function(List<String>, String) _statusUpdateCallback; // Callback для обновления статуса

  @override
  void initState() {
    super.initState();
    LoggerService.log('ChatScreen: initState for ${widget.contactEmail}');
    
    // Создаём callback для новых сообщений и регистрируем
    _messageCallback = () {
      LoggerService.log('ChatScreen: Callback triggered for ${widget.contactEmail}!');
      if (mounted) {
        LoggerService.log('ChatScreen: Loading messages...');
        _loadMessages();
        _sendReadReceipts();
      } else {
        LoggerService.log('ChatScreen: NOT mounted, skipping');
      }
    };
    
    // Создаём callback для обновления статуса (без перезагрузки)
    _statusUpdateCallback = (List<String> uids, String status) {
      LoggerService.log('ChatScreen: Status update callback for ${uids.length} messages to "$status"');
      if (mounted) {
        _updateMessageStatuses(uids, status);
      }
    };
    
    widget.chatService.addUICallback(_messageCallback);
    widget.chatService.addStatusUpdateCallback(_statusUpdateCallback);
    LoggerService.log('ChatScreen: Callbacks registered');
    
    // Загружаем сообщения из БД
    _loadMessages();
    _sendReadReceipts();
  }

  Future<void> _loadMessages() async {
    final startTime = DateTime.now();
    LoggerService.log('ChatScreen: _loadMessages() called at ${startTime.hour}:${startTime.minute}:${startTime.second}.${startTime.millisecond}');
    
    final messages = await StorageService.getMessages(
      widget.chatService.email,
      widget.contactEmail,
    );
    
    final afterDbTime = DateTime.now();
    final dbDuration = afterDbTime.difference(startTime).inMilliseconds;
    LoggerService.log('ChatScreen: Loaded ${messages.length} messages from DB in ${dbDuration}ms');

    // Сортируем по timestamp (новые внизу для чата)
    messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    
    final chatMessages = messages.map((msg) => _createMessage(msg)).toList();
    LoggerService.log('ChatScreen: Created ${chatMessages.length} chat messages');
     
    if (mounted) {
      LoggerService.log('ChatScreen: Calling setState to update UI');
      setState(() {
        _chatController.setMessages(chatMessages);
      });
      
      final endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime).inMilliseconds;
      LoggerService.log('ChatScreen: ✅ UI updated in ${totalDuration}ms total (DB: ${dbDuration}ms, UI: ${totalDuration - dbDuration}ms)');
    } else {
      LoggerService.log('ChatScreen: NOT mounted, cannot update UI');
    }
  }
  
  /// Обновление статуса сообщений без перезагрузки
  void _updateMessageStatuses(List<String> uids, String status) {
    LoggerService.log('ChatScreen: Updating ${uids.length} messages to status "$status"');
    
    final messages = _chatController.messages;
    final now = DateTime.now();
    
    for (final uid in uids) {
      final messageIndex = messages.indexWhere((m) => m.id == uid);
      if (messageIndex == -1) continue;
      
      final oldMessage = messages[messageIndex];
      if (oldMessage is! TextMessage) continue;
      
      // Создаём обновлённое сообщение
      final updatedMessage = oldMessage.copyWith(
        seenAt: status == 'read' ? now : oldMessage.seenAt,
        sentAt: status == 'sent' ? now : oldMessage.sentAt,
        failedAt: status == 'error' ? now : null,
        metadata: status == 'sending' 
          ? {'sending': true}
          : status == 'error'
            ? {'error': true}
            : null,
      );
      
      // Обновляем сообщение в контроллере (без перезагрузки всего списка)
      _chatController.updateMessage(oldMessage, updatedMessage);
      LoggerService.log('ChatScreen: ✅ Message $uid updated to "$status"');
    }
  }

  Message _createMessage(Map<String, dynamic> msg) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(msg['timestamp']);
    final isSent = msg['sent'] == 1 || msg['sent'] == true;
    final status = msg['status'] ?? 'sent';
    final uid = msg['uid'] ?? msg['id'].toString();
    
    // Логируем статус для отладки read receipts
    if (isSent) {
      LoggerService.log('ChatScreen: Message $uid status="$status" (sent=${isSent})');
    }
    
    return TextMessage(
      id: uid,
      authorId: isSent ? widget.chatService.email : widget.contactEmail,
      createdAt: timestamp,
      text: msg['text'],
      // Отправленные: показываем галочки
      sentAt: isSent && status == 'sent' ? timestamp : null,
      seenAt: isSent && status == 'read' ? timestamp : null,
      // Ошибка отправки
      failedAt: isSent && status == 'error' ? timestamp : null,
      // Метаданные для визуального отображения
      metadata: status == 'sending' 
        ? {'sending': true} 
        : status == 'error' 
          ? {'error': true} 
          : null,
    );
  }

  Future<void> _sendReadReceipts() async {
    // Находим непрочитанные входящие сообщения
    final messages = await StorageService.getMessages(
      widget.chatService.email,
      widget.contactEmail,
    );

    final unread = messages.where((m) => 
      !m['sent'] && !m['readSent'] && m['uid'] != null
    ).toList();

    if (unread.isEmpty) return;
    
    LoggerService.log('ChatScreen: Sending ${unread.length} read receipts');

    // Батчинг: отправляем все UID одним сообщением
    final uids = unread.map((m) => m['uid']).toList();
    
    try {
      final receipt = jsonEncode({
        'type': 'read_receipt',
        'message_uids': uids, // Массив вместо одного UID
      });

      final encrypted = await CryptoService.encryptMessage(
        plaintext: receipt,
        recipientPubKeyHex: widget.contactPublicKey,
        senderEmail: widget.chatService.email,
        recipientEmail: widget.contactEmail,
      );

      await widget.chatService.sendMessage(
        toEmail: widget.contactEmail,
        encryptedPayload: jsonEncode(encrypted),
      );
      
      // Помечаем все как отправленные
      for (final msg in unread) {
        await StorageService.markMessageReadSent(widget.chatService.email, msg['uid']);
      }
      
      LoggerService.log('ChatScreen: ✅ ${unread.length} read receipts sent');
    } catch (e) {
      LoggerService.log('Send read receipts error: $e');
    }
  }

  void _handleSendPressed(String text) async {
    final now = DateTime.now().toUtc();
    
    // 1. Разделяем текст на части для UI (чтобы показать сразу)
    final parts = _splitTextForUI(text);
    
    LoggerService.log('ChatScreen: Sending ${parts.length} message(s)');
    
    // 2. Создаём и показываем ВСЕ сообщения СРАЗУ в UI
    final messageUIDs = <String>[];
    final chatMessages = <TextMessage>[];
    
    for (int i = 0; i < parts.length; i++) {
      final messageUID = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}_$i';
      messageUIDs.add(messageUID);
      
      // Показываем в UI сразу со статусом "отправляется"
      final chatMessage = TextMessage(
        id: messageUID,
        authorId: widget.chatService.email,
        createdAt: now,
        text: parts[i],
        metadata: {'sending': true},
      );
      
      chatMessages.add(chatMessage);
      _chatController.insertMessage(chatMessage);
      
      // Сохраняем в БД сразу
      await StorageService.saveMessage(
        accountEmail: widget.chatService.email,
        contactEmail: widget.contactEmail,
        text: parts[i],
        sent: true,
        timestamp: now.millisecondsSinceEpoch,
        status: 'sending',
        uid: messageUID,
        messageId: null,
      );
    }
    
    // 3. Вызываем сервис для отправки (он сам применит rate limiting)
    widget.chatService.sendTextMessageWithSplit(
      toEmail: widget.contactEmail,
      text: text,
      recipientPublicKey: widget.contactPublicKey,
      onStatusUpdate: (uid, status) async {
        // Обновляем статус в БД
        await StorageService.updateMessageStatus(
          widget.chatService.email,
          uid,
          status,
        );
        
        // Обновляем UI
        if (mounted) {
          final messages = _chatController.messages;
          final messageIndex = messages.indexWhere((m) => m.id == uid);
          if (messageIndex != -1) {
            final oldMessage = messages[messageIndex] as TextMessage;
            final updatedMessage = oldMessage.copyWith(
              sentAt: status == 'sent' ? DateTime.now() : null,
              metadata: status == 'error' ? {'error': true} : null,
            );
            _chatController.updateMessage(oldMessage, updatedMessage);
          }
        }
      },
    ).catchError((e) {
      LoggerService.log('ChatScreen: Send error: $e');
    });
  }
  
  /// Разделение текста для UI (4096 символов)
  List<String> _splitTextForUI(String text) {
    const maxLength = 4096;
    if (text.length <= maxLength) {
      return [text];
    }
    
    final parts = <String>[];
    int start = 0;
    
    while (start < text.length) {
      int end = start + maxLength;
      if (end > text.length) {
        end = text.length;
      }
      parts.add(text.substring(start, end));
      start = end;
    }
    
    return parts;
  }
      
      final updatedMessage = chatMessage.copyWith(
        failedAt: now,
        metadata: {'error': true},
      );
      _chatController.updateMessage(chatMessage, updatedMessage);
      
      // Перезагружаем чтобы показать красное сообщение
      await _loadMessages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Ошибка отправки: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Копировать',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'Ошибка отправки: $e'));
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ошибка скопирована'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactEmail),
            FutureBuilder<String>(
              future: CryptoService.getFingerprint(widget.contactPublicKey),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Chat(
        chatController: _chatController,
        currentUserId: widget.chatService.email,
        onMessageSend: _handleSendPressed,
        onMessageLongPress: _handleMessageLongPress, // Добавляем long press
        resolveUser: (userId) async {
          return User(
            id: userId,
            name: userId == widget.chatService.email ? 'Вы' : widget.contactEmail,
          );
        },
        theme: ChatTheme.dark().copyWith(
          colors: ChatTheme.dark().colors.copyWith(
            primary: const Color(0xFF2b5278),
            surface: const Color(0xFF0e1621),
            onSurface: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleMessageLongPress(
    BuildContext context,
    Message message, {
    LongPressStartDetails? details,
    int? index,
  }) {
    if (message is! TextMessage) return;
    
    final isMyMessage = message.authorId == widget.chatService.email;
    final hasError = message.metadata?['error'] == true;
    final isSending = message.metadata?['sending'] == true;
    
    // Показываем меню действий
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a2332),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Копировать текст
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.white70),
              title: const Text('Копировать текст', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Текст скопирован'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            
            // Повторить отправку (только для ошибочных своих сообщений)
            if (isMyMessage && hasError)
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: const Text('Повторить отправку', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  Navigator.pop(context);
                  _retryMessage(message);
                },
              ),
            
            // Удалить (только для ошибочных или отправляющихся своих сообщений)
            if (isMyMessage && (hasError || isSending))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Удалить', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  Future<void> _retryMessage(TextMessage message) async {
    try {
      // Удаляем старое сообщение с ошибкой
      await StorageService.deleteMessage(widget.chatService.email, message.id);
      
      // Отправляем заново
      _handleSendPressed(message.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Повторная отправка...'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      LoggerService.log('Retry error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Ошибка: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  Future<void> _deleteMessage(TextMessage message) async {
    try {
      await StorageService.deleteMessage(widget.chatService.email, message.id);
      await _loadMessages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Сообщение удалено'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      LoggerService.log('Delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Ошибка удаления: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    LoggerService.log('ChatScreen: dispose() - removing callbacks');
    widget.chatService.removeUICallback(_messageCallback);
    widget.chatService.removeStatusUpdateCallback(_statusUpdateCallback);
    _chatController.dispose();
    super.dispose();
  }
}
