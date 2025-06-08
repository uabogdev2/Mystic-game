import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'dart:math'; // For Random

import '../../models/chat_message.dart'; // TODO: Update path
import '../chat/chat_message_bubble.dart'; // TODO: Update path
import '../themed/themed_input.dart'; // TODO: Update path
import '../themed/themed_button.dart'; // TODO: Update path
import '../../constants/design_constants.dart'; // TODO: Update path

// TODO (Performance - Chat): Implement message pagination for loading history efficiently.
// TODO (Performance - Chat): Implement local caching strategy for messages.
// TODO (Performance - Chat): If implementing search or real-time filtering, apply debouncing to input.

class LobbyChatWidget extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final bool isHost;

  // INFO (Performance): LobbyChatWidget is StatefulWidget because it manages local message list and timers.
  // If message state were global (e.g., Riverpod), this could potentially be a StatelessWidget + Consumer.
  const LobbyChatWidget({ // Made constructor const
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.isHost,
  });

  @override
  State<LobbyChatWidget> createState() => _LobbyChatWidgetState();
}

class _LobbyChatWidgetState extends State<LobbyChatWidget> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<AnimationController> _animationControllers = [];

  String? _typingUser;
  Timer? _playerActivityTimer;
  Timer? _typingIndicatorTimerSim;


  @override
  void initState() {
    super.initState();
    _addInitialMessages();

    _playerActivityTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _simulatePlayerActivity();
    });

    _typingIndicatorTimerSim = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _simulateTypingIndicator();
    });
  }

  void _addInitialMessages() {
    _addMessage(ChatMessage.system(
      messageId: "sys_welcome_${DateTime.now().millisecondsSinceEpoch}",
      content: "Bienvenue dans le salon ! Les règles seront expliquées par l'hôte.",
    ));
    if (widget.isHost) {
       _addMessage(ChatMessage.system(
        messageId: "sys_host_tip_${DateTime.now().millisecondsSinceEpoch}",
        content: "En tant qu'hôte, vous pouvez démarrer la partie une fois que suffisamment de joueurs ont rejoint.",
        type: ChatMessageType.hostAction
      ));
    }
  }

  void _simulatePlayerActivity() {
    final random = Random();
    if (random.nextBool() && _messages.length < 15) {
      final playerName = "Joueur${random.nextInt(10) + 2}";
      _addMessage(ChatMessage.system(
        messageId: "sys_join_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(100)}",
        content: "$playerName a rejoint le salon.",
        type: ChatMessageType.playerJoin,
      ));
    } else if (random.nextBool() && _messages.any((m) => m.senderName.startsWith("Joueur"))) {
       final playerMessage = _messages.lastWhere((m) => m.senderName.startsWith("Joueur") && m.messageType == ChatMessageType.playerJoin, orElse: () => _messages.first);
       if (playerMessage.messageType == ChatMessageType.playerJoin) {
            _addMessage(ChatMessage.system(
            messageId: "sys_leave_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(100)}",
            content: "${playerMessage.senderName.split(' ')[0]} a quitté le salon.",
            type: ChatMessageType.playerLeave,
            ));
       }
    }
  }

  void _simulateTypingIndicator() {
    final random = Random();
    if (_typingUser == null && random.nextBool()) {
      if(mounted) {
        setState(() {
          _typingUser = "Joueur${random.nextInt(10) + 2}";
        });
      }
      Future.delayed(Duration(seconds: 2 + random.nextInt(3)), () {
        if(mounted) setState(() => _typingUser = null);
      });
    }
  }


  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

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
  }

  void _addMessage(ChatMessage message) {
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // TODO (Performance): Consider removing animation controllers from list if message is removed.
    // If chat history grows very large and messages are removed from the top,
    // corresponding animation controllers should also be disposed and removed from _animationControllers.
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear(); // Clear the list itself
    _playerActivityTimer?.cancel();
    _typingIndicatorTimerSim?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // INFO (Performance): This ListView.builder rebuilds its items on new message.
    // For very active chats (e.g. >10 messages/sec), consider AnimatedList or optimizing item rebuilds.
    // For typical lobby chat volume, this is often acceptable.
    // TODO (Performance): Consider using itemExtent if all ChatMessageBubble instances will have the same height.
    // This can improve scrolling performance for long lists.
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(kSpacingXS),
            itemCount: _messages.length,
            // itemExtent: kChatMessageBubbleHeight, // Example if using itemExtent
            itemBuilder: (context, index) {
              final message = _messages[index];
              final animController = (index < _animationControllers.length)
                                      ? _animationControllers[index]
                                      : AnimationController(duration: const Duration(milliseconds:300), vsync: this)..forward();

              return FadeTransition(
                opacity: CurvedAnimation(parent: animController, curve: Curves.easeIn),
                child: SizeTransition(
                  sizeFactor: CurvedAnimation(parent: animController, curve: Curves.easeOut),
                  axisAlignment: -1.0,
                  child: ChatMessageBubble(
                    message: message,
                    currentUserId: widget.currentUserId,
                    isHostView: widget.isHost,
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
                child: ThemedInput(
                  controller: _messageController,
                  hintText: 'Envoyer un message...',
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: kSpacingXS),
              ThemedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(kSpacingSmall)),
                tooltip: "Envoyer",
                child: const Icon(Icons.send, size: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
