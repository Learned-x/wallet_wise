import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_wise/domain/value_objects/date_vo.dart';

void main() {
  test('DateVO rejects > 7 days in the future', () {
    final future = DateTime.now().add(const Duration(days: 8));
    expect(() => DateVO(future), throwsArgumentError);
  });

  test('DateVO rejects > 10 years in the past', () {
    final now = DateTime.now();
    final past = DateTime(now.year - 11, now.month, now.day);
    expect(() => DateVO(past), throwsArgumentError);
  });

  test('DateVO accepts valid date and formats ISO', () {
    final valid = DateTime.now().subtract(const Duration(days: 1));
    final vo = DateVO(valid);
    expect(vo.toString(), contains('T'));
  });
}
