import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:animated_text_kit/animated_text_kit.dart'; // For animated text

import '../../models/game_state.dart'; // For GamePhase enum
import '../../constants/design_constants.dart'; // For spacing
// TODO: Update import to core/constants path after refactoring


class PhaseTransitionOverlay extends StatefulWidget {
  final GamePhase targetPhase; // Day or Night
  final String message;
  final VoidCallback onComplete; // Callback when animation finishes
  final Duration duration;

  const PhaseTransitionOverlay({
    super.key,
    required this.targetPhase,
    required this.message,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 3000), // Total duration of the overlay
  });

  @override
  State<PhaseTransitionOverlay> createState() => _PhaseTransitionOverlayState();
}

class _PhaseTransitionOverlayState extends State<PhaseTransitionOverlay> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<Offset> _sunSlideAnimation;
  late Animation<Offset> _moonSlideAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  List<AnimationController> _starControllers = [];
  List<Animation<double>> _starFadeAnimations = [];
  final int _starCount = 30;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOut));

    _iconFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOut));

    // Adjust slide begin/end based on which icon should be visible initially vs sliding away/in
    final bool isNightComing = widget.targetPhase == GamePhase.night;

    _sunSlideAnimation = Tween<Offset>(
      begin: isNightComing ? Offset.zero : const Offset(0,-1.5), // Sun starts in view if day, slides from top if night
      end: isNightComing ? const Offset(0, 1.5) : Offset.zero, // Slides down for night, slides to view if day
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOutCubic));

    _moonSlideAnimation = Tween<Offset>(
      begin: !isNightComing ? Offset.zero : const Offset(0, 1.5), // Moon starts in view if night, slides from bottom if day
      end: !isNightComing ? const Offset(0, -1.5) : Offset.zero, // Slides up for day, slides to view if night
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeInOutCubic));

    _backgroundColorAnimation = ColorTween(
      begin: widget.targetPhase == GamePhase.night ? Colors.lightBlue.shade100.withOpacity(0.5) : Colors.black.withOpacity(0.5),
      end: widget.targetPhase == GamePhase.night ? Colors.black.withOpacity(0.85) : Colors.transparent,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.linear));

    if (widget.targetPhase == GamePhase.night) {
      for (int i = 0; i < _starCount; i++) {
        final starController = AnimationController(
          duration: Duration(milliseconds: 500 + _random.nextInt(1000)),
          vsync: this,
        );
        final starFade = TweenSequence<double>([
            TweenSequenceItem(tween: ConstantTween(0.0), weight: _random.nextDouble() * 40 + 10),
            TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20 + _random.nextDouble() * 20),
            TweenSequenceItem(tween: ConstantTween(1.0), weight: 40 + _random.nextDouble() * 40),
            TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20 + _random.nextDouble() * 20),
        ]).animate(CurvedAnimation(parent: starController, curve: Curves.easeInOut));

        _starControllers.add(starController);
        _starFadeAnimations.add(starFade);
        Future.delayed(Duration(milliseconds: (_mainController.duration!.inMilliseconds * 0.2).toInt() + _random.nextInt(1000)), () {
          if(mounted) starController.forward();
        });
      }
    }

    // Conceptual check for reduce motion setting
    // final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    // if (reduceMotion) {
    //   // If reduce motion is enabled, skip animations and call onComplete almost immediately.
    //   // Show a static representation of the target phase message.
    //   // This part needs to be carefully designed to provide a good UX.
    //   // For this placeholder, we'll just shorten the duration significantly
    //   // and ensure onComplete is called.
    //   _mainController.duration = const Duration(milliseconds: 100); // Drastically shorten
    //   // Or, directly set to end state and call onComplete:
    //   // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   //   widget.onComplete();
    //   // });
    //   // For the placeholder, we'll just let it run very fast.
    //   _mainController.forward();
    // } else {
    _mainController.forward();
    // }

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    for (var controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildStars(BuildContext context) {
    if (widget.targetPhase != GamePhase.night) return const SizedBox.shrink();
    // TODO (Accessibility): Ensure stars are decorative and don't cause issues for users sensitive to motion.
    // If reduceMotion is true, this _buildStars might return SizedBox.shrink() or fewer, static stars.
    return Stack(
      children: List.generate(_starCount, (index) {
        final top = _random.nextDouble() * MediaQuery.of(context).size.height * 0.6;
        final left = _random.nextDouble() * MediaQuery.of(context).size.width;
        final size = _random.nextDouble() * 2.5 + 0.5;
        return Positioned(
          top: top,
          left: left,
          child: FadeTransition(
            opacity: _starFadeAnimations[index],
            child: Icon(Icons.star, color: Colors.white.withOpacity(0.5 + _random.nextDouble() * 0.5), size: size),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    // if (reduceMotion) {
    //   // Simplified static display for reduce motion
    //   return Positioned.fill(
    //     child: Container(
    //       color: widget.targetPhase == GamePhase.night ? Colors.black.withOpacity(0.85) : Colors.transparent,
    //       alignment: Alignment.center,
    //       child: Text(
    //         widget.message,
    //         style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   );
    // }

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Container(
            color: _backgroundColorAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.targetPhase == GamePhase.night) _buildStars(context),
                FadeTransition(
                  opacity: _iconFadeAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SlideTransition(
                        position: _sunSlideAnimation,
                        child: Icon(Icons.wb_sunny, color: Colors.orangeAccent.withOpacity(0.8), size: 100),
                      ),
                      SlideTransition(
                        position: _moonSlideAnimation,
                        child: Icon(Icons.nightlight_round, color: Colors.blue.shade100.withOpacity(0.8), size: 100),
                      ),
                    ],
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(blurRadius: 10.0, color: Colors.black54, offset: Offset(0, 2)),
                              ],
                            ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              widget.message,
                              speed: const Duration(milliseconds: 100),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          isRepeatingAnimation: false,
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                        ),
                      ),
                      const Spacer(flex: 4),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
