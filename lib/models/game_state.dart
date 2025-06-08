import 'package:flutter/foundation.dart'; // For @required or clarity

// Enum for Game Phases
enum GamePhase { day, night, dusk, dawn } // Added dusk/dawn for transition moments

// Enum for Player Roles (can be expanded)
enum PlayerRole {
  villageois,
  loup_garou,
  voyante, // Seer
  sorciere, // Witch
  chasseur, // Hunter
  cupidon, // Cupid
  garde, // Bodyguard
  // Add more roles as per the game design
  petite_fille, // Little Girl
  ancien,       // Elder
  corbeau,      // Raven
  maire,        // Mayor (often elected, but can be a role)
  // Special roles for future expansion
  joueur_de_flute, // Pied Piper
  bouc_emissaire,  // Scapegoat
  // etc.
  unknown, // For players whose roles are not yet revealed to current player
  dead,    // To signify a player is out of the game but might still observe
}

// Enum for Game Chat Contexts
enum GameChatContext {
  day_debate,      // Open discussion during the day
  night_wolves,    // Wolves-only chat at night
  night_sorciere,  // Sorciere's private thoughts/actions (if any UI)
  night_voyante,   // Voyante's private thoughts/actions (if any UI)
  night_silence,   // General night phase for those who don't act or see specific chats
  dead_observers,  // Chat for players who are out of the game
  system_announcement, // For important game announcements (e.g., who died)
}

// Simple Player Model
class Player {
  final String id;
  final String name;
  PlayerRole role; // Role can change or be revealed
  bool isAlive;
  bool? isHost; // Optional: if host status is relevant at player level

  Player({
    required this.id,
    required this.name,
    this.role = PlayerRole.unknown, // Default to unknown until revealed
    this.isAlive = true,
    this.isHost = false,
  });

  // For easy updates, e.g., when a player dies or role changes
  Player copyWith({
    String? name,
    PlayerRole? role,
    bool? isAlive,
    bool? isHost,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      isHost: isHost ?? this.isHost,
    );
  }

  // Example: Check if player is a werewolf
  bool get isWerewolf => role == PlayerRole.loup_garou;
}

// Helper to get a display name for roles (for UI)
String getRoleDisplayName(PlayerRole role) {
  switch (role) {
    case PlayerRole.villageois: return 'Villageois';
    case PlayerRole.loup_garou: return 'Loup-Garou';
    case PlayerRole.voyante: return 'Voyante';
    case PlayerRole.sorciere: return 'Sorcière';
    case PlayerRole.chasseur: return 'Chasseur';
    case PlayerRole.cupidon: return 'Cupidon';
    case PlayerRole.garde: return 'Garde';
    case PlayerRole.petite_fille: return 'Petite Fille';
    case PlayerRole.ancien: return 'Ancien';
    case PlayerRole.corbeau: return 'Corbeau';
    case PlayerRole.maire: return 'Maire';
    case PlayerRole.joueur_de_flute: return 'Joueur de Flûte';
    case PlayerRole.bouc_emissaire: return 'Bouc Émissaire';
    case PlayerRole.unknown: return 'Inconnu';
    case PlayerRole.dead: return 'Mort';
    default: return role.toString().split('.').last; // Fallback
  }
}
