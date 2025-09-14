import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:wallet_wise/data/datasources/drift_database.dart' as dbpkg;

void main() {
  test('DB seeds default categories on create', () async {
    // Create an in-memory database for testing
    final db = dbpkg.AppDatabase.forTesting(NativeDatabase.memory());

    // Force migrations and seeds
    await db.initialize();

    final cats = await db.select(db.categories).get();
    expect(cats.isNotEmpty, true);

    await db.close();
  });
}
