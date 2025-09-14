import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/health_score.dart';
import '../domain/repositories/health_score_repository.dart';
import '../core/di.dart' as di;

final healthScoreRepositoryProvider = Provider<HealthScoreRepository>((ref) {
  try {
    return di.locator<HealthScoreRepository>();
  } catch (_) {
    throw UnimplementedError(
        'Provide a HealthScoreRepository implementation in DI');
  }
});

final healthScoreProvider = FutureProvider<HealthScore>((ref) async {
  final repo = ref.watch(healthScoreRepositoryProvider);
  return repo.calculate();
});
