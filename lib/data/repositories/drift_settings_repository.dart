import 'package:drift/drift.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/drift_database.dart';

class DriftSettingsRepository implements SettingsRepository {
  final AppDatabase _db;

  DriftSettingsRepository(this._db);

  @override
  Future<void> setString(String key, String value) async {
    final companion = AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(DateTime.now()),
    );
    await _db.into(_db.appSettings).insertOnConflictUpdate(companion);
  }

  @override
  Future<String?> getString(String key) async {
    final q = _db.select(_db.appSettings)..where((s) => s.key.equals(key));
    final row = await q.getSingleOrNull();
    return row?.value;
  }
}
