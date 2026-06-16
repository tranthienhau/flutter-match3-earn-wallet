import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where a unit of revenue came from - drives the ledger labels.
enum RevenueSource { rewardedAd, interstitial, offerwall, levelReward }

extension RevenueSourceLabel on RevenueSource {
  String get label => switch (this) {
        RevenueSource.rewardedAd => 'Rewarded video',
        RevenueSource.interstitial => 'Interstitial ad',
        RevenueSource.offerwall => 'Offerwall task',
        RevenueSource.levelReward => 'Level reward',
      };
}

/// One ledger row. Earned revenue is split 2/3 user / 1/3 platform on arrival,
/// then the user's share sits in a Net-30 queue until [clearsOnDay].
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.source,
    required this.gross,
    required this.userShare,
    required this.platformShare,
    required this.createdDay,
    required this.clearsOnDay,
    required this.cleared,
  });

  final int id;
  final RevenueSource source;
  final double gross;
  final double userShare;
  final double platformShare;
  final int createdDay; // simulated day index
  final int clearsOnDay; // createdDay + 30 (Net-30)
  final bool cleared;

  LedgerEntry copyWith({bool? cleared}) => LedgerEntry(
        id: id,
        source: source,
        gross: gross,
        userShare: userShare,
        platformShare: platformShare,
        createdDay: createdDay,
        clearsOnDay: clearsOnDay,
        cleared: cleared ?? this.cleared,
      );
}

class PayoutRequest {
  const PayoutRequest({
    required this.reference,
    required this.amount,
    required this.status,
  });
  final String reference;
  final double amount;
  final String status; // queued / processing / paid
}

class WalletState {
  const WalletState({
    required this.entries,
    required this.today,
    required this.lastPayout,
    required this.nextId,
  });

  final List<LedgerEntry> entries;
  final int today; // simulated current day index
  final PayoutRequest? lastPayout;
  final int nextId;

  static const double userSplit = 2 / 3;
  static const double platformSplit = 1 / 3;
  static const double payoutThreshold = 10.0;
  static const int netDays = 30;

  /// Cleared user funds, minus anything already paid out.
  double get available => entries
      .where((e) => e.cleared)
      .fold(0.0, (s, e) => s + e.userShare) -
      (lastPayout?.status == 'paid' ? lastPayout!.amount : 0);

  /// User funds still inside the 30-day clearance window.
  double get pending => entries
      .where((e) => !e.cleared)
      .fold(0.0, (s, e) => s + e.userShare);

  /// 1/3 cut routed to the platform admin wallet.
  double get platformTotal =>
      entries.fold(0.0, (s, e) => s + e.platformShare);

  double get lifetimeGross => entries.fold(0.0, (s, e) => s + e.gross);

  bool get canPayout => available >= payoutThreshold;
  double get towardThreshold => (available / payoutThreshold).clamp(0, 1);
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() {
    // Seed a believable history: a few cleared entries + some still in Net-30.
    final seed = <LedgerEntry>[];
    var id = 1;
    LedgerEntry mk(RevenueSource s, double gross, int created, bool cleared) {
      return LedgerEntry(
        id: id++,
        source: s,
        gross: gross,
        userShare: gross * WalletState.userSplit,
        platformShare: gross * WalletState.platformSplit,
        createdDay: created,
        clearsOnDay: created + WalletState.netDays,
        cleared: cleared,
      );
    }

    // today = day 40. Entries created day <= 10 are cleared (40 - 30).
    seed
      ..add(mk(RevenueSource.offerwall, 6.00, 2, true))
      ..add(mk(RevenueSource.rewardedAd, 0.90, 5, true))
      ..add(mk(RevenueSource.offerwall, 4.50, 8, true))
      ..add(mk(RevenueSource.interstitial, 0.30, 22, false))
      ..add(mk(RevenueSource.rewardedAd, 0.90, 28, false))
      ..add(mk(RevenueSource.offerwall, 3.00, 33, false));

    return WalletState(
      entries: seed,
      today: 40,
      lastPayout: null,
      nextId: id,
    );
  }

  /// Revenue arrives gross; we split 2/3 user / 1/3 platform and queue Net-30.
  void creditRevenue(RevenueSource source, double gross) {
    final s = state;
    final entry = LedgerEntry(
      id: s.nextId,
      source: source,
      gross: gross,
      userShare: gross * WalletState.userSplit,
      platformShare: gross * WalletState.platformSplit,
      createdDay: s.today,
      clearsOnDay: s.today + WalletState.netDays,
      cleared: false,
    );
    state = WalletState(
      entries: [entry, ...s.entries],
      today: s.today,
      lastPayout: s.lastPayout,
      nextId: s.nextId + 1,
    );
  }

  /// Advance the simulated clock - used by the "skip Net-30 clearance" demo
  /// button to show held funds maturing into the available balance.
  void advanceDays(int days) {
    final s = state;
    final today = s.today + days;
    final entries = [
      for (final e in s.entries)
        e.cleared || today >= e.clearsOnDay ? e.copyWith(cleared: true) : e,
    ];
    state = WalletState(
      entries: entries,
      today: today,
      lastPayout: s.lastPayout,
      nextId: s.nextId,
    );
  }

  /// Queue a bulk disbursement via the OPay Business/Payout API (mocked).
  /// Only fires once the user clears the $10 minimum threshold.
  void requestPayout() {
    final s = state;
    if (s.available < WalletState.payoutThreshold) return;
    final ref = 'OPAY-${100000 + s.today * 7 + s.entries.length}';
    state = WalletState(
      entries: s.entries,
      today: s.today,
      lastPayout:
          PayoutRequest(reference: ref, amount: s.available, status: 'paid'),
      nextId: s.nextId,
    );
  }
}

final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
