import '../models/health_score.dart';

abstract class HealthScoreRepository {
  Future<HealthScore> calculate();
  Future<void> save(HealthScore score);
}
