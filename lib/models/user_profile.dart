import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String displayName;
  final String? photoURL;
  final String? email;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastSeen;
  final Map<String, dynamic> stats;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.photoURL,
    this.email,
    required this.isAnonymous,
    required this.createdAt,
    required this.lastSeen,
    required this.stats,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      displayName: data['displayName'] as String,
      photoURL: data['photoURL'] as String?,
      email: data['email'] as String?,
      isAnonymous: data['isAnonymous'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
      stats: Map<String, dynamic>.from(data['stats'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoURL': photoURL,
      'email': email,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': Timestamp.fromDate(lastSeen),
      'stats': stats,
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? photoURL,
    String? email,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? lastSeen,
    Map<String, dynamic>? stats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      email: email ?? this.email,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      stats: stats ?? this.stats,
    );
  }
} 