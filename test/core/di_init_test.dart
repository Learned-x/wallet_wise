import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/core/di.dart';
import 'package:wallet_wise/domain/repositories/transactions_repository.dart';
import 'package:wallet_wise/domain/repositories/categories_repository.dart';
import 'package:wallet_wise/domain/repositories/settings_repository.dart';
import 'package:wallet_wise/domain/repositories/health_score_repository.dart';

void main() {
  test('initDI registers default repositories', () async {
    await initDI();
    expect(locator<TransactionsRepository>(), isA<TransactionsRepository>());
    expect(locator<CategoriesRepository>(), isA<CategoriesRepository>());
    expect(locator<SettingsRepository>(), isA<SettingsRepository>());
    expect(locator<HealthScoreRepository>(), isA<HealthScoreRepository>());
  });
}
