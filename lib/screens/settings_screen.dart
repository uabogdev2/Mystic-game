import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assumed for ThemeController access

import '../widgets/themed/themed_card.dart';
import '../widgets/themed/themed_button.dart'; // For potential save button
import '../constants/design_constants.dart';
import '../theme/theme_controller.dart'; // For AppThemeMode and ThemeController
import '../models/theme_mode.dart'; // For AppThemeMode enum (if defined separately from controller)

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for settings not yet managed by a controller
  double _animationIntensity = 0.5; // 0.0 (Low), 0.5 (Medium), 1.0 (High)
  double _soundVolume = 0.75;
  bool _notificationsEnabled = true;

  // This will hold the current theme selection for ToggleButtons
  // It will be initialized based on ThemeController's state.
  late List<bool> _themeSelected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize _themeSelected based on ThemeController
    // This assumes ThemeController is available via Provider.
    // If ThemeController is not available, this will throw an error or need a fallback.
    try {
      final themeController = Provider.of<ThemeController>(context, listen: false);
      _themeSelected = [
        themeController.currentAppThemeMode == AppThemeMode.light,
        themeController.currentAppThemeMode == AppThemeMode.dark,
        themeController.currentAppThemeMode == AppThemeMode.system,
      ];
    } catch (e) {
      // Fallback if ThemeController is not found (e.g., not provided in widget tree)
      print("SettingsScreen: ThemeController not found. Defaulting theme selection. Error: $e");
      _themeSelected = [false, false, true]; // Default to System
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Attempt to get ThemeController. If not available, theme switching UI won't work.
    ThemeController? themeController;
    try {
      themeController = Provider.of<ThemeController>(context, listen: false);
    } catch (e) {
      themeController = null; // Silently fail if not found, UI will indicate non-functional
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
      ),
      body: ListView(
        padding: kPaddingAllMedium,
        children: <Widget>[
          // Section: Theme Choice
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Choix du Thème", style: theme.textTheme.titleLarge),
                const SizedBox(height: kSpacingSmall),
                Center(
                  child: ToggleButtons(
                    isSelected: _themeSelected,
                    onPressed: themeController == null ? null : (int index) {
                      AppThemeMode selectedMode;
                      if (index == 0) selectedMode = AppThemeMode.light;
                      else if (index == 1) selectedMode = AppThemeMode.dark;
                      else selectedMode = AppThemeMode.system;

                      themeController.setThemeMode(selectedMode);

                      setState(() {
                        for (int i = 0; i < _themeSelected.length; i++) {
                          _themeSelected[i] = (i == index);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                    selectedBorderColor: theme.colorScheme.primary,
                    selectedColor: theme.colorScheme.onPrimary,
                    fillColor: theme.colorScheme.primary.withOpacity(0.8),
                    color: theme.colorScheme.onSurfaceVariant,
                    constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
                    children: const <Widget>[
                      Padding(padding: EdgeInsets.symmetric(horizontal: kSpacingSmall), child: Text("Clair")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: kSpacingSmall), child: Text("Sombre")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: kSpacingSmall), child: Text("Système")),
                    ],
                  ),
                ),
                if (themeController == null)
                  Padding(
                    padding: const EdgeInsets.only(top: kSpacingXS),
                    child: Text("(Contrôleur de thème non disponible)", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                  )
              ],
            ),
          ),
          const SizedBox(height: kSpacingMedium),

          // Section: Animation Intensity
          ThemedCard(
            child: ListTile(
              title: const Text("Intensité des animations"),
              subtitle: Slider(
                value: _animationIntensity,
                min: 0.0, // Low
                max: 1.0, // High
                divisions: 2,
                label: _animationIntensity == 0 ? "Basse" : (_animationIntensity == 0.5 ? "Moyenne" : "Haute"),
                onChanged: (value) {
                  setState(() => _animationIntensity = value);
                },
              ),
              trailing: Text("(${_animationIntensity == 0 ? "Basse" : (_animationIntensity == 0.5 ? "Moyenne" : "Haute")}) (Non implémenté)", style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: kSpacingMedium),

          // Section: Sound Volume
          ThemedCard(
            child: ListTile(
              title: const Text("Volume des effets sonores"),
              subtitle: Slider(
                value: _soundVolume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: "${(_soundVolume * 100).toInt()}%",
                onChanged: (value) {
                  setState(() => _soundVolume = value);
                },
              ),
              trailing: Text("(${(_soundVolume * 100).toInt()}%) (Non implémenté)", style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: kSpacingMedium),

          // Section: Notification Preferences
          ThemedCard(
            child: SwitchListTile(
              title: const Text("Activer les notifications"),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() => _notificationsEnabled = value);
              },
              secondary: Icon(_notificationsEnabled ? Icons.notifications_active : Icons.notifications_off),
              subtitle: Text("(Non implémenté)", style: theme.textTheme.bodySmall),
            ),
          ),

          // Add a save button or note that settings are saved automatically (if they were)
          // For now, these are local UI state only.
        ],
      ),
    );
  }
}
