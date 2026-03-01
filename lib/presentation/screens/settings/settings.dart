import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

import 'package:trueledger/main.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/user_provider.dart';
import 'package:trueledger/core/providers/version_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/core/theme/theme.dart';

import 'package:trueledger/presentation/screens/settings/trust_center.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';
import 'package:trueledger/presentation/screens/settings/personalization_settings.dart';
import 'package:trueledger/presentation/screens/settings/data_export_screen.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/insights_provider.dart';
import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/domain/services/biometric_service.dart';
import 'package:trueledger/core/providers/locale_provider.dart';
import 'package:trueledger/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showNamePicker(
      BuildContext context, WidgetRef ref, AppColors semantic) async {
    final currentName = ref.read(userProvider);
    final controller = TextEditingController(text: currentName);
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text(l10n.setUserName,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: semantic.text)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: semantic.text, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: l10n.enterYourName,
              hintStyle: TextStyle(
                  color: semantic.secondaryText.withValues(alpha: 0.5)),
              labelText: l10n.nameLabel,
              labelStyle: TextStyle(
                  color: semantic.secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2),
              filled: true,
              fillColor: semantic.surfaceCombined.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: semantic.divider, width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: semantic.divider, width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: semantic.primary, width: 2)),
            ),
            maxLength: 20,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel,
                  style: TextStyle(
                      color: semantic.secondaryText,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref
                      .read(userProvider.notifier)
                      .setName(controller.text.trim());
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: semantic.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(l10n.save,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showThemePicker(
      BuildContext context, WidgetRef ref, AppColors semantic) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.read(sharedPreferencesProvider);
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text(l10n.selectTheme,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: semantic.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeTile(
                  l10n.systemDefault,
                  Icons.settings_suggest_rounded,
                  ThemeMode.system,
                  ref,
                  prefs,
                  semantic,
                  context),
              const SizedBox(height: 8),
              _buildThemeTile(l10n.lightMode, Icons.light_mode_rounded,
                  ThemeMode.light, ref, prefs, semantic, context),
              const SizedBox(height: 8),
              _buildThemeTile(l10n.darkMode, Icons.dark_mode_rounded,
                  ThemeMode.dark, ref, prefs, semantic, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTile(String label, IconData icon, ThemeMode mode,
      WidgetRef ref, dynamic prefs, AppColors semantic, BuildContext context) {
    final isSelected = themeNotifier.value == mode;
    return InkWell(
      onTap: () {
        themeNotifier.value = mode;
        prefs.setString('theme_mode', mode.toString().split('.').last);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? semantic.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? semantic.primary.withValues(alpha: 0.3)
                  : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? semantic.primary : semantic.secondaryText),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label.toUpperCase(),
                  style: TextStyle(
                      color: isSelected ? semantic.primary : semantic.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5)),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: semantic.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showCurrencyPicker(
      BuildContext context, AppColors semantic) async {
    String searchQuery = "";
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: semantic.surfaceCombined,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: semantic.divider, width: 1.5),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: semantic.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Text(
                      l10n.selectCurrency,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: semantic.text,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    _buildIconButton(
                        Icons.close, () => Navigator.pop(context), semantic),
                  ],
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    final currentCurrency =
                        CurrencyFormatter.currencyNotifier.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: TextField(
                            style: TextStyle(
                                color: semantic.text,
                                fontWeight: FontWeight.w900),
                            decoration: InputDecoration(
                              hintText: l10n.searchCurrency,
                              hintStyle: TextStyle(
                                  color: semantic.secondaryText
                                      .withValues(alpha: 0.5)),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: semantic.secondaryText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: semantic.divider, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: semantic.divider, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: semantic.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: semantic.surfaceCombined
                                  .withValues(alpha: 0.3),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                searchQuery = val.toLowerCase();
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView(
                            controller: controller,
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            children: CurrencyFormatter.currencies.entries
                                .where((e) =>
                                    e.key.toLowerCase().contains(searchQuery) ||
                                    _getCurrencyName(context, e.key)
                                        .toLowerCase()
                                        .contains(searchQuery))
                                .map((entry) {
                              final isSelected = currentCurrency == entry.key;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    CurrencyFormatter.setCurrency(entry.key);
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? semantic.primary
                                              .withValues(alpha: 0.1)
                                          : semantic.surfaceCombined
                                              .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: isSelected
                                              ? semantic.primary
                                                  .withValues(alpha: 0.3)
                                              : semantic.divider,
                                          width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? semantic.primary
                                                : semantic.divider,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            entry.value,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: TextStyle(
                                                    color: semantic.text,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                _getCurrencyName(
                                                    context, entry.key),
                                                style: TextStyle(
                                                    color:
                                                        semantic.secondaryText,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check_circle_rounded,
                                              color: semantic.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, VoidCallback onTap, AppColors semantic) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: semantic.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: semantic.text),
      ),
    );
  }

  String _getCurrencyName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'INR':
        return l10n.inrRupeeName;
      case 'USD':
        return l10n.usdDollarName;
      case 'EUR':
        return l10n.eurEuroName;
      case 'GBP':
        return l10n.gbpPoundName;
      case 'JPY':
        return l10n.jpyYenName;
      case 'CAD':
        return l10n.cadDollarName;
      case 'AUD':
        return l10n.audDollarName;
      case 'SGD':
        return l10n.sgdDollarName;
      case 'AED':
        return l10n.aedDirhamName;
      case 'SAR':
        return l10n.sarRiyalName;
      case 'CNY':
        return l10n.cnyYuanName;
      case 'KRW':
        return l10n.krwWonName;
      case 'BRL':
        return l10n.brlRealName;
      case 'MXN':
        return l10n.mxnPesoName;
      default:
        return '';
    }
  }

  Future<void> _seedData(
      BuildContext context, WidgetRef ref, AppColors semantic) async {
    final l10n = AppLocalizations.of(context)!;
    final option = await showDialog<String>(
        context: context,
        builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: SimpleDialog(
                backgroundColor:
                    semantic.surfaceCombined.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: BorderSide(color: semantic.divider, width: 1.5)),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.selectDataScenario,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.2,
                            color: semantic.text)),
                    const SizedBox(height: 8),
                    Text(
                      l10n.fictionalDataDemoOnly,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: semantic.secondaryText),
                    ),
                  ],
                ),
                children: [
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, 'roadmap'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: semantic.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: semantic.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: semantic.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.star_rounded,
                                  color: semantic.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.completeDemo,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: semantic.text)),
                                  Text(l10n.allFeaturesStreaks,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: semantic.secondaryText)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));

    if (option != null) {
      final repo = ref.read(financialRepositoryProvider);

      try {
        if (option == 'roadmap') {
          await repo.seedRoadmapData();
        }

        if (context.mounted) {
          final scenarioName =
              option == 'roadmap' ? l10n.completeDemo : option.toUpperCase();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.generatedScenarioData(scenarioName)),
            backgroundColor: semantic.primary,
          ));
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint("Data seeding failed: $e");
      }
    }
  }

  Future<void> _resetData(
      BuildContext context, WidgetRef ref, AppColors semantic) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AlertDialog(
                backgroundColor:
                    semantic.surfaceCombined.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: BorderSide(color: semantic.divider, width: 1.5)),
                title: Text(l10n.deleteAllData,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.2,
                        color: semantic.overspent)),
                content: Text(
                  l10n.wipeAllDataWarning,
                  style: TextStyle(
                      color: semantic.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel,
                          style: TextStyle(
                              color: semantic.secondaryText,
                              fontWeight: FontWeight.w900,
                              fontSize: 12))),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: semantic.overspent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text(l10n.deleteAll,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 12))),
                ],
              ),
            ));

    if (confirmed == true) {
      try {
        final repo = ref.read(financialRepositoryProvider);
        final notificationService = ref.read(notificationServiceProvider);

        await repo.clearData();
        ref.read(intelligenceServiceProvider).resetAll();
        await notificationService.cancelAllNotifications();

        ref.invalidate(dashboardProvider);
        ref.invalidate(insightsProvider);
        ref.invalidate(analysisProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("ALL DATA HAS BEEN RESET"),
            backgroundColor: semantic.overspent,
          ));
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint("Reset failed: $e");
      }
    }
  }

  String _generateRecoveryKey() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return List.generate(14, (index) {
      if (index == 4 || index == 9) return '-';
      return chars[rnd.nextInt(chars.length)];
    }).join();
  }

  Future<void> _showRecoveryKeyDialog(
      BuildContext context, String key, AppColors semantic) async {
    bool checked = false;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                backgroundColor:
                    semantic.surfaceCombined.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: BorderSide(color: semantic.divider, width: 1.5)),
                title: Text("RECOVERY KEY GENERATED",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.2,
                        color: semantic.text)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SAVE THIS KEY SECURELY.\n\nIf you forget your PIN, this is the ONLY way to recover your data without resetting.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: semantic.secondaryText),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: key));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("COPIED TO CLIPBOARD"),
                                duration: Duration(seconds: 1)));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              color: semantic.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      semantic.primary.withValues(alpha: 0.3))),
                          child: Text(key,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: semantic.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2))),
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: semantic.primary,
                        title: Text("I HAVE SAFELY SAVED THIS KEY",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: semantic.text,
                                letterSpacing: 0.5)),
                        value: checked,
                        onChanged: (v) => setState(() => checked = v ?? false))
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        SharePlus.instance.share(ShareParams(
                          text:
                              "TrueLedger Recovery Key: $key\n\nKEEP THIS KEY SAFE. If you lose this, you lose access to your encrypted data.",
                        ));
                      },
                      child: Text("SHARE SECURELY",
                          style: TextStyle(
                              color: semantic.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12))),
                  ElevatedButton(
                      onPressed: checked ? () => Navigator.pop(ctx) : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: semantic.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text("DONE",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 12))),
                ],
              );
            }),
          );
        });
  }

  Future<bool> _verifyPin(
      BuildContext context, String correctPin, AppColors semantic) async {
    String input = "";
    return await showDialog<bool>(
            context: context,
            builder: (ctx) {
              bool obscure = true;
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      backgroundColor:
                          semantic.surfaceCombined.withValues(alpha: 0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                          side:
                              BorderSide(color: semantic.divider, width: 1.5)),
                      title: Text("VERIFY PIN",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.5,
                              color: semantic.text)),
                      content: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        obscureText: obscure,
                        maxLength: correctPin.length,
                        style: TextStyle(
                            color: semantic.text, fontWeight: FontWeight.w900),
                        onChanged: (v) => input = v,
                        decoration: InputDecoration(
                          hintText: "Enter current PIN",
                          filled: true,
                          fillColor:
                              semantic.surfaceCombined.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: semantic.divider)),
                          suffixIcon: IconButton(
                            icon: Icon(
                                obscure
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: semantic.secondaryText),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text("CANCEL",
                                style: TextStyle(
                                    color: semantic.secondaryText,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12))),
                        ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(ctx, input == correctPin),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: semantic.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: const Text("VERIFY",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12))),
                      ],
                    );
                  },
                ),
              );
            }) ??
        false;
  }

  Future<void> _setupPin(BuildContext context, AppColors semantic) async {
    const storage = FlutterSecureStorage();
    final currentPin = await storage.read(key: 'app_pin');

    if (!context.mounted) return;

    if (currentPin != null) {
      await showDialog(
          context: context,
          builder: (ctx) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AlertDialog(
                  backgroundColor:
                      semantic.surfaceCombined.withValues(alpha: 0.9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: BorderSide(color: semantic.divider, width: 1.5)),
                  title: Text("APP SECURITY",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.5,
                          color: semantic.text)),
                  content: Text("Manage your security settings.",
                      style: TextStyle(
                          color: semantic.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text("CANCEL",
                            style: TextStyle(
                                color: semantic.secondaryText,
                                fontWeight: FontWeight.w900,
                                fontSize: 12))),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          bool verified =
                              await _verifyPin(context, currentPin, semantic);
                          if (verified && context.mounted) {
                            final key =
                                await storage.read(key: 'recovery_key') ??
                                    "No key found (Legacy)";
                            if (context.mounted) {
                              _showRecoveryKeyDialog(context, key, semantic);
                            }
                          }
                        },
                        child: Text("VIEW RECOVERY KEY",
                            style: TextStyle(
                                color: semantic.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 12))),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          bool verified =
                              await _verifyPin(context, currentPin, semantic);
                          if (!verified) return;
                          if (!context.mounted) return;

                          final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 12, sigmaY: 12),
                                    child: AlertDialog(
                                        backgroundColor: semantic
                                            .surfaceCombined
                                            .withValues(alpha: 0.9),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(32),
                                            side: BorderSide(
                                                color: semantic.divider,
                                                width: 1.5)),
                                        title: Text("REMOVE SECURITY PIN?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                                color: semantic.overspent)),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, false),
                                              child: Text("CANCEL",
                                                  style: TextStyle(
                                                      color: semantic
                                                          .secondaryText,
                                                      fontWeight:
                                                          FontWeight.w900))),
                                          ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, true),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      semantic.overspent),
                                              child: const Text("REMOVE",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900))),
                                        ]),
                                  ));

                          if (confirm == true) {
                            await storage.delete(key: 'app_pin');
                            await storage.delete(key: 'recovery_key');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text("PIN REMOVED"),
                                backgroundColor: semantic.overspent,
                              ));
                            }
                          }
                        },
                        child: Text("REMOVE PIN",
                            style: TextStyle(
                                color: semantic.overspent,
                                fontWeight: FontWeight.w900,
                                fontSize: 12))),
                  ],
                ),
              ));
    } else {
      String newPin = "";
      int targetLength = 4;

      await showDialog(
          context: context,
          builder: (ctx) {
            bool obscure = true;
            return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                      backgroundColor:
                          semantic.surfaceCombined.withValues(alpha: 0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                          side:
                              BorderSide(color: semantic.divider, width: 1.5)),
                      title: Text("SET $targetLength-DIGIT PIN",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.5,
                              color: semantic.text)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            maxLength: targetLength,
                            obscureText: obscure,
                            style: TextStyle(
                                color: semantic.text,
                                fontWeight: FontWeight.w900),
                            onChanged: (val) => newPin = val,
                            decoration: InputDecoration(
                              hintText: "Enter PIN",
                              hintStyle: TextStyle(
                                  color: semantic.secondaryText
                                      .withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: semantic.surfaceCombined
                                  .withValues(alpha: 0.3),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: semantic.divider)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    obscure
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: semantic.secondaryText),
                                onPressed: () =>
                                    setState(() => obscure = !obscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () async {
                              final selected = await showDialog<int>(
                                context: context,
                                builder: (context) => BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: SimpleDialog(
                                    backgroundColor: semantic.surfaceCombined
                                        .withValues(alpha: 0.95),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        side: BorderSide(
                                            color: semantic.divider,
                                            width: 1.5)),
                                    title: Text("Passcode Options",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: semantic.text)),
                                    children: [
                                      SimpleDialogOption(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        onPressed: () =>
                                            Navigator.pop(context, 4),
                                        child: Text(
                                          "4-Digit Numeric Code",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: semantic.primary),
                                        ),
                                      ),
                                      Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: semantic.divider),
                                      SimpleDialogOption(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        onPressed: () =>
                                            Navigator.pop(context, 6),
                                        child: Text(
                                          "6-Digit Numeric Code",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: semantic.primary),
                                        ),
                                      ),
                                      Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: semantic.divider),
                                      SimpleDialogOption(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "Cancel",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: semantic.overspent),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (selected != null) {
                                setState(() {
                                  targetLength = selected;
                                  newPin = "";
                                });
                              }
                            },
                            child: Text("Passcode Options",
                                style: TextStyle(
                                    color: semantic.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("CANCEL",
                                style: TextStyle(
                                    color: semantic.secondaryText,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12))),
                        ElevatedButton(
                            onPressed: () async {
                              if (newPin.length == targetLength) {
                                final key = _generateRecoveryKey();
                                await storage.write(
                                    key: 'app_pin', value: newPin);
                                await storage.write(
                                    key: 'recovery_key', value: key);
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  await _showRecoveryKeyDialog(
                                      context, key, semantic);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          const Text("PIN ENABLED SECURELY"),
                                      backgroundColor: semantic.primary,
                                    ));
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: semantic.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: const Text("SAVE",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12))),
                      ]);
                }));
          });
    }
  }

  Future<void> _showLanguagePicker(
      BuildContext context, WidgetRef ref, AppColors semantic) async {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);

    await showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text(l10n.language.toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: semantic.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageTile(
                  "English", "en", currentLocale, ref, semantic, context),
              const SizedBox(height: 8),
              _buildLanguageTile("Telugu (తెలుగు)", "te", currentLocale, ref,
                  semantic, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String label, String code, Locale current,
      WidgetRef ref, AppColors semantic, BuildContext context) {
    final isSelected = current.languageCode == code;
    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(Locale(code, ''));
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? semantic.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? semantic.primary.withValues(alpha: 0.3)
                  : Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label.toUpperCase(),
                  style: TextStyle(
                      color: isSelected ? semantic.primary : semantic.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5)),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: semantic.primary, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final userName = ref.watch(userProvider);
    final l10n = AppLocalizations.of(context)!;
    final biometricService = ref.watch(biometricServiceProvider);
    final currentLocale = ref.watch(localeProvider);

    return AppleScaffold(
      title: l10n.settings,
      subtitle: "Preferences & Security",
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildOption(
                context,
                l10n.nameLabel,
                userName,
                Icons.person_rounded,
                semantic.primary,
                () => _showNamePicker(context, ref, semantic),
                semantic,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.trustAndControl, semantic),
              const SizedBox(height: 8),
              _buildOption(
                context,
                l10n.trustCenter,
                l10n.trustCenterSubtitle,
                Icons.verified_user_rounded,
                semantic.success,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TrustCenterScreen())),
                semantic,
              ),
              const SizedBox(height: 12),
              _buildOption(
                context,
                l10n.appSecurity,
                l10n.appSecuritySubtitle,
                Icons.lock_rounded,
                semantic.overspent,
                () => _setupPin(context, semantic),
                semantic,
              ),
              const SizedBox(height: 12),
              FutureBuilder<bool>(
                future: biometricService.canCheckBiometrics(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return _buildOption(
                      context,
                      l10n.biometrics,
                      l10n.enableBiometrics,
                      Icons.fingerprint_rounded,
                      Colors.blueGrey,
                      () async {
                        final enabled = biometricService.isBiometricEnabled;
                        await biometricService.setBiometricEnabled(!enabled);
                        ref.invalidate(biometricServiceProvider);
                      },
                      semantic,
                      trailing: SizedBox(
                        height: 24,
                        child: Switch(
                          value: biometricService.isBiometricEnabled,
                          onChanged: (val) async {
                            await biometricService.setBiometricEnabled(val);
                            ref.invalidate(biometricServiceProvider);
                          },
                          activeThumbColor: semantic.primary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.personalization, semantic),
              const SizedBox(height: 8),
              _buildOption(
                context,
                l10n.appearance,
                l10n.appearanceSubtitle,
                Icons.dark_mode_rounded,
                semantic.primary,
                () => _showThemePicker(context, ref, semantic),
                semantic,
              ),
              const SizedBox(height: 12),
              _buildOption(
                context,
                l10n.language,
                currentLocale.languageCode == 'en'
                    ? 'English'
                    : 'తెలుగు (Telugu)',
                Icons.translate_rounded,
                Colors.deepPurple,
                () => _showLanguagePicker(context, ref, semantic),
                semantic,
              ),
              const SizedBox(height: 12),
              _buildOption(
                context,
                l10n.personalizationHeader,
                l10n.personalizationSubtitle,
                Icons.auto_awesome_rounded,
                Colors.pinkAccent,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PersonalizationSettingsScreen())),
                semantic,
              ),
              const SizedBox(height: 12),
              _buildOption(
                context,
                l10n.currency,
                "${l10n.currencySubtitle} (${CurrencyFormatter.symbol})",
                Icons.payments_rounded,
                Colors.teal,
                () => _showCurrencyPicker(context, semantic),
                semantic,
              ),
              const SizedBox(height: 12),
              _buildOption(
                context,
                l10n.manageCategories,
                l10n.manageCategoriesSubtitle,
                Icons.category_rounded,
                Colors.orange,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageCategoriesScreen())),
                semantic,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.dataTools, semantic),
              const SizedBox(height: 8),
              _buildOption(
                context,
                l10n.dataExport,
                l10n.dataExportSubtitle,
                Icons.ios_share_rounded,
                semantic.primary,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DataExportScreen())),
                semantic,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                _buildOption(
                  context,
                  l10n.dataSeeding,
                  l10n.seedDataSubtitle,
                  Icons.science_rounded,
                  Colors.amber,
                  () => _seedData(context, ref, semantic),
                  semantic,
                ),
              ],
              const SizedBox(height: 12),
              _buildOption(
                context,
                l10n.resetAllData,
                l10n.resetApplicationSubtitle,
                Icons.refresh_rounded,
                semantic.overspent,
                () => _resetData(context, ref, semantic),
                semantic,
              ),
              const SizedBox(height: 48),
              _buildFooter(ref, semantic, context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, AppColors semantic) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: semantic.secondaryText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFooter(WidgetRef ref, AppColors semantic, BuildContext context) {
    return Column(
      children: [
        Text(
          "TRUELEDGER",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 4,
            color: semantic.secondaryText.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 8),
        ref.watch(appVersionProvider).when(
              data: (version) => Text("Version $version",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: semantic.secondaryText.withValues(alpha: 0.4))),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => Text("Version 1.2.0",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: semantic.secondaryText.withValues(alpha: 0.4))),
            ),
        const SizedBox(height: 40),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 12,
          children: [
            _buildFooterLink(
                "Trust Center",
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TrustCenterScreen())),
                semantic),
            _buildFooterLink(
                "Privacy Policy",
                () => launchUrl(Uri.parse(
                    "https://satyakommula96.github.io/trueledger/privacy/")),
                semantic),
            _buildFooterLink("Licenses", () {
              showLicensePage(
                context: context,
                applicationName: "TrueLedger",
                applicationVersion: ref.read(appVersionProvider).value ?? "",
              );
            }, semantic),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          "TrueLedger is privacy-first. All your financial data stays on your device and is never uploaded to any cloud.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: semantic.secondaryText.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildFooterLink(String text, VoidCallback onTap, AppColors semantic) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: semantic.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String sub,
      IconData icon, Color color, VoidCallback onTap, AppColors semantic,
      {Widget? trailing}) {
    return AppleGlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: semantic.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: semantic.secondaryText),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.chevron_right_rounded,
                        color: semantic.divider, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
