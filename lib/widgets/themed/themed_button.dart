import 'package:flutter/material.dart';
import '../../constants/design_constants.dart'; // Import design constants
// TODO: Update import to core/constants path after refactoring

class ThemedButton extends StatefulWidget {
  final VoidCallback? onPressed; // Allow null onPressed for disabled state
  final Widget child;
  final ButtonStyle? style;
  final Gradient? gradient;
  final bool isPulsing;
  final String? tooltip; // Added tooltip property

  const ThemedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.gradient,
    this.isPulsing = false,
    this.tooltip, // Added tooltip
  });

  @override
  State<ThemedButton> createState() => _ThemedButtonState();
}

class _ThemedButtonState extends State<ThemedButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulsingAnimationController;
  late Animation<double> _pulsingAnimation;

  @override
  void initState() {
    super.initState();
    _pulsingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulsingAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulsingAnimationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPulsing && widget.onPressed != null) { // Only pulse if enabled
      _pulsingAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ThemedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing || widget.onPressed != oldWidget.onPressed) {
      if (widget.isPulsing && widget.onPressed != null) {
        _pulsingAnimationController.repeat(reverse: true);
      } else {
        _pulsingAnimationController.stop();
        _pulsingAnimationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _pulsingAnimationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    // widget.onPressed!(); // The ElevatedButton handles its own onPressed call.
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pressScale = _isPressed ? 0.95 : 1.0;
    final bool isDisabled = widget.onPressed == null;

    Color? buttonBackgroundColor = widget.style?.backgroundColor?.resolve({}) ?? theme.colorScheme.primary;
    Color? buttonForegroundColor = widget.style?.foregroundColor?.resolve({}) ?? theme.colorScheme.onPrimary;

    if (isDisabled) {
      buttonBackgroundColor = theme.colorScheme.onSurface.withOpacity(0.12);
      buttonForegroundColor = theme.colorScheme.onSurface.withOpacity(0.38);
    } else if (widget.gradient != null) {
      buttonBackgroundColor = Colors.transparent;
    }

    final ButtonStyle effectiveStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonBackgroundColor,
      foregroundColor: buttonForegroundColor,
      disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
      disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
      padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      ),
      elevation: widget.gradient != null ? 0 : widget.style?.elevation?.resolve({}),
      shadowColor: widget.gradient != null ? Colors.transparent : widget.style?.shadowColor?.resolve({}),
    ).merge(widget.style);

    // The core button, which might be an ElevatedButton or just its child for gradient effect
    Widget coreButtonChild = widget.child;
    Widget buttonItself = ElevatedButton(
      style: effectiveStyle,
      onPressed: widget.onPressed,
      child: coreButtonChild,
    );

    // Apply gradient if provided and not disabled
    if (widget.gradient != null && !isDisabled) {
      buttonItself = Container(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          boxShadow: widget.style?.elevation?.resolve({}) != null && widget.style?.elevation?.resolve({})! > 0
              ? [
                  BoxShadow(
                    color: widget.style?.shadowColor?.resolve({}) ?? Colors.black.withOpacity(0.2),
                    blurRadius: widget.style?.elevation?.resolve({})! * 2,
                    spreadRadius: 0,
                    offset: Offset(0, widget.style?.elevation?.resolve({})! / 2),
                  )
                ]
              : [],
        ),
        child: ElevatedButton( // ElevatedButton here for behavior, styled to be transparent over gradient
          style: effectiveStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0), // Elevation handled by container
          ),
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      );
    }

    Widget animatedButton = AnimatedScale(
      scale: pressScale,
      duration: const Duration(milliseconds: 100),
      child: buttonItself,
    );

    if (widget.isPulsing && !isDisabled) {
      animatedButton = ScaleTransition(
        scale: _pulsingAnimation,
        child: animatedButton,
      );
    }

    // Add Semantics and Tooltip
    // If widget.child is Text, its data can be used for semantics if tooltip is null.
    String? semanticLabel = widget.tooltip;
    if (semanticLabel == null && widget.child is Text) {
      semanticLabel = (widget.child as Text).data;
    }

    // The GestureDetector is for the press down/up animation state.
    // The ElevatedButton handles the actual onPressed and focus.
    // Tooltip is applied to the ElevatedButton itself (or its container).
    Widget finalButton = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: animatedButton,
    );

    if (widget.tooltip != null) {
      finalButton = Tooltip(
        message: widget.tooltip!,
        child: finalButton,
      );
    }

    // Add a comment regarding text scaling and button padding/min size.
    // TODO (Accessibility): Review padding (kSpacingMedium, kSpacingSmall) and consider minimumSize
    // constraints in ButtonStyle to ensure good tap targets and text wrapping if font sizes are increased significantly by user settings.

    return finalButton;
  }
}
