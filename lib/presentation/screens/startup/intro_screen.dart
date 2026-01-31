import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/providers/user_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Track Your Wealth',
      'description':
          'See exactly where your money goes. Build your net worth with crystal-clear insights.',
      'icon': Icons.trending_up_rounded,
    },
    {
      'title': 'Smart Budgeting',
      'description':
          'Spend smarter, not harder. Set goals and limits that help you save without the sacrifice.',
      'icon': Icons.pie_chart_rounded,
    },
    {
      'title': 'Secure & Private',
      'description':
          'Your financial life stays on this device. No cloud uploads, no tracking, just 100% privacy.',
      'icon': Icons.security_rounded,
    },
    {
      'title': 'What should we call you?',
      'description': 'Your name helps us personalize your experience.',
      'icon': Icons.person_outline_rounded,
      'isNamePage': true,
    },
  ];

  Future<void> _finishIntro() async {
    await ref.read(notificationServiceProvider).requestPermissions();

    final prefs = ref.read(sharedPreferencesProvider);
    final name = _nameController.text.trim();
    if (name.length > 20) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name is too long (max 20 characters)')),
        );
      }
      return;
    }

    if (name.isNotEmpty) {
      ref.read(userProvider.notifier).setName(
          name); // setName is Future<void> but we don't strictly need to await it here for UI responsiveness if we navigate immediately
    }

    await prefs.setBool('intro_seen', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Subtle Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface,
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              if (page['isNamePage'] == true) {
                return _NamePage(
                  title: page['title'],
                  description: page['description'],
                  controller: _nameController,
                  onStart: _finishIntro,
                );
              }
              return _IntroPage(
                title: page['title'],
                description: page['description'],
                icon: page['icon'],
              );
            },
          ),
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 50 + MediaQuery.of(context).padding.top, // Safe area
              right: 24,
              child: TextButton(
                onPressed: () {
                  _pageController.animateToPage(
                    _pages.length - 1,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutQuint,
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('SKIP',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.secondary,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    )),
              ).animate().fade(delay: 500.ms),
            ),
          Positioned(
            bottom: 40 + MediaQuery.of(context).padding.bottom,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: _currentPage == index ? 32 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                if (_pages[_currentPage]['isNamePage'] != true) ...[
                  const SizedBox(height: 40),
                  if (_currentPage == _pages.length - 1)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _finishIntro,
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 8,
                          shadowColor:
                              colorScheme.primary.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'GET STARTED',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1),
                        ),
                      ),
                    )
                        .animate()
                        .scale(duration: 300.ms, curve: Curves.easeOutBack)
                        .fadeIn()
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutQuint,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.4),
                              width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text('NEXT',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1,
                                color: colorScheme.primary)),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _IntroPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 72,
              color: colorScheme.primary,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 60),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuint),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuint),
        ],
      ),
    );
  }
}

class _NamePage extends StatefulWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final VoidCallback onStart;

  const _NamePage({
    required this.title,
    required this.description,
    required this.controller,
    required this.onStart,
  });

  @override
  State<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<_NamePage> {
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = widget.controller.text;
    widget.controller.addListener(_updateName);
  }

  void _updateName() {
    if (mounted) {
      setState(() {
        _displayName = widget.controller.text;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.15),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(Icons.person_outline_rounded,
                  size: 60, color: colorScheme.primary),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 40),
            Text(
              _displayName.isEmpty ? widget.title : "Hello, $_displayName!",
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
                .animate(key: ValueKey(_displayName.isEmpty))
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            Text(
              _displayName.isEmpty
                  ? widget.description
                  : "We're excited to have you here.",
              style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                textAlign: TextAlign.center,
                maxLength: 20,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => widget.onStart(),
                decoration: InputDecoration(
                  hintText: "Your Name",
                  counterText: "",
                  hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  filled: true,
                  fillColor: isDark ? colorScheme.surface : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Icon(Icons.edit_rounded,
                        color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: widget.onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'GET STARTED',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2),
                ),
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
