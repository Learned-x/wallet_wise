abstract class DatabaseHelper {
  /// Returns the list of table names present in the database schema
  Future<List<String>> getTableNames();

  /// Placeholder for initialization (e.g., migrations)
  Future<void> initialize();
}
