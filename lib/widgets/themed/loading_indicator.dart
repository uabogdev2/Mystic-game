import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color; // Allow overriding theme color

  const LoadingIndicator({
    super.key,
    this.size = 36.0, // Default size
    this.strokeWidth = 4.0, // Default stroke width
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine the color for the indicator
    // Use provided color, else theme's accent/primary color, else default
    final Color indicatorColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        // backgroundColor can be set for a track, if desired
        // backgroundColor: indicatorColor.withOpacity(0.2),
      ),
    );
  }
}

// Example of a more centered/full-screen loading indicator variant
class CenteredLoadingIndicator extends StatelessWidget {
  final String? message; // Optional message below the indicator

  const CenteredLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(size: 48.0), // Larger indicator
          if (message != null) ...[
            const SizedBox(height: 16.0), // kSpacingMedium
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color // Subtle color
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
