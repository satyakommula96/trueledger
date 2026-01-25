import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/boot_provider.dart';
import 'package:truecash/core/providers/shared_prefs_provider.dart';
import 'package:truecash/presentation/screens/dashboard/dashboard.dart';
import 'package:truecash/presentation/screens/startup/intro_screen.dart';
import 'package:truecash/presentation/screens/startup/lock_screen.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootState = ref.watch(bootProvider);

    return bootState.when(
      data: (pin) {
        final prefs = ref.watch(sharedPreferencesProvider);
        final bool seen = prefs.getBool('intro_seen') ?? false;
        // pin is already loaded from secure storage via provider

        if (!seen) {
          return const IntroScreen();
        } else if (pin != null && pin.isNotEmpty) {
          return LockScreen(expectedPinLength: pin.length);
        } else {
          return const Dashboard();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text("Initializing...",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                const Text("Initialization Failed",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 8),
                Text(err.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => ref.refresh(bootProvider),
                  child: const Text("RETRY"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
