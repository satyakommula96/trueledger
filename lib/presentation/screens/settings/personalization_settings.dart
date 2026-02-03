import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/services/personalization_service.dart';
import 'package:trueledger/core/theme/theme.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Personalization",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(semantic),
          const SizedBox(height: 32),
          _buildToggle(
            title: "Enable Personalization",
            subtitle:
                "Allow the app to learn from your patterns to provide suggestions. All data stays on device.",
            value: _settings.personalizationEnabled,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(personalizationEnabled: v)),
          ),
          const Divider(height: 32),
          _buildSectionHeader("ADAPTIVE BEHAVIOR"),
          const SizedBox(height: 12),
          _buildToggle(
            title: "Remember last-used values",
            subtitle:
                "Automatically pre-fill category and payment method based on your last entry.",
            value: _settings.rememberLastUsed,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(rememberLastUsed: v)),
          ),
          _buildToggle(
            title: "Time-of-day suggestions",
            subtitle:
                "Suggest categories based on the time of day and your repetitions.",
            value: _settings.timeOfDaySuggestions,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(timeOfDaySuggestions: v)),
          ),
          _buildToggle(
            title: "Shortcut suggestions",
            subtitle:
                "Prompt to create quick-add shortcuts for frequent transactions.",
            value: _settings.shortcutSuggestions,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(shortcutSuggestions: v)),
          ),
          _buildToggle(
            title: "Personal baseline reflections",
            subtitle:
                "Show comparisons against your local spending history (e.g. 'Higher than your usual Friday').",
            value: _settings.baselineReflections,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(baselineReflections: v)),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("SALARY CYCLE"),
          const SizedBox(height: 12),
          ListTile(
            title: const Text("Usual Pay Day",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            subtitle: Text(
                _settings.payDay != null
                    ? "Day ${_settings.payDay}"
                    : "Not set",
                style: TextStyle(color: semantic.secondaryText)),
            trailing: const Icon(Icons.calendar_today_rounded),
            onTap: () async {
              final val = await showDialog<int>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Select Pay Day"),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text("$day",
                                  style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : null)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
              if (val != null) {
                _updateSettings(_settings.copyWith(payDay: val));
              }
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader("USER-CREATED PRESETS"),
          const SizedBox(height: 12),
          _buildPresetsList(context, semantic),
          const SizedBox(height: 32),
          _buildSectionHeader("REMINDERS"),
          const SizedBox(height: 12),
          ListTile(
            title: const Text("Preferred Reminder Time",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            subtitle: Text(_settings.preferredReminderTime ?? "Off",
                style: TextStyle(color: semantic.secondaryText)),
            trailing: const Icon(Icons.access_time_rounded),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _settings.preferredReminderTime != null
                    ? TimeOfDay(
                        hour: int.parse(
                            _settings.preferredReminderTime!.split(':')[0]),
                        minute: int.parse(
                            _settings.preferredReminderTime!.split(':')[1]))
                    : const TimeOfDay(hour: 21, minute: 0),
              );
              if (time != null) {
                _updateSettings(_settings.copyWith(
                  preferredReminderTime:
                      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                ));
              }
            },
            onLongPress: () {
              _updateSettings(_settings.copyWith(preferredReminderTime: null));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Reminder time cleared")),
              );
            },
          ),
          const SizedBox(height: 48),
          _buildDangerZone(context, semantic),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppColors semantic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Private & Local",
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  "All personalization data is stored only on your device. We never sync or upload your behavior patterns.",
                  style: TextStyle(
                      fontSize: 13, color: semantic.secondaryText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).extension<AppColors>()!.secondaryText)),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPresetsList(BuildContext context, AppColors semantic) {
    final presets = ref.watch(personalizationServiceProvider).getPresets();

    return Column(
      children: [
        if (presets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text("No presets created yet.",
                style: TextStyle(color: semantic.secondaryText, fontSize: 13)),
          ),
        ...presets.map((p) => ListTile(
              title: Text(p.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text("₹${p.amount} · ${p.category}",
                  style:
                      TextStyle(fontSize: 12, color: semantic.secondaryText)),
              trailing: IconButton(
                icon:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: () {
                  ref.read(personalizationServiceProvider).removePreset(p.id);
                  setState(() {});
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            )),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showAddPresetDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text("CREATE NEW PRESET",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        ),
      ],
    );
  }

  Future<void> _showAddPresetDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? category;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Preset"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: "Label (e.g. Coffee)"),
              autofocus: true,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Consumer(builder: (context, ref, _) {
              final categories = ref.watch(categoriesProvider('Variable'));
              return categories.when(
                data: (list) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Category"),
                  items: list
                      .map((c) =>
                          DropdownMenuItem(value: c.name, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => category = v,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text("Error: $e"),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  amountController.text.isNotEmpty &&
                  category != null) {
                final preset = QuickAddPreset(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  amount: int.parse(amountController.text),
                  category: category!,
                );
                ref.read(personalizationServiceProvider).addPreset(preset);
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("TRUST & CONTROL"),
        const SizedBox(height: 12),
        ListTile(
          title: const Text("Reset Personalization",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          subtitle: const Text(
              "Clear all learned patterns and adaptive defaults. This will not delete your transactions."),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Reset Personalization?"),
                content: const Text(
                    "This will wipe all local learned behaviors. Your expense history will remain safe."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL")),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("RESET",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await ref
                  .read(personalizationServiceProvider)
                  .resetPersonalization();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Personalization reset completed.")),
              );
            }
          },
        ),
      ],
    );
  }
}
