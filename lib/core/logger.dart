abstract class Logger {
  void debug(String message,
      {String? category, Map<String, dynamic>? metadata});
  void info(String message, {String? category, Map<String, dynamic>? metadata});
  void warning(String message,
      {String? category, Map<String, dynamic>? metadata});
  void error(String message,
      {Object? error, StackTrace? stackTrace, String? category});
  void critical(String message, {Object? error, StackTrace? stackTrace});
  void performance(String operation, Duration duration, {Map<String, dynamic>? metadata});
}

