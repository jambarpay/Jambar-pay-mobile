import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';

class ScannerPreview extends StatelessWidget {
  const ScannerPreview({
    super.key,
    required this.isDarkMode,
    required this.controller,
    required this.onDetect,
    this.lastScannedValue,
  });

  final bool isDarkMode;
  final MobileScannerController controller;
  final ValueChanged<String?> onDetect;
  final String? lastScannedValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cardWidth = availableWidth.clamp(260.0, 360.0).toDouble();
        final scannerSize = (cardWidth - 48).clamp(212.0, 312.0).toDouble();
        final cardHeight = (scannerSize + 118).clamp(330.0, 450.0).toDouble();
        final scannerTop =
            ((cardHeight - scannerSize) / 2) + (scannerSize * 0.5);

        return Container(
          key: key,
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.panel),
            color: AppColors.almostBlack,
            border: Border.all(color: Colors.black.withValues(alpha: 0.45)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.dialog),
                  child: SizedBox(
                    width: scannerSize,
                    height: scannerSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          controller: controller,
                          fit: BoxFit.cover,
                          onDetect: (capture) {
                            final barcode = capture.barcodes.isNotEmpty
                                ? capture.barcodes.first
                                : null;
                            onDetect(barcode?.rawValue);
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(
                              AppRadius.dialog,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: scannerTop.clamp(150.0, cardHeight - 90.0),
                child: Container(height: 4, color: AppColors.info),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 12,
                child: Text(
                  lastScannedValue == null
                      ? AppLocalizations.of(context).scanQrCode
                      : AppLocalizations.of(
                          context,
                        ).qrDetected(lastScannedValue!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LargeQrCard extends StatelessWidget {
  const LargeQrCard({
    super.key,
    required this.isDarkMode,
    required this.userProfile,
    this.scanResult,
    this.employeeQrContent,
  });

  final bool isDarkMode;
  final UserProfileModel userProfile;
  final QRScanResultModel? scanResult;
  final String? employeeQrContent;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final qrPayload = scanResult?.token ?? employeeQrContent ?? '';
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cardSize = availableWidth.clamp(250.0, 330.0).toDouble();

        return Container(
          key: key,
          width: cardSize,
          height: cardSize,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSubtle,
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: qrPayload.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : QrBlock(data: qrPayload, borderRadius: 18),
              ),
              const SizedBox(height: 12),
              Text(
                userProfile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scanResult?.token ?? AppLocalizations.of(context).employeeQr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: palette.secondaryText),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QrDetailsCard extends StatelessWidget {
  const QrDetailsCard({
    super.key,
    required this.userProfile,
    this.scanResult,
    this.paymentResult,
  });

  final UserProfileModel userProfile;
  final QRScanResultModel? scanResult;
  final PaymentResultModel? paymentResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userProfile.phone,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.neutralSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scanResult?.merchantName ??
                AppLocalizations.of(context).activeEmployeeQr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            paymentResult == null
                ? AppLocalizations.of(context).readyForScan
                : '${paymentResult!.amount.formatted} • ${paymentResult!.date}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.neutralSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class QrBlock extends StatelessWidget {
  const QrBlock({
    super.key,
    this.data = 'JAMBAR|QR|DEMO',
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.borderRadius = 12,
    this.showFrame = true,
  });

  final String data;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final bool showFrame;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: showFrame
              ? Border.all(
                  color: foregroundColor.withValues(alpha: 0.92),
                  width: 2.2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          backgroundColor: backgroundColor,
          padding: EdgeInsets.zero,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: foregroundColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: foregroundColor,
          ),
          semanticsLabel: 'QR code',
          errorStateBuilder: (context, error) {
            return Center(
              child: Icon(
                Icons.qr_code_2,
                color: Theme.of(context).colorScheme.error,
              ),
            );
          },
        ),
      ),
    );
  }
}
