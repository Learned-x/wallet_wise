import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_wise/data/repositories/in_memory_categories_repository.dart';
import 'package:wallet_wise/providers/categories_provider.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';

void main() {
  test('CategoriesListNotifier initializes and adds category', () async {
    final container = ProviderContainer(overrides: [
      categoriesRepositoryProvider
          .overrideWithValue(InMemoryCategoriesRepository()),
    ]);

    addTearDown(container.dispose);

    await Future.delayed(Duration(milliseconds: 50));

    final notifier = container.read(categoriesListProvider.notifier);
    await notifier.add(CategoryId('c-1'), 'Default');

    final after = container.read(categoriesListProvider);
    expect(after.asData!.value.length, 1);
  });
}
