import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/value_objects/amount.dart';
import '../../domain/value_objects/date_vo.dart';
import '../../domain/value_objects/category_id.dart';
import '../../domain/models/transaction_model.dart';
import '../../providers/transactions_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountCtl = TextEditingController();

  @override
  void dispose() {
    _amountCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(_amountCtl.text) ?? 0.0;
                try {
                  final tx = TransactionModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    amount: Amount.income(amt),
                    date: DateVO(DateTime.now()),
                    categoryId: CategoryId('default'),
                  );
                  await ref.read(transactionsListProvider.notifier).add(tx);
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
