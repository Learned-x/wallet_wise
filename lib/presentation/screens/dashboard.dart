import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/value_objects/category_id.dart';
import '../../providers/transactions_provider.dart';
import 'add_transaction.dart';
import '../../providers/categories_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionsListProvider);
    final catState = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Wise')),
      body: Column(
        children: [
          Expanded(
            child: txState.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => TransactionTile(list[index]),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          SizedBox(
            height: 120,
            child: catState.when(
              data: (cats) => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cats.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(label: Text(cats[index].value)),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add-tx',
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AddTransactionScreen()));
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add-cat',
            onPressed: () async {
              final notifier = ref.read(categoriesListProvider.notifier);
              await notifier.add(
                  CategoryId('c-${DateTime.now().millisecondsSinceEpoch}'),
                  'New');
            },
            child: const Icon(Icons.category),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;

  const TransactionTile(this.tx, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tx.amount.toString()),
      subtitle: Text(tx.date.toString()),
      trailing: Text(tx.categoryId.value),
    );
  }
}
