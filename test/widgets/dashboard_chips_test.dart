import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_wise/presentation/screens/dashboard.dart';
import 'package:wallet_wise/providers/categories_provider.dart';
import 'package:wallet_wise/data/repositories/in_memory_categories_repository.dart';
import 'package:wallet_wise/providers/transactions_provider.dart';
import 'package:wallet_wise/data/repositories/in_memory_transactions_repository.dart';

void main() {
  testWidgets('Dashboard add category shows chip', (tester) async {
    final container = ProviderContainer(overrides: [
      categoriesRepositoryProvider
          .overrideWithValue(InMemoryCategoriesRepository()),
      transactionsRepositoryProvider
          .overrideWithValue(InMemoryTransactionsRepository()),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: DashboardScreen()),
    ));

    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byIcon(Icons.category));
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsWidgets);
  });
}
