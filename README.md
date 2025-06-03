# 🌙 Cercle Mystique - Loup-Garou Flutter

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Une expérience de jeu Loup-Garou révolutionnaire avec système jour/nuit immersif**

[🎮 Démo](#demo) • [🚀 Installation](#installation) • [📱 Fonctionnalités](#fonctionnalités) • [🎨 Design](#design) • [🔧 Développement](#développement)

</div>

---

## 🌟 À Propos

**Cercle Mystique** transforme le célèbre jeu Loup-Garou en une expérience numérique immersive avec un système de thème jour/nuit adaptatif qui évolue selon les phases du jeu. Développé en Flutter avec Firebase, il offre une expérience multijoueur fluide pour 6 à 24 joueurs.

### ✨ Pourquoi Cercle Mystique ?

- 🌅 **Thème Adaptatif** : Interface qui passe du jour à la nuit selon les phases de jeu
- 💬 **Chat Contextuel** : Système de communication qui s'adapte aux rôles et phases
- 🎭 **Rôles Complets** : 12+ rôles avec mécaniques uniques
- 🔄 **Temps Réel** : Synchronisation instantanée entre tous les joueurs
- 🎨 **Animations Fluides** : Transitions cinématiques et micro-interactions
- 📱 **Cross-Platform** : Android, iOS et Web

---

## 🎮 Fonctionnalités

### 🏠 **Système de Lobby**
- Création de parties avec codes à 6 chiffres
- Gestion en temps réel des joueurs (6-24)
- Preview automatique de la répartition des rôles
- Chat libre avec modération pour l'hôte

### 🌙 **Phases de Jeu Immersives**
- **Phase Nuit** : Interface sombre avec chat privé loups-garous
- **Phase Jour** : Interface claire avec débats publics
- **Transitions Animées** : Soleil/lune avec effets de particules

### 💬 **Chat Intelligent**
- **Contextuel** : Permissions qui évoluent selon rôle et phase
- **Multi-Canal** : Public, privé loups, observateurs morts
- **Modération** : Filtres automatiques et contrôle hôte
- **Historique** : Sauvegarde et export des conversations

### 🎭 **Rôles Disponibles**
| Rôle | Disponible dès | Capacité spéciale |
|------|----------------|-------------------|
| 🐺 Loup-Garou | 6 joueurs | Élimination nocturne |
| 🔮 Voyant | 6 joueurs | Espionnage d'identité |
| 🧪 Sorcière | 6 joueurs | Potions vie/mort |
| 🏹 Chasseur | 6 joueurs | Tir de vengeance |
| 💘 Cupidon | 8 joueurs | Création couple amoureux |
| 🛡️ Garde | 10 joueurs | Protection nocturne |
| 👑 Maire | 12 joueurs | Vote double |
| 👧 Petite Fille | 14 joueurs | Espionnage loups |

---

## 🎨 Design System

### 🌅 **Mode Jour**
```css
Dégradés : Orange → Jaune → Crème
Accent : Orange vif (#FF6B35)
Ambiance : Chaleureuse et accueillante
Éléments : Soleil, nuages, particules dorées
```

### 🌙 **Mode Nuit**
```css
Dégradés : Bleu nuit → Violet → Noir
Accent : Rouge mystique (#E94560)
Ambiance : Mystérieuse et inquiétante
Éléments : Lune, étoiles, brume violette
```

### ✨ **Animations**
- **Splash Screen** : Transformation lune → soleil avec barre de progression
- **Transitions** : Morphing fluide entre thèmes (800ms)
- **Micro-interactions** : Boutons, cartes, notifications animées
- **Révélations** : Cartes de rôles avec effets de flip

---

## 🚀 Installation

### Prérequis
- Flutter 3.16+ 
- Dart 3.2+
- Firebase CLI
- Android Studio / VS Code

### 🔧 Setup Rapide

```bash
# 1. Cloner le projet
git clone https://github.com/votre-username/cercle-mystique.git
cd cercle-mystique

# 2. Installer les dépendances
flutter pub get

# 3. Configuration Firebase
flutterfire configure --project=cercle-mystic

# 4. Lancer l'application
flutter run
```

### 📱 Build Production

```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release

# Web
flutter build web --release
```

---

## 🏗️ Architecture

### 📁 Structure du projet
```
lib/
├── core/                    # Configuration et utilitaires
│   ├── themes/             # Système jour/nuit
│   ├── constants/          # Couleurs, animations
│   └── utils/              # Helpers
├── features/               # Fonctionnalités
│   ├── auth/              # Authentification
│   ├── lobby/             # Système lobby
│   ├── game/              # Logique de jeu
│   └── chat/              # Communication
├── shared/                # Composants partagés
│   ├── widgets/           # UI réutilisables  
│   ├── services/          # Services Firebase
│   └── animations/        # Animations communes
└── presentation/          # Écrans et contrôleurs
```

### 🔥 Services Firebase
- **Authentication** : Google Sign-In + Anonyme
- **Firestore** : Base de données temps réel
- **Collections** : `games`, `players`, `chat_messages`, `chat_permissions`

---

## 🔧 Développement

### 📋 Roadmap
- [x] **Phase 1** : Foundation + Splash + Thème
- [x] **Phase 2** : Authentification + Design avancé  
- [x] **Phase 3** : Lobby + Chat lobby
- [ ] **Phase 4** : Logique de jeu + Chat contextuel
- [ ] **Phase 5** : Polish + Chat premium

### 🧪 Tests
```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Tests de performance
flutter test --profile
```

### 🎯 Scripts Utiles
```bash
# Analyse du code
flutter analyze

# Formatting
dart format .

# Build runner (si nécessaire)
flutter packages pub run build_runner build
```

---

## 🤝 Contribution

### 🛠️ Comment contribuer
1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/amazing-feature`)
3. **Commit** vos changements (`git commit -m 'Add amazing feature'`)
4. **Push** vers la branche (`git push origin feature/amazing-feature`)
5. **Ouvrir** une Pull Request

### 📝 Standards de code
- Utiliser `dart format` avant chaque commit
- Respecter les conventions de nommage Dart
- Ajouter des tests pour les nouvelles fonctionnalités
- Commenter le code complexe

---

## 📄 Licence

Ce projet est sous licence **MIT** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👥 Équipe

<div align="center">

**Développé avec ❤️ par [Votre Nom]**

[🐙 GitHub](https://github.com/votre-username) • [💼 LinkedIn](https://linkedin.com/in/votre-profil) • [🐦 Twitter](https://twitter.com/votre-handle)

</div>

---

## 🙏 Remerciements

- 🎮 **Communauté Loup-Garou** pour l'inspiration du gameplay
- 🦋 **Flutter Team** pour le framework exceptionnel  
- 🔥 **Firebase** pour l'infrastructure backend
- 🎨 **Material Design** pour les guidelines UI/UX
- ✨ **Animate.css** pour l'inspiration animations

---

<div align="center">

### 🌟 **Si ce projet vous plaît, n'hésitez pas à lui donner une étoile !** ⭐

*Cercle Mystique - Où chaque nuit cache ses secrets* 🌙

</div>
