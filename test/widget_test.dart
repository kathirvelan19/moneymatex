import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monematex/app/app.dart';

void main() {
  testWidgets('MoneyMateX app Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MoneyMateXApp(),
      ),
    );
    expect(find.byType(MoneyMateXApp), findsOneWidget);
  });
}
