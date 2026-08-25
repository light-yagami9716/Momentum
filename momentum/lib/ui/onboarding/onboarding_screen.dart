import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../state/settings_provider.dart';
import '../navigation/app_routes.dart';
import '../widgets/streak_ring.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      icon: Icons.auto_awesome_rounded,
      title: 'Welcome to Momentum',
      body: 'Small actions, repeated consistently, compound into meaningful change. Momentum keeps the loop simple: pick a habit, show up, watch the streak grow.',
    ),
    (
      icon: Icons.local_fire_department_rounded,
      title: 'Streaks that forgive',
      body: 'Check in each day and build your streak. Miss a single day and Momentum bridges it for you, because progress is a pattern, not a perfect record.',
    ),
    (
      icon: Icons.lock_outline_rounded,
      title: 'Private by design',
      body: 'No accounts, no servers, no tracking. Everything you track lives only on your device, so your habits stay yours.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<SettingsProvider>().completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.root);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: StreakRing(
                            progress: (index + 1) / _pages.length,
                            color: palette.accent,
                            size: 140,
                            strokeWidth: 10,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: palette.accentSoft,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                page.icon,
                                size: 44,
                                color: palette.accent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: palette.textSecondary,
                                height: 1.6,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: AppMotion.base,
                          curve: AppMotion.entry,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? palette.accent
                                : palette.surfaceAlt,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: isLast
                        ? ElevatedButton(
                            onPressed: _finish,
                            child: const Text('Get started'),
                          )
                        : ElevatedButton(
                            onPressed: () => _controller.nextPage(
                              duration: AppMotion.page,
                              curve: AppMotion.entry,
                            ),
                            child: const Text('Continue'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
