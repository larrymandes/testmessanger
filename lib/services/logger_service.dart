class LoggerService {
  static final List<String> _logs = [];
  static const int maxLogs = 200;

  static void log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] $message';
    
    print(logEntry);
    
    _logs.insert(0, logEntry);
    if (_logs.length > maxLogs) {
      _logs.removeLast();
    }
  }

  static List<String> getLogs() => List.from(_logs);
  
  static void clear() => _logs.clear();
}
