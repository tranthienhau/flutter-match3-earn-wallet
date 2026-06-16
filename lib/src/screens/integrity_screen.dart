import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/integrity_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class IntegrityScreen extends ConsumerWidget {
  const IntegrityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(integrityProvider);
    final ok = s.allPass;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Panel(
          child: Row(
            children: [
              Icon(ok ? Icons.verified_user : Icons.gpp_bad,
                  color: ok ? AppColors.accent : AppColors.danger, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ok ? 'Device trusted' : 'Device blocked',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: ok ? AppColors.accent : AppColors.danger)),
                    Text(s.lastVerdict,
                        style: const TextStyle(
                            color: AppColors.textDim, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Anti-fraud signals'),
        ...s.signals.map((sig) => _SignalTile(sig)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(integrityProvider.notifier).simulateThreat(),
                icon: const Icon(Icons.bug_report, size: 18),
                label: const Text('Simulate fraud'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Re-attest',
                icon: Icons.refresh,
                onPressed: () =>
                    ref.read(integrityProvider.notifier).reset(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile(this.sig);
  final IntegritySignal sig;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sig.passed
                ? Colors.white10
                : AppColors.danger.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(sig.passed ? Icons.check_circle : Icons.cancel,
                color: sig.passed ? AppColors.accent : AppColors.danger,
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sig.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(sig.detail,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDim)),
                ],
              ),
            ),
          ],
        ),
      );
}
