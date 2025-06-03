import 'package:cloud_firestore/cloud_firestore.dart';

enum ThemePreference { day, night, auto }

class ChatPermissions {
  final String gameId;
  final String playerId;
  final bool canSend;
  final bool canReceive;
  final bool isMuted;
  final ThemePreference themePreference;
  final Timestamp lastMessageTime;

  ChatPermissions({
    required this.gameId,
    required this.playerId,
    this.canSend = true,
    this.canReceive = true,
    this.isMuted = false,
    this.themePreference = ThemePreference.auto,
    Timestamp? lastMessageTime,
  }) : lastMessageTime = lastMessageTime ?? Timestamp.now();

  factory ChatPermissions.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatPermissions(
      gameId: data['gameId'] ?? '',
      playerId: data['playerId'] ?? '',
      canSend: data['canSend'] ?? true,
      canReceive: data['canReceive'] ?? true,
      isMuted: data['isMuted'] ?? false,
      themePreference: ThemePreference.values.firstWhere(
        (e) => e.toString() == 'ThemePreference.${data['themePreference'] ?? 'auto'}',
        orElse: () => ThemePreference.auto,
      ),
      lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'playerId': playerId,
      'canSend': canSend,
      'canReceive': canReceive,
      'isMuted': isMuted,
      'themePreference': themePreference.toString().split('.').last,
      'lastMessageTime': lastMessageTime,
    };
  }

  ChatPermissions copyWith({
    bool? canSend,
    bool? canReceive,
    bool? isMuted,
    ThemePreference? themePreference,
    Timestamp? lastMessageTime,
  }) {
    return ChatPermissions(
      gameId: gameId,
      playerId: playerId,
      canSend: canSend ?? this.canSend,
      canReceive: canReceive ?? this.canReceive,
      isMuted: isMuted ?? this.isMuted,
      themePreference: themePreference ?? this.themePreference,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
} 