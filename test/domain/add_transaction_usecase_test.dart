import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/domain/models/transaction_model.dart';
import 'package:wallet_wise/domain/value_objects/amount.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';
import 'package:wallet_wise/domain/value_objects/date_vo.dart';
import 'package:wallet_wise/domain/usecases/add_transaction_usecase.dart';
import 'fakes/fake_transactions_repository.dart';

void main() {
  test('AddTransactionUseCase stores transaction and returns id', () async {
    final repo = FakeTransactionsRepository();
    final usecase = AddTransactionUseCase(repo);

    final t = TransactionModel(
      id: 'tx1',
      amount: Amount(-12.5),
      categoryId: CategoryId('food'),
      description: 'Lunch',
      date: DateVO(DateTime.now()),
    );

    final id = await usecase.execute(t);
    expect(id, 'tx1');
    final stored = await repo.getById('tx1');
    expect(stored, isNotNull);
    expect(stored!.description, 'Lunch');
  });
}
