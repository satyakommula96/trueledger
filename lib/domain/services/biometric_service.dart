import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(ref.watch(sharedPreferencesProvider));
});

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final SharedPreferences _prefs;
  static const String _biometricEnabledKey = 'biometric_enabled';

  BiometricService(this._prefs);

  bool get isBiometricEnabled => _prefs.getBool(_biometricEnabledKey) ?? false;

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    if (!isBiometricEnabled) return true;

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access TrueLedger',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
