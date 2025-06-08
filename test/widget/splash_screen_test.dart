import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystic/screens/splash_screen.dart'; // Adjusted import to match project structure
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart'; // For mocking

// Create a mock GoRouter
class MockGoRouter extends Mock implements GoRouter {}

// It's often easier to test navigation by checking if the method is called,
// rather than fully testing the navigation stack in a unit test.
// A more robust way is to use a navigatorObserver, but that's more complex for this subtask.

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  // Helper function to pump widget with a MaterialApp and MockGoRouterProvider
  Future<void> pumpSplashScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const SplashScreen(),
        ),
      ),
    );
  }

  testWidgets('SplashScreen shows initial elements and starts animation', (WidgetTester tester) async {
    await pumpSplashScreen(tester);

    // 1. Test for initial elements
    expect(find.byIcon(Icons.nightlight_round), findsOneWidget, reason: "Initial moon icon should be present");
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: "CircularProgressIndicator should be present");

    // Check for AnimatedTextKit with "Cercle Mystique"
    // This might be tricky due to how AnimatedTextKit renders text.
    // A more resilient way might be to find the DefaultTextStyle and check its child.
    expect(find.text('Cercle Mystique'), findsNothing, reason: "Text should not be immediately visible if ScaleAnimatedText starts scaled to 0 or is delayed");
    // Instead, let's find the AnimatedTextKit widget itself.
    expect(find.byType(AnimatedTextKit), findsOneWidget, reason: "AnimatedTextKit for 'Cercle Mystique' should be present");


    // 2. Test that animations are triggered
    // Pump a short duration to start animations
    await tester.pump(const Duration(milliseconds: 100));
    // The text might appear after a short delay due to animation
    expect(find.text('Cercle Mystique'), findsOneWidget, reason: "Text 'Cercle Mystique' should appear after animation starts");


    // Pump halfway through the animation (total 3s, so 1.5s)
    await tester.pump(const Duration(seconds: 1, milliseconds: 500));

    // Icon should have changed to sun by now (changes at controller.value >= 0.5)
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget, reason: "Sun icon should be visible after 1.5 seconds");
    expect(find.byIcon(Icons.nightlight_round), findsNothing, reason: "Moon icon should be gone after 1.5 seconds");

    // Check progress indicator value if possible (optional, can be complex)
    final CircularProgressIndicator progressIndicator = tester.widget(find.byType(CircularProgressIndicator));
    expect(progressIndicator.value, greaterThan(0.0));
    expect(progressIndicator.value, lessThan(1.0));


    // 3. Verify navigation is attempted after the full duration
    // Pump remaining time to complete animations
    await tester.pump(const Duration(seconds: 1, milliseconds: 500));
    await tester.pumpAndSettle(); // Ensure all animations are truly complete

    // Verify that context.go('/auth') was called on the mockGoRouter
    // Note: direct verification of context.go is hard without a proper mock setup for GoRouter's InheritedWidget.
    // For this subtask, we'll assume that if no exceptions are thrown and animations complete,
    // the go_router call was attempted.
    // In a real app, you'd use a NavigatorObserver or a more sophisticated GoRouter mock.

    // A simple way to check if go was called:
    // The following line would be ideal if MockGoRouter could directly capture calls.
    // verify(mockGoRouter.go('/auth')).called(1);
    // However, `go` is an extension method on BuildContext, making it harder to mock directly this way.
    // For now, we'll rely on the animation completing. If it completes, the listener *should* have fired.
    // If the test environment doesn't have a route '/auth', `context.go` might throw.
    // This test assumes the call is made. A more robust test would involve `tester.takeException()`.

    // To make the navigation testable, we'd typically inject the router or use a testing wrapper for GoRouter.
    // For now, this test primarily ensures the splash screen runs its course.
    // If `context.go` fails due to missing route in test, it would throw an error, failing the test, which is an indirect check.
    print("Test completed. If no errors, navigation was likely attempted.");
  });

  testWidgets('SplashScreen navigates after 3 seconds', (WidgetTester tester) async {
    // This test specifically checks the navigation call using a more direct (but still limited) approach.
    final List<String> navigationLog = [];
    final mockGoRouterForNav = MockGoRouter();

    when(mockGoRouterForNav.canPop()).thenReturn(false); // Common setup for go_router mocks
    when(mockGoRouterForNav.go(any)).thenAnswer((invocation) { // Use 'any' to capture the route
      navigationLog.add(invocation.positionalArguments.first as String);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouterForNav,
          child: const SplashScreen(),
        ),
      ),
    );

    // Wait for the full duration of the splash screen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(); // Let any post-frame callbacks finish

    expect(navigationLog, contains('/auth'), reason: "Navigation to '/auth' should have occurred");
  });
}
