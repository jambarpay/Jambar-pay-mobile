import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/language_controller.dart';
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
  late Locale _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LanguageController.localeNotifier.value;
  }

  void _showLanguageDialog() {
    final loc = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: Text(loc.french),
              value: const Locale('fr'),
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value == null) return;
                final newLocale = const Locale('fr');
                LanguageController.localeNotifier.value = newLocale;
                setState(() => _selectedLanguage = newLocale);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations(newLocale).languageChangedFrench)),
                );
              },
            ),
            RadioListTile<Locale>(
              title: Text(loc.english),
              value: const Locale('en'),
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value == null) return;
                final newLocale = const Locale('en');
                LanguageController.localeNotifier.value = newLocale;
                setState(() => _selectedLanguage = newLocale);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations(newLocale).languageChangedEnglish)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    final loc = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.contactSupport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.email),
            const SizedBox(height: 8),
            Text(loc.phone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.ok),
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
                  label: AppLocalizations.of(context).changeSecretCode,
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
                        SnackBar(
                          content: Text(AppLocalizations.of(context).secretCodeChanged),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 18),
                ProfileSwitchTile(
                  icon: Icons.contrast,
                  label: widget.isDarkMode ? AppLocalizations.of(context).darkMode : AppLocalizations.of(context).lightMode,
                  value: widget.isDarkMode,
                  onChanged: widget.onDarkModeChanged,
                  isDarkMode: widget.isDarkMode,
                ),
                const SizedBox(height: 12),
                ProfileActionTile(
                  icon: Icons.language,
                  label: _selectedLanguage.languageCode == 'fr'
                      ? AppLocalizations.of(context).french
                      : AppLocalizations.of(context).english,
                  isDarkMode: widget.isDarkMode,
                  onTap: _showLanguageDialog,
                ),
                const SizedBox(height: 32),
                ProfileActionTile(
                  icon: Icons.headset_mic_outlined,
                  label: AppLocalizations.of(context).contactSupport,
                  isDarkMode: widget.isDarkMode,
                  onTap: _contactSupport,
                ),
                const SizedBox(height: 18),
                ProfileActionTile(
                  icon: Icons.logout,
                  label: AppLocalizations.of(context).logout,
                  color: Colors.red,
                  isDarkMode: widget.isDarkMode,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context).logout),
                        content: Text(AppLocalizations.of(context).logoutConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context).cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onLogout();
                            },
                            child: Text(
                              AppLocalizations.of(context).logoutButton,
                              style: const TextStyle(color: Colors.red),
                            ),
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
