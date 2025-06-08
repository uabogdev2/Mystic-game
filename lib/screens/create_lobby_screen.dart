import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters
import 'dart:math'; // For Random code generation

import '../widgets/themed/themed_button.dart'; // TODO: Update path
import '../widgets/themed/themed_input.dart';  // TODO: Update path
import '../widgets/themed/themed_card.dart';   // TODO: Update path
import '../constants/design_constants.dart'; // TODO: Update path
import '../utils/game_logic_utils.dart'; // For calculateRoles and formatRoles // TODO: Update path
import 'lobby_screen.dart'; // To navigate to LobbyScreen // TODO: Update path

// TODO (Accessibility): Ensure FocusOrder is logical for keyboard navigation:
// Slider -> Input Field -> Create Button.
// The Slider should be operable with keyboard arrows.
// The Input Field should allow Enter key submission if it makes sense (e.g., if it's the last field before create).

class CreateLobbyScreen extends StatefulWidget {
  static const String routeName = '/create_lobby';

  const CreateLobbyScreen({super.key});

  @override
  State<CreateLobbyScreen> createState() => _CreateLobbyScreenState();
}

class _CreateLobbyScreenState extends State<CreateLobbyScreen> {
  double _playerCount = 8.0;
  final int _minPlayers = 6;
  final int _maxPlayers = 18;

  final TextEditingController _lobbyNameController = TextEditingController();
  final FocusNode _lobbyNameFocusNode = FocusNode(); // For keyboard focus management
  Map<String, int> _currentRoles = {};

  @override
  void initState() {
    super.initState();
    _updateRoles(_playerCount.toInt());
  }

  void _updateRoles(int count) {
    setState(() {
      _currentRoles = calculateRoles(count);
    });
  }

  void _createLobby() {
    // TODO (Accessibility): Consider if focus should move to a loading indicator or next screen.
    final String lobbyName = _lobbyNameController.text.trim().isEmpty
        ? "Salon de ${_playerCount.toInt()}"
        : _lobbyNameController.text.trim();
    final String lobbyCode = (100000 + Random().nextInt(900000)).toString();
    final int maxPlayers = _playerCount.toInt();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyScreen( // TODO: Update LobbyScreen path
          lobbyCode: lobbyCode,
          lobbyName: lobbyName,
          maxPlayers: maxPlayers,
          initialPlayerNames: const ["Hôte"],
          isHost: true,
          currentRoles: _currentRoles,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lobbyNameController.dispose();
    _lobbyNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canCreate = _playerCount.toInt() >= _minPlayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Salon'),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: kPaddingAllMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ThemedCard(
              child: Column(
                children: [
                  Text(
                    'Nombre de Joueurs: ${_playerCount.toInt()}',
                    style: theme.textTheme.titleLarge,
                    semanticsLabel: "Nombre de joueurs sélectionné: ${_playerCount.toInt()}",
                  ),
                  Slider(
                    value: _playerCount,
                    min: _minPlayers.toDouble(),
                    max: _maxPlayers.toDouble(),
                    divisions: (_maxPlayers - _minPlayers),
                    label: _playerCount.toInt().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _playerCount = value;
                        _updateRoles(_playerCount.toInt());
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.3),
                    // TODO (Accessibility): Ensure Slider has proper semantics or is wrapped if needed.
                    // Flutter's Slider is generally accessible.
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSpacingMedium),
            ThemedInput(
              controller: _lobbyNameController,
              focusNode: _lobbyNameFocusNode,
              labelText: 'Nom du Salon (Optionnel)',
              hintText: 'Ex: Soirée Loup-Garou',
              prefixIcon: Icons.label_outline,
              textInputAction: TextInputAction.done, // Or next if more fields
              onSubmitted: (_) { if (canCreate) _createLobby(); }, // Allow Enter to submit
            ),
            const SizedBox(height: kSpacingLarge),
            ThemedCard(
              padding: kPaddingAllMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aperçu des Rôles:',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: kSpacingXS),
                  Semantics( // Provide a combined semantic label for the role list
                    label: "Aperçu des rôles: ${formatRoles(_currentRoles).isEmpty ? 'Pas assez de joueurs.' : formatRoles(_currentRoles)}",
                    child: _currentRoles.isEmpty
                        ? Text(
                            'Pas assez de joueurs pour définir les rôles.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                          )
                        : Text(
                            formatRoles(_currentRoles),
                            style: theme.textTheme.bodyLarge,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSpacingXL),
            ThemedButton(
              onPressed: canCreate ? _createLobby : null,
              isPulsing: canCreate,
              tooltip: canCreate ? "Créer le salon avec les paramètres actuels" : "Nombre de joueurs insuffisant",
              child: const Text('Créer le Salon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
