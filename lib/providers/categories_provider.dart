import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/value_objects/category_id.dart';
import '../domain/repositories/categories_repository.dart';
import '../core/di.dart' as di;

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  try {
    return di.locator<CategoriesRepository>();
  } catch (_) {
    throw UnimplementedError(
        'Provide a CategoriesRepository implementation in DI');
  }
});

final categoriesListProvider =
    StateNotifierProvider<CategoriesListNotifier, AsyncValue<List<CategoryId>>>(
        (ref) {
  final repo = ref.watch(categoriesRepositoryProvider);
  return CategoriesListNotifier(repo);
});

class CategoriesListNotifier
    extends StateNotifier<AsyncValue<List<CategoryId>>> {
  final CategoriesRepository _repo;

  CategoriesListNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final list = await _repo.getAllCategories();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(CategoryId id, String name) async {
    await _repo.createCategory(id, name);
    final list = await _repo.getAllCategories();
    state = AsyncValue.data(list);
  }
}
