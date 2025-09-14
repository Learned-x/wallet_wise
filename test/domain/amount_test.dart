import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/domain/value_objects/amount.dart';

void main() {
  test('Amount rejects zero', () {
    expect(() => Amount(0), throwsArgumentError);
  });

  test('Amount rejects too large values', () {
    expect(() => Amount(1000000), throwsArgumentError);
  });

  test('Amount formats to 2 decimals', () {
    final a = Amount(12.3456);
    expect(a.toString(), '12.35');
  });

  test('Expense factory requires negative', () {
    expect(() => Amount.expense(10), throwsArgumentError);
  });

  test('Income factory requires positive', () {
    expect(() => Amount.income(-5), throwsArgumentError);
  });
}
