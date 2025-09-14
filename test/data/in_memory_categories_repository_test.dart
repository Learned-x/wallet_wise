import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/data/repositories/in_memory_categories_repository.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';

void main() {
  test('create and list categories', () async {
    final repo = InMemoryCategoriesRepository();
    await repo.createCategory(CategoryId('c1'), 'Food');
    await repo.createCategory(CategoryId('c2'), 'Travel');
    final all = await repo.getAllCategories();
    expect(all.map((e) => e.value), containsAll(['c1', 'c2']));
  });

  test('delete category removes it', () async {
    final repo = InMemoryCategoriesRepository();
    final id = CategoryId('c3');
    await repo.createCategory(id, 'Misc');
    await repo.deleteCategory(id);
    final all = await repo.getAllCategories();
    expect(all.any((c) => c.value == 'c3'), isFalse);
  });
}
