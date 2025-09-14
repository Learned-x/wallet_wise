import 'package:drift/drift.dart';
import '../../domain/models/health_score.dart' as domain;
import '../../domain/repositories/health_score_repository.dart';
import '../datasources/drift_database.dart';

class DriftHealthScoreRepository implements HealthScoreRepository {
  final AppDatabase _db;

  DriftHealthScoreRepository(this._db);

  @override
  Future<void> save(domain.HealthScore score) async {
    final companion = HealthScoresCompanion(
      score: Value(score.score),
      breakdownJson: Value(null),
      calculatedAt: Value(DateTime.now()),
    );
    await _db.into(_db.healthScores).insert(companion);
  }

  @override
  Future<domain.HealthScore> calculate() async {
    // Simple heuristic: average score of last 30 days (placeholder)
    final rows = await _db.select(_db.healthScores).get();
    if (rows.isEmpty) return domain.HealthScore(score: 50, mood: 'neutral');
    final avg = (rows.map((r) => r.score).reduce((a, b) => a + b) / rows.length)
        .round();
    final mood = avg >= 75 ? 'good' : (avg >= 50 ? 'neutral' : 'bad');
    return domain.HealthScore(score: avg, mood: mood);
  }
}
