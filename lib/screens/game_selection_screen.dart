import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/animated_background.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/auth_service.dart';
import '../theme/theme_constants.dart';
import 'create_lobby_screen.dart';
import 'join_lobby_screen.dart';

class GameSelectionScreen extends ConsumerWidget {
  const GameSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mystic',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: ThemeConstants.fontFamily,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : primaryColor,
          ),
        ),
        backgroundColor: isDark ? Colors.black26 : Colors.white.withOpacity(0.9),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: isDark ? Colors.white : primaryColor),
            onPressed: () {
              // TODO: Naviguer vers le profil
            },
          ),
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(Icons.logout, color: isDark ? Colors.white : primaryColor),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cercle Mystic',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: isDark ? Colors.white : primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Créez ou rejoignez une partie pour commencer l\'aventure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: isDark 
                      ? ThemeConstants.nightPrimaryGradient
                      : ThemeConstants.dayPrimaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : primaryColor).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateLobbyScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Créer une partie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white : primaryColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : primaryColor).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JoinLobbyScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: isDark ? Colors.white : primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Rejoindre une partie',
                          style: TextStyle(
                            color: isDark ? Colors.white : primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // TODO: Afficher l'aide
                  },
                  child: Text(
                    'Aide',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 