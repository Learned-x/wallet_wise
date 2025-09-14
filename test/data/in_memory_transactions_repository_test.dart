import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/data/repositories/in_memory_transactions_repository.dart';
import 'package:wallet_wise/domain/models/transaction_model.dart';
import 'package:wallet_wise/domain/value_objects/amount.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';
import 'package:wallet_wise/domain/value_objects/date_vo.dart';

void main() {
  test('add/get by id returns stored transaction', () async {
    final repo = InMemoryTransactionsRepository();
    final tx = TransactionModel(
      id: '1',
      amount: Amount.income(10),
      categoryId: CategoryId('c1'),
      date: DateVO(DateTime.now()),
    );
    await repo.addTransaction(tx);
    final got = await repo.getById('1');
    expect(got, isNotNull);
    expect(got!.amount.value, 10);
  });

  test('updateTransaction replaces existing', () async {
    final repo = InMemoryTransactionsRepository();
    final tx = TransactionModel(
      id: '1',
      amount: Amount.income(10),
      categoryId: CategoryId('c1'),
      date: DateVO(DateTime.now()),
    );
    await repo.addTransaction(tx);

    final updated = TransactionModel(
      id: '1',
      amount: Amount.expense(-5),
      categoryId: CategoryId('c2'),
      date: DateVO(DateTime.now()),
    );
    await repo.updateTransaction(updated);

    final got = await repo.getById('1');
    expect(got!.amount.value, -5);
    expect(got.categoryId.value, 'c2');
  });

  test('deleteTransaction removes item', () async {
    final repo = InMemoryTransactionsRepository();
    final tx = TransactionModel(
      id: '1',
      amount: Amount.income(10),
      categoryId: CategoryId('c1'),
      date: DateVO(DateTime.now()),
    );
    await repo.addTransaction(tx);
    await repo.deleteTransaction('1');
    final got = await repo.getById('1');
    expect(got, isNull);
  });

  test('pagination returns limited window', () async {
    final repo = InMemoryTransactionsRepository();
    for (var i = 0; i < 5; i++) {
      await repo.addTransaction(TransactionModel(
        id: '$i',
        amount: Amount.income(10.0 + i.toDouble()),
        categoryId: CategoryId('c'),
        date: DateVO(DateTime.now()),
      ));
    }
    final list = await repo.getTransactions(limit: 2, offset: 1);
    expect(list.length, 2);
    expect(list.first.id, '1');
    expect(list.last.id, '2');
  });
}
