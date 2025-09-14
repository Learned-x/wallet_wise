import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_wise/data/repositories/in_memory_health_score_repository.dart';
import 'package:wallet_wise/providers/health_score_provider.dart';

void main() {
  test('HealthScoreProvider returns a health score', () async {
    final container = ProviderContainer(overrides: [
      healthScoreRepositoryProvider
          .overrideWithValue(InMemoryHealthScoreRepository()),
    ]);

    addTearDown(container.dispose);

    final result = await container.read(healthScoreProvider.future);
    expect(result.score, isA<int>());
  });
}
