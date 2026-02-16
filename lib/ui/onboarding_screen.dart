import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _floatController;

  int _currentPage = 0;

  final _pages = const <_OnboardingPageData>[
    _OnboardingPageData(
      titleTop: 'Set Custom',
      titleAccent: 'Coefficients',
      description:
          'Customize how much each module counts towards your final grade. We calculate weighted averages based on official university standards.',
      cta: 'Next',
      mood: _OnboardingMood.coeff,
    ),
    _OnboardingPageData(
      titleTop: 'Easily Add',
      titleAccent: 'Your Modules',
      description:
          'Track your performance effortlessly. Add your modules, assign coefficients, and let us handle the math.',
      cta: 'Next',
      mood: _OnboardingMood.modules,
    ),
    _OnboardingPageData(
      titleTop: 'Track Your',
      titleAccent: 'Progress',
      description:
          'Watch your dynamic stats, module averages, and final result update in real time as you enter your grades.',
      cta: 'Get Started',
      mood: _OnboardingMood.progress,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage >= _pages.length - 1) {
      widget.onComplete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [tokens.bgTop, tokens.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _currentPage == 0
                          ? null
                          : () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onComplete,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: tokens.accentAlt,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return _OnboardingPage(
                      data: _pages[index],
                      isActive: index == _currentPage,
                      floatAnimation: _floatController,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        final selected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 34 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: selected
                                ? tokens.accentAlt
                                : tokens.accentAlt.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: tokens.accentAlt.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.accentAlt,
                          foregroundColor: const Color(0xFF081122),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _pages[_currentPage].cta,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF081122),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded),
                          ],
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
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.isActive,
    required this.floatAnimation,
  });

  final _OnboardingPageData data;
  final bool isActive;
  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: floatAnimation,
              builder: (context, child) {
                final y = math.sin(floatAnimation.value * math.pi * 2) * 8;
                return Transform.translate(offset: Offset(0, y), child: child);
              },
              child: _OnboardingIllustration(mood: data.mood),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 240),
            opacity: isActive ? 1 : 0.35,
            child: Column(
              children: [
                Text(
                  data.titleTop,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  data.titleAccent,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: tokens.accentAlt,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: tokens.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({required this.mood});

  final _OnboardingMood mood;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).height < 700;
    final panelSize = isCompact ? 232.0 : 292.0;
    final glowSize = isCompact ? 260.0 : 320.0;
    final panelPadding = isCompact ? 12.0 : 18.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: glowSize,
          height: glowSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                tokens.accentAlt.withValues(alpha: 0.2),
                tokens.accentAlt.withValues(alpha: 0.03),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          width: panelSize,
          height: panelSize,
          padding: EdgeInsets.all(panelPadding),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: tokens.accentAlt.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: tokens.shadow.withValues(alpha: 0.32),
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 300,
              height: 300,
              child: _moodContent(theme, tokens),
            ),
          ),
        ),
      ],
    );
  }

  Widget _moodContent(ThemeData theme, AppThemeTokens tokens) {
    switch (mood) {
      case _OnboardingMood.coeff:
        return Column(
          children: [
            _fakeBar(width: 120),
            const SizedBox(height: 18),
            _listRow(tokens, theme, highlighted: false),
            const SizedBox(height: 12),
            _listRow(tokens, theme, highlighted: true),
            const SizedBox(height: 12),
            _listRow(tokens, theme, highlighted: false),
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: tokens.cardAlt,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: tokens.shadow.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'x Weight',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF50647F),
                  ),
                ),
              ),
            ),
          ],
        );
      case _OnboardingMood.modules:
        return Column(
          children: [
            const Spacer(),
            Icon(Icons.checklist_rounded, size: 88, color: tokens.accentAlt),
            const SizedBox(height: 12),
            Text(
              'Add modules quickly',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _fakeChecklist(tokens),
            const Spacer(),
          ],
        );
      case _OnboardingMood.progress:
        return Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'LIVE STATS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: tokens.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(
                    painter: _MiniRingPainter(
                      color: tokens.accent,
                      track: tokens.chip,
                    ),
                    child: Center(
                      child: Text(
                        '14.8',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0D172A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _fakeBar(width: 170),
            const SizedBox(height: 10),
            _fakeBar(width: 130),
            const SizedBox(height: 20),
          ],
        );
    }
  }

  Widget _fakeChecklist(AppThemeTokens tokens) {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: index < 2
                    ? tokens.accentAlt
                    : tokens.textMuted.withValues(alpha: 0.45),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: index < 2
                        ? tokens.accentAlt.withValues(alpha: 0.25)
                        : tokens.chip,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _listRow(
    AppThemeTokens tokens,
    ThemeData theme, {
    required bool highlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlighted
            ? tokens.accentAlt.withValues(alpha: 0.12)
            : tokens.cardAlt,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(color: tokens.accentAlt.withValues(alpha: 0.55))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: highlighted ? tokens.accentAlt : tokens.chip,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              Icons.percent_rounded,
              color: highlighted ? const Color(0xFF071324) : tokens.textMuted,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _fakeBar(width: 130)),
          const SizedBox(width: 8),
          Text(
            highlighted ? '3.0' : '--',
            style: theme.textTheme.titleMedium?.copyWith(
              color: highlighted ? tokens.accentAlt : tokens.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fakeBar({required double width}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: 11,
        decoration: BoxDecoration(
          color: const Color(0xFFCFD6E2),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  _MiniRingPainter({required this.color, required this.track});

  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * 0.74, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.track != track;
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.titleTop,
    required this.titleAccent,
    required this.description,
    required this.cta,
    required this.mood,
  });

  final String titleTop;
  final String titleAccent;
  final String description;
  final String cta;
  final _OnboardingMood mood;
}

enum _OnboardingMood { coeff, modules, progress }
