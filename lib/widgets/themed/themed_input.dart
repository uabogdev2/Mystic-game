import 'package:flutter/material.dart';
import '../../constants/design_constants.dart'; // Import design constants

class ThemedInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon; // Changed to Widget for more flexibility (e.g. IconButton)
  final String? initialValue;
  final bool enabled;
  final int? maxLines;

  const ThemedInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.initialValue,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<ThemedInput> createState() => _ThemedInputState();
}

class _ThemedInputState extends State<ThemedInput> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderEmphasisAnimation;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), // Slightly longer for smoother feel
    );

    // This animation can be used to drive border thickness, or a color interpolation factor
    _borderEmphasisAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
      setState(() => _isFocused = true);
    } else {
      _animationController.reverse();
      setState(() => _isFocused = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange); // Important to remove listener
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define colors for border based on theme and focus state
    Color focusedBorderColor = theme.colorScheme.primary;
    Color enabledBorderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[400]!;
    Color errorBorderColor = theme.colorScheme.error;
    Color disabledBorderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;

    // Animated border width: increases when focused
    double baseBorderWidth = 1.0;
    double focusedBorderWidth = 2.0;

    return AnimatedBuilder(
      animation: _borderEmphasisAnimation,
      builder: (context, child) {
        // Calculate current border width based on animation
        // When animation value is 0 (not focused), width is baseBorderWidth.
        // When animation value is 1 (focused), width is focusedBorderWidth.
        final currentAnimatedBorderWidth = baseBorderWidth + (_borderEmphasisAnimation.value * (focusedBorderWidth - baseBorderWidth));

        return TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          style: TextStyle( // Use Poppins from theme
            color: widget.enabled ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            labelStyle: TextStyle(
              color: _isFocused ? focusedBorderColor : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
            ),
            hintStyle: TextStyle(color: isDarkMode ? Colors.grey[600] : Colors.grey[500]),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: _isFocused ? focusedBorderColor : Colors.grey)
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled
                       ? (isDarkMode ? Colors.grey[850]?.withOpacity(0.5) : Colors.grey[50])
                       : (isDarkMode ? Colors.grey[900] : Colors.grey[200]),
            contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingSmall + 2), // +2 for a bit more vertical room

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              borderSide: BorderSide(color: enabledBorderColor, width: baseBorderWidth),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              borderSide: BorderSide(
                color: widget.enabled ? enabledBorderColor : disabledBorderColor,
                width: baseBorderWidth
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              borderSide: BorderSide(
                color: focusedBorderColor,
                width: currentAnimatedBorderWidth, // Animated border width
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              borderSide: BorderSide(color: errorBorderColor, width: baseBorderWidth + 0.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              borderSide: BorderSide(color: errorBorderColor, width: currentAnimatedBorderWidth + 0.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kBorderRadiusMedium),
              borderSide: BorderSide(color: disabledBorderColor, width: baseBorderWidth),
            ),
          ),
        );
      },
    );
  }
}
