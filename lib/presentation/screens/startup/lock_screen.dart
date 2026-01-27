import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/analysis_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final int? expectedPinLength;
  const LockScreen({super.key, this.expectedPinLength});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = "";
  bool _isError = false;
  bool _showPin = false;
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
    const storage = FlutterSecureStorage();
    final stored = await storage.read(key: 'app_pin');
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
      const storage = FlutterSecureStorage();
      final storedPin = await storage.read(key: 'app_pin');

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
    const storage = FlutterSecureStorage();
    final hasKey = await storage.containsKey(key: 'recovery_key');

    if (!mounted) return;

    if (!hasKey) {
      // If no key exists (legacy), just show reset dialog
      _confirmReset();
      return;
    }

    // Show Options
    showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Trouble logging in?",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.key, color: Colors.blue),
                        ),
                        title: const Text("Use Recovery Key"),
                        subtitle: const Text(
                            "Enter your saved recovery key to unlock"),
                        onTap: () {
                          Navigator.pop(ctx);
                          _promptRecoveryKey();
                        }),
                    const SizedBox(height: 8),
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete_forever,
                              color: Colors.red),
                        ),
                        title: const Text("Reset Application"),
                        subtitle: const Text("Wipe all data and start fresh"),
                        onTap: () {
                          Navigator.pop(ctx);
                          _confirmReset();
                        })
                  ],
                ),
              ),
            ));
  }

  Future<void> _promptRecoveryKey() async {
    const storage = FlutterSecureStorage();
    final storedKey = await storage.read(key: 'recovery_key');
    String inputKey = "";

    if (!mounted) return;

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text("Enter Recovery Key"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        "Enter the 14-character key you saved when setting up your PIN."),
                    const SizedBox(height: 16),
                    TextField(
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "XXXX-XXXX-XXXX",
                          labelText: "Recovery Key"),
                      onChanged: (v) => inputKey = v,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("CANCEL")),
                  FilledButton(
                      onPressed: () async {
                        if (inputKey.trim() == storedKey) {
                          Navigator.pop(ctx);

                          // Success: Remove auth and enter
                          await storage.delete(key: 'app_pin');
                          await storage.delete(key: 'recovery_key');

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Identity Verified. PIN has been removed.")));
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Dashboard()));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Invalid Recovery Key"),
                                  backgroundColor: Colors.red));
                        }
                      },
                      child: const Text("VERIFY"))
                ]));
  }

  Future<void> _confirmReset() async {
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

      // 2. Wipe Prefs (PIN - now in Secure Storage) & Prefs
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
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
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index < _pin.length
                          ? Colors.transparent
                          : colorScheme.onSurface.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    color: _showPin && index < _pin.length
                        ? Colors.transparent
                        : (index < _pin.length
                            ? (_isError ? Colors.red : colorScheme.primary)
                            : Colors.transparent),
                  ),
                  child: _showPin && index < _pin.length
                      ? Text(
                          _pin[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        )
                      : null,
                );
              }),
            )
                .animate(target: _isError ? 1 : 0)
                .shakeX(duration: 500.ms, hz: 4, amount: 20),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => setState(() => _showPin = !_showPin),
              icon: Icon(
                _showPin
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: _showPin
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
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
