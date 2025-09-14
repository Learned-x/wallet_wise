import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/data/repositories/in_memory_health_score_repository.dart';
import 'package:wallet_wise/domain/models/health_score.dart';

void main() {
  test('calculate returns default deterministic score', () async {
    final repo = InMemoryHealthScoreRepository();
    final score = await repo.calculate();
    expect(score.score, 75);
  });

  test('save updates latest score', () async {
    final repo = InMemoryHealthScoreRepository();
    final first = await repo.calculate();
    expect(first.score, 75);
    await repo.save(HealthScore(score: 80, mood: 'better'));
    final second = await repo.calculate();
    expect(second.score, 80);
  });
}
