import '../../domain/value_objects/category_id.dart';
import '../../domain/repositories/categories_repository.dart';

class InMemoryCategoriesRepository implements CategoriesRepository {
  final List<Map<String, String>> _store = [];

  @override
  Future<void> createCategory(CategoryId id, String name) async {
    _store.add({'id': id.value, 'name': name});
  }

  @override
  Future<void> deleteCategory(CategoryId id) async {
    _store.removeWhere((m) => m['id'] == id.value);
  }

  @override
  Future<List<CategoryId>> getAllCategories() async {
    return _store.map((m) => CategoryId(m['id']!)).toList();
  }
}
