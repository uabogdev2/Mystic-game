# 🎮 Plan de Développement - Cercle Mystique

## Table des Matières
- [Phase 1: Foundation + Splash Animé + Thème Système](#phase-1-foundation--splash-animé--thème-système)
- [Phase 2: Authentification + Design Avancé + Chat Foundation](#phase-2-authentification--design-avancé--chat-foundation)
- [Phase 3: Lobby Système + Chat Lobby + Répartition Intelligente](#phase-3-lobby-système--chat-lobby--répartition-intelligente)
- [Phase 4: Logique de Jeu + Chat Contextuel + Animations de Phase](#phase-4-logique-de-jeu--chat-contextuel--animations-de-phase)
- [Phase 5: Polish + Chat Premium + Expérience Complète](#phase-5-polish--chat-premium--expérience-complète)
- [Architecture Technique](#architecture-technique-optimisée)
- [Responsive et Accessibilité](#responsive-et-accessibilité)
- [Optimisations Performances](#optimisations-performances)

## 🌅 Phase 1: Foundation + Splash Animé + Thème Système
**Durée estimée : 3-4 jours**

### Livrables Core
- ✅ Configuration Firebase complète avec projet cercle-mystic
- ✅ Structure projet organisée (MVC + Services + Widgets)
- ✅ Navigation avec go_router et routes typées
- ✅ State Management avec Provider/Riverpod

### Livrables Design
#### Splash Screen Premium
- Logo lune (Icons.nightlight_round) → soleil (Icons.wb_sunny)
- Animation rotation 360° avec changement d'icône fluide
- Barre de progression circulaire animée
- Dégradé de fond nuit → jour
- Texte "Cercle Mystique" en animated_text_kit
- Durée totale : 3 secondes

#### Système de Thème Jour/Nuit
- Provider ThemeController pour gestion globale
- AnimatedContainer pour transitions fluides
- AnimatedTheme pour changements automatiques
- Bouton toggle avec animation lune ↔ soleil
- Sauvegarde préférence utilisateur

#### Design System de Base
- Typographie : Google Fonts Poppins
- Composants de base thématiques
- Système de spacing et borders cohérent
- Micro-animations interactives

### Tests Phase 1
- [ ] Splash screen avec animations complètes
- [ ] Transition lune → soleil fluide
- [ ] Barre de progression sans lag
- [ ] Toggle jour/nuit instantané
- [ ] Dégradés animés fluides
- [ ] Firebase connecté
- [ ] Navigation opérationnelle
- [ ] Préférences thème sauvegardées

## 🔐 Phase 2: Authentification + Design Avancé + Chat Foundation
**Durée estimée : 2-3 jours**

### Livrables Auth
- ✅ Écrans d'authentification adaptés au thème jour/nuit
- ✅ Connexion Google avec bouton animé
- ✅ Connexion anonyme avec génération pseudo aléatoire
- ✅ Gestion des erreurs avec snackbars thématiques
- ✅ États de chargement avec shimmer effects

### Livrables Design Avancé
#### Animations contextuelles
- Boutons avec effet de pulsation
- Cards avec slide-in animations
- Loading states avec rotation fluide
- Transitions entre écrans avec fade/slide

#### Composants thématiques
- Inputs avec bordures animées
- Boutons avec dégradés adaptatifs
- Cards avec ombres dynamiques (jour) ou glow (nuit)
- Snackbars avec couleurs contextuelles

### Structure Firebase Chat
```javascript
// Collection "chat_messages"
{
  messageId: "msg_uuid",
  gameId: "game_id", 
  senderId: "player_id",
  senderName: "PseudoJoueur",
  content: "Message du joueur",
  timestamp: firestore.timestamp,
  messageType: "normal", // normal, system, host
  chatTheme: "day", // day, night - pour adaptation visuelle
  isDeleted: false
}

// Collection "chat_permissions"
{
  gameId: "game_id",
  playerId: "player_id",
  canSend: true,
  canReceive: true,
  isMuted: false,
  themePreference: "auto", // day, night, auto
  lastMessageTime: firestore.timestamp
}
```

### Tests Phase 2
- [ ] Authentification Google/anonyme fonctionnelle
- [ ] Interface adaptée aux deux thèmes
- [ ] Animations fluides sur tous les éléments
- [ ] Chat basique opérationnel avec thème adaptatif
- [ ] États de chargement élégants
- [ ] Gestion d'erreurs cohérente

## 🏠 Phase 3: Lobby Système + Chat Lobby + Répartition Intelligente
**Durée estimée : 4-5 jours**

### Algorithme de Répartition
```dart
Map<String, int> calculateRoles(int playerCount) {
  int wolves = (playerCount * 0.25).floor().clamp(1, playerCount ~/ 3);
  
  Map<String, int> roles = {
    'villageois': 0,
    'loup_garou': wolves,
    'voyant': playerCount >= 6 ? 1 : 0,
    'sorciere': playerCount >= 6 ? 1 : 0,
    'chasseur': playerCount >= 6 ? 1 : 0,
    'cupidon': playerCount >= 8 ? 1 : 0,
    'garde': playerCount >= 10 ? 1 : 0,
    'maire': playerCount >= 12 ? 1 : 0,
    'petite_fille': playerCount >= 14 ? 1 : 0,
    'barbier': playerCount >= 16 ? 1 : 0,
    'medium': playerCount >= 18 ? 1 : 0,
    'bouc_emissaire': playerCount >= 20 ? 1 : 0,
  };
  
  int specialRoles = roles.values.fold(0, (sum, count) => sum + count) - wolves;
  roles['villageois'] = playerCount - wolves - specialRoles;
  
  return roles;
}
```

### Livrables Lobby
#### Écran Création Partie
- Interface adaptée jour/nuit avec dégradés
- Sélecteur nombre joueurs (6-24) avec preview rôles
- Configuration avancée avec animations
- Génération code 6 chiffres unique

#### Écran Rejoindre Partie
- Input code avec validation temps réel
- Animations de recherche avec shimmer
- Liste parties publiques avec filtres
- États d'erreur élégants

#### Interface Lobby
- Liste joueurs en temps réel avec avatars
- Preview rôles dynamique selon participants
- Chat lobby intégré avec thème adaptatif
- Boutons d'action avec animations contextuelles

### Livrables Chat Lobby
#### Communication Libre
- Tous les joueurs peuvent parler
- Interface adaptée au thème jour/nuit
- Messages système pour arrivées/départs
- Animations d'apparition des messages

#### Modération Hôte
- Boutons mute/kick avec confirmations animées
- Interface de gestion des permissions
- Historique des actions de modération
- Notifications contextuelles

#### Interface Chat Thématique
- Couleurs adaptées : or/orange (jour), bleu/violet (nuit)
- Bulles de messages avec dégradés subtils
- Animations d'écriture (typing indicators)
- Auto-scroll intelligent

### Tests Phase 3
- [ ] Création partie génère interface thématique parfaite
- [ ] Répartition des rôles respecte l'algorithme optimisé
- [ ] Preview rôles s'actualise en temps réel
- [ ] Chat lobby fonctionne avec thème adaptatif
- [ ] Modération hôte opérationnelle avec animations
- [ ] Interface responsive sur toutes tailles
- [ ] Performance maintenue avec 24 joueurs

## 🎮 Phase 4: Logique de Jeu + Chat Contextuel + Animations de Phase
**Durée estimée : 6-7 jours**

### Transitions de Phase Cinématiques
#### Transition Jour → Nuit
- Animation du fond : dégradé jour vers nuit (2s)
- Soleil qui descend et disparaît, lune qui apparaît
- Étoiles qui scintillent progressivement
- Son ambiant + vibration légère
- Message système "La nuit tombe sur le village..."

#### Transition Nuit → Jour
- Animation inverse : nuit vers jour (2s)
- Lune qui s'estompe, soleil qui se lève
- Étoiles qui disparaissent en fondu
- Son d'aube + feedback haptique
- Message système "Le jour se lève..."

### Chat Contextuel Avancé
```javascript
const chatPermissions = {
  NIGHT: {
    wolves: {
      canSendWolves: true,
      canReceiveWolves: true,
      canSendPublic: false,
      canReceivePublic: true, // Messages système
      chatTheme: "night_wolves" // Rouge sombre + noir
    },
    others: {
      canSendWolves: false,
      canReceiveWolves: false,
      canSendPublic: false,
      canReceivePublic: true,
      chatTheme: "night_silence" // Bleu sombre + gris
    }
  },
  DAY: {
    alive: {
      canSendPublic: true,
      canReceivePublic: true,
      canSendWolves: false,
      canReceiveWolves: false,
      chatTheme: "day_debate" // Orange + jaune
    },
    dead: {
      canSendDead: true,
      canReceiveDead: true,
      canSendPublic: false,
      canReceivePublic: true,
      chatTheme: "dead_observers" // Gris + transparent
    }
  }
}
```

### Livrables Logique
- ✅ Distribution Rôles avec algorithme optimisé
- ✅ Phase de Nuit
  - Interface thématique nuit avec étoiles animées
  - Actions spéciales par rôle avec confirmations
  - Chat privé loups-garous avec thème sombre
  - Résolution automatique des actions
- ✅ Phase de Jour
  - Interface thématique jour avec nuages animés
  - Débats libres avec chat public coloré
  - Système de votes avec animations
  - Décomptes dynamiques et effets visuels
- ✅ Mécaniques Avancées
  - Tous les rôles implémentés avec animations
  - Pouvoirs spéciaux avec feedback visuel
  - Conditions de victoire avec écrans de fin
  - Gestion des amoureux et morts liées

### Tests Phase 4
- [ ] Transitions jour/nuit fluides et spectaculaires
- [ ] Chat contextuel fonctionne selon phase et rôle
- [ ] Toutes les mécaniques de jeu opérationnelles
- [ ] Animations de phase sans lag
- [ ] Interface thématique parfaite pour chaque contexte
- [ ] Performance optimale avec 24 joueurs + chat actif

## 🎨 Phase 5: Polish + Chat Premium + Expérience Complète
**Durée estimée : 3-4 jours**

### Interface Premium
#### Écrans de Fin de Partie
- Animations de victoire thématiques
- Statistiques complètes avec graphiques
- Podium avec effets de particules
- Partage de résultats stylisés

#### Révélation des Rôles
- Cartes avec animations de flip
- Effets de révélation progressifs
- Sons et vibrations contextuels
- Transitions fluides

### Chat Premium
#### Fonctionnalités Avancées
- Filtrage automatique de contenu
- Mentions @pseudo avec notifications
- Réactions emoji sur messages
- Messages épinglés par l'hôte

#### Historique et Export
- Sauvegarde conversations par partie
- Export PDF avec thème de la partie
- Statistiques de communication
- Replay chronologique

#### Performance et Accessibilité
- Support lecteurs d'écran
- Navigation clavier complète
- Optimisation mémoire pour long terme
- Compression intelligente des données

### Personnalisation
#### Paramètres Utilisateur
- Choix thème : Auto/Jour/Nuit
- Intensité des animations
- Volume des effets sonores
- Préférences de notifications

#### Profils Joueurs
- Statistiques de parties
- Historique des rôles joués
- Taux de victoire par rôle
- Badges et achievements

### Tests Phase 5
- [ ] Interface complètement polie et fluide
- [ ] Chat premium avec toutes fonctionnalités
- [ ] Performance excellente sur tous appareils
- [ ] Accessibilité complète respectée
- [ ] Export et historique fonctionnels
- [ ] Personnalisation sauvegardée correctement

## 🔥 Architecture Technique Optimisée

### Structure de Projet
```text
lib/
├── core/                    # Configuration et utilitaires
│   ├── themes/             # Système jour/nuit
│   ├── constants/          # Couleurs, tailles, durées
│   └── utils/              # Helpers et extensions
├── features/               # Fonctionnalités par modules
│   ├── auth/              # Authentification
│   ├── lobby/             # Système de lobby
│   ├── game/              # Logique de jeu
│   └── chat/              # Système de chat
├── shared/                # Composants partagés
│   ├── widgets/           # Widgets réutilisables
│   ├── animations/        # Animations communes
│   └── services/          # Services Firebase
└── presentation/          # Écrans et controllers
```

### Services Principaux
- ThemeService : Gestion jour/nuit avec animations
- ChatService : Communication temps réel adaptative
- GameService : Logique de jeu et synchronisation
- AnimationService : Orchestration des transitions
- AudioService : Effets sonores contextuels

### Performance et Monitoring
- Firestore : Optimisation requêtes et index
- Cache : Gestion intelligente des données locales
- Analytics : Tracking des performances et usage
- Crash Reporting : Monitoring erreurs et stabilité

## 📱 Responsive et Accessibilité

### Adaptation Multi-Écrans
- Mobile : Interface compacte avec navigation gestuelle
- Tablette : Layout étendu avec panneaux latéraux
- Desktop : Interface complète avec raccourcis clavier

### Accessibilité Complète
- Contraste : Ratios WCAG AA respectés jour/nuit
- Navigation : Support clavier et lecteurs d'écran
- Tailles : Texte et boutons ajustables
- Animations : Réduction mouvement pour sensibilités

## ⚡ Optimisations Performances

### Chat Haute Performance
- Pagination : Chargement progressif des messages
- Compression : Réduction taille des données
- Cache Local : Stockage intelligent offline
- Debouncing : Limitation requêtes en temps réel

### Jeu Multi-Joueurs
- Synchronisation : Optimisation des mises à jour
- État Local : Gestion hybride local/distant
- Connexion : Gestion automatique des déconnexions
- Memory Management : Nettoyage automatique des ressources
