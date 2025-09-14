import 'package:drift/drift.dart';
import '../datasources/drift_database.dart';
import '../../domain/value_objects/category_id.dart';

/// Seed helper to populate default categories if they don't exist.
Future<void> seedDefaultCategories(AppDatabase db) async {
  final existing = await db.select(db.categories).get();
  if (existing.isNotEmpty) return; // already seeded

  final defaults = [
    CategoryId('food'),
    CategoryId('transport'),
    CategoryId('entertainment'),
    CategoryId('bills'),
    CategoryId('income'),
  ];

  for (var i = 0; i < defaults.length; i++) {
    final id = defaults[i].value;
    await db.into(db.categories).insertOnConflictUpdate(
      CategoriesCompanion(
        id: Value(id),
        name: Value(id),
        sortOrder: Value(i),
        isCustom: const Value(false),
        isIncome: Value(id == 'income'),
        createdAt: Value(DateTime.now()),
      ),
    );
  }
}
