import 'package:get_it/get_it.dart';
import 'logger.dart';
import '../data/repositories/in_memory_transactions_repository.dart';
import '../data/repositories/in_memory_categories_repository.dart';
import '../data/repositories/in_memory_settings_repository.dart';
import '../data/repositories/in_memory_health_score_repository.dart';
import '../domain/repositories/health_score_repository.dart';
import '../domain/repositories/transactions_repository.dart';
import '../domain/repositories/categories_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../data/datasources/drift_database.dart';
import '../data/repositories/drift_transactions_repository.dart';
import '../data/repositories/drift_categories_repository.dart';
import '../data/repositories/drift_settings_repository.dart';
import '../data/repositories/drift_health_score_repository.dart';

final GetIt locator = GetIt.instance;

Future<void> initDI({bool useInMemory = true}) async {
  locator.registerLazySingleton<Logger>(() => ConsoleLogger());

  if (useInMemory) {
    locator.registerLazySingleton<TransactionsRepository>(
        () => InMemoryTransactionsRepository());
    locator.registerLazySingleton<CategoriesRepository>(
        () => InMemoryCategoriesRepository());
    locator.registerLazySingleton<SettingsRepository>(
        () => InMemorySettingsRepository());
    locator.registerLazySingleton<HealthScoreRepository>(
        () => InMemoryHealthScoreRepository());
  } else {
        final db = await _initAppDatabase();
        // Ensure DB is initialized and seeded before registering repositories
        await db.initialize();
    locator.registerLazySingleton<AppDatabase>(() => db);
    locator.registerLazySingleton<TransactionsRepository>(
        () => DriftTransactionsRepository(db));
    locator.registerLazySingleton<CategoriesRepository>(
        () => DriftCategoriesRepository(db));
    locator.registerLazySingleton<SettingsRepository>(
        () => DriftSettingsRepository(db));
    locator.registerLazySingleton<HealthScoreRepository>(
        () => DriftHealthScoreRepository(db));
  }
}

Future<AppDatabase> _initAppDatabase() async {
  final db = AppDatabase();
  return db;
}
