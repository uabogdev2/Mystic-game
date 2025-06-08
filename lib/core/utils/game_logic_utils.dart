// lib/utils/game_logic_utils.dart
Map<String, int> calculateRoles(int playerCount) {
  if (playerCount < 6) return {}; // Minimum 6 players for a game with roles

  // Define base roles and their minimum player counts for inclusion
  // Wolves calculation: roughly 25%, ensuring at least 1. Max can be playerCount / 3.
  int wolves = (playerCount * 0.25).floor().clamp(1, (playerCount ~/ 3).clamp(1, 100));

  Map<String, int> roles = {
    'loup_garou': wolves,
    // Roles are added based on player count.
    // Using a list of tuples: [roleName, minPlayerCountForRole]
    // This makes it easier to manage and scale.
    'voyante': playerCount >= 6 ? 1 : 0,        // Voyante (Seer) from 6 players
    'sorciere': playerCount >= 7 ? 1 : 0,       // Sorciere (Witch) from 7 players
    'chasseur': playerCount >= 8 ? 1 : 0,       // Chasseur (Hunter) from 8 players
    'cupidon': playerCount >= 9 ? 1 : 0,        // Cupidon (Cupid) from 9 players
    'garde': playerCount >= 10 ? 1 : 0,         // Garde (Bodyguard) from 10 players
    // 'petite_fille': playerCount >= 11 ? 1 : 0, // Petite Fille (Little Girl) from 11 (example)
    // 'ancien': playerCount >= 12 ? 1 : 0,        // Ancien (Elder) from 12 (example)
    // 'corbeau': playerCount >= 13 ? 1 : 0,       // Corbeau (Raven) from 13 (example)
    // 'maire': 0, // Mayor is usually elected, not assigned initially, but can be a role.
                  // If assigned: playerCount >= 12 ? 1 : 0 (example)
    // Add other roles from the plan as needed, e.g.:
    // 'joueur_de_flute': playerCount >= 14 ? 1 : 0,
    // 'bouc_emissaire': playerCount >= 15 ? 1 : 0,
    // 'frere_macon_1': playerCount >= 16 ? 1 : 0, // Need to handle pairs if adding multiple
    // 'frere_macon_2': playerCount >= 16 ? 1 : 0,
  };

  // Calculate total special roles (excluding wolves, already counted)
  int specialRolesCount = 0;
  roles.forEach((key, value) {
    if (key != 'loup_garou') {
      specialRolesCount += value;
    }
  });

  // Calculate villageois count
  int villageoisCount = playerCount - wolves - specialRolesCount;
  roles['villageois'] = villageoisCount.clamp(0, playerCount); // Ensure non-negative and not exceeding total

  // Filter out roles with 0 count for a cleaner output
  roles.removeWhere((key, value) => value == 0);

  // Ensure consistency: if villageois count becomes negative due to too many special roles for a given playerCount,
  // it means the role assignment logic needs adjustment for that playerCount.
  // For now, this setup prioritizes special roles and wolves.
  // A more complex system might re-balance by removing lowest priority special roles if villageois < 0.
  if (roles['villageois'] == 0 && playerCount > (wolves + specialRolesCount)) {
      // This case should ideally not be hit if logic is sound, but as a fallback:
      // If there are players left but no villagers, something is off.
      // For simplicity here, we'll assume the sum of roles should not exceed playerCount.
  }

  // Final check: sum of all roles should equal playerCount
  int totalAssignedRoles = 0;
  roles.values.forEach((count) => totalAssignedRoles += count);
  if (totalAssignedRoles != playerCount && playerCount >= 6) {
    // This indicates a discrepancy in role calculation logic vs player count.
    // For this version, we'll print a warning. A robust implementation would handle this more gracefully.
    print("Warning: Role count mismatch. Total roles: $totalAssignedRoles, Players: $playerCount");
    // Potentially adjust villageois count as a simple fix if sum is less than playerCount
    if (totalAssignedRoles < playerCount) {
        roles['villageois'] = (roles['villageois'] ?? 0) + (playerCount - totalAssignedRoles);
    }
    // If totalAssignedRoles > playerCount, the logic for adding special roles needs review for that playerCount.
  }


  return roles;
}

// Helper to format roles for display (example)
String formatRoles(Map<String, int> roles) {
  if (roles.isEmpty) return "Pas assez de joueurs.";
  return roles.entries.map((entry) => "${_capitalize(entry.key.replaceAll('_', ' '))}: ${entry.value}").join(', ');
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
