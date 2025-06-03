import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_permissions.dart';
import '../models/chat_theme.dart';

final chatServiceProvider = Provider((ref) => ChatService());

// Stream des messages du lobby
final lobbyMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, lobbyId) {
  return ref.read(chatServiceProvider).streamMessages(lobbyId);
});

class ChatService {
  final _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference _messages(String lobbyId) =>
      _firestore.collection('lobbies').doc(lobbyId).collection('messages');
  CollectionReference get _permissions =>
      _firestore.collection('chat_permissions');

  // Obtenir le stream des messages
  Stream<List<ChatMessage>> getMessages(String lobbyId) {
    return _messages(lobbyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // Envoyer un message
  Future<void> sendMessage({
    required String lobbyId,
    required String senderId,
    required String senderName,
    required String content,
    String type = 'user',
    ChatTheme? chatTheme,
  }) async {
    final message = ChatMessage(
      id: '',
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
      type: type,
      chatTheme: chatTheme,
    );

    await _messages(lobbyId).add(message.toFirestore());
  }

  // Envoyer un message système
  Future<void> sendSystemMessage({
    required String lobbyId,
    required String content,
  }) async {
    await sendMessage(
      lobbyId: lobbyId,
      senderId: 'system',
      senderName: 'Système',
      content: content,
      type: 'system',
    );
  }

  // Supprimer un message
  Future<void> deleteMessage(String lobbyId, String messageId) async {
    await _messages(lobbyId)
        .doc(messageId)
        .update({'isDeleted': true});
  }

  // Obtenir les permissions d'un joueur
  Future<ChatPermissions> getPermissions(String gameId, String playerId) async {
    final doc = await _permissions
        .where('gameId', isEqualTo: gameId)
        .where('playerId', isEqualTo: playerId)
        .get();

    if (doc.docs.isEmpty) {
      // Créer des permissions par défaut si elles n'existent pas
      final defaultPermissions = ChatPermissions(
        gameId: gameId,
        playerId: playerId,
      );

      await _permissions.add(defaultPermissions.toFirestore());
      return defaultPermissions;
    }

    return ChatPermissions.fromFirestore(doc.docs.first);
  }

  // Mettre à jour les permissions
  Future<void> updatePermissions(ChatPermissions permissions) async {
    final doc = await _permissions
        .where('gameId', isEqualTo: permissions.gameId)
        .where('playerId', isEqualTo: permissions.playerId)
        .get();

    if (doc.docs.isNotEmpty) {
      await _permissions.doc(doc.docs.first.id).update(permissions.toFirestore());
    } else {
      await _permissions.add(permissions.toFirestore());
    }
  }

  // Stream de messages pour un lobby spécifique
  Stream<List<ChatMessage>> streamMessages(String lobbyId) {
    return _messages(lobbyId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  // Stream des messages privés (loups-garous)
  Stream<List<ChatMessage>> streamPrivateMessages(String lobbyId) {
    return _messages(lobbyId)
        .where('type', isEqualTo: 'private')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  // Nettoyer les anciens messages
  Future<void> cleanOldMessages(String lobbyId) async {
    final oldMessages = await _messages(lobbyId)
        .where(
          'timestamp',
          isLessThan: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 24)),
          ),
        )
        .get();

    for (var doc in oldMessages.docs) {
      await doc.reference.delete();
    }
  }
}
