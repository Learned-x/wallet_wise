import 'dart:convert';

import '../logger.dart';

/// Simple console logger that outputs structured JSON lines.
class StructuredConsoleLogger implements Logger {
  final List<String> _sensitiveKeys = ['password', 'token', 'credit_card', 'card_number'];

  String _format(String level, String message, {String? category, Map<String, dynamic>? metadata}) {
    final now = DateTime.now().toUtc().toIso8601String();
    final entry = {
      'ts': now,
      'level': level,
      'category': category ?? 'general',
      'message': message,
      if (metadata != null) 'meta': _sanitize(metadata),
    };
    return jsonEncode(entry);
  }

  Map<String, dynamic> _sanitize(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (_sensitiveKeys.contains(k.toLowerCase())) {
        out[k] = '[REDACTED]';
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  @override
  void debug(String message, {String? category, Map<String, dynamic>? metadata}) {
    print(_format('DEBUG', message, category: category, metadata: metadata));
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace, String? category}) {
    final meta = <String, dynamic>{};
    if (error != null) meta['error'] = error.toString();
    if (stackTrace != null) meta['stack'] = stackTrace.toString();
    print(_format('ERROR', message, category: category, metadata: meta));
  }

  @override
  void info(String message, {String? category, Map<String, dynamic>? metadata}) {
    print(_format('INFO', message, category: category, metadata: metadata));
  }

  @override
  void critical(String message, {Object? error, StackTrace? stackTrace}) {
    final meta = <String, dynamic>{};
    if (error != null) meta['error'] = error.toString();
    if (stackTrace != null) meta['stack'] = stackTrace.toString();
    print(_format('CRITICAL', message, metadata: meta));
  }

  @override
  void performance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    final meta = <String, dynamic>{'operation': operation, 'duration_ms': duration.inMilliseconds};
    if (metadata != null) meta.addAll(_sanitize(metadata));
    print(_format('PERF', 'performance', metadata: meta));
  }

  @override
  void warning(String message, {String? category, Map<String, dynamic>? metadata}) {
    print(_format('WARN', message, category: category, metadata: metadata));
  }
}
