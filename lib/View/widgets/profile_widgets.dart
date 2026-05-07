import 'package:flutter/material.dart';
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
    const subtitleColor = Color(0xFFD5D4DE);

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
              'Retour',
              style: TextStyle(color: subtitleColor, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 40, color: const Color(0xFF9A99A7)),
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
    this.color = const Color(0xFF1C1A33),
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
        : const Color(0xFF1C1A33);
    final iconColor = color == const Color(0xFF1C1A33) && isDarkMode
        ? contentColor
        : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? palette.tileBackground
                : const Color(0xFFEAE9FF),
            borderRadius: BorderRadius.circular(12),
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
                      : const Color(0xFF8A8898),
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
        : const Color(0xFF1C1A33);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? palette.tileBackground
            : const Color(0xFFEAE9FF),
        borderRadius: BorderRadius.circular(12),
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
                ? const Color(0xFF181632)
                : const Color(0xFFF57C21),
            activeTrackColor: const Color(0xFFBFC2FF),
            inactiveThumbColor: widget.isDarkMode
                ? Colors.white
                : const Color(0xFFF4F4F4),
            inactiveTrackColor: widget.isDarkMode
                ? const Color(0xFF69668D)
                : const Color(0xFFD9D9E8),
          ),
        ],
      ),
    );
  }
}

class ProfileDropdownTile extends StatelessWidget {
  const ProfileDropdownTile({
    required this.icon,
    required this.label,
    this.isDarkMode = false,
  });

  final IconData icon;
  final String label;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final contentColor = isDarkMode
        ? palette.primaryText
        : const Color(0xFF1C1A33);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? palette.tileBackground : const Color(0xFFEAE9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: contentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: contentColor,
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down, size: 30, color: palette.mutedText),
        ],
      ),
    );
  }
}
