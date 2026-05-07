import 'package:flutter/material.dart';
import '../models/mobile_employee_space.dart';
import 'secret_code_screen.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onBackHome,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.userProfile,
    required this.onChangeSecretCode,
    required this.onLogout,
  });

  final VoidCallback onBackHome;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final UserProfileModel userProfile;
  final String? Function(String currentPin, String newPin) onChangeSecretCode;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'Francais';

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Francais'),
              value: 'Francais',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Langue changee: Francais')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language changed: English')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@jambarpay.com'),
            SizedBox(height: 8),
            Text('Phone: +221 33 123 45 67'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);

    return Column(
      children: [
        SubPageHeader(
          title: '',
          onBack: widget.onBackHome,
          customContent: ProfileHeaderCard(
            onBack: widget.onBackHome,
            isDarkMode: widget.isDarkMode,
            userProfile: widget.userProfile,
          ),
          isDarkMode: widget.isDarkMode,
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
                  isDarkMode: widget.isDarkMode,
                  onTap: () async {
                    final didChange = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => SecretCodeScreen(
                          mode: SecretCodeFlowMode.change,
                          phoneNumber: widget.userProfile.phone,
                          isDarkMode: widget.isDarkMode,
                          onChangePin: widget.onChangeSecretCode,
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
                  label: widget.isDarkMode ? 'Sombre' : 'Claire',
                  value: widget.isDarkMode,
                  onChanged: widget.onDarkModeChanged,
                  isDarkMode: widget.isDarkMode,
                ),
                const SizedBox(height: 12),
                ProfileActionTile(
                  icon: Icons.language,
                  label: _selectedLanguage,
                  isDarkMode: widget.isDarkMode,
                  onTap: _showLanguageDialog,
                ),
                const SizedBox(height: 32),
                ProfileActionTile(
                  icon: Icons.headset_mic_outlined,
                  label: 'Contactez le support',
                  isDarkMode: widget.isDarkMode,
                  onTap: _contactSupport,
                ),
                const SizedBox(height: 18),
                ProfileActionTile(
                  icon: Icons.logout,
                  label: 'Deconnexion',
                  color: Colors.red,
                  isDarkMode: widget.isDarkMode,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Deconnexion'),
                        content: const Text('Voulez-vous vraiment vous deconnecter?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onLogout();
                            },
                            child: const Text('Deconnexion', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
