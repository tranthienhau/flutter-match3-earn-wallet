import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wallet_state.dart';

/// A single offerwall task. In production the reward is confirmed by a
/// Server-to-Server (S2S) postback from the network (BitLabs / Adjoe / Torox);
/// here we simulate that postback arriving after the user taps "Complete".
class Offer {
  const Offer({
    required this.id,
    required this.network,
    required this.title,
    required this.payout,
    required this.completed,
    required this.postbackVerified,
  });

  final int id;
  final String network;
  final String title;
  final double payout; // gross USD the offer pays the platform
  final bool completed;
  final bool postbackVerified;

  Offer copyWith({bool? completed, bool? postbackVerified}) => Offer(
        id: id,
        network: network,
        title: title,
        payout: payout,
        completed: completed ?? this.completed,
        postbackVerified: postbackVerified ?? this.postbackVerified,
      );
}

class EarnState {
  const EarnState({
    required this.offers,
    required this.adsWatched,
    required this.lastPostback,
  });
  final List<Offer> offers;
  final int adsWatched;
  final String? lastPostback;

  EarnState copyWith({
    List<Offer>? offers,
    int? adsWatched,
    String? lastPostback,
  }) =>
      EarnState(
        offers: offers ?? this.offers,
        adsWatched: adsWatched ?? this.adsWatched,
        lastPostback: lastPostback ?? this.lastPostback,
      );
}

class EarnNotifier extends Notifier<EarnState> {
  @override
  EarnState build() => const EarnState(
        offers: [
          Offer(
            id: 1,
            network: 'BitLabs',
            title: 'Complete a 3-min survey',
            payout: 1.20,
            completed: false,
            postbackVerified: false,
          ),
          Offer(
            id: 2,
            network: 'Adjoe',
            title: 'Reach level 5 in Bubble Saga',
            payout: 3.00,
            completed: false,
            postbackVerified: false,
          ),
          Offer(
            id: 3,
            network: 'Torox',
            title: 'Sign up + verify email',
            payout: 0.80,
            completed: false,
            postbackVerified: false,
          ),
        ],
        adsWatched: 0,
        lastPostback: null,
      );

  /// AdMob rewarded video. Pays a small CPM into the wallet on completion.
  void watchRewarded() {
    ref.read(walletProvider.notifier)
        .creditRevenue(RevenueSource.rewardedAd, 0.90);
    state = state.copyWith(adsWatched: state.adsWatched + 1);
  }

  /// AdMob interstitial - lower payout, shown between rounds.
  void showInterstitial() {
    ref.read(walletProvider.notifier)
        .creditRevenue(RevenueSource.interstitial, 0.30);
    state = state.copyWith(adsWatched: state.adsWatched + 1);
  }

  /// Mark an offer done, then simulate the network's S2S postback verifying it
  /// before crediting revenue (untrusted client completion alone never pays).
  void completeOffer(int id) {
    final offers = [
      for (final o in state.offers)
        o.id == id ? o.copyWith(completed: true) : o,
    ];
    state = state.copyWith(offers: offers);
    final offer = offers.firstWhere((o) => o.id == id);
    Future.delayed(const Duration(milliseconds: 900), () {
      final verified = [
        for (final o in state.offers)
          o.id == id ? o.copyWith(postbackVerified: true) : o,
      ];
      ref.read(walletProvider.notifier)
          .creditRevenue(RevenueSource.offerwall, offer.payout);
      state = state.copyWith(
        offers: verified,
        lastPostback:
            'S2S postback OK - ${offer.network} #${offer.id} verified, '
            '\$${offer.payout.toStringAsFixed(2)} credited',
      );
    });
  }
}

final earnProvider =
    NotifierProvider<EarnNotifier, EarnState>(EarnNotifier.new);
