class CategoryId {
  final String value;

  CategoryId(this.value) {
    if (value.isEmpty) throw ArgumentError('CategoryId cannot be empty');
  }

  @override
  String toString() => value;
}
