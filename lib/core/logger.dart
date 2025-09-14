abstract class Logger {
  void debug(String message,
      {String? category, Map<String, dynamic>? metadata});
  void info(String message, {String? category, Map<String, dynamic>? metadata});
  void warning(String message,
      {String? category, Map<String, dynamic>? metadata});
  void error(String message,
      {Object? error, StackTrace? stackTrace, String? category});
}

class ConsoleLogger implements Logger {
  @override
  void debug(String message,
      {String? category, Map<String, dynamic>? metadata}) {
    print('[DEBUG] ${category ?? 'GENERAL'}: $message ${metadata ?? ''}');
  }

  @override
  void info(String message,
      {String? category, Map<String, dynamic>? metadata}) {
    print('[INFO] ${category ?? 'GENERAL'}: $message ${metadata ?? ''}');
  }

  @override
  void warning(String message,
      {String? category, Map<String, dynamic>? metadata}) {
    print('[WARN] ${category ?? 'GENERAL'}: $message ${metadata ?? ''}');
  }

  @override
  void error(String message,
      {Object? error, StackTrace? stackTrace, String? category}) {
    print('[ERROR] ${category ?? 'GENERAL'}: $message ${error ?? ''}');
    if (stackTrace != null) print(stackTrace);
  }
}
