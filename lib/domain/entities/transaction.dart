class TransactionEntity {
  final String id;
  final double amount;
  final String categoryId;
  final String? description;
  final DateTime date;

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
  });
}
