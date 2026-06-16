import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One device-trust signal. In production these come from Play Integrity API /
/// Apple DeviceCheck plus a server-side IP check; here each is a mock verdict.
class IntegritySignal {
  const IntegritySignal({
    required this.name,
    required this.detail,
    required this.passed,
  });
  final String name;
  final String detail;
  final bool passed;
}

class IntegrityState {
  const IntegrityState({required this.signals, required this.lastVerdict});
  final List<IntegritySignal> signals;
  final String lastVerdict;

  bool get allPass => signals.every((s) => s.passed);
  int get failing => signals.where((s) => !s.passed).length;
}

class IntegrityNotifier extends Notifier<IntegrityState> {
  @override
  IntegrityState build() => const IntegrityState(
        signals: [
          IntegritySignal(
            name: 'Play Integrity / DeviceCheck',
            detail: 'Genuine, certified device - MEETS_DEVICE_INTEGRITY',
            passed: true,
          ),
          IntegritySignal(
            name: 'Emulator detection',
            detail: 'No emulator / cloud-phone fingerprint',
            passed: true,
          ),
          IntegritySignal(
            name: 'VPN / proxy block',
            detail: 'Direct connection - no datacenter ASN',
            passed: true,
          ),
          IntegritySignal(
            name: 'Multi-account farming',
            detail: 'One active wallet per device attestation',
            passed: true,
          ),
          IntegritySignal(
            name: 'Click-bot heuristics',
            detail: 'Human tap cadence within bounds',
            passed: true,
          ),
        ],
        lastVerdict: 'Trusted - rewards and payouts enabled',
      );

  /// Demo toggle: simulate a flagged device (VPN + emulator) so the UI shows
  /// how a failed attestation freezes earning/payout.
  void simulateThreat() {
    state = const IntegrityState(
      signals: [
        IntegritySignal(
          name: 'Play Integrity / DeviceCheck',
          detail: 'Basic integrity only - not certified',
          passed: false,
        ),
        IntegritySignal(
          name: 'Emulator detection',
          detail: 'Emulator fingerprint detected',
          passed: false,
        ),
        IntegritySignal(
          name: 'VPN / proxy block',
          detail: 'Datacenter IP (ASN 14061) - blocked',
          passed: false,
        ),
        IntegritySignal(
          name: 'Multi-account farming',
          detail: '4 wallets share this device id',
          passed: false,
        ),
        IntegritySignal(
          name: 'Click-bot heuristics',
          detail: 'Inhuman tap interval - 12ms',
          passed: false,
        ),
      ],
      lastVerdict: 'Blocked - earning frozen, payout held for review',
    );
  }

  void reset() => state = build();
}

final integrityProvider =
    NotifierProvider<IntegrityNotifier, IntegrityState>(IntegrityNotifier.new);
