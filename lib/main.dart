import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/game_selection_screen.dart';
import 'services/auth_service.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/animated_background.dart';
import 'constants/strings.dart';
import 'services/lobby_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialisation de la localisation française pour timeago
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setDefaultLocale('fr');
  
  // Démarrer le nettoyage automatique des lobbies
  final lobbyService = LobbyService();
  lobbyService.startCleanupTimer();
  lobbyService.cleanInactiveLobbies(); // Nettoyage initial
  
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AnimatedBackground(
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
                      Card(
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
