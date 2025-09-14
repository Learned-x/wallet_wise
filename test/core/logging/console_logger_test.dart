import 'dart:convert';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/core/logging/console_logger.dart';

void main() {
  test('ConsoleLogger outputs JSON with required fields', () {
    final logger = StructuredConsoleLogger();
    // Capture print output
    final prints = <String>[];
    final spec = ZoneSpecification(
      print: (_, __, ___, String msg) {
        prints.add(msg);
      },
    );

    Zone.current.fork(specification: spec).run(() {
      logger.info('hello', category: 'test', metadata: {'k': 'v'});
      expect(prints.length, 1);
      final parsed = jsonDecode(prints.first) as Map<String, dynamic>;
      expect(parsed.containsKey('ts'), isTrue);
      expect(parsed['level'], 'INFO');
      expect(parsed['category'], 'test');
      expect(parsed['message'], 'hello');
      expect(parsed['meta']['k'], 'v');
    });
  });
}
