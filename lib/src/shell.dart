import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/earn_screen.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/integrity_screen.dart';
import 'screens/wallet_screen.dart';
import 'theme.dart';

/// Holds the selected bottom-nav tab so tests (and the Home "Play" button)
/// can drive navigation deterministically.
final tabProvider = StateProvider<int>((_) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _titles = ['ShapeCash', 'Memory Match', 'Wallet', 'Earn', 'Trust'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabProvider);

    final pages = [
      HomeScreen(onPlay: () => ref.read(tabProvider.notifier).state = 1),
      const GameScreen(),
      const WalletScreen(),
      const EarnScreen(),
      const IntegrityScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[tab],
            style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.bg,
        centerTitle: false,
      ),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) =>
            ref.read(tabProvider.notifier).state = i,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.25),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Play'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet'),
          NavigationDestination(
              icon: Icon(Icons.redeem_outlined),
              selectedIcon: Icon(Icons.redeem),
              label: 'Earn'),
          NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Trust'),
        ],
      ),
    );
  }
}
