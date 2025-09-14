import 'package:wallet_wise/domain/models/transaction_model.dart';
import 'package:wallet_wise/domain/repositories/transactions_repository.dart';

class FakeTransactionsRepository implements TransactionsRepository {
  final Map<String, TransactionModel> _store = {};

  @override
  Future<String> addTransaction(TransactionModel transaction) async {
    _store[transaction.id] = transaction;
    return transaction.id;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _store.remove(id);
  }

  @override
  Future<TransactionModel?> getById(String id) async {
    return _store[id];
  }

  @override
  Future<List<TransactionModel>> getTransactions(
      {int? limit, int? offset}) async {
    final l = limit ?? _store.length;
    final o = offset ?? 0;
    return _store.values.skip(o).take(l).toList();
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    _store[transaction.id] = transaction;
  }
}
