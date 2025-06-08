import 'package:flutter/material.dart';
import '../models/game_state.dart'; // For Player, PlayerRole, getRoleDisplayName
import '../widgets/themed/themed_button.dart';
import '../widgets/themed/themed_card.dart';
import '../constants/design_constants.dart';
import '../utils/snackbar_utils.dart'; // For ThemedSnackbar
// Define an enum for winning team for clarity, or use a String
enum WinningTeam { villageois, loups_garous, solo, egalite } // Solo for roles like Joueur de Flute

class EndGameScreen extends StatelessWidget {
  static const String routeName = '/end_game';

  final WinningTeam winningTeam;
  final List<Player> players; // Full list of players with their final status and roles

  const EndGameScreen({
    super.key,
    required this.winningTeam,
    required this.players,
  });

  String _getWinningMessage() {
    switch (winningTeam) {
      case WinningTeam.villageois:
        return "VICTOIRE DU VILLAGE !";
      case WinningTeam.loups_garous:
        return "VICTOIRE DES LOUPS-GAROUS !";
      case WinningTeam.solo:
        // Potentially find the solo winner's role if applicable
        // For now, a generic message.
        return "VICTOIRE D'UN JOUEUR SOLO !";
      case WinningTeam.egalite:
        return "ÉGALITÉ ! PERSONNE NE GAGNE.";
      default:
        return "FIN DE LA PARTIE";
    }
  }

  Color _getWinningMessageColor(ThemeData theme) {
     switch (winningTeam) {
      case WinningTeam.villageois:
        return Colors.green.shade700;
      case WinningTeam.loups_garous:
        return Colors.red.shade700;
      case WinningTeam.solo:
        return theme.colorScheme.tertiary;
      case WinningTeam.egalite:
        return theme.colorScheme.onSurface.withOpacity(0.7);
      default:
        return theme.colorScheme.onSurface;
    }
  }

  IconData _getRoleIcon(PlayerRole role) {
    // Placeholder icons for roles
    switch (role) {
      case PlayerRole.loup_garou:
        return Icons.nightlight_round; // Moon for werewolf
      case PlayerRole.villageois:
        return Icons.person_outline;
      case PlayerRole.voyante:
        return Icons.visibility_outlined;
      case PlayerRole.sorciere:
        return Icons.science_outlined; // Potion/science icon
      case PlayerRole.chasseur:
        return Icons.gps_fixed_outlined; // Target/crosshair
      case PlayerRole.cupidon:
        return Icons.favorite_border_outlined;
      case PlayerRole.garde:
        return Icons.shield_outlined;
      case PlayerRole.petite_fille:
        return Icons.child_friendly_outlined;
      case PlayerRole.ancien:
        return Icons.elderly_outlined;
      case PlayerRole.maire:
        return Icons.star_border_outlined;
      default:
        return Icons.help_outline; // Default for unknown or other roles
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String winningMessage = _getWinningMessage();
    final Color winningColor = _getWinningMessageColor(theme);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fin de la Partie"),
        automaticallyImplyLeading: false, // No back button
        backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
      ),
      body: Padding(
        padding: kPaddingAllMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Victory/Defeat Message
            ThemedCard(
              color: winningColor.withOpacity(0.1),
              padding: kPaddingAllMedium,
              child: Text(
                winningMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: winningColor,
                ),
              ),
            ),
            const SizedBox(height: kSpacingMedium),

            // Player Roles and Status
            Text("Récapitulatif des Rôles:", style: theme.textTheme.titleLarge),
            const SizedBox(height: kSpacingSmall),
            Expanded(
              flex: 3, // Give more space to player list
              child: ThemedCard(
                padding: const EdgeInsets.symmetric(vertical: kSpacingXS), // Less vertical padding for list items
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return ListTile(
                      leading: Icon(
                        _getRoleIcon(player.role),
                        color: player.isAlive ? theme.colorScheme.primary : Colors.grey,
                        size: 28,
                      ),
                      title: Text(
                        player.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: !player.isAlive ? TextDecoration.lineThrough : null,
                          color: !player.isAlive ? Colors.grey : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      subtitle: Text(
                        getRoleDisplayName(player.role),
                        style: theme.textTheme.bodyMedium?.copyWith(
                           color: !player.isAlive ? Colors.grey[600] : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      trailing: Text(
                        player.isAlive ? "Vivant" : "Mort",
                        style: TextStyle(
                          color: player.isAlive ? Colors.green.shade600 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: kSpacingMedium),

            // Placeholder sections
            ThemedCard(
              padding: kPaddingAllSmall,
              child: Column(
                children: [
                  Text("Statistiques complètes et graphiques (Bientôt disponible)", style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                  const SizedBox(height: kSpacingXS),
                  Text("Podium avec effets de particules (Bientôt disponible)", style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: kSpacingLarge),

            // Action Buttons
            ThemedButton(
              onPressed: () {
                // Navigate to home/auth screen. For now, using AuthScreen as placeholder.
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/auth', // Assuming AuthScreen.routeName or similar is '/auth'
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              child: const Text("Retourner à l'accueil"),
            ),
            const SizedBox(height: kSpacingSmall),
            ThemedButton(
              onPressed: () {
                SnackbarUtils.showThemedSnackbar(context, "Rejouer (Non implémenté)", type: SnackbarType.info);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
              child: Text("Rejouer", style: TextStyle(color: theme.colorScheme.onSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
