import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';

enum SnackBarType { success, error, info, warning }

class ThemedSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final LinearGradient gradient;
    final Color textColor;
    final IconData icon;

    switch (type) {
      case SnackBarType.success:
        gradient = LinearGradient(
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF81C784),
          ],
        );
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        gradient = LinearGradient(
          colors: [
            const Color(0xFFF44336),
            const Color(0xFFE57373),
          ],
        );
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        gradient = LinearGradient(
          colors: [
            const Color(0xFFFFA726),
            const Color(0xFFFFB74D),
          ],
        );
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
      default:
        gradient = isDarkMode
            ? ThemeConstants.nightPrimaryGradient
            : ThemeConstants.dayPrimaryGradient;
        textColor = Colors.white;
        icon = Icons.info;
    }

    final snackBar = SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onAction();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    actionLabel.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
} 