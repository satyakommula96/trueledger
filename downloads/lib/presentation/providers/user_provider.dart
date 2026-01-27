import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

class UserNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString('user_name') ?? 'User';
  }

  Future<void> setName(String name) async {
    state = name;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('user_name', name);
  }
}

final userProvider = NotifierProvider<UserNotifier, String>(() {
  return UserNotifier();
});
