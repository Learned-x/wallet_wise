import '../value_objects/category_id.dart';

abstract class CategoriesRepository {
  Future<List<CategoryId>> getAllCategories();
  Future<void> createCategory(CategoryId id, String name);
  Future<void> deleteCategory(CategoryId id);
}
