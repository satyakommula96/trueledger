import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive notifier for the current [AppLifecycleState].
class AppLifecycleNotifier extends Notifier<AppLifecycleState> {
  @override
  AppLifecycleState build() {
    final observer = _LifecycleObserver(this);
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
    // If null, we're likely in the early boot phase
    return WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.detached;
  }

  void updateState(AppLifecycleState newState) {
    state = newState;
  }
}

/// Exposes the current [AppLifecycleState] reactively.
final appLifecycleProvider =
    NotifierProvider<AppLifecycleNotifier, AppLifecycleState>(
        AppLifecycleNotifier.new);

class _LifecycleObserver extends WidgetsBindingObserver {
  final AppLifecycleNotifier _notifier;

  _LifecycleObserver(this._notifier);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notifier.updateState(state);
  }
}
