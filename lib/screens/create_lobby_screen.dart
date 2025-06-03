import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/lobby_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/theme_constants.dart';
import 'lobby_screen.dart';

class CreateLobbyScreen extends ConsumerStatefulWidget {
  const CreateLobbyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends ConsumerState<CreateLobbyScreen> {
  int _selectedPlayers = 6;
  bool _isPublic = true;
  bool _isLoading = false;

  void _createLobby() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final lobby = await ref.read(lobbyServiceProvider).createLobby(
        hostName: user.displayName ?? 'Invité',
        maxPlayers: _selectedPlayers,
        isPublic: _isPublic,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyScreen(lobbyId: lobby.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer une partie',
          style: TextStyle(
            color: isDark ? Colors.white : primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.black26 : Colors.white.withOpacity(0.9),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : primaryColor,
        ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark 
                      ? ThemeConstants.nightCardColor
                      : ThemeConstants.dayCardColor,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre de joueurs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDark ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedPlayers joueurs',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _selectedPlayers > 6
                                    ? () => setState(() => _selectedPlayers--)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: isDark ? Colors.white : primaryColor,
                              ),
                              Text(
                                _selectedPlayers.toString(),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                onPressed: _selectedPlayers < 24
                                    ? () => setState(() => _selectedPlayers++)
                                    : null,
                                icon: const Icon(Icons.add_circle_outline),
                                color: isDark ? Colors.white : primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Visibilité',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDark ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'Partie publique',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _isPublic
                              ? 'Visible dans la liste des parties'
                              : 'Accessible uniquement avec le code',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value),
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
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
                    onPressed: _isLoading ? null : _createLobby,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Créer la partie',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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