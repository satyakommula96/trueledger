import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_details.dart';
import 'package:trueledger/presentation/screens/investments/investments_screen.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/presentation/components/apple_style.dart';
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

    return AppleScaffold(
      title: l10n.netWorthTrackingTitle,
      subtitle: l10n.financialPosition,
      slivers: [
        if (_isLoading)
          SliverFillRemaining(
            child: Center(
                child: CircularProgressIndicator(color: semantic.primary)),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCurrentNetWorthCard(semantic, isPrivate)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 24),
                _buildAssetsLiabilitiesRow(semantic, isPrivate)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 16),
                _buildInvestmentsBanner(semantic)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms),
                const SizedBox(height: 48),
                AppleSectionHeader(
                  title: l10n.trend,
                  subtitle: l10n.twelveMonthOverview,
                ),
                const SizedBox(height: 16),
                _buildTrendChart(semantic, isPrivate)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 48),
                _buildInsightCard(semantic, isPrivate)
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms),
                const SizedBox(height: 100),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentNetWorthCard(AppColors semantic, bool isPrivate) {
    final l10n = AppLocalizations.of(context)!;
    final isNegative = _currentNetWorth < 0;

    final primaryColor = isNegative ? semantic.overspent : semantic.primary;
    final secondaryColor = isNegative ? Colors.orange : semantic.success;

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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: AspectRatio(
          aspectRatio: 1.6,
          child: AppleGlassCard(
            padding: EdgeInsets.zero,
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Stack(
              children: [
                _buildMeshCircle(
                    -60, -60, 280, secondaryColor.withValues(alpha: 0.3)),
                _buildMeshCircle(
                    160, 50, 220, Colors.white.withValues(alpha: 0.1)),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Text(
                              l10n.netWorth.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          if (monthlyChange != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (monthlyChange > 0
                                        ? Colors.white
                                        : Colors.white)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    monthlyChange > 0
                                        ? CupertinoIcons.graph_circle_fill
                                        : CupertinoIcons.minus_circle_fill,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${monthlyChange > 0 ? '+' : ''}${monthlyChange.toStringAsFixed(1)}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
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
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
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
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                      Icon(CupertinoIcons.square_stack_3d_up_fill,
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
                      Icon(CupertinoIcons.creditcard_fill,
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
      return AppleGlassCard(
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

    return AppleGlassCard(
      key: WidgetKeys.analysisTrendChart,
      padding: const EdgeInsets.all(24),
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
                        gridColor: semantic.divider.withValues(alpha: 0.1),
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
    return DateFormat.yMMM().format(date).toUpperCase();
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

    return AppleGlassCard(
      color: (isPositive ? semantic.income : semantic.overspent)
          .withValues(alpha: 0.05),
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
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: isPositive ? semantic.income : semantic.overspent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.insight.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
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
                        ? l10n.netWorthIncreased
                        : l10n.netWorthDecreased),
                TextSpan(
                  text: isPositive ? l10n.increasedLabel : l10n.decreasedLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isPositive ? semantic.income : semantic.overspent,
                  ),
                ),
                TextSpan(text: l10n.byLabel),
                TextSpan(
                  text: CurrencyFormatter.format(change.abs(),
                      isPrivate: isPrivate),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isPositive ? semantic.income : semantic.overspent,
                  ),
                ),
                TextSpan(
                  text:
                      " (${percentChange.abs().toStringAsFixed(1)}%)${l10n.overLast12Months}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentsBanner(AppColors semantic) {
    final l10n = AppLocalizations.of(context)!;
    return AppleGlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvestmentsScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantic.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(CupertinoIcons.chart_bar_square_fill,
                      color: semantic.success, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.investments.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: semantic.secondaryText,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.trackGrowthInsights,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: semantic.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right, color: semantic.divider),
              ],
            ),
          ),
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
