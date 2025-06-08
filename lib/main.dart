import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;

// Updated imports
import 'core/themes/app_theme.dart';
import 'core/themes/theme_controller.dart';
import 'core/themes/theme_constants.dart';
import 'screens/splash_screen.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'screens/game_selection_screen.dart';
import 'features/auth/application/services/auth_service.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/animated_background.dart';
import 'core/constants/strings.dart';
import 'services/lobby_service.dart';

// INFO (Performance): Ensure all subscriptions (Streams, ValueNotifiers, etc.)
// are properly cancelled in dispose methods throughout the app to prevent memory leaks.
// Regularly review widget rebuilds using Flutter DevTools (Performance Overlay, Widget Rebuild Stats)
// to identify and optimize unnecessary rebuilds, especially in frequently updated UI sections.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setDefaultLocale('fr');

  final lobbyService = LobbyService();
  lobbyService.startCleanupTimer();
  lobbyService.cleanInactiveLobbies();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeControllerProvider);
    final authState = ref.watch(authStateProvider);

    // INFO (Performance): MaterialApp rebuilds when isDarkMode or authState changes.
    // This is generally acceptable for a root widget.
    // If specific parts of the MaterialApp (like home) were complex and didn't depend on
    // both isDarkMode and authState, further optimization might involve splitting them.
    return MaterialApp(
      title: Strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showSplash
          ? SplashScreen(
              onComplete: () => setState(() => _showSplash = false),
            )
          : authState.when(
              data: (user) => user != null ? const GameSelectionScreen() : const AuthScreen(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const AuthScreen(),
            ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);
  // INFO (Performance): HomePage is a ConsumerWidget. It will rebuild if its consumed providers change.
  // Ensure that only necessary data is consumed to prevent excessive rebuilds.
  // The child widgets (AnimatedBackground, Text, Card, etc.) are mostly stateless or simple stateful,
  // which is good for performance unless they are part of a very frequently changing parent.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AnimatedBackground( // INFO (Performance): AnimatedBackground should be optimized if its animation is complex and always running.
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Strings.appTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: ThemeConstants.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const ThemeToggleButton(),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card( // INFO (Performance): Card is relatively lightweight.
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                Strings.welcome,
                                style: Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Votre voyage dans le royaume mystique commence ici',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
