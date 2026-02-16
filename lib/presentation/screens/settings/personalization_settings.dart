import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/domain/services/personalization_service.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';

class PersonalizationSettingsScreen extends ConsumerStatefulWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  ConsumerState<PersonalizationSettingsScreen> createState() =>
      _PersonalizationSettingsScreenState();
}

class _PersonalizationSettingsScreenState
    extends ConsumerState<PersonalizationSettingsScreen> {
  late PersonalizationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(personalizationServiceProvider).getSettings();
  }

  void _updateSettings(PersonalizationSettings newSettings) {
    setState(() => _settings = newSettings);
    ref.read(personalizationServiceProvider).updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personalization.toUpperCase()),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 48 + MediaQuery.of(context).padding.bottom),
        children: [
          _buildInfoCard(semantic, l10n),
          const SizedBox(height: 32),
          _buildMainToggle(semantic, l10n),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.adaptiveBehavior, semantic),
          const SizedBox(height: 12),
          _buildGlassToggle(
            title: l10n.rememberLastUsed,
            subtitle: l10n.rememberLastUsedDesc,
            value: _settings.rememberLastUsed,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(rememberLastUsed: v)),
            semantic: semantic,
          ),
          const SizedBox(height: 16),
          _buildGlassToggle(
            title: l10n.timeOfDaySuggestions,
            subtitle: l10n.timeOfDaySuggestionsDesc,
            value: _settings.timeOfDaySuggestions,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(timeOfDaySuggestions: v)),
            semantic: semantic,
          ),
          const SizedBox(height: 16),
          _buildGlassToggle(
            title: l10n.shortcutSuggestions,
            subtitle: l10n.shortcutSuggestionsDesc,
            value: _settings.shortcutSuggestions,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(shortcutSuggestions: v)),
            semantic: semantic,
          ),
          const SizedBox(height: 16),
          _buildGlassToggle(
            title: l10n.baselineReflections,
            subtitle: l10n.baselineReflectionsDesc,
            value: _settings.baselineReflections,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(baselineReflections: v)),
            semantic: semantic,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.salaryCycle, semantic),
          const SizedBox(height: 12),
          _buildGlassAction(
            title: l10n.usualPayDay,
            subtitle: _settings.payDay != null
                ? l10n.dayNum(_settings.payDay!)
                : l10n.notSet,
            icon: Icons.calendar_today_rounded,
            onTap: () => _showPayDayDialog(context, semantic, l10n),
            semantic: semantic,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.quickPresets, semantic),
          const SizedBox(height: 12),
          _buildPresetsList(context, semantic, l10n),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.reminders, semantic),
          const SizedBox(height: 12),
          _buildGlassAction(
            title: l10n.reminderTime,
            subtitle: _settings.preferredReminderTime ?? l10n.off,
            icon: Icons.access_time_rounded,
            onTap: () => _showReminderTimePicker(context, semantic),
            onLongPress: () {
              _updateSettings(_settings.copyWith(preferredReminderTime: null));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l10n.reminderTimeCleared),
                    backgroundColor: semantic.primary),
              );
            },
            semantic: semantic,
          ),
          const SizedBox(height: 48),
          _buildDangerZone(context, semantic, l10n),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppColors semantic, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: semantic.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: semantic.primary.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: semantic.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Icon(Icons.security_rounded, color: semantic.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.privateAndLocal,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: semantic.text,
                        letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(
                  l10n.privateAndLocalDesc,
                  style: TextStyle(
                      fontSize: 13,
                      color: semantic.secondaryText,
                      fontWeight: FontWeight.w700,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slide(
          begin: const Offset(0, 0.05),
          end: const Offset(0, 0),
          curve: Curves.easeOutQuart,
        );
  }

  Widget _buildMainToggle(AppColors semantic, AppLocalizations l10n) {
    final enabled = _settings.personalizationEnabled;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: enabled
            ? semantic.primary.withValues(alpha: 0.05)
            : semantic.surfaceCombined.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: enabled
                ? semantic.primary.withValues(alpha: 0.3)
                : semantic.divider,
            width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _updateSettings(
              _settings.copyWith(personalizationEnabled: !enabled)),
          borderRadius: BorderRadius.circular(32),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dynamicAdaptation,
                        style: TextStyle(
                            color: enabled ? semantic.primary : semantic.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Text(
                      l10n.dynamicAdaptationDesc,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: semantic.secondaryText),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeTrackColor: semantic.primary,
                onChanged: (v) => _updateSettings(
                    _settings.copyWith(personalizationEnabled: v)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors semantic) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: semantic.secondaryText,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildGlassToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColors semantic,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: semantic.text,
                              letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: semantic.secondaryText,
                              height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: value,
                  activeTrackColor: semantic.primary,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    required AppColors semantic,
  }) {
    return HoverWrapper(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: semantic.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: semantic.primary, size: 20),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: semantic.text,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: semantic.primary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: semantic.divider, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsList(
      BuildContext context, AppColors semantic, AppLocalizations l10n) {
    final presets = ref.watch(personalizationServiceProvider).getPresets();

    return Column(
      children: [
        if (presets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l10n.noPresetsYet,
                style: TextStyle(
                    color: semantic.secondaryText.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
          ),
        ...presets.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: semantic.surfaceCombined.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: semantic.divider, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: semantic.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                          p.title.isNotEmpty ? p.title[0].toUpperCase() : "?",
                          style: TextStyle(
                              color: semantic.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title.toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: semantic.text)),
                          Text(
                              "${CurrencyFormatter.format(p.amount, compact: false)} · ${p.category}",
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: semantic.secondaryText)),
                        ],
                      ),
                    ),
                    _buildIconButton(Icons.delete_outline_rounded, () {
                      ref
                          .read(personalizationServiceProvider)
                          .removePreset(p.id);
                      setState(() {});
                    }, semantic, color: semantic.overspent),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showAddPresetDialog(context, semantic, l10n),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                  color: semantic.primary.withValues(alpha: 0.3), width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: semantic.primary.withValues(alpha: 0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: semantic.primary, size: 20),
                const SizedBox(width: 8),
                Text(l10n.createNewPreset,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: semantic.primary,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, AppColors semantic,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? semantic.text).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color ?? semantic.text),
      ),
    );
  }

  Future<void> _showPayDayDialog(
      BuildContext context, AppColors semantic, AppLocalizations l10n) async {
    final val = await showDialog<int>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text(l10n.selectPayDay,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: semantic.text)),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isSelected = _settings.payDay == day;
                return InkWell(
                  onTap: () => Navigator.pop(context, day),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? semantic.primary
                          : semantic.divider.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text("$day",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color:
                                  isSelected ? Colors.white : semantic.text)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    if (val != null) {
      _updateSettings(_settings.copyWith(payDay: val));
    }
  }

  Future<void> _showReminderTimePicker(
      BuildContext context, AppColors semantic) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _settings.preferredReminderTime != null
          ? TimeOfDay(
              hour: int.parse(_settings.preferredReminderTime!.split(':')[0]),
              minute: int.parse(_settings.preferredReminderTime!.split(':')[1]))
          : const TimeOfDay(hour: 21, minute: 0),
    );
    if (time != null) {
      _updateSettings(_settings.copyWith(
        preferredReminderTime:
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
      ));
    }
  }

  Future<void> _showAddPresetDialog(
      BuildContext context, AppColors semantic, AppLocalizations l10n) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? category;

    await showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text(l10n.createPreset,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: semantic.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(
                    color: semantic.text, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  labelText: l10n.presetLabel,
                  labelStyle: TextStyle(
                      color: semantic.secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1),
                  filled: true,
                  fillColor: semantic.surfaceCombined.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.all(18),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: semantic.divider, width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: semantic.primary, width: 2)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                style: TextStyle(
                    color: semantic.text, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  labelStyle: TextStyle(
                      color: semantic.secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1),
                  filled: true,
                  fillColor: semantic.surfaceCombined.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.all(18),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: semantic.divider, width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: semantic.primary, width: 2)),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              Consumer(builder: (context, ref, _) {
                final categories = ref.watch(categoriesProvider('Variable'));
                return categories.when(
                  data: (list) => DropdownButtonFormField<String>(
                    isExpanded: true,
                    dropdownColor: semantic.surfaceCombined,
                    style: TextStyle(
                        color: semantic.text, fontWeight: FontWeight.w900),
                    decoration: InputDecoration(
                      labelText: l10n.category,
                      labelStyle: TextStyle(
                          color: semantic.secondaryText,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
                      filled: true,
                      fillColor:
                          semantic.surfaceCombined.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: semantic.divider)),
                    ),
                    items: list
                        .map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(
                              c.name.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            )))
                        .toList(),
                    onChanged: (v) => category = v,
                  ),
                  loading: () => Center(
                      child:
                          CircularProgressIndicator(color: semantic.primary)),
                  error: (e, _) => Text("Error: $e"),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("CANCEL",
                    style: TextStyle(
                        color: semantic.secondaryText,
                        fontWeight: FontWeight.w900,
                        fontSize: 12))),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    category != null) {
                  final preset = QuickAddPreset(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    category: category!,
                  );
                  ref.read(personalizationServiceProvider).addPreset(preset);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: semantic.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("SAVE",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(
      BuildContext context, AppColors semantic, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.trustAndControl, semantic),
        const SizedBox(height: 12),
        HoverWrapper(
          onTap: () async {
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
                  title: Text(l10n.resetPersonalization,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: semantic.overspent)),
                  content: Text(
                    l10n.resetPersonalizationDesc,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel.toUpperCase(),
                            style: TextStyle(
                                color: semantic.secondaryText,
                                fontWeight: FontWeight.w900))),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: semantic.overspent),
                      child: Text(l10n.reset,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            );

            if (confirmed == true) {
              await ref
                  .read(personalizationServiceProvider)
                  .resetPersonalization();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.personalizationResetCompleted),
                  backgroundColor: semantic.overspent,
                ),
              );
              setState(() {
                _settings =
                    ref.read(personalizationServiceProvider).getSettings();
              });
            }
          },
          borderRadius: 24,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: semantic.overspent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: semantic.overspent.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: semantic.overspent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("RESET PERSONALIZATION",
                          style: TextStyle(
                              color: semantic.overspent,
                              fontWeight: FontWeight.w900,
                              fontSize: 13)),
                      const SizedBox(height: 2),
                      Text("Clear all learned patterns and adaptive defaults.",
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
      ],
    );
  }
}
