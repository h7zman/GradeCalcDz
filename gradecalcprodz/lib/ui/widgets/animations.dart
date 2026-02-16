import 'dart:ui';
import 'package:flutter/material.dart';

class Motion {
  static const Duration page = Duration(milliseconds: 350);
  static const Duration item = Duration(milliseconds: 250);
  static const Duration tap = Duration(milliseconds: 200);
  static const Duration swipe = Duration(milliseconds: 180);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve spring = Curves.elasticOut;

  static const double y = 18;
  static const double x = 24;
}

class FadeSlide extends StatelessWidget {
  const FadeSlide({
    super.key,
    required this.animation,
    required this.child,
    this.dy = Motion.y,
    this.dx = 0,
  });

  final Animation<double> animation;
  final Widget child;
  final double dy;
  final double dx;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;
          return Transform.translate(
            offset: Offset(dx * (1 - t), dy * (1 - t)),
            child: child,
          );
        },
      ),
    );
  }
}

/// A widget that scales in with a spring-like bounce.
class ScaleIn extends StatelessWidget {
  const ScaleIn({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value.clamp(0.0, 1.2),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class TabBodySwitcher extends StatelessWidget {
  const TabBodySwitcher({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Motion.page,
      switchInCurve: Motion.curve,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (widget, animation) {
        return FadeTransition(
          opacity: animation,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => Transform.translate(
              offset: Offset(0, 12 * (1 - animation.value)),
              child: widget,
            ),
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(index), child: child),
    );
  }
}

class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: Motion.tap,
          curve: Curves.easeOut,
          scale: _down ? 0.96 : 1.0,
          child: AnimatedOpacity(
            duration: Motion.tap,
            curve: Curves.easeOut,
            opacity: _down ? 0.92 : 1,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A frosted glassmorphism container.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.blur = 16,
    this.opacity = 0.08,
    this.borderColor,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.white.withValues(alpha: opacity * 3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color:
                  borderColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.3)),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
