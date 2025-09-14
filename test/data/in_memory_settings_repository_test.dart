import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/data/repositories/in_memory_settings_repository.dart';

void main() {
  test('set and get setting value', () async {
    final repo = InMemorySettingsRepository();
    await repo.setString('language', 'it');
    final value = await repo.getString('language');
    expect(value, 'it');
  });
}
