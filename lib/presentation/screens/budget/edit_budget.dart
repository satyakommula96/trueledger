import 'package:flutter/material.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';

import 'package:trueledger/domain/usecases/budget_usecases.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  final Budget budget;
  const EditBudgetScreen({super.key, required this.budget});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  late TextEditingController limitCtrl;

  @override
  void initState() {
    super.initState();
    limitCtrl =
        TextEditingController(text: widget.budget.monthlyLimit.toString());
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Flexible(
              child: Text(
                "EDIT ${widget.budget.category.toUpperCase()}",
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            if (widget.budget.isStable) ...[
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: semantic.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: semantic.success.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "STABLE",
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: semantic.success),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: semantic.overspent),
            onPressed: _delete,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "MONTHLY CEILING",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: limitCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 48,
                letterSpacing: -2,
                color: semantic.text,
              ),
              decoration: InputDecoration(
                prefixText: "${CurrencyFormatter.symbol} ",
                border: InputBorder.none,
                hintText: "0",
                hintStyle: TextStyle(
                    color: semantic.secondaryText.withValues(alpha: 0.1)),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: OutlinedButton(
                onPressed: _markReviewed,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: semantic.primary, width: 2),
                ),
                child: Text(
                  "MARK AS REVIEWED",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 2,
                    color: semantic.primary,
                  ),
                ),
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: semantic.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text(
                  "UPDATE BUDGET",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Future<void> _markReviewed() async {
    final markReviewed = ref.read(markBudgetAsReviewedUseCaseProvider);
    final result = await markReviewed(widget.budget.id);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failureOrThrow.message)));
    }
  }

  Future<void> _update() async {
    final limit = double.tryParse(limitCtrl.text);
    if (limit == null || limit < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid non-negative limit")));
      return;
    }

    final updateBudget = ref.read(updateBudgetUseCaseProvider);
    final result = await updateBudget(UpdateBudgetParams(
      id: widget.budget.id,
      monthlyLimit: limit,
    ));

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failureOrThrow.message)));
    }
  }

  Future<void> _delete() async {
    final deleteBudget = ref.read(deleteBudgetUseCaseProvider);
    final result = await deleteBudget(widget.budget.id);

    if (!mounted) return;

    if (result.isSuccess) {
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted ${widget.budget.category} budget"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () async {
            final addBudget = ref.read(addBudgetUseCaseProvider);
            await addBudget(AddBudgetParams(
              category: widget.budget.category,
              monthlyLimit: widget.budget.monthlyLimit,
            ));
            // We assume the Dashboard will refresh which it usually does on route return
          },
        ),
      ));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failureOrThrow.message)));
    }
  }
}
