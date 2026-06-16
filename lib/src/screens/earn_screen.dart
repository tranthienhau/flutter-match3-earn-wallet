import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/earn_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class EarnScreen extends ConsumerWidget {
  const EarnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earn = ref.watch(earnProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const SectionTitle('AdMob'),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Rewarded +\$0.90',
                icon: Icons.play_circle,
                onPressed: () =>
                    ref.read(earnProvider.notifier).watchRewarded(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Interstitial +\$0.30',
                icon: Icons.fullscreen,
                color: AppColors.surfaceAlt,
                onPressed: () =>
                    ref.read(earnProvider.notifier).showInterstitial(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('${earn.adsWatched} ads watched this session',
            style: const TextStyle(color: AppColors.textDim, fontSize: 12.5)),
        const SizedBox(height: 18),

        const SectionTitle('Offerwall'),
        const Text(
          'Tasks pay only after the network confirms them with a '
          'Server-to-Server postback - a tapped "Complete" never credits alone.',
          style: TextStyle(color: AppColors.textDim, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        ...earn.offers.map((o) => _OfferTile(o)),

        if (earn.lastPostback != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.dns, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(earn.lastPostback!,
                      style: const TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OfferTile extends ConsumerWidget {
  const _OfferTile(this.offer);
  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget trailing;
    if (offer.postbackVerified) {
      trailing = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: AppColors.accent, size: 18),
          SizedBox(width: 4),
          Text('Verified',
              style: TextStyle(color: AppColors.accent, fontSize: 12.5)),
        ],
      );
    } else if (offer.completed) {
      trailing = const Text('Awaiting postback...',
          style: TextStyle(color: AppColors.warn, fontSize: 12.5));
    } else {
      trailing = FilledButton(
        onPressed: () => ref.read(earnProvider.notifier).completeOffer(offer.id),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: const Text('Complete'),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(offer.network,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13.5)),
                Text('Pays ${usd(offer.payout)}',
                    style: const TextStyle(
                        color: AppColors.textDim, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
