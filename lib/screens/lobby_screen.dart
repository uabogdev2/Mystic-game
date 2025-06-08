import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

// Assuming these paths are correct after the (theoretical) refactoring
// If not, they would point to core/ or shared/ locations
import '../widgets/themed/themed_button.dart';
import '../widgets/themed/themed_card.dart';
import '../constants/design_constants.dart'; // Should be core/constants
import '../utils/game_logic_utils.dart';   // Should be core/utils
import '../utils/snackbar_utils.dart';    // Should be core/utils
import 'auth_screen.dart'; // Should be features/auth/...
import '../widgets/chat/lobby_chat.dart'; // This might move to features/lobby/presentation/widgets or shared/widgets

// TODO: Update all above imports to reflect the new structure after refactoring is complete.
// For now, using original paths as they were before this theoretical refactoring subtask.

class LobbyScreen extends StatefulWidget {
  static const String routeName = '/lobby';

  final String lobbyCode;
  final String lobbyName;
  final int maxPlayers;
  final List<String> initialPlayerNames;
  final bool isHost;
  final Map<String, int>? currentRoles;

  const LobbyScreen({
    super.key,
    required this.lobbyCode,
    required this.lobbyName,
    required this.maxPlayers,
    this.initialPlayerNames = const [],
    required this.isHost,
    this.currentRoles,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late List<String> _players;
  late Map<String, int> _rolesPreview;
  final int _minPlayersToStart = 6;
  final String _currentUserId = "user_me_123";
  String _currentUserName = "Moi-même";

  // Breakpoint for tablet layout
  static const double kTabletBreakpoint = 720.0;

  @override
  void initState() {
    super.initState();
    _players = List.from(widget.initialPlayerNames);
    if (widget.isHost && _players.isNotEmpty) {
      _currentUserName = _players.first;
    } else if (!widget.isHost && _players.isNotEmpty) {
      _currentUserName = _players.firstWhere((name) => name.contains("Joueur") || name == "Moi-même", orElse: () => "Joueur X");
    }
    _rolesPreview = widget.currentRoles ?? calculateRoles(widget.maxPlayers);
    if (_players.length < widget.maxPlayers && _players.length < 5) {
      int playersToAdd = (widget.maxPlayers - _players.length).clamp(0, 3);
      for (int i = 0; i < playersToAdd; i++) {
        _players.add("Joueur ${i + _players.length + 1} (IA)");
      }
    }
  }

  void _startGame() {
    if (widget.isHost && _players.length >= _minPlayersToStart) {
      SnackbarUtils.showThemedSnackbar(context, 'La partie commence bientôt!', type: SnackbarType.success);
    } else {
      SnackbarUtils.showThemedSnackbar(context, 'Pas assez de joueurs ou vous n\'êtes pas l\'hôte.', type: SnackbarType.warning);
    }
  }

  void _leaveLobby() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()), // TODO: Update to correct AuthScreen path
      (Route<dynamic> route) => false,
    );
  }

  void _copyLobbyCode() {
    Clipboard.setData(ClipboardData(text: widget.lobbyCode));
    SnackbarUtils.showThemedSnackbar(context, 'Code du salon copié!', type: SnackbarType.info);
  }

  // Helper method for the Player List Panel (for Tablet)
  Widget _buildPlayerListPanel(BuildContext context, ThemeData theme) {
    return SingleChildScrollView( // Make this panel scrollable if content overflows
      padding: const EdgeInsets.only(right: kSpacingSmall), // Padding for tablet layout separation
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           ThemedCard(
            padding: kPaddingAllSmall,
            child: ListTile(
              leading: Icon(Icons.group, color: theme.colorScheme.primary, size: kIconSizeLarge),
              title: Text('Code du Salon: ${widget.lobbyCode}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('Appuyez pour copier', style: theme.textTheme.bodySmall),
              onTap: _copyLobbyCode,
              trailing: IconButton(
                icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
                onPressed: _copyLobbyCode,
              ),
            ),
          ),
          const SizedBox(height: kSpacingMedium),
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Joueurs (${_players.length}/${widget.maxPlayers})',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kSpacingSmall),
                SizedBox( // Consider a dynamic height or ensure this panel can scroll
                  height: 200, // Increased height for tablet view
                  child: _players.isEmpty
                      ? Center(child: Text('En attente de joueurs...', style: theme.textTheme.bodyMedium))
                      : ListView.builder(
                          itemCount: _players.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.secondaryContainer,
                                child: Text(
                                  _players[index].substring(0, 1).toUpperCase(),
                                  style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                                ),
                              ),
                              title: Text(_players[index], style: theme.textTheme.bodyLarge),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kSpacingMedium),
           ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration des Rôles (pour ${widget.maxPlayers} joueurs):',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: kSpacingXS),
                  _rolesPreview.isEmpty
                    ? Text('Les rôles seront définis par l\'hôte.', style: theme.textTheme.bodyMedium)
                    : Text(formatRoles(_rolesPreview), style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for Lobby Details and Chat Panel (for Tablet)
  Widget _buildLobbyDetailsAndChatPanel(BuildContext context, ThemeData theme, bool canStartGame) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ThemedCard(
            padding: EdgeInsets.zero,
            child: LobbyChatWidget(
              currentUserId: _currentUserId,
              currentUserName: _currentUserName,
              isHost: widget.isHost,
            ),
          ),
        ),
        const SizedBox(height: kSpacingMedium),
        _buildActionButtons(context, theme, canStartGame), // Buttons at the bottom of this panel
      ],
    );
  }

  // Helper for action buttons, used by both layouts
  Widget _buildActionButtons(BuildContext context, ThemeData theme, bool canStartGame) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Important for Column inside another Column/Row
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.isHost)
          ThemedButton(
            onPressed: canStartGame ? _startGame : null,
            isPulsing: canStartGame,
            gradient: canStartGame
                ? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary])
                : null,
            child: Text(
              'Commencer la Partie',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: canStartGame ? Colors.white : Colors.grey[700])
            ),
          ),
        const SizedBox(height: kSpacingSmall),
        ThemedButton(
          onPressed: _leaveLobby,
          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.errorContainer),
          child: Text(
            'Quitter le Salon',
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onErrorContainer)
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canStartGame = widget.isHost && _players.length >= _minPlayersToStart && _players.length <= widget.maxPlayers;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lobbyName),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Partager le code',
            onPressed: _copyLobbyCode,
          )
        ],
      ),
      body: Padding(
        padding: kPaddingAllMedium,
        child: LayoutBuilder( // Added LayoutBuilder for responsiveness
          builder: (context, constraints) {
            if (constraints.maxWidth >= kTabletBreakpoint) {
              // Tablet Layout: Row with PlayerListPanel and Details/ChatPanel
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1, // Adjust flex factor as needed
                    child: _buildPlayerListPanel(context, theme),
                  ),
                  const SizedBox(width: kSpacingMedium), // Separator
                  Expanded(
                    flex: 2, // Adjust flex factor as needed
                    child: _buildLobbyDetailsAndChatPanel(context, theme, canStartGame),
                  ),
                ],
              );
            } else {
              // Mobile Layout: Original Column layout
              return Column(
                children: <Widget>[
                  ThemedCard(
                    padding: kPaddingAllSmall,
                    child: ListTile(
                      leading: Icon(Icons.group, color: theme.colorScheme.primary, size: kIconSizeLarge),
                      title: Text('Code du Salon: ${widget.lobbyCode}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Appuyez pour copier', style: theme.textTheme.bodySmall),
                      onTap: _copyLobbyCode,
                      trailing: IconButton(
                        icon: Icon(Icons.copy, color: theme.colorScheme.secondary),
                        onPressed: _copyLobbyCode,
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  ThemedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Joueurs (${_players.length}/${widget.maxPlayers})',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kSpacingSmall),
                        SizedBox(
                          height: 150,
                          child: _players.isEmpty
                              ? Center(child: Text('En attente de joueurs...', style: theme.textTheme.bodyMedium))
                              : ListView.builder(
                                  itemCount: _players.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: theme.colorScheme.secondaryContainer,
                                        child: Text(
                                          _players[index].substring(0, 1).toUpperCase(),
                                          style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                                        ),
                                      ),
                                      title: Text(_players[index], style: theme.textTheme.bodyLarge),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  ThemedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuration des Rôles (pour ${widget.maxPlayers} joueurs):',
                           style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: kSpacingXS),
                         _rolesPreview.isEmpty
                            ? Text('Les rôles seront définis par l\'hôte.', style: theme.textTheme.bodyMedium)
                            : Text(formatRoles(_rolesPreview), style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  Expanded(
                    child: ThemedCard(
                      padding: EdgeInsets.zero,
                      child: LobbyChatWidget(
                        currentUserId: _currentUserId,
                        currentUserName: _currentUserName,
                        isHost: widget.isHost,
                      ),
                    ),
                  ),
                  const SizedBox(height: kSpacingMedium),
                  _buildActionButtons(context, theme, canStartGame),
                ],
              );
            }
          }
        ),
      ),
    );
  }
}
