import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/core/providers/shared_prefs_provider.dart';

class PrivacyNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool('is_private_mode') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('is_private_mode', state);
  }
}

final privacyProvider = NotifierProvider<PrivacyNotifier, bool>(() {
  return PrivacyNotifier();
});
