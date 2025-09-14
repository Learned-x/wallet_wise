import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_wise/main.dart';
import 'package:wallet_wise/core/di.dart';

void main() {
  testWidgets('App shows dashboard scaffold', (WidgetTester tester) async {
    await initDI();
    await tester.pumpWidget(const ProviderScope(child: WalletWiseApp()));
    await tester.pumpAndSettle();
    expect(find.text('Wallet Wise'), findsOneWidget);
  });
}
