import 'package:flutter/material.dart';
import '../constants/design_constants.dart'; // For padding/radius if needed

enum SnackbarType { info, success, warning, error }

class SnackbarUtils {
  static void showThemedSnackbar(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor; // Typically content color will be derived by SnackBarTheme or defaults

    switch (type) {
      case SnackbarType.success:
        backgroundColor = isDarkMode ? Colors.green[700]! : Colors.green[400]!;
        textColor = Colors.white; // Ensure contrast
        break;
      case SnackbarType.warning:
        backgroundColor = isDarkMode ? Colors.orange[700]! : Colors.orange[400]!;
        textColor = Colors.black87; // Ensure contrast
        break;
      case SnackbarType.error:
        backgroundColor = isDarkMode ? theme.colorScheme.errorContainer : theme.colorScheme.error;
        textColor = isDarkMode ? theme.colorScheme.onErrorContainer : theme.colorScheme.onError;
        break;
      case SnackbarType.info:
      default:
        // Use SnackBarTheme defaults or a subtle color
        backgroundColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
        textColor = isDarkMode ? Colors.white : Colors.black87;
        break;
    }

    // For info, try to use theme's snackbar colors if defined, else fallback.
    // SnackBarThemeData snackBarTheme = theme.snackBarTheme;
    // if (type == SnackbarType.info) {
    //   backgroundColor = snackBarTheme.backgroundColor ?? (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!);
    //   textColor = snackBarTheme.contentTextStyle?.color ?? (isDarkMode ? Colors.white : Colors.black87);
    // }


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor, fontFamily: 'Poppins'),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating, // Floating looks more modern
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusSmall),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: kSpacingMedium,
          vertical: kSpacingMedium,
        ),
      ),
    );
  }
}
