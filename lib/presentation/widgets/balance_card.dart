import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';
import 'qr_widgets.dart';
import '../utils/localized_view_data.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.onQrTap,
    required this.wallet,
    this.isDarkMode = false,
  });

  final VoidCallback onQrTap;
  final WalletSummaryModel? wallet;
  final bool isDarkMode;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 350;
        final qrWidth = (constraints.maxWidth * (isCompact ? 0.34 : 0.3))
            .clamp(isCompact ? 82.0 : 104.0, 118.0)
            .toDouble();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.brand : AppColors.darkBalance,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _BalanceInfo(
                  wallet: widget.wallet,
                  palette: palette,
                  isBalanceVisible: _isBalanceVisible,
                  onToggleVisibility: _toggleBalanceVisibility,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              _QrActionButton(width: qrWidth, onTap: widget.onQrTap),
            ],
          ),
        );
      },
    );
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }
}

class _BalanceInfo extends StatelessWidget {
  const _BalanceInfo({
    required this.wallet,
    required this.palette,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
  });

  final WalletSummaryModel? wallet;
  final AppPalette palette;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).availableBalanceTitle,
          style: TextStyle(
            color: palette.onHeader,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              child: Text(
                isBalanceVisible
                    ? wallet?.balance.formatted ?? '0 Fcfa'
                    : '•••••• Fcfa',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.onHeader,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onToggleVisibility,
              borderRadius: BorderRadius.circular(AppRadius.navigation),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isBalanceVisible
                      ? Icons.visibility_off_outlined
                      : Icons.remove_red_eye_outlined,
                  size: 16,
                  color: palette.onHeader.withValues(alpha: 0.92),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          wallet == null
              ? AppLocalizations.of(context).walletUnavailable
              : '${localizeWalletStatus(context, wallet!.status)} • '
                    '${localizeRelativeDate(context, wallet!.lastUpdated)}',
          style: TextStyle(
            color: palette.onHeader.withValues(alpha: 0.72),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _QrActionButton extends StatelessWidget {
  const _QrActionButton({required this.width, required this.onTap});

  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.navigation),
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.navigation),
        ),
        child: Column(
          children: [
            const QrBlock(data: 'JAMBAR|BALANCE|ENTRY', borderRadius: 10),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).scan,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
