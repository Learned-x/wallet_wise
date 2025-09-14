import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/data/datasources/in_memory_database_helper.dart';

void main() {
  test('Database schema contains expected tables', () async {
    final db = InMemoryDatabaseHelper(tables: [
      'transactions',
      'categories',
      'health_scores',
      'app_settings',
      'user_feedback'
    ]);

    final tables = await db.getTableNames();
    expect(tables, contains('transactions'));
    expect(tables, contains('categories'));
    expect(tables, contains('health_scores'));
    expect(tables, contains('app_settings'));
    expect(tables, contains('user_feedback'));
  });
}
