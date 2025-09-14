import 'package:drift/drift.dart';
import '../../domain/models/transaction_model.dart' as domain;
import '../../domain/value_objects/amount.dart' as domain_amount;
import '../../domain/value_objects/category_id.dart' as domain_category;
import '../../domain/value_objects/date_vo.dart' as domain_date;
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/drift_database.dart';

class DriftTransactionsRepository implements TransactionsRepository {
  final AppDatabase _db;

  DriftTransactionsRepository(this._db);

  @override
  Future<String> addTransaction(domain.TransactionModel transaction) async {
    final companion = TransactionsCompanion(
      id: Value(transaction.id),
      amount: Value(transaction.amount.value),
      categoryId: Value(transaction.categoryId.value),
      description: Value(transaction.description),
  date: Value(transaction.date.value),
  photoPath: const Value.absent(),
      createdAt: Value(DateTime.now()),
    );
    await _db.into(_db.transactions).insertOnConflictUpdate(companion);
    return transaction.id;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<domain.TransactionModel?> getById(String id) async {
    final row = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return domain.TransactionModel(
      id: row.id,
      amount: domain_amount.Amount(row.amount),
      categoryId: domain_category.CategoryId(row.categoryId),
      description: row.description,
      date: domain_date.DateVO(row.date),
    );
  }

  @override
  Future<List<domain.TransactionModel>> getTransactions(
      {int? limit, int? offset}) async {
    var query = _db.select(_db.transactions);
    final rows = await query.get();

    // Apply pagination in-memory to avoid API differences across drift versions
    final start = offset ?? 0;
    final end =
        limit != null ? (start + limit).clamp(0, rows.length) : rows.length;
    final slice = rows.sublist(start.clamp(0, rows.length), end);

    return slice
        .map((row) => domain.TransactionModel(
              id: row.id,
              amount: domain_amount.Amount(row.amount),
              categoryId: domain_category.CategoryId(row.categoryId),
              description: row.description,
              date: domain_date.DateVO(row.date),
            ))
        .toList();
  }

  @override
  Future<void> updateTransaction(domain.TransactionModel transaction) async {
    await (_db.update(_db.transactions)
          ..where((t) => t.id.equals(transaction.id)))
        .write(
      TransactionsCompanion(
        amount: Value(transaction.amount.value),
        categoryId: Value(transaction.categoryId.value),
        description: Value(transaction.description),
        date: Value(transaction.date.value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
