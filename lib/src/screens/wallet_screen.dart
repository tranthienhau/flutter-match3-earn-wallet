import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/wallet_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(walletProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Balance summary
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Available to cash out',
                  style: TextStyle(color: AppColors.textDim, fontSize: 13)),
              const SizedBox(height: 4),
              Text(usd(w.available),
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _MiniStat('Pending (Net-30)', usd(w.pending),
                      AppColors.primary),
                  const SizedBox(width: 12),
                  _MiniStat('Platform 1/3', usd(w.platformTotal),
                      AppColors.textDim),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Revenue split explainer
        const SectionTitle('Revenue split'),
        Panel(
          child: Column(
            children: [
              _SplitRow('Your wallet', WalletState.userSplit, AppColors.accent),
              const SizedBox(height: 10),
              _SplitRow(
                  'Platform admin', WalletState.platformSplit, AppColors.textDim),
              const SizedBox(height: 12),
              const Text(
                'Every \$1 of ad/offer revenue is split on arrival: \$0.67 to '
                'your wallet, \$0.33 to the platform admin wallet.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textDim),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Threshold + payout
        const SectionTitle('Cash out'),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${usd(w.available)} of ${usd(WalletState.payoutThreshold)} min',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(w.canPayout ? 'Eligible' : 'Below threshold',
                      style: TextStyle(
                          fontSize: 13,
                          color: w.canPayout
                              ? AppColors.accent
                              : AppColors.warn)),
                ],
              ),
              const SizedBox(height: 10),
              Bar(
                value: w.towardThreshold,
                color: w.canPayout ? AppColors.accent : AppColors.warn,
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Cash out via OPay (Nigeria)',
                icon: Icons.account_balance,
                color: AppColors.accent,
                onPressed: w.canPayout
                    ? () => ref.read(walletProvider.notifier).requestPayout()
                    : null,
              ),
              if (w.lastPayout != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OPay disbursement ${w.lastPayout!.status.toUpperCase()} '
                          '- ${usd(w.lastPayout!.amount)}  -  ref ${w.lastPayout!.reference}',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () =>
                    ref.read(walletProvider.notifier).advanceDays(30),
                icon: const Icon(Icons.fast_forward, size: 16),
                label: const Text('Demo: advance 30 days (clear Net-30 queue)'),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.textDim),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Ledger
        const SectionTitle('Ledger'),
        ...w.entries.map((e) => _LedgerTile(e, w.today)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16, color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textDim)),
            ],
          ),
        ),
      );
}

class _SplitRow extends StatelessWidget {
  const _SplitRow(this.label, this.fraction, this.color);
  final String label;
  final double fraction;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(child: Bar(value: fraction, color: color, height: 10)),
          const SizedBox(width: 10),
          Text('${(fraction * 100).round()}%',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      );
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile(this.e, this.today);
  final LedgerEntry e;
  final int today;
  @override
  Widget build(BuildContext context) {
    final daysLeft = (e.clearsOnDay - today).clamp(0, 999);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            e.cleared ? Icons.check_circle : Icons.hourglass_bottom,
            color: e.cleared ? AppColors.accent : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.source.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  e.cleared
                      ? 'Cleared - ${usd(e.userShare)} available'
                      : 'Clears in $daysLeft d - ${usd(e.userShare)} held',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textDim),
                ),
              ],
            ),
          ),
          Text('+${usd(e.gross)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.text)),
        ],
      ),
    );
  }
}
