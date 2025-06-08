import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters

import '../widgets/themed/themed_button.dart';
import '../widgets/themed/themed_input.dart';
import '../widgets/themed/themed_card.dart';
import '../widgets/themed/loading_indicator.dart'; // For placeholder loading
import '../constants/design_constants.dart';
import '../utils/snackbar_utils.dart'; // For showing errors
import 'lobby_screen.dart'; // To navigate to LobbyScreen
// import '../utils/game_logic_utils.dart'; // Not strictly needed here, but LobbyScreen will use it

class JoinLobbyScreen extends StatefulWidget {
  static const String routeName = '/join_lobby';

  const JoinLobbyScreen({super.key});

  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends State<JoinLobbyScreen> {
  final TextEditingController _lobbyCodeController = TextEditingController();
  final FocusNode _lobbyCodeFocusNode = FocusNode();
  bool _isLoading = false; // For simulated join process

  void _joinLobby() async {
    final String lobbyCode = _lobbyCodeController.text.trim();
    if (lobbyCode.length != 6) {
      SnackbarUtils.showThemedSnackbar(
        context,
        'Le code du salon doit comporter 6 chiffres.',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    // Simulate network request or validation
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    // Placeholder: Assume validation passed and we got lobby details
    // In a real app, you'd fetch lobby details using the code.
    // For now, we'll navigate with placeholder data.
    // Max players and roles would typically come from the server/host.
    // We pass a placeholder name, and the player's actual name would be added.

    // Example: Fetch roles based on a placeholder player count (e.g. 8) if not provided by lobby data
    // final roles = calculateRoles(8);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyScreen(
          lobbyCode: lobbyCode,
          lobbyName: "Salon #$lobbyCode", // Placeholder name
          maxPlayers: 8, // Placeholder max players
          initialPlayerNames: const ["Joueur X"], // Placeholder for current user joining
          isHost: false,
          // currentRoles: roles, // Roles would be determined by the lobby's host/settings
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lobbyCodeController.dispose();
    _lobbyCodeFocusNode.dispose();
    super.dispose();
  }

  Widget _buildPlaceholderPublicLobbies(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salons Publics (Bientôt disponible)',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: kSpacingSmall),
        SizedBox(
          height: 150, // Fixed height for the placeholder list
          child: ListView.builder(
            itemCount: 3, // Show a few placeholder cards
            itemBuilder: (context, index) {
              return ThemedCard(
                padding: kPaddingAllSmall,
                margin: const EdgeInsets.only(bottom: kSpacingSmall),
                child: ListTile(
                  leading: Icon(Icons.public, color: theme.colorScheme.secondary),
                  title: Text('Salon Public ${index + 1}', style: theme.textTheme.titleMedium),
                  subtitle: Text('Joueurs: ${5 + index}/10', style: theme.textTheme.bodyMedium),
                  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  onTap: () {
                     SnackbarUtils.showThemedSnackbar(context, 'Fonctionnalité à venir!', type: SnackbarType.info);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre un Salon'),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: kPaddingAllMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ThemedInput(
              controller: _lobbyCodeController,
              focusNode: _lobbyCodeFocusNode,
              labelText: 'Code du Salon',
              hintText: 'Entrez le code à 6 chiffres',
              prefixIcon: Icons.sensor_door_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              textInputAction: TextInputAction.join,
              onSubmitted: (_) => _isLoading ? null : _joinLobby(),
            ),
            const SizedBox(height: kSpacingMedium),
            _isLoading
                ? const Center(child: LoadingIndicator(size: 48))
                : ThemedButton(
                    onPressed: _joinLobby,
                    isPulsing: true, // Make it a primary call to action
                    child: const Text('Rejoindre le Salon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
            const SizedBox(height: kSpacingXL),
            const Divider(thickness: 1, height: kSpacingXL),
            const SizedBox(height: kSpacingSmall),
            _buildPlaceholderPublicLobbies(theme),
          ],
        ),
      ),
    );
  }
}
