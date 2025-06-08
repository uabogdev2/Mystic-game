import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'dart:math'; // For Random

import '../../models/chat_message.dart'; // TODO: Update path
import '../../models/game_state.dart'; // For GameChatContext // TODO: Update path
import '../chat/chat_message_bubble.dart'; // TODO: Update path
import '../themed/themed_input.dart'; // TODO: Update path
import '../themed/themed_button.dart'; // TODO: Update path
import '../../constants/design_constants.dart'; // TODO: Update path

// TODO (Accessibility): Ensure FocusOrder is logical.
// TODO (Accessibility): Consider Enter key submission for chat input. ThemedInput's onSubmitted handles this.
// TODO (Performance - Chat): Implement message pagination for loading history efficiently.
// TODO (Performance - Chat): Implement local caching strategy for messages.
// TODO (Performance - Chat): If implementing search or real-time filtering, apply debouncing to input.

class GameChatWidget extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final PlayerRole currentPlayerRole;
  final bool isHost;
  final GameChatContext chatContext;
  final List<Player> allPlayers;

  // INFO (Performance): GameChatWidget is StatefulWidget due to local message list, timers, and animations.
  const GameChatWidget({ // Made constructor const
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentPlayerRole,
    required this.isHost,
    required this.chatContext,
    required this.allPlayers,
  });

  @override
  State<GameChatWidget> createState() => _GameChatWidgetState();
}

class _GameChatWidgetState extends State<GameChatWidget> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<AnimationController> _animationControllers = [];

  String? _typingUser;
  Timer? _typingIndicatorTimer; // Renamed from _typingIndicatorTimerSim for clarity
  Timer? _systemMessageTimer;
  bool _isMentioning = false;

  @override
  void initState() {
    super.initState();
    _addInitialMessagesBasedOnContext();
    _systemMessageTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
       if (!mounted) {
        timer.cancel();
        return;
      }
      _simulateGameEvents();
    });
  }

  @override
  void didUpdateWidget(GameChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatContext != oldWidget.chatContext) {
      _addContextChangeMessage();
    }
  }

  void _addInitialMessagesBasedOnContext() {
     _addMessage(ChatMessage.system(
      messageId: "sys_context_init_${DateTime.now().millisecondsSinceEpoch}",
      content: "Chat initialisé pour: ${widget.chatContext.toString().split('.').last}",
      type: ChatMessageType.system,
    ));
    if (widget.chatContext == GameChatContext.night_wolves && widget.currentPlayerRole == PlayerRole.loup_garou) {
        _addMessage(ChatMessage.system(
          messageId: "sys_wolves_welcome_${DateTime.now().millisecondsSinceEpoch}",
          content: "Loups-Garous, planifiez discrètement votre prochaine victime...",
          type: ChatMessageType.system,
      ));
    }
  }

  void _addContextChangeMessage() {
    _addMessage(ChatMessage.system(
      messageId: "sys_context_change_${DateTime.now().millisecondsSinceEpoch}",
      content: "Le contexte du chat est maintenant: ${widget.chatContext.toString().split('.').last}",
      type: ChatMessageType.announcement,
    ));
  }

  void _simulateGameEvents() {
    if (widget.chatContext == GameChatContext.day_debate || widget.chatContext == GameChatContext.dead_observers) {
      final random = Random();
      if (random.nextDouble() < 0.2) {
        final deadPlayer = widget.allPlayers[random.nextInt(widget.allPlayers.length)];
        if (deadPlayer.isAlive) {
             _addMessage(ChatMessage.system(
              messageId: "sys_player_death_${DateTime.now().millisecondsSinceEpoch}",
              content: "${deadPlayer.name} a été retrouvé mort ce matin!",
              type: ChatMessageType.announcement,
            ));
        }
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (widget.chatContext == GameChatContext.night_silence && widget.currentPlayerRole != PlayerRole.loup_garou ) {
      _messageController.clear();
      return;
    }

    // **Conceptual Content Filtering Placeholder**
    // String filteredText = text;
    // if (profanityFilter.isProfane(text)) { // Assume a profanityFilter utility
    //   filteredText = "[Message Modéré]";
    // }

    final message = ChatMessage(
      messageId: "${widget.currentUserId}_${DateTime.now().millisecondsSinceEpoch}",
      senderId: widget.currentUserId,
      senderName: widget.currentUserName,
      content: text,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.normal,
    );
    _addMessage(message);
    _messageController.clear();
    if(mounted) setState(() => _isMentioning = false);
    _typingUser = null;
    _typingIndicatorTimer?.cancel();
  }

  void _addMessage(ChatMessage message) {
    if (widget.chatContext == GameChatContext.night_wolves) {
      bool amIWolf = widget.currentPlayerRole == PlayerRole.loup_garou;
      // Ensure Player model has `role` property accessible for this check
      bool isSenderWolf = widget.allPlayers.firstWhere((p) => p.id == message.senderId, orElse: () => Player(id: "", name: "", role: PlayerRole.unknown)).role == PlayerRole.loup_garou;

      if (!amIWolf && message.messageType == ChatMessageType.normal) return;
      if (amIWolf && !isSenderWolf && message.messageType == ChatMessageType.normal && message.senderId != widget.currentUserId) return;
    }

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // TODO (Performance): Consider removing animation controllers from list if message is removed.
    _animationControllers.add(animationController);

    if(mounted) {
      setState(() {
        _messages.add(message);
      });
    }
    animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onInputChanged(String text) {
    _typingIndicatorTimer?.cancel();
    bool currentlyMentioning = text.endsWith('@') || (text.contains('@') && _messageController.selection.baseOffset > text.lastIndexOf('@') && !text.substring(text.lastIndexOf('@')).contains(' '));
    if (mounted && _isMentioning != currentlyMentioning) {
      setState(() {
        _isMentioning = currentlyMentioning;
      });
    }

    if (text.isNotEmpty) {
      // Typing indicator logic (placeholder)
    } else {
      if (mounted) {
        setState(() {
          _typingUser = null;
          if(_isMentioning) _isMentioning = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear(); // Clear the list itself
    _typingIndicatorTimer?.cancel();
    _systemMessageTimer?.cancel();
    super.dispose();
  }

  // _getContextualInputFillColor is removed as ThemedInput styling is internal or via wrapper

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool canSendMessage = true;
    String inputHint = "Envoyer un message...";

    if (widget.chatContext == GameChatContext.night_silence && widget.currentPlayerRole != PlayerRole.loup_garou ) {
        canSendMessage = false;
        inputHint = "Le silence règne...";
    }
    // Ensure player is found before checking isAlive, provide a default if not found
    final currentPlayerFromList = widget.allPlayers.firstWhere((p)=> p.id == widget.currentUserId, orElse: () => Player(id: widget.currentUserId, name: widget.currentUserName, isAlive: false));
    if (!currentPlayerFromList.isAlive && widget.chatContext != GameChatContext.dead_observers){
        canSendMessage = false;
        inputHint = "Les morts ne parlent pas (ici).";
    }

    // INFO (Performance): ListView.builder for chat. Consider itemExtent for fixed height items.
    // TODO (Performance): For very high message rates, explore more optimized list views or data structures.
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(kSpacingXS),
            itemCount: _messages.length,
            // itemExtent: kChatMessageBubbleEstimatedHeight, // Example if all bubbles have similar height
            itemBuilder: (context, index) {
              final message = _messages[index];
              final animController = (index < _animationControllers.length)
                                      ? _animationControllers[index]
                                      : AnimationController(duration: const Duration(milliseconds: 300), vsync: this)..forward();

              if (widget.chatContext == GameChatContext.night_wolves &&
                  widget.currentPlayerRole != PlayerRole.loup_garou &&
                  message.messageType == ChatMessageType.normal) {
                return const SizedBox.shrink();
              }

              return FadeTransition(
                opacity: CurvedAnimation(parent: animController, curve: Curves.easeIn),
                child: SizeTransition(
                  sizeFactor: CurvedAnimation(parent: animController, curve: Curves.easeOut),
                  child: ChatMessageBubble( // This could be const if message properties were final and ChatMessageBubble was const.
                    message: message,
                    currentUserId: widget.currentUserId,
                    isHostView: widget.isHost,
                    chatContext: widget.chatContext,
                  ),
                ),
              );
            },
          ),
        ),
        if (_typingUser != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium, vertical: kSpacingXXS),
            child: Text(
              "$_typingUser est en train d'écrire...",
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(kSpacingXS),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: _isMentioning ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: _isMentioning ? theme.colorScheme.tertiary.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(kBorderRadiusMedium + (_isMentioning ? 1.5 : 0)),
                  ),
                  child: ThemedInput(
                    controller: _messageController,
                    hintText: inputHint,
                    enabled: canSendMessage,
                    onChanged: _onInputChanged,
                    textInputAction: TextInputAction.send,
                    onSubmitted: canSendMessage ? (_) => _sendMessage() : null,
                  ),
                ),
              ),
              const SizedBox(width: kSpacingXS),
              ThemedButton(
                onPressed: canSendMessage ? _sendMessage : null,
                tooltip: "Envoyer le message",
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(kSpacingSmall),
                  backgroundColor: canSendMessage ? theme.colorScheme.primary : Colors.grey,
                ),
                child: const Icon(Icons.send, size: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
