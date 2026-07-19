import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.onBack,
    required this.isDarkMode,
    required this.userProfile,
  });

  final VoidCallback onBack;
  final bool isDarkMode;
  final UserProfileModel userProfile;

  @override
  Widget build(BuildContext context) {
    const titleColor = Colors.white;
    const subtitleColor = AppColors.darkSecondaryText;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back, color: titleColor, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context).back,
              style: TextStyle(color: subtitleColor, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 40, color: AppColors.neutralAvatar),
        ),
        const SizedBox(height: 14),
        Text(
          userProfile.name,
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userProfile.phone,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.lightPrimaryText,
    this.isDarkMode = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDarkMode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final contentColor = isDarkMode
        ? palette.primaryText
        : AppColors.lightPrimaryText;
    final iconColor = color == AppColors.lightPrimaryText && isDarkMode
        ? contentColor
        : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? palette.tileBackground : AppColors.lightControl,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color == Colors.red && isDarkMode
                        ? Colors.redAccent
                        : (color == Colors.red ? Colors.red : contentColor),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: isDarkMode
                      ? palette.mutedText
                      : AppColors.lightMutedText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSwitchTile extends StatefulWidget {
  const ProfileSwitchTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isDarkMode = false,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDarkMode;

  @override
  State<ProfileSwitchTile> createState() => _ProfileSwitchTileState();
}

class _ProfileSwitchTileState extends State<ProfileSwitchTile> {
  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);
    final contentColor = widget.isDarkMode
        ? palette.primaryText
        : AppColors.lightPrimaryText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? palette.tileBackground
            : AppColors.lightControl,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: contentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: contentColor,
              ),
            ),
          ),
          Switch(
            value: widget.value,
            onChanged: widget.onChanged,
            activeThumbColor: widget.isDarkMode
                ? AppColors.darkControl
                : AppColors.brand,
            activeTrackColor: AppColors.switchActiveTrack,
            inactiveThumbColor: widget.isDarkMode
                ? Colors.white
                : AppColors.lightThumb,
            inactiveTrackColor: widget.isDarkMode
                ? AppColors.darkSwitchTrack
                : AppColors.lightSwitchTrack,
          ),
        ],
      ),
    );
  }
}
