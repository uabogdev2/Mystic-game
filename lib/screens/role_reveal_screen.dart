import 'package:flutter/material.dart';
import '../models/game_state.dart'; // For PlayerRole
import '../widgets/game/role_reveal_card_widget.dart';
import '../widgets/themed/themed_button.dart';
import '../constants/design_constants.dart';
// import 'game_screen.dart'; // Or wherever to navigate next

class RoleRevealScreen extends StatelessWidget {
  static const String routeName = '/role_reveal';

  final PlayerRole assignedRole;
  final String? playerName; // Optional player name to display on card

  const RoleRevealScreen({
    super.key,
    required this.assignedRole,
    this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95), // Slightly dimmed background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kSpacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Votre Rôle Secret",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: kSpacingLarge),
              RoleRevealCardWidget(
                role: assignedRole,
                playerName: playerName, // Pass player name if available
                autoReveal: true, // Card will flip automatically on screen load
              ),
              const SizedBox(height: kSpacingXL),
              ThemedButton(
                onPressed: () {
                  // Navigate to the GameScreen or back to Lobby/Loading screen
                  // For now, pop the screen if it was pushed, or navigate to a placeholder.
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Fallback if it's the first screen (e.g. for testing)
                    // Navigator.pushReplacementNamed(context, GameScreen.routeName); // Example
                    // Or to auth screen as a generic fallback
                     Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                  }
                },
                child: const Text("Compris ! Continuer vers la partie"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
