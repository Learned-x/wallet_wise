import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_wise/data/repositories/in_memory_settings_repository.dart';
import 'package:wallet_wise/providers/settings_provider.dart';

void main() {
  test('SettingsNotifier sets and retrieves value', () async {
    final container = ProviderContainer(overrides: [
      settingsRepositoryProvider
          .overrideWithValue(InMemorySettingsRepository()),
    ]);

    addTearDown(container.dispose);

    final notifier = container.read(settingsProvider.notifier);
    await notifier.set('theme', 'dark');

    final after = container.read(settingsProvider);
    expect(after.asData!.value['theme'], 'dark');
  });
}
