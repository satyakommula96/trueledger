import 'package:flutter/material.dart';
import '../db/database.dart';

class EditCreditCardScreen extends StatefulWidget {
  final Map<String, dynamic> card;
  const EditCreditCardScreen({super.key, required this.card});

  @override
  State<EditCreditCardScreen> createState() => _EditCreditCardScreenState();
}

class _EditCreditCardScreenState extends State<EditCreditCardScreen> {
  late TextEditingController bankCtrl;
  late TextEditingController limitCtrl;
  late TextEditingController stmtCtrl;
  late TextEditingController minDueCtrl;
  late TextEditingController dueDateCtrl;

  @override
  void initState() {
    super.initState();
    bankCtrl = TextEditingController(text: widget.card['bank'].toString());
    limitCtrl = TextEditingController(text: widget.card['credit_limit'].toString());
    stmtCtrl = TextEditingController(text: widget.card['statement_balance'].toString());
    minDueCtrl = TextEditingController(text: widget.card['min_due'].toString());
    dueDateCtrl = TextEditingController(text: widget.card['due_date']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Credit Card"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField("Bank Name", bankCtrl, Icons.account_balance),
            _buildField("Credit Limit", limitCtrl, Icons.speed, isNumber: true),
            _buildField("Statement Balance", stmtCtrl, Icons.account_balance_wallet, isNumber: true),
            _buildField("Minimum Due", minDueCtrl, Icons.low_priority, isNumber: true),
            _buildField("Due Date (e.g. 15th)", dueDateCtrl, Icons.calendar_today),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("UPDATE CARD", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: colorScheme.onSurface.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<void> _update() async {
    if (bankCtrl.text.isEmpty || limitCtrl.text.isEmpty) return;
    final db = await AppDatabase.db;
    await db.update(
      'credit_cards',
      {
        'bank': bankCtrl.text,
        'credit_limit': int.tryParse(limitCtrl.text) ?? 0,
        'statement_balance': int.tryParse(stmtCtrl.text) ?? 0,
        'min_due': int.tryParse(minDueCtrl.text) ?? 0,
        'due_date': dueDateCtrl.text,
      },
      where: 'id = ?',
      whereArgs: [widget.card['id']],
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card Details Updated"), behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Card?"),
        content: const Text("This will permanently remove this card from your list."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = await AppDatabase.db;
      await db.delete('credit_cards', where: 'id = ?', whereArgs: [widget.card['id']]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card Deleted"), behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    }
  }
}
