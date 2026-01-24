import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truecash/presentation/screens/dashboard.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = "";
  bool _isError = false;
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      setState(() {
        _canCheckBiometrics = canCheck;
      });
      // We do not auto-authenticate anymore to avoid the dual-window issue on desktop.
      // User can tap the fingerprint icon to authenticate.
    } catch (e) {
      debugPrint("Biometric check failed: $e");
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access TrueCash',
      );
      if (didAuthenticate && mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Dashboard()));
      }
    } catch (e) {
      debugPrint("Auth error: $e");
    }
  }

  void _onDigitPress(String digit) async {
    setState(() {
      _isError = false;
      if (_pin.length < 4) {
        _pin += digit;
      }
    });

    if (_pin.length == 4) {
      final prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString('app_pin');

      if (storedPin == _pin) {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const Dashboard()));
        }
      } else {
        setState(() {
          _isError = true;
          _pin = "";
        });
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey)
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              "Enter PIN",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? (_isError ? Colors.red : colorScheme.primary)
                        : colorScheme.surfaceContainerHighest,
                  ),
                );
              }),
            )
                .animate(target: _isError ? 1 : 0)
                .shakeX(duration: 500.ms, hz: 4, amount: 20),
            if (_isError)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child:
                    Text("Incorrect PIN", style: TextStyle(color: Colors.red)),
              ).animate().fadeIn().slideY(begin: -0.5),
            const Spacer(),
            Container(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey("1"),
                      _buildKey("2"),
                      _buildKey("3"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey("4"),
                      _buildKey("5"),
                      _buildKey("6"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey("7"),
                      _buildKey("8"),
                      _buildKey("9"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _canCheckBiometrics
                          ? InkWell(
                              onTap: _authenticate,
                              borderRadius: BorderRadius.circular(40),
                              child: Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                child: Icon(Icons.fingerprint,
                                    size: 36, color: colorScheme.primary),
                              ),
                            )
                          : const SizedBox(width: 80),
                      _buildKey("0"),
                      InkWell(
                        onTap: _onDelete,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          child: Icon(Icons.backspace_outlined,
                              size: 28, color: colorScheme.onSurface),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ).animate().slideY(
                begin: 0.3,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuint),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String val) {
    return InkWell(
      onTap: () => _onDigitPress(val),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          val,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
