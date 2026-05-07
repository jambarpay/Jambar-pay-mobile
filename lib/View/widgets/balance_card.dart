import 'package:flutter/material.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';
import 'qr_widgets.dart';

class BalanceCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 350;
        final qrWidth = (constraints.maxWidth * 0.3).clamp(104.0, 118.0).toDouble();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? palette.sectionContainer : const Color(0xFF242140),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceInfo(
                      wallet: wallet,
                      palette: palette,
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _QrActionButton(
                        width: qrWidth,
                        onTap: onQrTap,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _BalanceInfo(
                        wallet: wallet,
                        palette: palette,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _QrActionButton(
                      width: qrWidth,
                      onTap: onQrTap,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _BalanceInfo extends StatelessWidget {
  const _BalanceInfo({required this.wallet, required this.palette});

  final WalletSummaryModel? wallet;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Solde Disponible',
          style: TextStyle(
            color: palette.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              child: Text(
                wallet?.balance.formatted ?? '0 Fcfa',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.remove_red_eye_outlined,
              size: 16,
              color: palette.primaryText.withValues(alpha: 0.92),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          wallet == null
              ? 'Portefeuille indisponible'
              : '${wallet!.status} • ${wallet!.lastUpdated}',
          style: TextStyle(
            color: palette.primaryText.withValues(alpha: 0.72),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const QrBlock(),
            const SizedBox(height: 10),
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Scanner',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
