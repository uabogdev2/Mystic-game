import 'package:flutter/foundation.dart'; // For @required if using older Flutter, or just for clarity

// Enum for different types of chat messages
enum ChatMessageType {
  normal,       // A standard user message
  system,       // General system messages (e.g., "Lobby created")
  playerJoin,   // Player joined the lobby
  playerLeave,  // Player left the lobby
  hostAction,   // An action taken by the host (e.g., "Host started the game")
  roleReveal,   // For game phase: role reveal messages (e.g., "You are a Loup-Garou") - future use
  announcement, // Important game announcements - future use
}

class ChatMessage {
  final String messageId;
  final String senderId;    // Could be "system" for system messages, or a user ID
  final String senderName;  // e.g., Player's name, "Système", "Hôte"
  final String content;
  final DateTime timestamp;
  final ChatMessageType messageType;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.messageType = ChatMessageType.normal,
  });

  // Example factory for creating a system message easily
  factory ChatMessage.system({
    required String messageId,
    required String content,
    ChatMessageType type = ChatMessageType.system, // Allow specifying subtype like playerJoin/Leave
  }) {
    return ChatMessage(
      messageId: messageId,
      senderId: 'system_id', // Consistent ID for system messages
      senderName: 'Système',    // Consistent name for system messages
      content: content,
      timestamp: DateTime.now(),
      messageType: type,
    );
  }
}
