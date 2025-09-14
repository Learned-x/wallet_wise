import 'dart:async';
import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/transactions_repository.dart';

class InMemoryTransactionsRepository implements TransactionsRepository {
  final List<TransactionModel> _store = [];

  @override
  Future<String> addTransaction(TransactionModel transaction) async {
    final id = transaction.id;
    _store.add(transaction);
    return id;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _store.removeWhere((t) => t.id == id);
  }

  @override
  Future<TransactionModel?> getById(String id) async {
    try {
      return _store.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(
      {int? limit, int? offset}) async {
    if (limit == null && offset == null) return List.unmodifiable(_store);
    final start = offset ?? 0;
    final end = limit != null ? (start + limit) : _store.length;
    final safeStart = start.clamp(0, _store.length);
    final safeEnd = end.clamp(0, _store.length);
    return _store.sublist(safeStart, safeEnd);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final idx = _store.indexWhere((t) => t.id == transaction.id);
    if (idx >= 0) {
      _store[idx] = transaction;
    }
  }
}
