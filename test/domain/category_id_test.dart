import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/domain/value_objects/category_id.dart';

void main() {
  test('CategoryId rejects empty', () {
    expect(() => CategoryId(''), throwsArgumentError);
  });

  test('CategoryId toString equals value', () {
    final id = CategoryId('food');
    expect(id.toString(), 'food');
  });
}
