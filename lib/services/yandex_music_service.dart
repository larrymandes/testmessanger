import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'logger_service.dart';

/// Сервис для работы с Яндекс.Музыкой
/// 
/// Получает информацию о треке и проигрывает 30-секундный отрывок
class YandexMusicService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  
  /// Извлечь Track ID из строки (число или ссылка)
  String? extractTrackId(String input) {
    final trimmed = input.trim();
    
    // Если это просто число
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return trimmed;
    }
    
    // Если это ссылка: https://music.yandex.ru/album/41305001/track/149601172
    final urlPattern = RegExp(r'/track/(\d+)');
    final match = urlPattern.firstMatch(trimmed);
    if (match != null) {
      return match.group(1);
    }
    
    return null;
  }
  
  /// Получить информацию о треке (название, артист, обложка)
  Future<Map<String, String?>?> getTrackInfo(String trackId) async {
    try {
      LoggerService.log('YandexMusic: Fetching track info for $trackId');
      
      final url = Uri.parse('https://api.music.yandex.net/tracks/$trackId');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode != 200) {
        LoggerService.log('YandexMusic: Failed to fetch track info: ${response.statusCode}');
        return null;
      }
      
      final data = json.decode(response.body);
      final track = data['result']?[0];
      if (track == null) {
        LoggerService.log('YandexMusic: Track not found');
        return null;
      }
      
      // Получаем обложку
      String? coverUri = track['coverUri'] ?? track['ogImage'];
      String? coverUrl;
      if (coverUri != null) {
        coverUrl = 'https://$coverUri'.replaceAll('%%', '400x400');
      }
      
      final title = track['title'] as String?;
      final artist = track['artists']?[0]?['name'] as String?;
      
      LoggerService.log('YandexMusic: ✅ Track info: $title - $artist');
      
      return {
        'title': title,
        'artist': artist,
        'coverUrl': coverUrl,
      };
    } catch (e) {
      LoggerService.log('YandexMusic: Error fetching track info: $e');
      return null;
    }
  }
  
  /// Получить прямую ссылку на 30-секундный отрывок
  Future<String?> getPreviewUrl(String trackId) async {
    try {
      LoggerService.log('YandexMusic: Getting preview URL for $trackId');
      
      // Шаг 1: Получаем download-info
      final infoRes = await http.get(
        Uri.parse('https://api.music.yandex.net/tracks/$trackId/download-info'),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );
      
      if (infoRes.statusCode != 200) {
        LoggerService.log('YandexMusic: Failed to get download-info: ${infoRes.statusCode}');
        return null;
      }
      
      final infoJson = json.decode(infoRes.body);
      final results = infoJson['result'] as List?;
      
      if (results == null || results.isEmpty) {
        LoggerService.log('YandexMusic: No download info available');
        return null;
      }
      
      // Ищем preview версию
      Map<String, dynamic>? previewItem;
      for (final item in results) {
        if (item['preview'] == true) {
          previewItem = item;
          break;
        }
      }
      
      if (previewItem == null) {
        LoggerService.log('YandexMusic: No preview available');
        return null;
      }
      
      final downloadInfoUrl = previewItem['downloadInfoUrl'] as String?;
      if (downloadInfoUrl == null) {
        LoggerService.log('YandexMusic: No downloadInfoUrl');
        return null;
      }
      
      // Шаг 2: Получаем XML с host/path/ts/s
      final xmlRes = await http.get(Uri.parse(downloadInfoUrl));
      if (xmlRes.statusCode != 200) {
        LoggerService.log('YandexMusic: Failed to get XML: ${xmlRes.statusCode}');
        return null;
      }
      
      final doc = XmlDocument.parse(xmlRes.body);
      
      final host = doc.findAllElements('host').first.innerText;
      final path = doc.findAllElements('path').first.innerText;
      final ts = doc.findAllElements('ts').first.innerText;
      final s = doc.findAllElements('s').first.innerText;
      
      final previewUrl = 'https://$host/get-mp3/$s/$ts$path';
      
      LoggerService.log('YandexMusic: ✅ Preview URL obtained');
      
      return previewUrl;
    } catch (e) {
      LoggerService.log('YandexMusic: Error getting preview URL: $e');
      return null;
    }
  }
  
  /// Проиграть трек (30-секундный отрывок)
  Future<void> playTrack(String trackId) async {
    try {
      LoggerService.log('YandexMusic: Playing track $trackId');
      
      final previewUrl = await getPreviewUrl(trackId);
      if (previewUrl == null) {
        LoggerService.log('YandexMusic: Cannot play - no preview URL');
        throw Exception('Не удалось получить ссылку на трек');
      }
      
      LoggerService.log('YandexMusic: Setting source: $previewUrl');
      
      // Останавливаем если что-то играет
      await _audioPlayer.stop();
      
      // Загружаем и проигрываем
      await _audioPlayer.play(UrlSource(previewUrl));
      _isPlaying = true;
      
      LoggerService.log('YandexMusic: ✅ Playing');
    } catch (e) {
      LoggerService.log('YandexMusic: Error playing track: $e');
      _isPlaying = false;
      rethrow;
    }
  }
  
  /// Остановить проигрывание
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    LoggerService.log('YandexMusic: Stopped');
  }
  
  /// Пауза
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    LoggerService.log('YandexMusic: Paused');
  }
  
  /// Возобновить
  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    LoggerService.log('YandexMusic: Resumed');
  }
  
  /// Перемотать на позицию
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    LoggerService.log('YandexMusic: Seeked to ${position.inSeconds}s');
  }
  
  /// Проверить играет ли сейчас
  bool get isPlaying => _isPlaying;
  
  /// Stream состояния проигрывания
  Stream<PlayerState> get playerStateStream => _audioPlayer.onPlayerStateChanged;
  
  /// Stream позиции
  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  
  /// Stream длительности
  Stream<Duration> get durationStream => _audioPlayer.onDurationChanged;
  
  /// Освободить ресурсы
  void dispose() {
    _audioPlayer.dispose();
    LoggerService.log('YandexMusic: Disposed');
  }
}
