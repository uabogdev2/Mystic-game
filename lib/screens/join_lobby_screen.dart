import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/lobby_service.dart';
import '../services/auth_service.dart';
import '../models/lobby.dart';
import '../widgets/animated_background.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/theme_constants.dart';
import 'lobby_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinLobbyScreen extends ConsumerStatefulWidget {
  const JoinLobbyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends ConsumerState<JoinLobbyScreen> {
  final _codeController = TextEditingController();
  bool _isJoining = false;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _isRefreshing = true);
        ref.refresh(publicLobbiesProvider);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() => _isRefreshing = false);
          }
        });
      }
    });
  }

  void _joinLobbyByCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isJoining = true);

    try {
      final lobbyService = ref.read(lobbyServiceProvider);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lobbies')
          .where('code', isEqualTo: code)
          .where('status', isEqualTo: 'waiting')
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Aucune partie trouvée avec ce code');
      }

      final lobbyDoc = querySnapshot.docs.first;
      final lobby = Lobby.fromFirestore(lobbyDoc);

      if (lobby.isFull()) {
        throw Exception('La partie est complète');
      }

      await lobbyService.joinLobby(
        lobbyId: lobby.id,
        playerName: user.displayName ?? 'Invité',
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
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _joinPublicLobby(Lobby lobby) async {
    if (_isJoining) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isJoining = true);

    try {
      final lobbyService = ref.read(lobbyServiceProvider);
      await lobbyService.joinLobby(
        lobbyId: lobby.id,
        playerName: user.displayName ?? 'Invité',
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
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final authService = ref.watch(authServiceProvider);
    final publicLobbies = ref.watch(publicLobbiesProvider);

    return Scaffold(
      appBar: AppBar(

title: Text(
  'Rejoindre une partie',
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
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Code de la partie',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Entrez le code...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isJoining ? null : _joinLobbyByCode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isJoining
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Rejoindre',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Parties publiques',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: publicLobbies.when(
                    data: (lobbies) {
                      if (lobbies.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aucune partie publique disponible',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              if (_isRefreshing)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() => _isRefreshing = true);
                          ref.refresh(publicLobbiesProvider);
                          await Future.delayed(const Duration(seconds: 1));
                          if (mounted) {
                            setState(() => _isRefreshing = false);
                          }
                        },
                        child: ListView.builder(
                          itemCount: lobbies.length,
                          itemBuilder: (context, index) {
                            final lobby = lobbies[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: isDark
                                  ? ThemeConstants.nightCardColor
                                  : ThemeConstants.dayCardColor,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  'Partie de ${lobby.playerNames.first}',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${lobby.playerIds.length}/${lobby.maxPlayers} joueurs',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: _isJoining || lobby.isFull()
                                      ? null
                                      : () => _joinPublicLobby(lobby),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? ThemeConstants.nightPrimaryGradient.colors.first
                                        : ThemeConstants.dayPrimaryGradient.colors.first,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    lobby.isFull() ? 'Complet' : 'Rejoindre',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Erreur de chargement',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () => ref.refresh(publicLobbiesProvider),
                            child: const Text('Réessayer'),
                          ),
                        ],
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