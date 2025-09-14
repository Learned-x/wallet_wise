import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/domain/models/transaction_model.dart';
import 'package:wallet_wise/domain/value_objects/amount.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';
import 'package:wallet_wise/domain/value_objects/date_vo.dart';
import 'package:wallet_wise/domain/usecases/get_transactions_usecase.dart';
import 'fakes/fake_transactions_repository.dart';

void main() {
  test('GetTransactionsUseCase returns stored transactions', () async {
    final repo = FakeTransactionsRepository();
    final usecase = GetTransactionsUseCase(repo);

    final t1 = TransactionModel(
      id: 't1',
      amount: Amount(-5),
      categoryId: CategoryId('food'),
      description: 'Snack',
      date: DateVO(DateTime.now()),
    );

    final t2 = TransactionModel(
      id: 't2',
      amount: Amount(100),
      categoryId: CategoryId('salary'),
      description: 'Pay',
      date: DateVO(DateTime.now()),
    );

    await repo.addTransaction(t1);
    await repo.addTransaction(t2);

    final list = await usecase.execute(limit: 10);
    expect(list.length, 2);
  });
}
