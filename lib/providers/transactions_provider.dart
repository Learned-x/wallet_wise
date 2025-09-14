import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/transaction_model.dart';
import '../domain/repositories/transactions_repository.dart';

import '../core/di.dart' as di;

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  try {
    return di.locator<TransactionsRepository>();
  } catch (_) {
    throw UnimplementedError(
        'Provide a TransactionsRepository implementation in DI');
  }
});

final transactionsListProvider = StateNotifierProvider<TransactionsListNotifier,
    AsyncValue<List<TransactionModel>>>((ref) {
  final repo = ref.watch(transactionsRepositoryProvider);
  return TransactionsListNotifier(repo);
});

class TransactionsListNotifier
    extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final TransactionsRepository _repo;

  TransactionsListNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final list = await _repo.getTransactions();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(TransactionModel t) async {
    await _repo.addTransaction(t);
    final list = await _repo.getTransactions();
    state = AsyncValue.data(list);
  }
}
