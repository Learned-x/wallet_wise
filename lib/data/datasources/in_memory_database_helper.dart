import 'database_helper.dart';

class InMemoryDatabaseHelper implements DatabaseHelper {
  final List<String> _tables;

  InMemoryDatabaseHelper({List<String>? tables}) : _tables = tables ?? [];

  @override
  Future<List<String>> getTableNames() async {
    return _tables;
  }

  @override
  Future<void> initialize() async {
    // no-op for in-memory
    return;
  }
}
