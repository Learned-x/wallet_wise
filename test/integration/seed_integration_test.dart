import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:wallet_wise/data/datasources/drift_database.dart' as dbpkg;
import 'package:wallet_wise/data/migrations/seed.dart';

void main() {
  group('Drift Database Integration Tests', () {
    test('DB seeds default categories on create', () async {
      // Create an in-memory database for testing
      final db = dbpkg.AppDatabase.forTesting(NativeDatabase.memory());

      // Force migrations and seeds
      await db.initialize();

      final cats = await db.select(db.categories).get();
      expect(cats.isNotEmpty, true);
      
      // Check that we have the expected default categories
      final categoryNames = cats.map((c) => c.name).toList();
      expect(categoryNames.contains('food'), true);
      expect(categoryNames.contains('transport'), true);
      expect(categoryNames.contains('entertainment'), true);
      expect(categoryNames.contains('bills'), true);
      expect(categoryNames.contains('income'), true);
      
      // Check that income category is marked as income
      final incomeCategory = cats.firstWhere((c) => c.name == 'income');
      expect(incomeCategory.isIncome, true);
      
      // Check that other categories are not marked as income
      final foodCategory = cats.firstWhere((c) => c.name == 'food');
      expect(foodCategory.isIncome, false);

      await db.close();
    });

    test('DB does not re-seed if categories already exist', () async {
      final db = dbpkg.AppDatabase.forTesting(NativeDatabase.memory());
      
      // First initialization - should seed
      await db.initialize();
      
      final initialCats = await db.select(db.categories).get();
      final initialCount = initialCats.length;
      
      // Add a custom category
      await db.into(db.categories).insert(
        dbpkg.CategoriesCompanion.insert(
          id: 'custom_test',
          name: 'Custom Test Category',
        ),
      );
      
      // Re-run seeding
      await seedDefaultCategories(db);
      
      final finalCats = await db.select(db.categories).get();
      // Should have same default categories plus our custom one
      expect(finalCats.length, initialCount + 1);
      
      await db.close();
    });
  });
}
