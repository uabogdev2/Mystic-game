import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/game_selection_screen.dart';
import '../models/user_profile.dart';

final authServiceProvider = Provider((ref) => AuthService());
final authStateProvider = StreamProvider((ref) => FirebaseAuth.instance.authStateChanges());
final userProfileProvider = StreamProvider.family<UserProfile?, String>((ref, userId) {
  return ref.read(authServiceProvider).streamUserProfile(userId);
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Créer ou mettre à jour le profil utilisateur
      if (userCredential.user != null) {
        await _updateUserProfile(
          userCredential.user!,
          isAnonymous: false,
          email: googleUser.email,
          displayName: googleUser.displayName ?? 'Utilisateur Google',
          photoURL: googleUser.photoUrl,
        );

        // Rediriger vers l'écran de sélection
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GameSelectionScreen(),
          ),
        );
      }

      return userCredential;
    } catch (e) {
      print('Erreur de connexion Google: $e');
      return null;
    }
  }

  // Connexion anonyme
  Future<UserCredential?> signInAnonymously(BuildContext context) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      // Créer ou mettre à jour le profil utilisateur
      if (userCredential.user != null) {
        await _updateUserProfile(
          userCredential.user!,
          isAnonymous: true,
          displayName: 'Invité ${userCredential.user!.uid.substring(0, 4)}',
        );

        // Rediriger vers l'écran de sélection
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GameSelectionScreen(),
          ),
        );
      }

      return userCredential;
    } catch (e) {
      print('Erreur de connexion anonyme: $e');
      return null;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> _updateUserProfile(
    User user, {
    required bool isAnonymous,
    String? email,
    String? displayName,
    String? photoURL,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // Créer un nouveau profil
      final profile = UserProfile(
        id: user.uid,
        displayName: displayName ?? 'Utilisateur',
        photoURL: photoURL,
        email: email,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        stats: {
          'gamesPlayed': 0,
          'gamesWon': 0,
          'totalKills': 0,
        },
      );

      await userRef.set(profile.toFirestore());
    } else {
      // Mettre à jour le profil existant
      await userRef.update({
        'displayName': displayName ?? userDoc.get('displayName'),
        'photoURL': photoURL,
        'email': email,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  // Stream du profil utilisateur
  Stream<UserProfile?> streamUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  // Déconnexion
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'lastSeen': FieldValue.serverTimestamp()});
    }
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Mettre à jour les statistiques
  Future<void> updateStats(String userId, Map<String, dynamic> updates) async {
    final userRef = _firestore.collection('users').doc(userId);
    final statsUpdates = updates.map((key, value) => MapEntry('stats.$key', value));
    await userRef.update(statsUpdates);
  }
} 