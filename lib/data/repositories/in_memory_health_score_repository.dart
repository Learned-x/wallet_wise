import '../../domain/models/health_score.dart';
import '../../domain/repositories/health_score_repository.dart';

class InMemoryHealthScoreRepository implements HealthScoreRepository {
  HealthScore? _latest;

  @override
  Future<HealthScore> calculate() async {
    // Simple deterministic implementation for now
    _latest ??= HealthScore(score: 75, mood: 'neutral');
    return _latest!;
  }

  @override
  Future<void> save(HealthScore score) async {
    _latest = score;
  }
}
