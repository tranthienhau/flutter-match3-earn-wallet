import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/account_state.dart';
import '../state/wallet_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onPlay});
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acc = ref.watch(accountProvider);
    final wallet = ref.watch(walletProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(acc.name.substring(0, 1),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Text('${acc.country}  -  Level ${acc.level}',
                    style: const TextStyle(
                        color: AppColors.textDim, fontSize: 13)),
              ],
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: acc.subscribed
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.warn.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                acc.subscribed ? 'PRO' : 'FREE',
                style: TextStyle(
                    color: acc.subscribed ? AppColors.accent : AppColors.warn,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Level progress
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Level progress',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('${acc.xp} / ${acc.xpForNext} XP',
                      style: const TextStyle(
                          color: AppColors.textDim, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Bar(value: acc.levelProgress, color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: StatChip(
                icon: Icons.bolt,
                label: 'Energy',
                value: '${acc.energy} / ${acc.maxEnergy}',
                color: AppColors.warn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatChip(
                icon: Icons.account_balance_wallet,
                label: 'Available',
                value: usd(wallet.available),
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatChip(
                icon: Icons.hourglass_bottom,
                label: 'Pending (Net-30)',
                value: usd(wallet.pending),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatChip(
                icon: Icons.payments,
                label: 'Lifetime earned',
                value: usd(wallet.lifetimeGross),
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (!acc.subscribed) _SubGate(),
        if (acc.subscribed)
          PrimaryButton(
            label: acc.energy > 0
                ? 'Play - Memory Match'
                : 'Out of energy - refill',
            icon: Icons.grid_view_rounded,
            onPressed: () {
              if (acc.energy == 0) {
                ref.read(accountProvider.notifier).refillEnergy();
              }
              onPlay();
            },
          ),
        const SizedBox(height: 16),

        Panel(
          child: Row(
            children: [
              const Icon(Icons.shield, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Device attested via Play Integrity. Rewards split 2/3 to you, '
                  '1/3 to platform, paid out via OPay after the \$10 threshold.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textDim),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subscription gateway',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          const Text(
            'Unlock unlimited daily play for \$1/month. Billed via Google Play '
            'Billing / Apple IAP. Cancel anytime.',
            style: TextStyle(color: AppColors.textDim, fontSize: 13),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Subscribe - \$1.00 / month',
            icon: Icons.lock_open,
            color: AppColors.accent,
            onPressed: () => ref.read(accountProvider.notifier).subscribe(),
          ),
        ],
      ),
    );
  }
}
