import '../models/transaction_model.dart';
import '../repositories/transactions_repository.dart';

class AddTransactionUseCase {
  final TransactionsRepository repository;

  AddTransactionUseCase(this.repository);

  Future<String> execute(TransactionModel t) async {
    // validation could be added here
    return await repository.addTransaction(t);
  }
}
