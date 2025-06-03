import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_theme.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String type;
  final ChatTheme? chatTheme;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    this.chatTheme,
  });

  bool get isSystem => type == 'system';

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'user',
      chatTheme: data['chatTheme'] != null ? ChatTheme.values[data['chatTheme']] : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'chatTheme': chatTheme?.index,
    };
  }
} 