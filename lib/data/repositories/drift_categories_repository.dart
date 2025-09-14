import 'package:drift/drift.dart';
import '../../domain/value_objects/category_id.dart' as domain;
import '../../domain/repositories/categories_repository.dart';
import '../datasources/drift_database.dart';

class DriftCategoriesRepository implements CategoriesRepository {
  final AppDatabase _db;

  DriftCategoriesRepository(this._db);

  @override
  Future<void> createCategory(domain.CategoryId id, String name) async {
    final companion = CategoriesCompanion(
      id: Value(id.value),
      name: Value(name),
      createdAt: Value(DateTime.now()),
    );
    await _db.into(_db.categories).insert(companion);
  }

  @override
  Future<void> deleteCategory(domain.CategoryId id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id.value)))
        .go();
  }

  @override
  Future<List<domain.CategoryId>> getAllCategories() async {
    final rows = await _db.select(_db.categories).get();
    return rows.map((r) => domain.CategoryId(r.id)).toList();
  }
}
