import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
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
    await prefs.setBool('intro_seen', true);

    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await prefs.setString('user_name', name);
    }

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
                );
              }
              return _IntroPage(
                title: page['title'],
                description: page['description'],
                icon: page['icon'],
              );
            },
          ),
          Positioned(
            top: 50 + MediaQuery.of(context).padding.top, // Safe area
            right: 24,
            child: TextButton(
              onPressed: _finishIntro,
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
                        shadowColor: colorScheme.primary.withValues(alpha: 0.4),
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

class _NamePage extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController controller;

  const _NamePage({
    required this.title,
    required this.description,
    required this.controller,
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.15),
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline_rounded,
                size: 60, color: colorScheme.primary),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 48),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: "Your Name",
              hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.2)),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.all(24),
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
                    color: colorScheme.primary.withValues(alpha: 0.4)),
              ),
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
