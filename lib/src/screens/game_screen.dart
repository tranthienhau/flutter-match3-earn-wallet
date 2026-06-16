import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/account_state.dart';
import '../state/earn_state.dart';
import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shape_tile.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final acc = ref.watch(accountProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: StatChip(
                  icon: Icons.bolt,
                  label: 'Energy',
                  value: '${acc.energy}/${acc.maxEnergy}',
                  color: AppColors.warn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatChip(
                  icon: Icons.swap_horiz,
                  label: 'Moves',
                  value: '${game.moves}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatChip(
                  icon: Icons.check_circle,
                  label: 'Pairs',
                  value: '${game.matchedPairs}/${game.totalPairs}',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: game.cards.length,
              itemBuilder: (_, i) {
                final c = game.cards[i];
                return ShapeCard(
                  kind: c.kind,
                  revealed: c.revealed,
                  matched: c.matched,
                  hinted: c.hinted,
                  onTap: () => ref.read(gameProvider.notifier).tap(i),
                );
              },
            ),
          ),
        ),
        if (game.won)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Panel(
              child: Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: AppColors.warn, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Board cleared!',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(
                          '+60 XP  -  ${usd(game.rewardEarned)} reward queued '
                          '(2/3 to your wallet)',
                          style: const TextStyle(
                              color: AppColors.textDim, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Rewarded "Hint": watch a rewarded video, then reveal a pair.
                    ref.read(earnProvider.notifier).watchRewarded();
                    ref.read(gameProvider.notifier).useHint();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 1200),
                        content:
                            Text('Rewarded video watched - hint revealed'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lightbulb, size: 18),
                  label: const Text('Hint (rewarded)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warn,
                    side: const BorderSide(color: AppColors.warn),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: game.won ? 'Play again' : 'New board',
                  icon: Icons.refresh,
                  onPressed: acc.energy > 0 || game.won
                      ? () => ref.read(gameProvider.notifier).startRound()
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
