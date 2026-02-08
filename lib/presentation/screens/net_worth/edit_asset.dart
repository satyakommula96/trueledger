import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

class EditAssetScreen extends ConsumerStatefulWidget {
  final Asset asset;
  const EditAssetScreen({super.key, required this.asset});

  @override
  ConsumerState<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends ConsumerState<EditAssetScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController amountCtrl;
  late TextEditingController typeCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.asset.name);
    amountCtrl = TextEditingController(text: widget.asset.amount.toString());
    typeCtrl = TextEditingController(text: widget.asset.type);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT ASSET"),
        actions: [
          IconButton(
            onPressed: _confirmDelete,
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            _buildField("Asset Name", nameCtrl, Icons.description),
            _buildField("Value", amountCtrl, Icons.attach_money,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField("Type", typeCtrl, Icons.category),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("UPDATE ASSET",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool isNumber = false, String? prefix}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          prefixText: prefix != null ? "$prefix " : null,
          filled: true,
          fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<void> _update() async {
    final name = nameCtrl.text.trim();
    final amountText = amountCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Asset Name cannot be empty")),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a valid non-negative value")),
      );
      return;
    }

    final repo = ref.read(financialRepositoryProvider);
    final updates = {
      'name': name,
      'amount': amount,
      'type': typeCtrl.text,
    };

    // 'Investment' maps to 'investments' table in FinancialRepositoryImpl
    await repo.updateEntry('Investment', widget.asset.id, updates);

    if (mounted) {
      ref.invalidate(dashboardProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Asset Updated"), behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Asset?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(financialRepositoryProvider);
      await repo.deleteItem('investments', widget.asset.id);
      if (mounted) {
        ref.invalidate(dashboardProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Asset Deleted"),
            behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    }
  }
}
