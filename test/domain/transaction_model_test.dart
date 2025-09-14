import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/domain/models/transaction_model.dart';
import 'package:wallet_wise/domain/value_objects/amount.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';
import 'package:wallet_wise/domain/value_objects/date_vo.dart';

void main() {
  test('TransactionModel creates correctly', () {
    final t = TransactionModel(
      id: 't1',
      amount: Amount(-10.5),
      categoryId: CategoryId('food'),
      description: 'Cena',
      date: DateVO(DateTime.now()),
    );

    expect(t.id, 't1');
    expect(t.amount.value, -10.5);
    expect(t.categoryId.value, 'food');
  });
}
