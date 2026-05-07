import 'package:flutter/material.dart';
import '../models/mobile_employee_space.dart';
import 'secret_code_screen.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onBackHome,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.userProfile,
    required this.onChangeSecretCode,
  });

  final VoidCallback onBackHome;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final UserProfileModel userProfile;
  final String? Function(String currentPin, String newPin) onChangeSecretCode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Column(
      children: [
        SubPageHeader(
          title: '',
          onBack: onBackHome,
          customContent: ProfileHeaderCard(
            onBack: onBackHome,
            isDarkMode: isDarkMode,
            userProfile: userProfile,
          ),
          isDarkMode: isDarkMode,
        ),
        Expanded(
          child: ColoredBox(
            color: palette.pageBackground,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                ProfileActionTile(
                  icon: Icons.shield_outlined,
                  label: 'Modifiez votre code secret',
                  isDarkMode: isDarkMode,
                  onTap: () async {
                    final didChange = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => SecretCodeScreen(
                          mode: SecretCodeFlowMode.change,
                          phoneNumber: userProfile.phone,
                          isDarkMode: isDarkMode,
                          onChangePin: onChangeSecretCode,
                        ),
                      ),
                    );

                    if (didChange == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code secret modifie avec succes.'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 18),
                ProfileSwitchTile(
                  icon: Icons.contrast,
                  label: isDarkMode ? 'Sombre' : 'Claire',
                  value: isDarkMode,
                  onChanged: onDarkModeChanged,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
                ProfileDropdownTile(
                  icon: Icons.language,
                  label: 'Francais',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 32),
                ProfileActionTile(
                  icon: Icons.headset_mic_outlined,
                  label: 'Contactez le support',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 18),
                ProfileActionTile(
                  icon: Icons.logout,
                  label: 'Deconnexion',
                  color: Colors.red,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
