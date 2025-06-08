import 'package:flutter/material.dart';
import '../../models/game_state.dart'; // For Player
import '../themed/themed_button.dart';
import '../../constants/design_constants.dart';
import '../../utils/snackbar_utils.dart';

class VotingWidget extends StatefulWidget {
  final List<Player> eligiblePlayers; // Players who can be voted against
  final String currentUserId;
  final Function(String playerId) onVoteSubmitted; // Callback with the ID of the voted player
  final bool hasVoted; // To disable voting if already voted

  const VotingWidget({
    super.key,
    required this.eligiblePlayers,
    required this.currentUserId,
    required this.onVoteSubmitted,
    required this.hasVoted,
  });

  @override
  State<VotingWidget> createState() => _VotingWidgetState();
}

class _VotingWidgetState extends State<VotingWidget> {
  String? _selectedPlayerIdForVote;

  void _selectPlayerForVote(String playerId) {
    if (widget.hasVoted) return; // Cannot change vote once submitted (for this simulation)

    // Cannot vote for self
    if (playerId == widget.currentUserId) {
      SnackbarUtils.showThemedSnackbar(context, "Vous не pouvez pas voter pour vous-même.", type: SnackbarType.warning);
      return;
    }

    setState(() {
      if (_selectedPlayerIdForVote == playerId) {
        _selectedPlayerIdForVote = null; // Deselect
      } else {
        _selectedPlayerIdForVote = playerId;
      }
    });
  }

  void _submitVote() {
    if (_selectedPlayerIdForVote != null && !widget.hasVoted) {
      widget.onVoteSubmitted(_selectedPlayerIdForVote!);
      // Visual feedback or disable voting might be handled by parent updating `hasVoted`
    } else if (widget.hasVoted) {
       SnackbarUtils.showThemedSnackbar(context, "Vous avez déjà voté.", type: SnackbarType.info);
    }
    else {
      SnackbarUtils.showThemedSnackbar(context, "Veuillez sélectionner un joueur.", type: SnackbarType.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(kSpacingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(kBorderRadiusLarge),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.hasVoted ? "Vote Soumis!" : "Qui souhaitez-vous éliminer ?",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: kSpacingMedium),
          if (!widget.hasVoted)
            SizedBox(
              // Constrain height or use Flexible/Expanded if in a Column
              height: MediaQuery.of(context).size.height * 0.25, // Example height
              child: ListView.builder(
                itemCount: widget.eligiblePlayers.length,
                itemBuilder: (context, index) {
                  final player = widget.eligiblePlayers[index];
                  if (!player.isAlive) return const SizedBox.shrink(); // Don't show dead players for voting

                  final bool isSelected = player.id == _selectedPlayerIdForVote;
                  final bool isSelf = player.id == widget.currentUserId;

                  return Card(
                    color: isSelected ? theme.colorScheme.primaryContainer : theme.cardColor,
                    elevation: isSelected ? 4 : 2,
                    margin: const EdgeInsets.symmetric(vertical: kSpacingXXS),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Text(player.name.substring(0,1).toUpperCase()),
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.textTheme.bodyLarge?.color,
                        )
                      ),
                      trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
                      onTap: isSelf ? null : () => _selectPlayerForVote(player.id), // Cannot vote for self
                    ),
                  );
                },
              ),
            ),
          if (widget.hasVoted)
             Padding(
               padding: const EdgeInsets.symmetric(vertical: kSpacingLarge),
               child: Text(
                "En attente des autres joueurs...",
                style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
             ),
          const SizedBox(height: kSpacingMedium),
          if (!widget.hasVoted)
            ThemedButton(
              onPressed: _selectedPlayerIdForVote != null ? _submitVote : null,
              isPulsing: _selectedPlayerIdForVote != null,
              child: const Text("Soumettre le Vote"),
            ),
          // Placeholder for vote counts (to be implemented if needed)
          // if (showVoteCounts) ... [
          //   const SizedBox(height: kSpacingMedium),
          //   Text("Résultats des votes (placeholder):", style: theme.textTheme.titleMedium),
          //   ...voteCounts.entries.map((entry) => Text("${entry.key}: ${entry.value} vote(s)")),
          // ]
        ],
      ),
    );
  }
}
