import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/lifecycle_provider.dart';
import 'package:trueledger/presentation/providers/boot_provider.dart';
import 'package:trueledger/presentation/screens/startup/lock_screen.dart';

class SessionLockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void lock() => state = true;
  void unlock() => state = false;
}

/// A global provider to track if the session is currently locked.
final sessionLockedProvider =
    NotifierProvider<SessionLockedNotifier, bool>(SessionLockedNotifier.new);

/// Wraps the application to enforce re-locking when the app resumes.
class PrivacyGuard extends ConsumerWidget {
  final Widget child;

  const PrivacyGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the session lock state
    final isLocked = ref.watch(sessionLockedProvider);

    // 2. Listen to lifecycle changes
    ref.listen(appLifecycleProvider, (previous, next) {
      if (next == AppLifecycleState.resumed) {
        final bootState = ref.read(bootProvider);
        final pin = bootState.asData?.value;
        // If a PIN exists and we just resumed, lock the session.
        if (pin != null && pin.isNotEmpty) {
          ref.read(sessionLockedProvider.notifier).lock();
        }
      }
    });

    if (isLocked) {
      final bootState = ref.read(bootProvider);
      final pin = bootState.asData?.value;
      if (pin != null && pin.isNotEmpty) {
        return LockScreen(
          expectedPinLength: pin.length,
          onUnlocked: () {
            ref.read(sessionLockedProvider.notifier).unlock();
          },
        );
      }
    }

    return child;
  }
}
