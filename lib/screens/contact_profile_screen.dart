import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';

class ContactProfileScreen extends StatefulWidget {
  final String contactEmail;
  final String contactPublicKey;
  final String accountEmail;

  const ContactProfileScreen({
    super.key,
    required this.contactEmail,
    required this.contactPublicKey,
    required this.accountEmail,
  });

  @override
  State<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends State<ContactProfileScreen> {
  String? _emojiFingerprint;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  bool _isMutual = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Загружаем фингерпринт
      final fingerprint = await CryptoService.getEmojiFingerprint(widget.contactPublicKey);
      
      // Загружаем контакт для проверки mutual
      final contact = await StorageService.getContact(
        widget.accountEmail,
        widget.contactEmail,
      );
      
      // Загружаем статистику
      final messages = await StorageService.getMessages(
        widget.accountEmail,
        widget.contactEmail,
      );
      
      final sentCount = messages.where((m) => m['sent'] == 1 || m['sent'] == true).length;
      final receivedCount = messages.length - sentCount;
      final firstMessageTime = messages.isEmpty 
        ? null 
        : DateTime.fromMillisecondsSinceEpoch(messages.first['timestamp']);
      
      if (mounted) {
        setState(() {
          _emojiFingerprint = fingerprint;
          _isMutual = contact?['mutual'] == true;
          _stats = {
            'total': messages.length,
            'sent': sentCount,
            'received': receivedCount,
            'firstMessage': firstMessageTime,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.log('ContactProfileScreen: Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e1621),
      appBar: AppBar(
        title: const Text('Профиль контакта'),
        backgroundColor: const Color(0xFF1a2332),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2b5278),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.contactEmail[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Email
                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: widget.contactEmail,
                  onCopy: () => _copyToClipboard(widget.contactEmail, 'Email скопирован'),
                ),
                
                const SizedBox(height: 16),
                
                // Фингерпринт
                if (_emojiFingerprint != null)
                  _buildInfoCard(
                    icon: Icons.fingerprint,
                    title: 'Emoji Fingerprint',
                    value: _emojiFingerprint!,
                    onCopy: () => _copyToClipboard(_emojiFingerprint!, 'Фингерпринт скопирован'),
                    valueStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Статус взаимности
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isMutual ? const Color(0xFF1a4d2e) : const Color(0xFF4d2e1a),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isMutual ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isMutual ? Icons.check_circle : Icons.pending,
                        color: _isMutual ? Colors.green : Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isMutual ? 'Взаимные контакты' : 'Ожидание подтверждения',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isMutual ? Colors.green : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isMutual 
                                ? 'Вы можете обмениваться сообщениями'
                                : 'Ожидайте пока собеседник добавит вас в контакты',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Публичный ключ
                _buildInfoCard(
                  icon: Icons.key,
                  title: 'Публичный ключ',
                  value: _formatPublicKey(widget.contactPublicKey),
                  onCopy: () => _copyToClipboard(widget.contactPublicKey, 'Публичный ключ скопирован'),
                  valueStyle: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Статистика
                if (_stats != null) ...[
                  const Text(
                    'Статистика',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.message,
                          label: 'Всего',
                          value: '${_stats!['total']}',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.arrow_upward,
                          label: 'Отправлено',
                          value: '${_stats!['sent']}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.arrow_downward,
                          label: 'Получено',
                          value: '${_stats!['received']}',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Первое сообщение
                  if (_stats!['firstMessage'] != null)
                    _buildInfoCard(
                      icon: Icons.history,
                      title: 'Первое сообщение',
                      value: _formatDate(_stats!['firstMessage']),
                    ),
                ],
              ],
            ),
          ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onCopy,
    TextStyle? valueStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2332),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: Colors.white70,
                  onPressed: onCopy,
                  tooltip: 'Копировать',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: valueStyle ?? const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2332),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPublicKey(String key) {
    // Убираем заголовки
    final cleaned = key
      .replaceAll('-----BEGIN PUBLIC KEY-----', '')
      .replaceAll('-----END PUBLIC KEY-----', '')
      .replaceAll('\n', '')
      .trim();
    
    // Разбиваем на строки по 64 символа
    final lines = <String>[];
    for (int i = 0; i < cleaned.length; i += 64) {
      final end = (i + 64 < cleaned.length) ? i + 64 : cleaned.length;
      lines.add(cleaned.substring(i, end));
    }
    
    return lines.join('\n');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Сегодня в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Вчера в ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} дн. назад';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} нед. назад';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} мес. назад';
    } else {
      return '${(diff.inDays / 365).floor()} г. назад';
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ $message'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
