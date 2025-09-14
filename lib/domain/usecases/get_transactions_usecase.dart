import '../models/transaction_model.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionsUseCase {
  final TransactionsRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionModel>> execute(
      {int limit = 50, int offset = 0}) async {
    return await repository.getTransactions(limit: limit, offset: offset);
  }
}
