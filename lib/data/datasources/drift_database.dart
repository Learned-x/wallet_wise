import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../migrations/seed.dart';

part 'drift_database.g.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column>? get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer().nullable()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column>? get primaryKey => {id};
}

class HealthScores extends Table {
  TextColumn get id => text()();
  IntColumn get score => integer()();
  TextColumn get breakdownJson => text().nullable()();
  DateTimeColumn get calculatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  IntColumn get month => integer().nullable()();
  IntColumn get year => integer().nullable()();

  @override
  Set<Column>? get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column>? get primaryKey => {key};
}

@DriftDatabase(tables: [Transactions, Categories, HealthScores, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Named constructor for tests to provide a custom QueryExecutor (e.g. in-memory DB).
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
  // Basic DAOs / helpers can be added here
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();
  Future<void> insertTransaction(Insertable<Transaction> t) =>
      into(transactions).insert(t);

  /// Migration strategy: run seed in `onCreate` and support future upgrades.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed defaults after schema creation
          await seedDefaultCategories(this);
        },
        onUpgrade: (m, from, to) async {
          // Add versioned migration steps here. Example:
          // if (from < 2) { await m.addColumn(transactions, transactions.photoPath); }
        },
        beforeOpen: (details) async {
          if (details.hadUpgrade) {
            // Optionally run tasks after an upgrade.
          }
        },
      );

  /// Initialize is a lightweight hook called by DI; it forces DB open if needed.
  Future<void> initialize() async {
    // Perform a lightweight read to ensure DB is opened and migrations applied.
    await (select(appSettings).get());
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wallet_wise.sqlite'));
    return NativeDatabase(file);
  });
}
