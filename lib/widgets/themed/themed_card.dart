import 'package:flutter/material.dart';
import '../../constants/design_constants.dart'; // Import design constants
// TODO: Update import to core/constants path after refactoring

class ThemedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final bool animateEntry;
  final Duration animationDuration;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
    this.animateEntry = true,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<ThemedCard> createState() => _ThemedCardState();
}

class _ThemedCardState extends State<ThemedCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    if (widget.animateEntry) {
      // // Hypothetical check for reduce motion setting (Conceptual)
      // final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      // if (reduceMotion) {
      //   _animationController.value = 1.0; // Skip animation
      // } else {
      //   _animationController.forward();
      // }
      _animationController.forward(); // Original behavior
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final CardTheme cardTheme = theme.cardTheme;

    final cardColor = widget.color ?? cardTheme.color ?? theme.cardColor;
    final cardElevation = widget.elevation ?? cardTheme.elevation ?? 4.0;

    List<BoxShadow>? cardShadows;

    if (isDarkMode) {
      cardShadows = [
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.3),
          blurRadius: kBorderRadiusMedium,
          spreadRadius: kSpacingXXXS,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          blurRadius: kBorderRadiusLarge,
          spreadRadius: kSpacingXXS,
        ),
      ];
    } else {
      // Light theme shadows are typically handled well by Card's default elevation.
      // If more pronounced shadows are needed, they can be defined here like for dark mode.
      // cardShadows = [
      //   BoxShadow(
      //     color: Colors.black.withOpacity(0.15),
      //     blurRadius: cardElevation * 2,
      //     spreadRadius: 0,
      //     offset: Offset(0, cardElevation / 2),
      //   ),
      // ];
    }

    // TODO (Accessibility): Review padding (kSpacingMedium) and ensure content within the card
    // (passed as widget.child) is responsive to text scaling. Ensure interactive elements
    // within the child have adequate tap target sizes.

    Widget cardContent = Card(
      color: cardColor,
      elevation: (isDarkMode && cardShadows != null) ? 0 : cardElevation, // Use container shadow for glow
      shape: widget.shape ?? cardTheme.shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
      ),
      margin: cardTheme.margin ?? const EdgeInsets.all(kSpacingXXS), // Use theme margin or a default
      shadowColor: (isDarkMode && cardShadows != null) ? Colors.transparent : cardTheme.shadowColor,
      clipBehavior: Clip.antiAlias, // Ensure content respects rounded corners
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(kSpacingMedium),
        child: widget.child,
      ),
    );

    if (isDarkMode && cardShadows != null) {
      cardContent = Container(
        decoration: BoxDecoration(
          // This container is primarily for the glow effect.
          // The actual background color is handled by the Card itself.
          borderRadius: (widget.shape is RoundedRectangleBorder)
              ? (widget.shape as RoundedRectangleBorder).borderRadius.resolve(Directionality.maybeOf(context))
              : BorderRadius.circular(kBorderRadiusMedium), // Fallback or default
          boxShadow: cardShadows,
        ),
        // The Card is placed inside this container.
        // Margin for the Card itself should be zero as the container handles spacing/shadow.
        child: Card(
          color: cardColor,
          elevation: 0, // Elevation is handled by the outer container's boxShadow for the glow
          shape: widget.shape ?? cardTheme.shape ?? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(kSpacingMedium),
            child: widget.child,
          ),
        ),
      );
    }


    if (widget.animateEntry) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: cardContent,
        ),
      );
    } else {
      return cardContent;
    }
  }
}
