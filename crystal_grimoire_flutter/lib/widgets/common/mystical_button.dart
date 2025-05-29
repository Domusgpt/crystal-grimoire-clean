import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../animations/mystical_animations.dart';

/// Mystical button with glow effects and haptic feedback
class MysticalButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? glowColor;
  final bool isPrimary;

  const MysticalButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.glowColor,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  State<MysticalButton> createState() => _MysticalButtonState();
}

class _MysticalButtonState extends State<MysticalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(_) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(_) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ??
        (widget.isPrimary
            ? theme.colorScheme.primary
            : theme.colorScheme.surface);
    final glowColor = widget.glowColor ??
        (widget.isPrimary
            ? theme.colorScheme.primary.withOpacity(0.5)
            : theme.colorScheme.secondary.withOpacity(0.3));

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor,
                    backgroundColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: glowColor.withOpacity(_glowAnimation.value * 0.6),
                    offset: const Offset(0, 0),
                    blurRadius: 20 + (_glowAnimation.value * 10),
                    spreadRadius: _glowAnimation.value * 5,
                  ),
                ],
                border: Border.all(
                  color: glowColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: widget.width == null ? MainAxisSize.min : MainAxisSize.max,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.isPrimary ? Colors.white : theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.isPrimary ? Colors.white : theme.colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Floating action button with crystal shape
class CrystalFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const CrystalFAB({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  }) : super(key: key);

  @override
  State<CrystalFAB> createState() => _CrystalFABState();
}

class _CrystalFABState extends State<CrystalFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PulsingGlow(
      glowColor: Theme.of(context).colorScheme.secondary,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: ClipPath(
              clipper: _CrystalClipper(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onPressed();
                    },
                    child: Transform.rotate(
                      angle: -_rotationAnimation.value,
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Crystal shape clipper for FAB
class _CrystalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Create hexagon shape
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * 3.14159 / 180;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;

  double cos(double angle) => (angle == 0) ? 1 : (angle == 3.14159) ? -1 : 
    (angle < 1.57) ? 0.5 : (angle < 3.14159) ? -0.5 : 
    (angle < 4.71) ? -0.5 : 0.5;
    
  double sin(double angle) => (angle < 1.05) ? 0.866 : (angle < 2.09) ? 0.866 : 
    (angle < 3.14159) ? 0 : (angle < 4.19) ? -0.866 : 
    (angle < 5.24) ? -0.866 : 0;
}

/// Icon button with mystical hover effect
class MysticalIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color? color;
  final String? tooltip;

  const MysticalIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.size = 24,
    this.color,
    this.tooltip,
  }) : super(key: key);

  @override
  State<MysticalIconButton> createState() => _MysticalIconButtonState();
}

class _MysticalIconButtonState extends State<MysticalIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                widget.onPressed();
              },
              icon: Icon(
                widget.icon,
                size: widget.size,
                color: color,
              ),
              tooltip: widget.tooltip,
            ),
          );
        },
      ),
    );
  }
}