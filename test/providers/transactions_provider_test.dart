import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_wise/data/repositories/in_memory_transactions_repository.dart';
import 'package:wallet_wise/providers/transactions_provider.dart';
import 'package:wallet_wise/domain/models/transaction_model.dart';
import 'package:wallet_wise/domain/value_objects/amount.dart';
import 'package:wallet_wise/domain/value_objects/date_vo.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';

void main() {
  test('TransactionsListNotifier initializes and adds transaction', () async {
    final container = ProviderContainer(overrides: [
      transactionsRepositoryProvider
          .overrideWithValue(InMemoryTransactionsRepository()),
    ]);

    addTearDown(container.dispose);

    // Wait a tick for init
    await Future.delayed(Duration(milliseconds: 50));

    final initial = container.read(transactionsListProvider);
    expect(initial, isA<AsyncValue>());

    final notifier = container.read(transactionsListProvider.notifier);
    final tx = TransactionModel(
      id: 'tx-1',
      amount: Amount.income(10.0),
      date: DateVO(DateTime.now()),
      categoryId: CategoryId('default'),
    );

    await notifier.add(tx);

    final after = container.read(transactionsListProvider);
    expect(after.asData!.value.length, 1);
  });
}
