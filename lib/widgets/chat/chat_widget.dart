import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../theme/theme_controller.dart';
import '../themed/themed_input.dart';
import '../themed/themed_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatWidget extends ConsumerStatefulWidget {
  final String gameId;
  final String userId;
  final String userName;

  const ChatWidget({
    Key? key,
    required this.gameId,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  ConsumerState<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatService = ref.read(chatServiceProvider);
    final isDarkMode = ref.read(themeControllerProvider);

    try {
      await chatService.sendMessage(
        gameId: widget.gameId,
        senderId: widget.userId,
        senderName: widget.userName,
        content: _messageController.text.trim(),
        chatTheme: isDarkMode ? ChatTheme.night : ChatTheme.day,
      );

      _messageController.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeControllerProvider);
    final chatService = ref.watch(chatServiceProvider);

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: chatService.getMessages(widget.gameId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final messages = snapshot.data!;

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isCurrentUser = message.senderId == widget.userId;

                  return Align(
                    alignment: isCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ThemedCard(
                        padding: const EdgeInsets.all(12),
                        elevation: 2,
                        slideDirection: isCurrentUser
                            ? SlideDirection.left
                            : SlideDirection.right,
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message.senderName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  timeago.format(
                                    message.timestamp.toDate(),
                                    locale: 'fr',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white38
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ThemedInput(
                  label: '',
                  hint: 'Écrivez votre message...',
                  controller: _messageController,
                  prefixIcon: Icons.message,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 