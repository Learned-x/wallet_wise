import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_wise/presentation/screens/add_transaction.dart';
import 'package:wallet_wise/providers/transactions_provider.dart';
import 'package:wallet_wise/data/repositories/in_memory_transactions_repository.dart';

void main() {
  testWidgets('AddTransactionScreen saves a transaction', (tester) async {
    final container = ProviderContainer(overrides: [
      transactionsRepositoryProvider
          .overrideWithValue(InMemoryTransactionsRepository()),
    ]);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AddTransactionScreen()),
    ));

    await tester.enterText(find.byType(TextField), '12.5');
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Wait for the async provider state to update (avoid race in CI)
    await tester.runAsync(() async {
      for (var i = 0; i < 20; i++) {
        final state = container.read(transactionsListProvider);
        if (state.asData?.value.length == 1) return;
        await Future.delayed(const Duration(milliseconds: 50));
      }
    });

    await tester.pumpAndSettle();

    final state = container.read(transactionsListProvider);
    expect(state.asData?.value.length, 1);
  });
}
