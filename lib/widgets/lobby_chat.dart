import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lobby.dart';

class LobbyChat extends ConsumerWidget {
  final String lobbyId;
  final String userId;
  final String userName;

  const LobbyChat({
    Key? key,
    required this.lobbyId,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatService = ref.watch(chatServiceProvider);
    final textController = TextEditingController();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? _hostId;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: chatService.getMessages(lobbyId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur de chargement des messages',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final messages = snapshot.data!;

              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun message',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                );
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: firestore.collection('lobbies').doc(lobbyId).snapshots(),
                builder: (context, lobbySnapshot) {
                  if (lobbySnapshot.hasData && lobbySnapshot.data != null) {
                    final lobby = Lobby.fromFirestore(lobbySnapshot.data!);
                    _hostId = lobby.hostId;
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSystem = message.type == 'system';
                      final isCurrentUser = message.senderId == userId;
                      final isHost = message.senderId == _hostId;

                      if (isSystem) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isCurrentUser) ...[
                              CircleAvatar(
                                backgroundColor: isHost
                                    ? Colors.amber
                                    : Theme.of(context).primaryColor,
                                child: Text(
                                  message.senderName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Theme.of(context).primaryColor
                                      : (isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
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
                                            color: isCurrentUser
                                                ? Colors.white
                                                : (isDark
                                                    ? Colors.white70
                                                    : Colors.black54),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (isHost) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'Hôte',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isCurrentUser
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isCurrentUser) const SizedBox(width: 8),
                          ],
                        ),
                      );
                    },
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
                child: TextField(
                  controller: textController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Votre message...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  final message = textController.text.trim();
                  if (message.isNotEmpty) {
                    chatService.sendMessage(
                      lobbyId: lobbyId,
                      senderId: userId,
                      senderName: userName,
                      content: message,
                      type: 'user',
                    );
                    textController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
} 