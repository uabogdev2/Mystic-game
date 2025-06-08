import 'package:flutter/material.dart';
import '../widgets/themed/themed_card.dart';
import '../constants/design_constants.dart';
import '../widgets/themed/themed_button.dart'; // For potential edit button

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';

  // In a real app, user data would be passed or fetched from a service/provider
  // final User user;

  const ProfileScreen({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: kSpacingMedium, bottom: kSpacingSmall),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String label, String value, {IconData? icon}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: icon != null ? Icon(icon, color: theme.colorScheme.primary, size: 28) : null,
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    const String playerName = "LoupAlpha77";
    const String playerEmail = "alpha.loup@example.com"; // Placeholder

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Utilisateur"),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Modifier le profil (Non implémenté)",
            onPressed: () {
              // Navigate to an edit profile screen or show dialog
            },
          ),
        ],
      ),
      body: ListView(
        padding: kPaddingAllMedium,
        children: <Widget>[
          // User Info Header
          ThemedCard(
            padding: kPaddingAllMedium,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  // backgroundColor: theme.colorScheme.secondaryContainer,
                  // child: Text(playerName.substring(0,1).toUpperCase(), style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
                  child: Icon(Icons.person, size: 50), // Placeholder avatar
                ),
                const SizedBox(width: kSpacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerName,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSpacingXXS),
                      Text(
                        playerEmail, // Placeholder
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Section: Statistiques
          _buildSectionTitle(context, "Statistiques de Jeu"),
          ThemedCard(
            child: Column(
              children: [
                _buildStatTile(context, "Parties Jouées", "128 (Bientôt)", icon: Icons.games_outlined),
                const Divider(height: 1),
                _buildStatTile(context, "Victoires Totales", "72 (Bientôt)", icon: Icons.emoji_events_outlined),
                const Divider(height: 1),
                _buildStatTile(context, "Taux de Victoire", "56% (Bientôt)", icon: Icons.percent_outlined),
              ],
            ),
          ),

          // Section: Historique des Rôles (Simplified)
          _buildSectionTitle(context, "Rôles Fréquents"),
          ThemedCard(
            child: Column(
              children: [
                _buildStatTile(context, "Loup-Garou", "30 fois (Bientôt)", icon: Icons.nightlight_round_outlined),
                const Divider(height: 1),
                _buildStatTile(context, "Villageois", "65 fois (Bientôt)", icon: Icons.groups_outlined),
                const Divider(height: 1),
                _buildStatTile(context, "Voyante", "10 fois (Bientôt)", icon: Icons.visibility_outlined),
              ],
            ),
          ),

          // Section: Badges et Succès
          _buildSectionTitle(context, "Badges & Succès"),
          ThemedCard(
            child: Column(
              children: [
                 ListTile(
                  leading: Icon(Icons.shield_moon_outlined, color: theme.colorScheme.secondary, size: 28),
                  title: Text("Badge Alpha", style: theme.textTheme.titleMedium),
                  subtitle: Text("Pour avoir survécu en tant que dernier Loup-Garou. (Bientôt)", style: theme.textTheme.bodySmall),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.verified_user_outlined, color: theme.colorScheme.secondary, size: 28),
                  title: Text("Justicier du Village", style: theme.textTheme.titleMedium),
                  subtitle: Text("Pour avoir démasqué 5 Loups-Garous en tant que Villageois. (Bientôt)", style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: kSpacingLarge),
          ThemedButton(
            onPressed: () {
              // Logout logic or navigate to auth screen
               Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.errorContainer),
            child: Text("Se Déconnecter", style: TextStyle(color: theme.colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
