import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Floating particles animation for mystical background effects
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color color;
  
  const FloatingParticles({
    Key? key,
    this.particleCount = 20,
    this.color = Colors.purpleAccent,
  }) : super(key: key);

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<double> _sizes;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.particleCount,
      (index) => AnimationController(
        duration: Duration(seconds: 10 + _random.nextInt(10)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      final beginX = _random.nextDouble() * 2 - 1;
      final beginY = _random.nextDouble() * 2 - 1;
      final endX = _random.nextDouble() * 2 - 1;
      final endY = _random.nextDouble() * 2 - 1;

      return Tween<Offset>(
        begin: Offset(beginX, beginY),
        end: Offset(endX, endY),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    _sizes = List.generate(
      widget.particleCount,
      (index) => _random.nextDouble() * 4 + 2,
    );

    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.particleCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned.fill(
              child: Align(
                alignment: Alignment(
                  _animations[index].value.dx,
                  _animations[index].value.dy,
                ),
                child: Container(
                  width: _sizes[index],
                  height: _sizes[index],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: _sizes[index] * 2,
                        spreadRadius: _sizes[index] / 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Pulsing glow animation for mystical elements
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double minGlowRadius;
  final double maxGlowRadius;
  final Duration duration;

  const PulsingGlow({
    Key? key,
    required this.child,
    this.glowColor = Colors.purpleAccent,
    this.minGlowRadius = 10,
    this.maxGlowRadius = 20,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.minGlowRadius,
      end: widget.maxGlowRadius,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.6),
                blurRadius: _animation.value,
                spreadRadius: _animation.value / 2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmering text effect for mystical headings
class ShimmeringText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;

  const ShimmeringText({
    Key? key,
    required this.text,
    this.style,
    this.colors = const [
      Colors.purple,
      Colors.purpleAccent,
      Colors.deepPurple,
    ],
  }) : super(key: key);

  @override
  State<ShimmeringText> createState() => _ShimmeringTextState();
}

class _ShimmeringTextState extends State<ShimmeringText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: widget.colors,
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style?.copyWith(color: Colors.white) ??
                const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        );
      },
    );
  }
}

/// Mystical loading indicator
class MysticalLoader extends StatefulWidget {
  final double size;
  final Color color;

  const MysticalLoader({
    Key? key,
    this.size = 50,
    this.color = Colors.purpleAccent,
  }) : super(key: key);

  @override
  State<MysticalLoader> createState() => _MysticalLoaderState();
}

class _MysticalLoaderState extends State<MysticalLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(3, (index) {
              return Transform.rotate(
                angle: (_controller.value + index / 3) * 2 * math.pi,
                child: Container(
                  width: widget.size * (0.3 + index * 0.1),
                  height: widget.size * (0.3 + index * 0.1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(1 - index * 0.3),
                      width: 2,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Fade and scale animation wrapper
class FadeScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeScaleIn({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutBack,
  }) : super(key: key);

  @override
  State<FadeScaleIn> createState() => _FadeScaleInState();
}

class _FadeScaleInState extends State<FadeScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: widget.child,
          ),
        );
      },
    );
  }
}