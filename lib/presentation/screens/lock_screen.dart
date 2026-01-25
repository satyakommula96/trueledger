import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truecash/presentation/screens/dashboard.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';
import 'package:truecash/presentation/providers/dashboard_provider.dart';
import 'package:truecash/presentation/providers/analysis_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final int? expectedPinLength;
  const LockScreen({super.key, this.expectedPinLength});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = "";
  bool _isError = false;
  late int _pinLength;

  @override
  void initState() {
    super.initState();
    _pinLength = widget.expectedPinLength ?? 4;
    if (widget.expectedPinLength == null) {
      _loadPinLength();
    }
  }

  Future<void> _loadPinLength() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('app_pin');
    if (stored != null && stored.length == 6) {
      if (mounted) setState(() => _pinLength = 6);
    }
  }

  void _onDigitPress(String digit) async {
    setState(() {
      _isError = false;
      if (_pin.length < _pinLength) {
        _pin += digit;
      }
    });

    if (_pin.length == _pinLength) {
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

  Future<void> _onForgotPin() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Reset Application?"),
              content: const Text(
                  "Since you forgot your PIN, you must reset the application to regain access. \n\nTHIS WILL DELETE ALL FINANCIAL DATA.\n\nAre you sure you want to proceed?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("CANCEL")),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("RESET EVERYTHING",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold))),
              ],
            ));

    if (confirmed == true) {
      // 1. Wipe Data
      final repo = ref.read(financialRepositoryProvider);
      await repo.clearData();

      // 2. Wipe Prefs (PIN)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Refresh Providers (just in case functionality remains)
      ref.invalidate(dashboardProvider);
      ref.invalidate(analysisProvider);

      // 4. Navigate
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Dashboard()));
      }
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
              children: List.generate(_pinLength, (index) {
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
              padding: const EdgeInsets.only(bottom: 20),
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
                      const SizedBox(width: 80),
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
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: _onForgotPin,
                    child: Text("Forgot PIN?",
                        style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold)),
                  )
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
