import '../value_objects/amount.dart';
import '../value_objects/category_id.dart';
import '../value_objects/date_vo.dart';

class TransactionModel {
  final String id;
  final Amount amount;
  final CategoryId categoryId;
  final String? description;
  final DateVO date;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
  });
}
