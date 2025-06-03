import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme_constants.dart';
import '../../theme/theme_controller.dart';

enum SlideDirection { left, right, up, down }

class ThemedCard extends ConsumerStatefulWidget {
  final Widget child;
  final SlideDirection slideDirection;
  final Duration slideDuration;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool animate;

  const ThemedCard({
    Key? key,
    required this.child,
    this.slideDirection = SlideDirection.up,
    this.slideDuration = const Duration(milliseconds: 500),
    this.elevation = 4,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.animate = true,
  }) : super(key: key);

  @override
  ConsumerState<ThemedCard> createState() => _ThemedCardState();
}

class _ThemedCardState extends ConsumerState<ThemedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.slideDuration,
      vsync: this,
    );

    // Définir la direction du slide
    final Offset beginOffset;
    switch (widget.slideDirection) {
      case SlideDirection.left:
        beginOffset = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1.0, 0.0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0.0, 1.0);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0.0, -1.0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeControllerProvider);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? ThemeConstants.nightCardColor
                    : ThemeConstants.dayCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isDarkMode)
                    BoxShadow(
                      color: ThemeConstants.nightAccent.withOpacity(0.2),
                      blurRadius: widget.elevation * 2,
                      spreadRadius: -widget.elevation,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: widget.elevation,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 