import 'package:flutter/material.dart';
import 'dart:async';

import '../../constants/design_constants.dart';

class CountdownTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback onFinished;
  final TextStyle? textStyle;
  final String prefixText;

  const CountdownTimerWidget({
    super.key,
    required this.duration,
    required this.onFinished,
    this.textStyle,
    this.prefixText = "Temps restant: ",
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late Duration _currentDuration;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentDuration.inSeconds > 0) {
          _currentDuration = _currentDuration - const Duration(seconds: 1);
        } else {
          _timer.cancel();
          widget.onFinished();
        }
      });
    });
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _timer.cancel();
      _currentDuration = widget.duration;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds"; // Include hours if needed
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.titleMedium ?? const TextStyle();
    final effectiveTextStyle = widget.textStyle ?? defaultStyle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXXS),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(kBorderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: effectiveTextStyle.fontSize, color: effectiveTextStyle.color),
          const SizedBox(width: kSpacingXS),
          Text(
            "${widget.prefixText}${_formatDuration(_currentDuration)}",
            style: effectiveTextStyle,
          ),
        ],
      ),
    );
  }
}
