import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'package:trueledger/presentation/screens/loans/add_loan.dart';
import 'package:trueledger/presentation/screens/loans/edit_loan.dart';
import 'package:trueledger/presentation/screens/cards/add_card.dart';
import 'package:trueledger/presentation/screens/cards/edit_card.dart';
import 'package:trueledger/presentation/screens/net_worth/edit_asset.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

enum NetWorthView { assets, liabilities }

class NetWorthDetailsScreen extends ConsumerStatefulWidget {
  final NetWorthView viewMode;
  const NetWorthDetailsScreen({super.key, required this.viewMode});

  @override
  ConsumerState<NetWorthDetailsScreen> createState() =>
      _NetWorthDetailsScreenState();
}

class _NetWorthDetailsScreenState extends ConsumerState<NetWorthDetailsScreen> {
  // final _repo = FinancialRepository(); // Removed
  bool _isLoading = true;

  // Liabilities
  List<CreditCard> _creditCards = [];
  List<Loan> _bankLoans = [];
  List<Loan> _personalBorrowings = [];

  // Assets
  List<Map<String, dynamic>> _investments = [];

  // Computed totals for header
  double _totalAssets = 0;
  double _totalLiabilities = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(financialRepositoryProvider);
    final cards = await repo.getCreditCards();
    final loans = await repo.getLoans();
    final investments = (await repo.getAllValues('investments'))
        .where((i) => i['active'] == 1)
        .toList();
    final retirement = await repo.getAllValues('retirement_contributions');

    // Categorize Liabilities
    final bankLoans = <Loan>[];
    final personalBorrowings = <Loan>[];
    for (var loan in loans) {
      if (loan.loanType == 'Individual') {
        personalBorrowings.add(loan);
      } else {
        bankLoans.add(loan);
      }
    }

    // Calculate Totals
    double liabilities = 0;
    for (var c in cards) {
      liabilities += c.statementBalance;
    }
    for (var l in loans) {
      liabilities += l.remainingAmount;
    }

    double assets = 0;
    for (var i in investments) {
      assets += (i['amount'] as int);
    }
    for (var r in retirement) {
      assets += (r['amount'] as int);
    }

    if (mounted) {
      setState(() {
        _creditCards = cards;
        _bankLoans = bankLoans;
        _personalBorrowings = personalBorrowings;
        _investments = [...investments, ...retirement]; // Merging for now
        _totalAssets = assets;
        _totalLiabilities = liabilities;
        _isLoading = false;
      });
    }
  }

  Future<void> _openAssetEditor(Map<String, dynamic> i) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAssetScreen(asset: Asset.fromMap(i)),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
            widget.viewMode == NetWorthView.assets
                ? "ASSETS BREAKUP"
                : "LIABILITIES BREAKUP",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.viewMode == NetWorthView.assets
              ? _buildAssetsView(semantic)
              : _buildLiabilitiesView(semantic),
    );
  }

  Widget _buildLiabilitiesView(AppColors semantic) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildTotalHeader(
                  "LIABILITIES", _totalLiabilities, semantic.overspent),
              const SizedBox(height: 24),
            ]),
          ),
        ),
        _buildSliverSectionHeader("LOANS", semantic, onAdd: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddLoanScreen(initialType: 'Bank')));
          _loadData();
        }, iconColor: semantic.overspent),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_bankLoans.isEmpty) {
                  return _buildEmptyState("No active loans");
                }
                final l = _bankLoans[index];
                return _buildListItem(
                  l.name,
                  CurrencyFormatter.format(l.remainingAmount, compact: false),
                  l.loanType,
                  semantic.overspent,
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EditLoanScreen(loan: l)));
                    _loadData();
                  },
                );
              },
              childCount: _bankLoans.isEmpty ? 1 : _bankLoans.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        _buildSliverSectionHeader("CREDIT CARD OUTSTANDING", semantic,
            onAdd: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => AddCreditCardScreen()));
          _loadData();
        }, iconColor: semantic.overspent),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_creditCards.isEmpty) {
                  return _buildEmptyState("No credit cards");
                }
                final c = _creditCards[index];
                return _buildListItem(
                  c.bank,
                  CurrencyFormatter.format(c.statementBalance, compact: false),
                  DateHelper.formatDue(c.dueDate),
                  semantic.overspent,
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EditCreditCardScreen(card: c)));
                    _loadData();
                  },
                );
              },
              childCount: _creditCards.isEmpty ? 1 : _creditCards.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        _buildSliverSectionHeader("INDIVIDUAL BORROWINGS", semantic,
            onAdd: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const AddLoanScreen(initialType: 'Individual')));
          _loadData();
        }, iconColor: semantic.overspent),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_personalBorrowings.isEmpty) {
                  return _buildEmptyState("No personal borrowings");
                }
                final l = _personalBorrowings[index];
                return _buildListItem(
                  l.name,
                  CurrencyFormatter.format(l.remainingAmount, compact: false),
                  "Individual",
                  semantic.overspent,
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EditLoanScreen(loan: l)));
                    _loadData();
                  },
                );
              },
              childCount:
                  _personalBorrowings.isEmpty ? 1 : _personalBorrowings.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
            child:
                SizedBox(height: 100 + MediaQuery.of(context).padding.bottom)),
      ],
    );
  }

  Widget _buildAssetsView(AppColors semantic) {
    final equity = _investments.where((i) {
      final type = (i['type'] as String? ?? '').toLowerCase();
      return type.contains('equity') ||
          type.contains('stock') ||
          type.contains('fund');
    }).toList();

    final gold = _investments
        .where(
            (i) => (i['type'] as String? ?? '').toLowerCase().contains('gold'))
        .toList();

    final retirement = _investments.where((i) {
      final type = (i['type'] as String? ?? '').toLowerCase();
      return type.contains('epf') ||
          type.contains('nps') ||
          type.contains('ppf') ||
          type.contains('retirement');
    }).toList();

    final lending = _investments
        .where((i) =>
            (i['type'] as String? ?? '').toLowerCase().contains('lending'))
        .toList();

    final other = _investments.where((i) {
      final type = (i['type'] as String? ?? '').toLowerCase();
      return !type.contains('equity') &&
          !type.contains('stock') &&
          !type.contains('fund') &&
          !type.contains('gold') &&
          !type.contains('lending') &&
          !type.contains('epf') &&
          !type.contains('nps') &&
          !type.contains('ppf') &&
          !type.contains('retirement');
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildTotalHeader("ASSETS", _totalAssets, semantic.income),
              const SizedBox(height: 24),
            ]),
          ),
        ),
        _buildSliverSectionHeader("EQUITY & MUTUAL FUNDS", semantic,
            onAdd: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddExpense(
                        initialType: 'Investment',
                        initialCategory: 'Mutual Funds',
                        allowedTypes: ['Investment'],
                      )));
          _loadData();
        }),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (equity.isEmpty) {
                  return _buildEmptyState("No equity investments");
                }
                final i = equity[index];
                return _buildListItem(
                  i['name'] ?? 'Investment',
                  CurrencyFormatter.format(i['amount'], compact: false),
                  i['type'] ?? 'Equity',
                  semantic.income,
                  onTap: () => _openAssetEditor(i),
                );
              },
              childCount: equity.isEmpty ? 1 : equity.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        _buildSliverSectionHeader("GOLD & COMMODITIES", semantic,
            onAdd: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddExpense(
                        initialType: 'Investment',
                        initialCategory: 'Gold',
                        allowedTypes: ['Investment'],
                      )));
          _loadData();
        }),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (gold.isEmpty) {
                  return _buildEmptyState("No gold investments");
                }
                final i = gold[index];
                return _buildListItem(
                  i['name'] ?? 'Gold',
                  CurrencyFormatter.format(i['amount'], compact: false),
                  i['type'] ?? 'Commodity',
                  semantic.income,
                  onTap: () => _openAssetEditor(i),
                );
              },
              childCount: gold.isEmpty ? 1 : gold.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        _buildSliverSectionHeader("RETIREMENT & SAVINGS", semantic,
            onAdd: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddExpense(
                        initialType: 'Investment',
                        initialCategory: 'Retirement',
                        allowedTypes: ['Investment'],
                      )));
          _loadData();
        }),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (retirement.isEmpty) {
                  return _buildEmptyState("No retirement savings");
                }
                final i = retirement[index];
                return _buildListItem(
                  i['name'] ?? 'Savings',
                  CurrencyFormatter.format(i['amount'], compact: false),
                  i['type'] ?? 'Retirement',
                  semantic.income,
                );
              },
              childCount: retirement.isEmpty ? 1 : retirement.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        _buildSliverSectionHeader("INDIVIDUAL LENDING", semantic,
            onAdd: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddExpense(
                        initialType: 'Investment',
                        initialCategory: 'Lending',
                        allowedTypes: ['Investment'],
                      )));
          _loadData();
        }),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (lending.isEmpty) {
                  return _buildEmptyState("No lending records",
                      icon: Icons.handshake);
                }
                final i = lending[index];
                return _buildListItem(
                  i['name'] ?? 'Lending',
                  CurrencyFormatter.format(i['amount'], compact: false),
                  "Individual",
                  semantic.income,
                  onTap: () => _openAssetEditor(i),
                );
              },
              childCount: lending.isEmpty ? 1 : lending.length,
            ),
          ),
        ),
        if (other.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _buildSliverSectionHeader("OTHER ASSETS", semantic, onAdd: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddExpense(
                          initialType: 'Investment',
                          initialCategory: 'Other',
                          allowedTypes: ['Investment'],
                        )));
            _loadData();
          }),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final i = other[index];
                  return _buildListItem(
                    i['name'] ?? 'Asset',
                    CurrencyFormatter.format(i['amount'], compact: false),
                    i['type'] ?? 'Other',
                    semantic.income,
                    onTap: () => _openAssetEditor(i),
                  );
                },
                childCount: other.length,
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
            child:
                SizedBox(height: 100 + MediaQuery.of(context).padding.bottom)),
      ],
    );
  }

  Widget _buildSliverSectionHeader(String title, AppColors semantic,
      {VoidCallback? onAdd, Color? iconColor}) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        title: title,
        color: Theme.of(context).colorScheme.surface,
        textColor: semantic.secondaryText,
        action: onAdd != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.add_circle_outline_rounded,
                        size: 20, color: iconColor ?? semantic.income),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTotalHeader(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(amount.toInt(), compact: false),
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .scale(duration: 600.ms, curve: Curves.easeOutBack),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState(String msg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.info_outline,
              size: 16, color: Theme.of(context).disabledColor),
          const SizedBox(width: 12),
          Text(msg,
              style: TextStyle(
                  color: Theme.of(context).disabledColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildListItem(
      String title, String amount, String subtitle, Color amountColor,
      {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoverWrapper(
        onTap: onTap,
        borderRadius: 12,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Theme.of(context).hintColor, fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  Text(amount,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: amountColor)),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right,
                        size: 16, color: Theme.of(context).hintColor),
                  ],
                ],
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuint),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final Color color;
  final Color textColor;
  final Widget? action;

  _StickyHeaderDelegate({
    required this.title,
    required this.color,
    required this.textColor,
    this.action,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: color,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 44.0;

  @override
  double get minExtent => 44.0;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.color != color ||
        oldDelegate.textColor != textColor ||
        oldDelegate.action != action;
  }
}
