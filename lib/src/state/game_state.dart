import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import 'account_state.dart';
import 'wallet_state.dart';

class GameCard {
  const GameCard({
    required this.kind,
    this.revealed = false,
    this.matched = false,
    this.hinted = false,
  });
  final ShapeKind kind;
  final bool revealed;
  final bool matched;
  final bool hinted;

  GameCard copyWith({bool? revealed, bool? matched, bool? hinted}) => GameCard(
        kind: kind,
        revealed: revealed ?? this.revealed,
        matched: matched ?? this.matched,
        hinted: hinted ?? this.hinted,
      );
}

class GameState {
  const GameState({
    required this.cards,
    required this.moves,
    required this.matchedPairs,
    required this.firstPick,
    required this.busy,
    required this.won,
    required this.rewardEarned,
  });

  final List<GameCard> cards;
  final int moves;
  final int matchedPairs;
  final int? firstPick;
  final bool busy;
  final bool won;
  final double rewardEarned;

  int get totalPairs => cards.length ~/ 2;

  GameState copyWith({
    List<GameCard>? cards,
    int? moves,
    int? matchedPairs,
    int? firstPick,
    bool clearFirstPick = false,
    bool? busy,
    bool? won,
    double? rewardEarned,
  }) =>
      GameState(
        cards: cards ?? this.cards,
        moves: moves ?? this.moves,
        matchedPairs: matchedPairs ?? this.matchedPairs,
        firstPick: clearFirstPick ? null : (firstPick ?? this.firstPick),
        busy: busy ?? this.busy,
        won: won ?? this.won,
        rewardEarned: rewardEarned ?? this.rewardEarned,
      );
}

class GameNotifier extends Notifier<GameState> {
  // Fixed seed -> deterministic board, so screenshots are reproducible.
  final _rng = math.Random(42);

  @override
  GameState build() => _freshBoard();

  GameState _freshBoard() {
    const kinds = ShapeKind.values; // 6 kinds -> 6 pairs -> 12 cards
    final deck = <GameCard>[
      for (final k in kinds) ...[GameCard(kind: k), GameCard(kind: k)],
    ]..shuffle(_rng);
    return GameState(
      cards: deck,
      moves: 0,
      matchedPairs: 0,
      firstPick: null,
      busy: false,
      won: false,
      rewardEarned: 0,
    );
  }

  /// Start a round: costs one energy, deals a fresh deterministic board.
  void startRound() {
    ref.read(accountProvider.notifier).spendEnergy();
    state = _freshBoard();
  }

  void tap(int i) {
    final s = state;
    if (s.busy || s.won) return;
    final card = s.cards[i];
    if (card.matched || card.revealed) return;

    final cards = [...s.cards];
    cards[i] = card.copyWith(revealed: true, hinted: false);

    if (s.firstPick == null) {
      state = s.copyWith(cards: cards, firstPick: i);
      return;
    }

    // Second pick -> resolve match or schedule a flip-back.
    final first = s.firstPick!;
    final moves = s.moves + 1;
    if (cards[first].kind == cards[i].kind) {
      cards[first] = cards[first].copyWith(matched: true);
      cards[i] = cards[i].copyWith(matched: true);
      final matched = s.matchedPairs + 1;
      final won = matched == s.totalPairs;
      state = s.copyWith(
        cards: cards,
        moves: moves,
        matchedPairs: matched,
        clearFirstPick: true,
        won: won,
      );
      if (won) _onWin();
    } else {
      state = s.copyWith(cards: cards, moves: moves, busy: true);
      Future.delayed(const Duration(milliseconds: 700), () {
        final cur = [...state.cards];
        cur[first] = cur[first].copyWith(revealed: false);
        cur[i] = cur[i].copyWith(revealed: false);
        state = state.copyWith(cards: cur, busy: false, clearFirstPick: true);
      });
    }
  }

  /// Rewarded "Hint": briefly highlight a still-unmatched matching pair.
  /// Caller is responsible for showing the rewarded video first.
  void useHint() {
    final s = state;
    final byKind = <ShapeKind, List<int>>{};
    for (var i = 0; i < s.cards.length; i++) {
      if (s.cards[i].matched) continue;
      byKind.putIfAbsent(s.cards[i].kind, () => []).add(i);
    }
    final pair = byKind.values.firstWhere((v) => v.length >= 2, orElse: () => []);
    if (pair.isEmpty) return;
    final cards = [...s.cards];
    cards[pair[0]] = cards[pair[0]].copyWith(hinted: true);
    cards[pair[1]] = cards[pair[1]].copyWith(hinted: true);
    state = s.copyWith(cards: cards);
    Future.delayed(const Duration(milliseconds: 1400), () {
      final cur = [
        for (final c in state.cards) c.hinted ? c.copyWith(hinted: false) : c,
      ];
      state = state.copyWith(cards: cur);
    });
  }

  void _onWin() {
    // Clearing a board grants XP and a small cash "level reward" into the
    // wallet, where it gets split 2/3 user / 1/3 platform and queued Net-30.
    const reward = 1.50;
    ref.read(accountProvider.notifier).awardXp(60);
    ref.read(walletProvider.notifier)
        .creditRevenue(RevenueSource.levelReward, reward);
    state = state.copyWith(rewardEarned: reward);
  }
}

final gameProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
