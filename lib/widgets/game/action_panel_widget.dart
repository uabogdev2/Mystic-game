import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../themed/themed_button.dart';
import '../../constants/design_constants.dart';
import '../../utils/snackbar_utils.dart'; // For showing action feedback

// Define a simple callback type for actions that might require targeting
typedef void RequestTargetingCallback(String actionType, String buttonText);

class ActionPanelWidget extends StatelessWidget {
  final PlayerRole currentPlayerRole;
  final GamePhase gamePhase;
  final bool isPlayerAlive;
  final RequestTargetingCallback requestTargetingMode; // Callback to GameScreen
  final VoidCallback? onNoTargetAction; // For actions that don't require targeting

  const ActionPanelWidget({
    super.key,
    required this.currentPlayerRole,
    required this.gamePhase,
    required this.isPlayerAlive,
    required this.requestTargetingMode,
    this.onNoTargetAction,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> actionButtons = _buildActionButtons(context);

    if (actionButtons.isEmpty || !isPlayerAlive) {
      // If no actions or player is dead, show a placeholder or nothing
      return Container(
        padding: const EdgeInsets.all(kSpacingMedium),
        child: Center(
          child: Text(
            !isPlayerAlive ? "Les morts ne parlent pas... ni n'agissent." : "Aucune action disponible pour le moment.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall, horizontal: kSpacingXS),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
      ),
      child: Wrap( // Use Wrap for buttons to flow if space is limited
        alignment: WrapAlignment.center,
        spacing: kSpacingSmall,
        runSpacing: kSpacingXS,
        children: actionButtons,
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    // Common actions (available to most roles if alive)
    if (gamePhase == GamePhase.day && isPlayerAlive) {
      buttons.add(
        ThemedButton(
          onPressed: () => requestTargetingMode("day_vote", "Désigner pour le Vote"),
          child: const Text("Voter pour Éliminer"),
        ),
      );
    }

    // Role-specific actions
    switch (currentPlayerRole) {
      case PlayerRole.voyante:
        if (gamePhase == GamePhase.night && isPlayerAlive) {
          buttons.add(
            ThemedButton(
              onPressed: () => requestTargetingMode("inspect_voyante", "Inspecter un Joueur"),
              child: const Text("Inspecter un Joueur"),
            ),
          );
        }
        break;
      case PlayerRole.loup_garou:
        if (gamePhase == GamePhase.night && isPlayerAlive) {
          buttons.add(
            ThemedButton(
              onPressed: () => requestTargetingMode("kill_loup", "Désigner pour Élimination"),
              child: const Text("Dévorer une Victime"),
            ),
          );
        }
        break;
      case PlayerRole.sorciere:
        if (gamePhase == GamePhase.night && isPlayerAlive) {
          // These actions might need to know who was targeted by wolves (passed from GameScreen state)
          // For now, they are general target selections.
          buttons.add(
            ThemedButton(
              onPressed: () {
                // Sorciere might save someone without targeting, or target self/other for heal
                // Placeholder: For now, assume potion de vie is used on "last attacked" (not implemented here)
                // Or, it enables targeting for healing someone.
                SnackbarUtils.showThemedSnackbar(context, "Potion de Vie utilisée (simulé)", type: SnackbarType.success);
                // requestTargetingMode("save_sorciere", "Utiliser Potion de Vie");
              },
              child: const Text("Potion de Vie (1)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            ),
          );
          buttons.add(
            ThemedButton(
              onPressed: () => requestTargetingMode("kill_sorciere", "Utiliser Potion de Mort"),
              child: const Text("Potion de Mort (1)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
            ),
          );
        }
        break;
      // Add other roles and their actions here
      // e.g. Chasseur (action on death, not typically a button press)
      // e.g. Garde (select someone to protect at night)
      case PlayerRole.garde:
        if (gamePhase == GamePhase.night && isPlayerAlive) {
           buttons.add(
            ThemedButton(
              onPressed: () => requestTargetingMode("protect_garde", "Protéger un Joueur"),
              child: const Text("Protéger Quelqu'un"),
            ),
          );
        }
        break;
      default:
        // No specific actions for this role/phase combination
        break;
    }
    return buttons;
  }
}
