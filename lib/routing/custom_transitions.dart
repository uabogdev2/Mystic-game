import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // GoRouter is needed for CustomTransitionPage

// A Fade Transition Page
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
    super.transitionDuration = const Duration(milliseconds: 300), // Default duration
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );
}

// A Slide Transition Page (e.g., from Right to Left)
class SlideTransitionPage<T> extends CustomTransitionPage<T> {
  SlideTransitionPage({
    required LocalKey super.key,
    required super.child,
    super.transitionDuration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(1.0, 0.0), // Slide from right by default
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(begin: beginOffset, end: Offset.zero);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic, // Common curve for page transitions
            );
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
        );
}

// Example of how to use it with GoRouter (for documentation purposes):
/*
GoRoute(
  path: '/some_path',
  pageBuilder: (context, state) => FadeTransitionPage(
    key: state.pageKey,
    child: const SomeScreen(),
  ),
),
GoRoute(
  path: '/another_path',
  pageBuilder: (context, state) => SlideTransitionPage(
    key: state.pageKey,
    child: const AnotherScreen(),
  ),
),
*/
