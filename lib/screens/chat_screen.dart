import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'dart:convert';
import '../services/chat_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';
import 'contact_profile_screen.dart';

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
  bool _isMutual = false; // Флаг взаимности контакта
  String _contactNickname = ''; // ✅ Никнейм контакта

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
        // ✅ НЕ отправляем read receipts при каждом callback!
        // Read receipts отправляются ТОЛЬКО при открытии чата (в initState)
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
    
    // Проверяем mutual статус и загружаем никнейм
    _checkMutualStatus();
    
    // Загружаем сообщения из БД (read receipts отправятся автоматически)
    _loadMessages();
  }
  
  Future<void> _checkMutualStatus() async {
    final contact = await StorageService.getContact(
      widget.chatService.email,
      widget.contactEmail,
    );
    
    if (mounted) {
      setState(() {
        _isMutual = contact?['mutual'] == true;
        _contactNickname = contact?['nickname'] ?? ''; // ✅ Загружаем никнейм
      });
      LoggerService.log('ChatScreen: Mutual status = $_isMutual, nickname = $_contactNickname');
    }
  }

  Future<void> _loadMessages() async {
    final startTime = DateTime.now();
    LoggerService.log('ChatScreen: _loadMessages() called at ${startTime.hour}:${startTime.minute}:${startTime.second}.${startTime.millisecond}');
    
    // Обновляем mutual статус
    await _checkMutualStatus();
    
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
      
      // ✅ ВАЖНО: Отправляем read receipts ПОСЛЕ загрузки сообщений
      // Это гарантирует что мы отправим receipts для ВСЕХ непрочитанных сообщений
      _sendReadReceiptsIfNeeded();
    } else {
      LoggerService.log('ChatScreen: NOT mounted, cannot update UI');
    }
  }
  
  /// Отправка read receipts ТОЛЬКО если есть непрочитанные сообщения
  Future<void> _sendReadReceiptsIfNeeded() async {
    try {
      // Проверяем есть ли непрочитанные сообщения
      final unread = await StorageService.getUnreadMessagesForReceipt(
        widget.chatService.email,
        widget.contactEmail,
      );
      
      if (unread.isEmpty) {
        LoggerService.log('ChatScreen: No unread messages, skipping read receipts');
        return;
      }
      
      LoggerService.log('ChatScreen: Found ${unread.length} unread messages, sending read receipts...');
      await widget.chatService.sendReadReceipts(widget.contactEmail);
      LoggerService.log('ChatScreen: ✅ Read receipts sent');
    } catch (e) {
      LoggerService.log('ChatScreen: ❌ Read receipts error: $e');
    }
  }
  
  /// Обновление статуса сообщений без перезагрузки и БЕЗ анимации
  void _updateMessageStatuses(List<String> messageIds, String status) {
    LoggerService.log('ChatScreen: Updating ${messageIds.length} messages to status "$status"');
    
    final messages = _chatController.messages.toList(); // Копируем список
    final now = DateTime.now();
    bool hasChanges = false;
    
    for (final messageId in messageIds) {
      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) continue;
      
      final oldMessage = messages[messageIndex];
      if (oldMessage is! TextMessage) continue;
      
      // Создаём обновлённое сообщение
      // ✅ ВАЖНО: При переходе в "read" сохраняем sentAt (если был) или устанавливаем now
      final updatedMessage = oldMessage.copyWith(
        seenAt: status == 'read' ? now : oldMessage.seenAt,
        sentAt: status == 'sent' 
          ? now 
          : status == 'read' 
            ? (oldMessage.sentAt ?? now)  // ✅ Сохраняем или устанавливаем
            : oldMessage.sentAt,
        failedAt: status == 'error' ? now : null,
        metadata: status == 'sending' 
          ? {'sending': true}
          : status == 'error'
            ? {'error': true}
            : null,
      );
      
      // Заменяем сообщение в списке
      messages[messageIndex] = updatedMessage;
      hasChanges = true;
      LoggerService.log('ChatScreen: ✅ Message $messageId updated to "$status"');
    }
    
    // ✅ Обновляем весь список БЕЗ анимации через setMessages
    if (hasChanges) {
      _chatController.setMessages(messages);
    }
  }

  Message _createMessage(Map<String, dynamic> msg) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(msg['timestamp']);
    final isSent = msg['sent'] == 1 || msg['sent'] == true;
    final status = msg['status'] ?? 'sent';
    final messageId = msg['message_id'] as String;
    
    // Логируем статус для отладки read receipts
    if (isSent) {
      LoggerService.log('ChatScreen: Message $messageId status="$status" (sent=${isSent})');
    }
    
    return TextMessage(
      id: messageId,
      authorId: isSent ? widget.chatService.email : widget.contactEmail,
      createdAt: timestamp,
      text: msg['text'],
      // ✅ Галочки для отправленных сообщений:
      // - status == 'sent' → sentAt установлен → одна галочка ✓
      // - status == 'read' → sentAt + seenAt установлены → две галочки ✓✓
      sentAt: isSent && (status == 'sent' || status == 'read') ? timestamp : null,
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

  /// Отправка read receipts (через сервис!)
  Future<void> _sendReadReceipts() async {
    try {
      await widget.chatService.sendReadReceipts(widget.contactEmail);
      LoggerService.log('ChatScreen: ✅ Read receipts sent');
    } catch (e) {
      LoggerService.log('ChatScreen: ❌ Read receipts error: $e');
    }
  }

  void _handleSendPressed(String text) async {
    // 🔒 ПРОВЕРКА: Можно ли отправлять сообщения?
    if (!_isMutual) {
      LoggerService.log('ChatScreen: ❌ Cannot send - not mutual contacts');
      // ✅ НЕ показываем уведомление - кнопка заблокирована
      return;
    }
    
    final now = DateTime.now().toUtc();
    
    // 1. Разделяем текст на части для UI
    final parts = _splitTextForUI(text);
    
    LoggerService.log('ChatScreen: Sending ${parts.length} message(s)');
    
    // 2. Генерируем Message-IDs и показываем сообщения СРАЗУ
    final messageIds = <String>[];
    for (int i = 0; i < parts.length; i++) {
      // Генерируем Message-ID (как SMTP)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecond;
      final messageId = '<$timestamp.$random.${i}@${widget.chatService.email.split('@')[1]}>';
      messageIds.add(messageId);
      
      // Показываем в UI сразу
      final chatMessage = TextMessage(
        id: messageId,
        authorId: widget.chatService.email,
        createdAt: now,
        text: parts[i],
        metadata: {'sending': true},
      );
      
      _chatController.insertMessage(chatMessage);
      
      // Сохраняем в БД
      await StorageService.saveMessage(
        messageId: messageId,
        accountEmail: widget.chatService.email,
        contactEmail: widget.contactEmail,
        text: parts[i],
        sent: true,
        timestamp: now.millisecondsSinceEpoch,
        status: 'sending',
      );
    }
    
    // 3. Отправляем в фоне с callback для обновления статусов
    _sendInBackground(text, messageIds);
  }
  
  /// Отправка в фоне
  void _sendInBackground(String text, List<String> messageIds) async {
    try {
      await widget.chatService.sendTextMessageWithUIDs(
        toEmail: widget.contactEmail,
        text: text,
        recipientPublicKey: widget.contactPublicKey,
        messageIds: messageIds,
        onStatusUpdate: (messageId, status) async {
          LoggerService.log('ChatScreen: Status update for $messageId: $status');
          
          // Обновляем статус в БД
          await StorageService.updateMessageStatus(
            widget.chatService.email,
            messageId,
            status,
          );
          
          // Обновляем UI
          if (mounted) {
            final messages = _chatController.messages;
            final messageIndex = messages.indexWhere((m) => m.id == messageId);
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
      );
    } catch (e) {
      LoggerService.log('ChatScreen: Send error: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    // ✅ Показываем никнейм если есть, иначе email
    final displayName = _contactNickname.isNotEmpty ? _contactNickname : widget.contactEmail;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          // Кнопка открытия профиля
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Профиль контакта',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactProfileScreen(
                    contactEmail: widget.contactEmail,
                    contactPublicKey: widget.contactPublicKey,
                    accountEmail: widget.chatService.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Баннер если не взаимные контакты
          if (!_isMutual)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ожидание подтверждения. Вы не можете отправлять сообщения пока собеседник не добавит вас в контакты.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          
          // Чат
          Expanded(
            child: Chat(
              chatController: _chatController,
              currentUserId: widget.chatService.email,
              onMessageSend: _isMutual ? _handleSendPressed : null, // ✅ Блокируем если не взаимные
              onMessageLongPress: _handleMessageLongPress,
              resolveUser: (userId) async {
                return User(
                  id: userId,
                  name: userId == widget.chatService.email ? 'Вы' : widget.contactEmail,
                );
              },
              theme: ChatTheme.dark().copyWith(
                colors: ChatTheme.dark().colors.copyWith(
                  primary: Theme.of(context).primaryColor,
                  surface: Theme.of(context).scaffoldBackgroundColor,
                  onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
            ),
          ),
        ],
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
