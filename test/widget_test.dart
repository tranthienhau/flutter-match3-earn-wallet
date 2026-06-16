import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_match3_earn_wallet/src/app.dart';

void main() {
  testWidgets('App boots into the Level-to-Earn home shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: Match3EarnApp()));
    await tester.pump(const Duration(milliseconds: 300));

    // Bottom nav with the five demoable tabs is present.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Wallet'), findsWidgets);
    expect(find.text('Earn'), findsWidgets);
  });
}
