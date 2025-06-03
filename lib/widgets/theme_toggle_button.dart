import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_constants.dart';
import '../theme/theme_controller.dart';
import '../constants/strings.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeControllerProvider);

    return Tooltip(
      message: isDarkMode ? Strings.themeToggleLight : Strings.themeToggleDark,
      child: GestureDetector(
        onTap: () => ref.read(themeControllerProvider.notifier).toggleTheme(),
        child: AnimatedContainer(
          duration: ThemeConstants.animationDuration,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode 
              ? ThemeConstants.nightPrimaryGradient.colors.first
              : ThemeConstants.dayPrimaryGradient.colors.first,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: ThemeConstants.animationDuration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              key: ValueKey<bool>(isDarkMode),
              color: isDarkMode ? Colors.white : Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
} 