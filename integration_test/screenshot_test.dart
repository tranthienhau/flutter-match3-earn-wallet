import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_match3_earn_wallet/src/app.dart';
import 'package:flutter_match3_earn_wallet/src/widgets/shape_tile.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Deterministic board (seed 42): matching index pairs by shape kind.
  const pairs = <List<int>>[
    [4, 5], // circle
    [0, 11], // star
    [1, 6], // square
    [2, 7], // diamond
    [3, 8], // hexagon
    [9, 10], // triangle
  ];

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 350));
    await binding.takeScreenshot(name);
  }

  Future<void> matchPair(WidgetTester tester, List<int> p) async {
    await tester.tap(find.byType(ShapeCard).at(p[0]));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.byType(ShapeCard).at(p[1]));
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('capture level-to-earn flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: Match3EarnApp()));
    await tester.pumpAndSettle();

    // 01 - Home dashboard with subscription gateway + wallet stats.
    await shoot(tester, '01-home');

    // 02 - Memory Match board, mid-play: 3 pairs cleared + a rewarded hint.
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await matchPair(tester, pairs[0]);
    await matchPair(tester, pairs[1]);
    await matchPair(tester, pairs[2]);
    await tester.tap(find.text('Hint (rewarded)'));
    await tester.pump(const Duration(milliseconds: 400));
    await shoot(tester, '02-game');
    await tester.pump(const Duration(milliseconds: 1600)); // drain hint timer

    // 03 - Clear the rest of the board -> win panel + queued level reward.
    await matchPair(tester, pairs[3]);
    await matchPair(tester, pairs[4]);
    await matchPair(tester, pairs[5]);
    await tester.pumpAndSettle();
    await shoot(tester, '03-win');

    // 04 - Wallet: 2/3-1/3 split, Net-30 queue, threshold, ledger.
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    await shoot(tester, '04-wallet');

    // 05 - Mature the Net-30 queue, then cash out via OPay.
    await tester.tap(find.textContaining('advance 30 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Cash out via OPay'));
    await tester.pumpAndSettle();
    await shoot(tester, '05-payout');

    // 06 - Earn: AdMob + offerwall with S2S postback verification.
    await tester.tap(find.text('Earn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete').first);
    await tester.pump(const Duration(milliseconds: 1100)); // await postback
    await shoot(tester, '06-earn');

    // 07 - Trust: device attestation passing.
    await tester.tap(find.text('Trust'));
    await tester.pumpAndSettle();
    await shoot(tester, '07-trust');

    // 08 - Trust: simulated fraud -> earning frozen.
    await tester.tap(find.text('Simulate fraud'));
    await tester.pumpAndSettle();
    await shoot(tester, '08-trust-blocked');
  });
}
