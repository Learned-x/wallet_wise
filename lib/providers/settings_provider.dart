import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/settings_repository.dart';
import '../core/di.dart' as di;

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  try {
    return di.locator<SettingsRepository>();
  } catch (_) {
    throw UnimplementedError(
        'Provide a SettingsRepository implementation in DI');
  }
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<Map<String, String>>>(
        (ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

class SettingsNotifier extends StateNotifier<AsyncValue<Map<String, String>>> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // For simplicity, no keys list API — start empty
      state = const AsyncValue.data({});
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> set(String key, String value) async {
    await _repo.setString(key, value);
    final current = state.asData?.value ?? {};
    final copy = Map<String, String>.from(current)..[key] = value;
    state = AsyncValue.data(copy);
  }
}
