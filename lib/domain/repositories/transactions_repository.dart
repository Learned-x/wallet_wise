import '../models/transaction_model.dart';

abstract class TransactionsRepository {
  Future<String> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getTransactions({int? limit, int? offset});
  Future<TransactionModel?> getById(String id);
}
