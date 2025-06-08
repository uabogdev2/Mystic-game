import 'package:flutter/material.dart';
import 'dart:async';

import '../models/game_state.dart';
import '../widgets/themed/themed_button.dart'; // TODO: Update path
import '../constants/design_constants.dart'; // TODO: Update path
import '../widgets/game/phase_transition_overlay.dart'; // TODO: Update path
import '../widgets/game/game_chat_widget.dart'; // TODO: Update path
import '../widgets/game/action_panel_widget.dart';  // TODO: Update path
import '../widgets/game/voting_widget.dart';  // TODO: Update path
import '../widgets/game/countdown_timer_widget.dart';  // TODO: Update path
import '../utils/snackbar_utils.dart'; // TODO: Update path

// TODO: Update all above imports to reflect the new structure after refactoring is complete.

// INFO (Performance - Game): Current state is local. For multiplayer, efficient state synchronization
// and a hybrid local/remote state model will be critical.
// TODO (Performance - Game): Implement robust handling for network latency and disconnections.

class GameScreen extends StatefulWidget {
  static const String routeName = '/game';

  final List<Player> initialPlayers;
  final String currentPlayerId;

  // INFO (Performance): Consider making GameScreen constructor const if all its fields are final
  // and if it's appropriate for how it's used (e.g. if passed around as a widget reference).
  // However, since it takes non-const initialPlayers, it cannot be const directly.
  const GameScreen({
    super.key,
    required this.initialPlayers,
    required this.currentPlayerId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GamePhase _currentPhase = GamePhase.day;
  late Player _currentPlayer;
  late List<Player> _activePlayers;
  GameChatContext _gameChatContext = GameChatContext.day_debate;
  bool _isPhaseTransitioning = false;
  String _phaseTransitionMessage = "";

  bool _isTargetingMode = false;
  String? _selectedPlayerId;
  String _currentTargetingAction = "";

  bool _isVotingPhaseActive = false;
  bool _currentPlayerHasVoted = false;
  Map<String, int> _voteCounts = {};

  Duration _currentPhaseDuration = const Duration(seconds: 60);
  Key _timerKey = UniqueKey();

  // INFO (Performance): All AnimationControllers, TextEditingControllers, ScrollControllers, FocusNodes, Timers
  // created in this State should be disposed in the dispose() method.
  // Currently, _timerKey is used to recreate CountdownTimerWidget, which handles its own internal Timer.

  @override
  void initState() {
    super.initState();
    // Initialize players and current player
    if (widget.initialPlayers.isEmpty) {
      _activePlayers = List.generate(
          8, (index) => Player(id: 'player_$index', name: 'Joueur ${index + 1}', role: index == 0 ? PlayerRole.loup_garou : PlayerRole.villageois, isHost: index == 0));
      if (widget.currentPlayerId.isEmpty || !_activePlayers.any((p) => p.id == widget.currentPlayerId)) {
        _currentPlayer = _activePlayers.first;
      } else {
         _currentPlayer = _activePlayers.firstWhere((p) => p.id == widget.currentPlayerId);
      }
    } else {
      _activePlayers = List.from(widget.initialPlayers);
      try {
         _currentPlayer = _activePlayers.firstWhere((p) => p.id == widget.currentPlayerId);
      } catch (e) {
         print("Error: Current player ID '${widget.currentPlayerId}' not found in initial players list. Defaulting.");
         _currentPlayer = _activePlayers.isNotEmpty ? _activePlayers.first : Player(id: widget.currentPlayerId, name: "Erreur Joueur", role: PlayerRole.unknown, isAlive: false);
      }
    }
    _currentPlayer.isHost ??= (_activePlayers.isNotEmpty && _activePlayers.first.id == _currentPlayer.id);

    _updateGameChatContext();
    _resetAndStartPhaseTimer();
  }

  void _resetAndStartPhaseTimer() {
    // INFO (Performance): Frequent calls to setState for timer updates directly in GameScreen were removed.
    // CountdownTimerWidget now manages its own timer ticks internally.
    // This setState call is for resetting phase-specific aspects.
    setState(() {
      if (_currentPhase == GamePhase.night) {
        _currentPhaseDuration = const Duration(seconds: 45);
      } else {
        _currentPhaseDuration = const Duration(seconds: 90);
      }
      _timerKey = UniqueKey();
      _isVotingPhaseActive = false;
      _currentPlayerHasVoted = false;
      _voteCounts = {};
      _isTargetingMode = false;
      _selectedPlayerId = null;
      _currentTargetingAction = "";
    });
  }

  void _simulatePhaseChange() {
    if (_isPhaseTransitioning) return;
    // INFO (Performance): This setState call triggers a rebuild. If other parts of UI don't depend
    // on _isPhaseTransitioning or _phaseTransitionMessage, they could be extracted.
    // For now, this is acceptable as phase transitions are not extremely frequent.
    setState(() {
      _isPhaseTransitioning = true;
      GamePhase nextPhase = (_currentPhase == GamePhase.day) ? GamePhase.night : GamePhase.day;
      _phaseTransitionMessage = nextPhase == GamePhase.night ? "La nuit tombe..." : "Le jour se lève...";
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      // INFO (Performance): This setState call updates the main game state after transition.
      setState(() {
        _currentPhase = (_currentPhase == GamePhase.day) ? GamePhase.night : GamePhase.day;
        _isPhaseTransitioning = false;
        _updateGameChatContext();
        _resetAndStartPhaseTimer();
        if (_currentPhase == GamePhase.day) {
          _startDayVotingPhase();
        }
      });
    });
  }

  void _startDayVotingPhase() {
    if (!_currentPlayer.isAlive) return;
    // INFO (Performance): setState for UI change (voting active, timer update).
    setState(() {
      _isVotingPhaseActive = true;
      _currentPhaseDuration = const Duration(seconds: 45);
      _timerKey = UniqueKey();
    });
  }

  void _handleVoteSubmitted(String votedPlayerId) {
    if (_currentPlayerHasVoted || !_currentPlayer.isAlive) return;
    // INFO (Performance): setState limited to vote status and counts.
    setState(() {
      _currentPlayerHasVoted = true;
      _voteCounts[votedPlayerId] = (_voteCounts[votedPlayerId] ?? 0) + 1;
    });
    SnackbarUtils.showThemedSnackbar(context, "Vous avez voté pour ${getPlayerNameById(votedPlayerId)}.", type: SnackbarType.info);
  }

  String getPlayerNameById(String playerId) {
    try {
      return _activePlayers.firstWhere((p) => p.id == playerId).name;
    } catch (e) {
      return "Joueur Inconnu";
    }
  }

  void _updateGameChatContext() {
    // INFO (Performance): This logic determines chat context. If it were more complex or
    // involved external calls, it might be moved to a separate controller/service.
    GameChatContext newContext;
    if (!_currentPlayer.isAlive) {
      newContext = GameChatContext.dead_observers;
    } else if (_currentPhase == GamePhase.night) {
      if (_currentPlayer.role == PlayerRole.loup_garou) {
        newContext = GameChatContext.night_wolves;
      } else {
        newContext = GameChatContext.night_silence;
      }
    } else {
      newContext = GameChatContext.day_debate;
    }
    if (_gameChatContext != newContext) {
      setState(() => _gameChatContext = newContext);
    }
  }

  Widget _buildPlayerAvatars(BuildContext context) {
    final theme = Theme.of(context);
    // INFO (Performance): This map() operation rebuilds player avatar widgets if _activePlayers,
    // _selectedPlayerId, or _isTargetingMode changes. PlayerAvatar could be a StatefulWidget
    // if its internal state was complex, but here it's fine as part of GameScreen's build.
    return Semantics(
      label: "Liste des joueurs",
      child: Wrap(
        spacing: kSpacingXS,
        runSpacing: kSpacingXS,
        alignment: WrapAlignment.center,
        children: _activePlayers.map((player) {
          final bool isSelected = player.id == _selectedPlayerId;
          final bool isSelf = player.id == _currentPlayer.id;
          final bool canBeTargeted = player.isAlive &&
                                     _isTargetingMode &&
                                     (!isSelf || _currentTargetingAction == "self_heal_sorciere");

          return Semantics(
            label: "Joueur: ${player.name}, Statut: ${player.isAlive ? 'Vivant' : 'Mort'}${isSelected ? ', Sélectionné' : ''}${isSelf ? ', (Vous)' : ''}",
            button: canBeTargeted,
            selected: isSelected,
            enabled: player.isAlive,
            child: Opacity(
              opacity: player.isAlive ? 1.0 : 0.4,
              child: InkWell(
                onTap: canBeTargeted ? () => _onPlayerSelected(player.id) : null,
                borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(kSpacingXXS),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                      width: 2.0,
                    ),
                    color: canBeTargeted && !isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: player.isAlive ? theme.colorScheme.secondaryContainer : Colors.grey[700],
                        child: Text(
                          player.name.isNotEmpty ? player.name.substring(0, 1).toUpperCase() : "?",
                          style: TextStyle(color: player.isAlive ? theme.colorScheme.onSecondaryContainer : Colors.white54),
                        ),
                      ),
                      const SizedBox(height: kSpacingXXS),
                      Text(
                        player.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: player.isAlive ? null : TextDecoration.lineThrough,
                          color: player.isAlive ? theme.textTheme.bodySmall?.color : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (player.id == _currentPlayer.id)
                        Text("(${getRoleDisplayName(_currentPlayer.role)})", style: theme.textTheme.labelSmall)
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onPlayerSelected(String playerId) {
    if(!_isTargetingMode) return;
    setState(() {
      if (_selectedPlayerId == playerId) {
        _selectedPlayerId = null;
      } else {
        _selectedPlayerId = playerId;
      }
    });
  }

  void _confirmTargetSelection() {
    if (_selectedPlayerId == null) {
      SnackbarUtils.showThemedSnackbar(context, "Aucun joueur sélectionné.", type: SnackbarType.warning);
      return;
    }
    final selectedPlayer = _activePlayers.firstWhere((p) => p.id == _selectedPlayerId);
    String actionMessage = "Action sur ${selectedPlayer.name} confirmée pour : $_currentTargetingAction";

    if (_currentTargetingAction == "inspect_voyante") {
      actionMessage = "Voyante inspecte ${selectedPlayer.name}... C'est un ${getRoleDisplayName(selectedPlayer.role)}! (simulé)";
    } else if (_currentTargetingAction == "kill_loup") {
      actionMessage = "Les Loups-Garous ont choisi de dévorer ${selectedPlayer.name}.";
    } else if (_currentTargetingAction == "protect_garde") {
        actionMessage = "Le Garde protège ${selectedPlayer.name} cette nuit.";
    } else if (_currentTargetingAction == "kill_sorciere") {
        actionMessage = "La Sorcière empoisonne ${selectedPlayer.name}!";
    }
    SnackbarUtils.showThemedSnackbar(context, actionMessage, type: SnackbarType.success);
    setState(() {
      _isTargetingMode = false;
      _selectedPlayerId = null;
      _currentTargetingAction = "";
    });
  }

  void _cancelTargetSelection() {
    setState(() {
      _isTargetingMode = false;
      _selectedPlayerId = null;
      _currentTargetingAction = "";
    });
  }

  @override
  void dispose() {
    // INFO (Performance): Timers like _phaseTimer (if it were active and not managed by CountdownTimerWidget)
    // and any other manual AnimationControllers, StreamSubscriptions, etc., created in this State
    // MUST be disposed here to prevent memory leaks.
    // _phaseTimer?.cancel(); // Example for a directly managed timer
    super.dispose();
  }

  void _requestTargetingMode(String actionType, String buttonText) {
    if (!_currentPlayer.isAlive) {
        SnackbarUtils.showThemedSnackbar(context, "Les morts n'ont pas d'actions.", type: SnackbarType.warning);
        return;
    }
    // INFO (Performance): This setState call is fine as it directly relates to UI mode change.
    setState(() {
      _isTargetingMode = true;
      _isVotingPhaseActive = false;
      _currentTargetingAction = actionType;
      _selectedPlayerId = null;
    });
    SnackbarUtils.showThemedSnackbar(context, "$buttonText: Sélectionnez un joueur.", type: SnackbarType.info);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // INFO (Performance): The main build method of GameScreen. Consider breaking down complex UI sections
    // into separate widgets if they have independent state or don't always need to rebuild with GameScreen.
    // Example: PlayerAvatars might not need to rebuild if only chat context changes.
    // Using `Consumer` or `ValueListenableBuilder` for granular rebuilds can be beneficial.
    // TODO (Responsive): Wrap this Scaffold's body with LayoutBuilder for tablet.
    // On tablet, PlayerAvatars + ActionPanel/Voting could be in one column (flex:1),
    // and GameChatWidget in another (flex:1 or 2), arranged in a Row.
    return Scaffold(
      appBar: AppBar(
        title: Text('Partie en Cours - ${getRoleDisplayName(_currentPlayer.role)}'),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: kSpacingXS),
            child: Center(
              child: CountdownTimerWidget(
                key: _timerKey,
                duration: _currentPhaseDuration,
                onFinished: () {
                  SnackbarUtils.showThemedSnackbar(context, "Temps écoulé!", type: SnackbarType.info);
                  if (_isVotingPhaseActive && !_currentPlayerHasVoted) {
                  } else if (_isTargetingMode) {
                     _cancelTargetSelection();
                  } else if (_currentPhase == GamePhase.day && !_isVotingPhaseActive) {
                     _startDayVotingPhase();
                  }
                  else {
                    _simulatePhaseChange();
                  }
                },
                textStyle: theme.textTheme.bodyMedium,
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(kSpacingSmall),
                child: Text(
                  _currentPhase == GamePhase.day ? "C'est le Jour" : "C'est la Nuit",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                child: _buildPlayerAvatars(context),
              ),
              const SizedBox(height: kSpacingSmall),

              if (_isTargetingMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingXXS),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ThemedButton(
                        onPressed: _cancelTargetSelection,
                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.errorContainer),
                        child: Text("Annuler", style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                      ),
                      ThemedButton(
                        onPressed: _selectedPlayerId != null ? _confirmTargetSelection : null,
                        child: const Text("Confirmer Cible"),
                      ),
                    ],
                  ),
                ),

              if (!_isTargetingMode && _isVotingPhaseActive)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    child: VotingWidget(
                      eligiblePlayers: _activePlayers.where((p) => p.isAlive && p.id != _currentPlayer.id).toList(),
                      currentUserId: _currentPlayer.id,
                      onVoteSubmitted: _handleVoteSubmitted,
                      hasVoted: _currentPlayerHasVoted,
                    ),
                  ),
                )
              else if (!_isTargetingMode && !_isVotingPhaseActive)
                Expanded(
                  flex: 2,
                   child: Padding(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    child: ActionPanelWidget(
                      currentPlayerRole: _currentPlayer.role,
                      gamePhase: _currentPhase,
                      isPlayerAlive: _currentPlayer.isAlive,
                      requestTargetingMode: _requestTargetingMode,
                      onNoTargetAction: () {
                        if (_currentPlayer.role == PlayerRole.sorciere) {
                           SnackbarUtils.showThemedSnackbar(context, "Potion de Vie utilisée sur vous-même (simulé).", type: SnackbarType.success);
                        }
                      },
                    ),
                  ),
                ),
              Expanded(
                flex: 3,
                child: GameChatWidget(
                  currentUserId: _currentPlayer.id,
                  currentUserName: _currentPlayer.name,
                  currentPlayerRole: _currentPlayer.role,
                  isHost: _currentPlayer.isHost ?? false,
                  chatContext: _gameChatContext,
                  allPlayers: _activePlayers,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(kSpacingSmall),
                child: ThemedButton(
                  onPressed: _simulatePhaseChange,
                  child: Text(_currentPhase == GamePhase.day ? 'Passer à la Nuit' : 'Passer au Jour'),
                ),
              ),
            ],
          ),
          if (_isPhaseTransitioning)
            PhaseTransitionOverlay(
              targetPhase: _currentPhase == GamePhase.day ? GamePhase.night : GamePhase.day,
              message: _phaseTransitionMessage,
              onComplete: () {
              },
            ),
        ],
      ),
    );
  }
}
