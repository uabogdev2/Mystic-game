import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/animated_background.dart';
import '../theme/theme_constants.dart';
import '../constants/strings.dart';
import '../services/auth_service.dart';
import '../widgets/theme_toggle_button.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Bouton de thème en haut à droite
              Positioned(
                top: 16,
                right: 16,
                child: ThemeToggleButton(),
              ),
              // Contenu principal
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mystic',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFamily: ThemeConstants.fontFamily,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final userCredential = await ref.read(authServiceProvider).signInWithGoogle(context);
                                  if (userCredential != null) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Connexion réussie !')),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur de connexion: $e')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.g_mobiledata, size: 32),
                              label: const Text('Se connecter avec Google'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: isDark ? Colors.white : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  final userCredential = await ref.read(authServiceProvider).signInAnonymously(context);
                                  if (userCredential != null) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Connexion anonyme réussie !')),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur de connexion: $e')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.person_outline),
                              label: const Text('Continuer en tant qu\'invité'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                                ),
                                foregroundColor: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 