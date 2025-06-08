import 'package:flutter/material.dart';
import 'dart:math' as math; // For PI constant for rotation

import '../../models/game_state.dart'; // For PlayerRole and getRoleDisplayName
import '../../constants/design_constants.dart'; // TODO: Update path
import '../themed/themed_card.dart'; // For consistent card appearance if needed // TODO: Update path

class RoleRevealCardWidget extends StatefulWidget {
  final PlayerRole role;
  final String? playerName;
  final Duration animationDuration;
  final bool autoReveal;

  const RoleRevealCardWidget({
    super.key,
    required this.role,
    this.playerName,
    this.animationDuration = const Duration(milliseconds: 800),
    this.autoReveal = true,
  });

  @override
  State<RoleRevealCardWidget> createState() => _RoleRevealCardWidgetState();
}

class _RoleRevealCardWidgetState extends State<RoleRevealCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  bool _isFrontVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.forward && _animationController.value > 0.5 && !_isFrontVisible) {
        setState(() => _isFrontVisible = true);
      } else if (status == AnimationStatus.reverse && _animationController.value < 0.5 && _isFrontVisible) {
        setState(() => _isFrontVisible = false);
      }
    });

    if (widget.autoReveal) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          // // Conceptual check for reduce motion setting
          // final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
          // if (reduceMotion) {
          //   // If reduce motion is enabled, skip animation, show front directly
          //   setState(() {
          //     _isFrontVisible = true;
          //     _animationController.value = 1.0; // Set animation to end
          //   });
          // } else {
          //   _animationController.forward();
          // }
          _animationController.forward(); // Original behavior
        }
      });
    }
  }

  void flipCard() {
    if (_animationController.isAnimating) return;
     // // Conceptual check for reduce motion setting
    // final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    // if (reduceMotion) {
    //   setState(() {
    //     _isFrontVisible = !_isFrontVisible; // Instant flip
    //     _animationController.value = _isFrontVisible ? 1.0 : 0.0;
    //   });
    //   return;
    // }

    if (_animationController.isCompleted) {
      // _animationController.reverse(); // Can implement reverse flip if needed
      // For now, assume one-way reveal or re-reveal is fine by just re-running forward
       setState(() => _isFrontVisible = false); // Reset to back before flipping forward again
      _animationController.reset();
      _animationController.forward();
    } else {
      _animationController.forward();
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCardFace(BuildContext context, bool isFront) {
    final theme = Theme.of(context);
    final roleName = getRoleDisplayName(widget.role);
    final cardWidth = MediaQuery.of(context).size.width * 0.75;
    final cardHeight = cardWidth * 1.5;

    if (isFront) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        child: ThemedCard(
          elevation: 8,
          color: theme.colorScheme.surface,
          padding: kPaddingAllMedium,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.playerName != null ? widget.playerName! : "VOTRE RÔLE EST",
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingSmall),
              Text(
                roleName.toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingMedium),
              Icon(_getRoleIcon(widget.role), size: 80, color: theme.colorScheme.primary.withOpacity(0.8)),
              const SizedBox(height: kSpacingMedium),
              Expanded( // Allow description to take remaining space and be scrollable if too long
                child: SingleChildScrollView(
                  child: Text(
                    _getRoleDescription(widget.role),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
         width: cardWidth,
         height: cardHeight,
         child: ThemedCard(
          elevation: 6,
          color: theme.colorScheme.primaryContainer,
          padding: kPaddingAllMedium,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.shield_moon_outlined, size: 100, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5)),
                    const SizedBox(height: kSpacingMedium),
                    Text("Mystères de Thiercelieux", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7)))
                ],
            )
          ),
        ),
      );
    }
  }

  IconData _getRoleIcon(PlayerRole role) {
    switch (role) {
      case PlayerRole.loup_garou: return Icons.nightlight_round;
      case PlayerRole.villageois: return Icons.person;
      case PlayerRole.voyante: return Icons.visibility;
      case PlayerRole.sorciere: return Icons.science;
      case PlayerRole.chasseur: return Icons.gps_fixed;
      case PlayerRole.cupidon: return Icons.favorite;
      case PlayerRole.garde: return Icons.shield;
      default: return Icons.help_rounded;
    }
  }

  String _getRoleDescription(PlayerRole role) {
    switch (role) {
      case PlayerRole.loup_garou: return "Chaque nuit, vous vous réunissez avec les autres loups-garous pour dévorer un villageois.";
      case PlayerRole.villageois: return "Votre objectif est de démasquer et d'éliminer tous les loups-garous.";
      case PlayerRole.voyante: return "Chaque nuit, vous pouvez découvrir la véritable identité d'un joueur.";
      case PlayerRole.sorciere: return "Vous possédez deux potions : une pour sauver une victime des loups, une pour éliminer un joueur.";
      case PlayerRole.chasseur: return "Si vous êtes éliminé, vous pouvez emporter un joueur de votre choix dans la tombe avec vous.";
      default: return "Votre destin vous sera révélé en temps voulu.";
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO (Accessibility): If reduceMotion is enabled, consider replacing the flip
    // animation with a simple cross-fade or direct display of the front of the card.
    // final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    // if (reduceMotion && widget.autoReveal) {
    //    return _buildCardFace(context, true); // Instantly show front if autoReveal and reduceMotion
    // }


    return GestureDetector(
      onTap: flipCard, // Allow manual flip regardless of autoReveal for re-checking
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          final showFrontBasedOnAnimation = (_animationController.value > 0.5);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            // Use _isFrontVisible for content to switch it at the right visual moment of the flip
            // but use animation controller's value for the actual rotation to avoid visual jump
            child: Transform( // Second Transform to flip the content when it's "behind"
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(showFrontBasedOnAnimation ? math.pi : 0), // Flips content if it's the "back" of the currently shown face
              child: showFrontBasedOnAnimation ? _buildCardFace(context, true) : _buildCardFace(context, false),
            )
          );
        },
      ),
    );
  }
}
