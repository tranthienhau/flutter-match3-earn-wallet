import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Player profile: XP / level progression, the "Energy" play gate, and the
/// $1/month subscription status (Google Play Billing / Apple IAP, mocked here).
class Account {
  const Account({
    required this.name,
    required this.country,
    required this.level,
    required this.xp,
    required this.energy,
    required this.maxEnergy,
    required this.subscribed,
    required this.subRenewsInDays,
  });

  final String name;
  final String country;
  final int level;
  final int xp;
  final int energy;
  final int maxEnergy;
  final bool subscribed;
  final int subRenewsInDays;

  /// XP needed to reach the next level (simple escalating curve).
  int get xpForNext => level * 100;
  double get levelProgress => (xp / xpForNext).clamp(0, 1);

  Account copyWith({
    int? level,
    int? xp,
    int? energy,
    bool? subscribed,
    int? subRenewsInDays,
  }) =>
      Account(
        name: name,
        country: country,
        level: level ?? this.level,
        xp: xp ?? this.xp,
        energy: energy ?? this.energy,
        maxEnergy: maxEnergy,
        subscribed: subscribed ?? this.subscribed,
        subRenewsInDays: subRenewsInDays ?? this.subRenewsInDays,
      );
}

class AccountNotifier extends Notifier<Account> {
  @override
  Account build() => const Account(
        name: 'Ada O.',
        country: 'Nigeria',
        level: 3,
        xp: 140,
        energy: 4,
        maxEnergy: 5,
        subscribed: false,
        subRenewsInDays: 0,
      );

  bool get canPlay => state.energy > 0 && state.subscribed;

  /// Spend one energy to start a round.
  void spendEnergy() {
    state = state.copyWith(energy: (state.energy - 1).clamp(0, state.maxEnergy));
  }

  void refillEnergy() => state = state.copyWith(energy: state.maxEnergy);

  /// Award XP for a cleared board; roll over into the next level.
  void awardXp(int amount) {
    var xp = state.xp + amount;
    var level = state.level;
    while (xp >= level * 100) {
      xp -= level * 100;
      level += 1;
    }
    state = state.copyWith(xp: xp, level: level);
  }

  /// Mock the recurring $1/month subscription purchase gateway.
  void subscribe() =>
      state = state.copyWith(subscribed: true, subRenewsInDays: 30);
}

final accountProvider =
    NotifierProvider<AccountNotifier, Account>(AccountNotifier.new);
