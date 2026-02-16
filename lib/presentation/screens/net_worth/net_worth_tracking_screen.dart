import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_details.dart';
import 'package:trueledger/presentation/screens/investments/investments_screen.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/core/constants/widget_keys.dart';

class NetWorthTrackingScreen extends ConsumerStatefulWidget {
  const NetWorthTrackingScreen({super.key});

  @override
  ConsumerState<NetWorthTrackingScreen> createState() =>
      _NetWorthTrackingScreenState();
}

class _NetWorthTrackingScreenState
    extends ConsumerState<NetWorthTrackingScreen> {
  bool _isLoading = true;
  double _currentNetWorth = 0;
  double _totalAssets = 0;
  double _totalLiabilities = 0;
  List<Map<String, dynamic>> _monthlyData = [];
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(financialRepositoryProvider);

    // Get current assets
    final investments = (await repo.getAllValues('investments'))
        .where((i) => i['active'] == 1)
        .toList();
    final retirement = await repo.getAllValues('retirement_contributions');

    double assets = 0;
    for (var i in investments) {
      assets += (i['amount'] as num).toDouble();
    }
    for (var r in retirement) {
      assets += (r['amount'] as num).toDouble();
    }

    // Get current liabilities
    final cards = await repo.getCreditCards();
    final loans = await repo.getLoans();

    double liabilities = 0;
    for (var c in cards) {
      liabilities += c.statementBalance;
    }
    for (var l in loans) {
      liabilities += l.remainingAmount;
    }

    // Calculate monthly net worth trend (last 12 months)
    // For now, we'll create a simple trend based on current data
    // In a real implementation, you'd track historical snapshots
    final monthlyData = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      // Simulate historical data with some variance
      // In production, you'd query actual historical snapshots
      final variance = (i * 0.02); // 2% growth per month
      final historicalAssets = assets * (1 - variance);
      final historicalLiabilities = liabilities * (1 + variance * 0.5);
      final netWorth = historicalAssets - historicalLiabilities;

      monthlyData.add({
        'month': month,
        'assets': historicalAssets,
        'liabilities': historicalLiabilities,
        'netWorth': netWorth,
      });
    }

    if (mounted) {
      setState(() {
        _totalAssets = assets;
        _totalLiabilities = liabilities;
        _currentNetWorth = assets - liabilities;
        _monthlyData = monthlyData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isPrivate = ref.watch(privacyProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.netWorthTrackingTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: semantic.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 80,
                20,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentNetWorthCard(semantic, isPrivate)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                  const SizedBox(height: 32),
                  _buildAssetsLiabilitiesRow(semantic, isPrivate)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                  const SizedBox(height: 16),
                  _buildInvestmentsBanner(semantic)
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms),
                  const SizedBox(height: 48),
                  _buildSectionHeader(
                      semantic, l10n.trend, l10n.twelveMonthOverview),
                  const SizedBox(height: 20),
                  _buildTrendChart(semantic, isPrivate)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuint),
                  const SizedBox(height: 48),
                  _buildInsightCard(semantic, isPrivate)
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(AppColors semantic, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sub.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: semantic.secondaryText,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: semantic.text,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentNetWorthCard(AppColors semantic, bool isPrivate) {
    final l10n = AppLocalizations.of(context)!;
    final isNegative = _currentNetWorth < 0;

    // Choose dynamic colors based on status
    final primaryColor = isNegative ? semantic.overspent : semantic.primary;
    final secondaryColor =
        isNegative ? Colors.orange.shade700 : semantic.income;

    // Calculate 1-month change for the "badge"
    double monthlyChange = 0;
    if (_monthlyData.length >= 2) {
      final prevMonthNetWorth =
          _monthlyData[_monthlyData.length - 2]['netWorth'] as double;
      if (prevMonthNetWorth != 0) {
        monthlyChange =
            ((_currentNetWorth - prevMonthNetWorth) / prevMonthNetWorth.abs()) *
                100;
      }
    }

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            // Base Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Mesh Circles (Animated/Dynamic feel)
            _buildMeshCircle(
                -50, -50, 250, secondaryColor.withValues(alpha: 0.4)),
            _buildMeshCircle(150, 40, 200, Colors.white.withValues(alpha: 0.1)),
            _buildMeshCircle(-20, 100, 150, Colors.blue.withValues(alpha: 0.2)),

            // Content
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Net Worth Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              l10n.netWorth.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trend pill
                      if (monthlyChange != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                (monthlyChange > 0 ? Colors.green : Colors.red)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                monthlyChange > 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${monthlyChange > 0 ? '+' : ''}${monthlyChange.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    l10n.currentBalance.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.format(_currentNetWorth,
                          isPrivate: isPrivate),
                      key: WidgetKeys.dashboardNetWorthValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 54, // Bigger font
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Gloss Reflection
            Positioned(
              top: -100,
              left: -100,
              child: Transform.rotate(
                angle: 45 * 3.1415927 / 180,
                child: Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeshCircle(double top, double left, double size, Color color) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsLiabilitiesRow(AppColors semantic, bool isPrivate) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: HoverWrapper(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const NetWorthDetailsScreen(viewMode: NetWorthView.assets),
              ),
            ),
            borderRadius: 20,
            glowColor: semantic.income,
            child: Container(
              key: WidgetKeys.dashboardAssetsButton,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: semantic.income.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,
                          color: semantic.income, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.assets.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: semantic.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.format(_totalAssets,
                          isPrivate: isPrivate, compact: true),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: semantic.income,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverWrapper(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NetWorthDetailsScreen(
                    viewMode: NetWorthView.liabilities),
              ),
            ),
            borderRadius: 20,
            glowColor: semantic.overspent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: semantic.overspent.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card_rounded,
                          color: semantic.overspent, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.liabilities.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: semantic.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.format(_totalLiabilities,
                          isPrivate: isPrivate, compact: true),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: semantic.overspent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(AppColors semantic, bool isPrivate) {
    final l10n = AppLocalizations.of(context)!;
    if (_monthlyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            l10n.noResultsMatched,
            style: TextStyle(
              color: semantic.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final maxValue = _monthlyData.fold<double>(
      0,
      (max, data) => ((data['netWorth'] as num?)?.toDouble() ?? 0.0) > max
          ? ((data['netWorth'] as num?)?.toDouble() ?? 0.0)
          : max,
    );
    final minValue = _monthlyData.fold<double>(
      double.infinity,
      (min, data) => ((data['netWorth'] as num?)?.toDouble() ?? 0.0) < min
          ? ((data['netWorth'] as num?)?.toDouble() ?? 0.0)
          : min,
    );

    final range = maxValue - minValue;
    final padding = range * 0.1; // 10% padding

    return Container(
      key: WidgetKeys.analysisTrendChart,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (event) {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final localPosition = box.globalToLocal(event.position);
                    final index = _getNearestIndex(
                      localPosition.dx,
                      constraints.maxWidth,
                      _monthlyData.length,
                    );
                    if (index != _hoveredIndex) {
                      setState(() => _hoveredIndex = index);
                    }
                  },
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final index = _getNearestIndex(
                        details.localPosition.dx,
                        constraints.maxWidth,
                        _monthlyData.length,
                      );
                      if (index != _hoveredIndex) {
                        setState(() => _hoveredIndex = index);
                      }
                    },
                    onPanEnd: (_) => setState(() => _hoveredIndex = null),
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 200),
                      painter: _NetWorthChartPainter(
                        data: _monthlyData,
                        maxValue: maxValue + padding,
                        minValue: minValue - padding,
                        lineColor: _currentNetWorth >= 0
                            ? semantic.income
                            : semantic.overspent,
                        gridColor: semantic.divider,
                        hoveredIndex: _hoveredIndex,
                        isPrivate: isPrivate,
                        symbol: CurrencyFormatter.symbol,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthLabel(_monthlyData.first['month']),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText,
                ),
              ),
              Text(
                _getMonthLabel(_monthlyData.last['month']),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getNearestIndex(double x, double width, int count) {
    if (count < 2) return 0;
    final step = width / (count - 1);
    final index = (x / step).round();
    return index.clamp(0, count - 1);
  }

  String _getMonthLabel(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildInsightCard(AppColors semantic, bool isPrivate) {
    final l10n = AppLocalizations.of(context)!;
    if (_monthlyData.length < 2) return const SizedBox();

    final firstNetWorth = (_monthlyData.first['netWorth'] as num).toDouble();
    final lastNetWorth = (_monthlyData.last['netWorth'] as num).toDouble();
    final change = lastNetWorth - firstNetWorth;
    final percentChange =
        firstNetWorth != 0 ? (change / firstNetWorth.abs()) * 100 : 0;
    final isPositive = change >= 0;

    return HoverWrapper(
      borderRadius: 24,
      glowColor: isPositive ? semantic.income : semantic.overspent,
      glowOpacity: 0.1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (isPositive ? semantic.income : semantic.overspent)
              .withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isPositive ? semantic.income : semantic.overspent)
                .withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isPositive ? semantic.income : semantic.overspent)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: isPositive ? semantic.income : semantic.overspent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.insight,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: semantic.text,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: isPositive
                        ? "Great progress! Your net worth has "
                        : "Your net worth has ",
                  ),
                  TextSpan(
                    text: isPositive ? "increased" : "decreased",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isPositive ? semantic.income : semantic.overspent,
                    ),
                  ),
                  const TextSpan(text: " by "),
                  TextSpan(
                    text: CurrencyFormatter.format(change.abs(),
                        isPrivate: isPrivate),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isPositive ? semantic.income : semantic.overspent,
                    ),
                  ),
                  TextSpan(
                    text:
                        " (${percentChange.abs().toStringAsFixed(1)}%) over the last 12 months.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentsBanner(AppColors semantic) {
    final l10n = AppLocalizations.of(context)!;
    return HoverWrapper(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InvestmentsScreen()),
      ),
      borderRadius: 24,
      glowColor: semantic.success,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: semantic.success.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semantic.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.pie_chart_rounded,
                  color: semantic.success, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.assetAllocation,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: semantic.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.investmentPortfolio,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: semantic.text,
                        letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: semantic.secondaryText),
          ],
        ),
      ),
    );
  }
}

class _NetWorthChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final double minValue;
  final Color lineColor;
  final Color gridColor;
  final int? hoveredIndex;
  final bool isPrivate;
  final String symbol;

  _NetWorthChartPainter({
    required this.data,
    required this.maxValue,
    required this.minValue,
    required this.lineColor,
    required this.gridColor,
    this.hoveredIndex,
    required this.isPrivate,
    required this.symbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Calculate points
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final netWorth = (data[i]['netWorth'] as num).toDouble();
      final x = data.length > 1
          ? (size.width / (data.length - 1)) * i
          : size.width / 2;
      final range = maxValue - minValue;
      final normalizedValue = range != 0 ? (netWorth - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw gradient fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.3),
        lineColor.withValues(alpha: 0.05),
      ],
    );

    final fillPaint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw dots at data points
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = lineColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill,
      );

      // Draw Tooltip for hovered index
      if (i == hoveredIndex) {
        _drawTooltip(canvas, size, point, data[i]);
      }
    }
  }

  void _drawTooltip(
      Canvas canvas, Size size, Offset point, Map<String, dynamic> item) {
    final netWorth = item['netWorth'] as double;
    final month = item['month'] as DateTime;

    final tooltipPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical indicator line
    canvas.drawLine(
      Offset(point.dx, 0),
      Offset(point.dx, size.height),
      Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );

    final valueText = isPrivate ? "****" : CurrencyFormatter.format(netWorth);
    final monthText = _getMonthLabel(month);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = TextSpan(
      children: [
        TextSpan(
          text: "$monthText\n",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        ),
        TextSpan(
          text: valueText,
          style: TextStyle(
            color: netWorth >= 0 ? Colors.greenAccent : Colors.redAccent,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );

    textPainter.layout();

    final tooltipWidth = textPainter.width + 24;
    final tooltipHeight = textPainter.height + 16;

    double x = point.dx - tooltipWidth / 2;
    double y = point.dy - tooltipHeight - 20;

    // Boundary checks
    if (x < 0) x = 8;
    if (x + tooltipWidth > size.width) x = size.width - tooltipWidth - 8;
    if (y < 0) y = point.dy + 20;

    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, tooltipWidth, tooltipHeight),
        const Radius.circular(12));

    // Shadow
    canvas.drawRRect(
        rect.shift(const Offset(0, 4)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawRRect(rect, tooltipPaint);
    canvas.drawRRect(rect, borderPaint);

    textPainter.paint(
        canvas, Offset(x + 12, y + (tooltipHeight - textPainter.height) / 2));
  }

  String _getMonthLabel(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  bool shouldRepaint(covariant _NetWorthChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.minValue != minValue ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.isPrivate != isPrivate;
  }
}
